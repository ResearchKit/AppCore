//
//  APCNetworkManager.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppleCore.h"
#import "Reachability.h"

#define MAX_RETRY_COUNT 5

static APCNetworkManager * sharedInstance;
NSString * kBackgroundSessionIdentifier = @"com.ymedialabs.backgroundsession";

/*********************************************************************************/
#pragma mark - APC Retry Object - Keeps track of retry count
/*********************************************************************************/
@interface APCNetworkRetryObject : NSObject

@property (nonatomic) NSInteger retryCount;
@property (nonatomic, copy) void (^failureBlock)(NSURLSessionDataTask *, NSError *);
@property (nonatomic, copy) void (^retryBlock)(void);

@end

@implementation APCNetworkRetryObject

@end

/*********************************************************************************/
#pragma mark - APC Network Manager
/*********************************************************************************/

@interface APCNetworkManager ()
{
    Reachability * _internetReachability;
    Reachability * _serverReachability;
}

@property (nonatomic, strong) NSString * baseURL;
@property (nonatomic, strong) NSURLSession * mainSession; //For data tasks
@property (nonatomic, strong) NSURLSession * backgroundSession; //For upload/download tasks

@end

@implementation APCNetworkManager

/*********************************************************************************/
#pragma mark - Initializers & Accessors
/*********************************************************************************/

+ (APCNetworkManager *)sharedManager
{
    return  sharedInstance;
}

+ (void)setUpSharedNetworkManagerWithBaseURL:(NSString *)baseURL
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithBaseURL:baseURL];
    });
}

- (instancetype) initWithBaseURL: (NSString*) baseURL
{
    self = [[[self class] alloc] init]; //Using [self class] instead of APCNetworkManager to enable subclassing
    if (self) {
        self.baseURL = baseURL;
        _internetReachability = [Reachability reachabilityForInternetConnection];
        NSURL * url = [NSURL URLWithString:baseURL];
        _serverReachability = [Reachability reachabilityWithHostName:[url host]]; //Check if only hostname is required
        [_serverReachability startNotifier]; //Turning on ONLY server reachability notifiers
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
    }
    return self;
}

- (NSURLSession *)mainSession
{
    if (!_mainSession) {
        _mainSession = [NSURLSession sharedSession];
    }
    return _mainSession;
}

- (NSURLSession *)backgroundSession
{
    if (!_backgroundSession) {
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kBackgroundSessionIdentifier];
        _backgroundSession = [NSURLSession sessionWithConfiguration:config];
    }
    return _backgroundSession;
}

- (BOOL)isInternetConnected
{
    return (_internetReachability.currentReachabilityStatus == NotReachable) ? NO : YES;
}

- (BOOL)isServerReachable
{
    return (_serverReachability.currentReachabilityStatus == NotReachable) ? NO : YES;
}

/*********************************************************************************/
#pragma mark - basic HTTP methods
/*********************************************************************************/
-(NSURLSessionDataTask *)get:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    return [self doDataTask:@"GET" retryObject:nil URLString:URLString parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)post:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    return [self doDataTask:@"POST" retryObject:nil URLString:URLString parameters:parameters success:success failure:failure];
}


/*********************************************************************************/
#pragma mark - Helper Methods
/*********************************************************************************/
- (NSURLSessionDataTask *) doDataTask: (NSString*) method
                          retryObject: (APCNetworkRetryObject*) retryObject
                            URLString: (NSString*)URLString
                           parameters:(id)parameters
                              success:(void (^)(NSURLSessionDataTask *, id))success
                              failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    APCNetworkRetryObject * localRetryObject;
    __weak APCNetworkRetryObject * weakLocalRetryObject;
    if (!retryObject) {
        localRetryObject = [[APCNetworkRetryObject alloc] init];
        weakLocalRetryObject = localRetryObject;
        localRetryObject.failureBlock = failure;
        localRetryObject.retryBlock = ^ {
            __strong APCNetworkRetryObject * strongLocalRetryObject = weakLocalRetryObject; //To break retain cycle
            [self doDataTask:method retryObject:strongLocalRetryObject URLString:URLString parameters:parameters success:success failure:failure];
        };
    }
    else
    {
        localRetryObject = retryObject;
    }
    
    NSMutableURLRequest *request = [self requestWithMethod:method URLString:URLString parameters:parameters error:nil];
    NSURLSessionDataTask *task = [self.mainSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError * httpError = [self generateAPCErrorForHTTPResponse:(NSHTTPURLResponse*)response];
        if (error)
        {
            [self handleError:error task:task retryObject:localRetryObject];
        }
        else if (httpError)
        {
            //TODO: Add retry for Server maintenance
            if (failure) {
                failure(task, httpError);
            }
        }
        else
        {
            NSDictionary * responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if (success) {
                success(task, responseObject);
            }
        }
    }];
    
    [task resume];
    return task;
    
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                                     error:(NSError *__autoreleasing *)error
{
    
    NSURL *url = [self URLForRelativeorAbsoluteURLString:URLString];
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    mutableRequest.HTTPMethod = method;
    
    //TODO: Lower Priority. Switch parameters to part of query if its GET.
    if (parameters) {
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            [mutableRequest setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
        }
        
        [mutableRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:error]];
    }
    
    return mutableRequest;
}

- (NSURL *) URLForRelativeorAbsoluteURLString: (NSString*) URLString
{
    NSURL *url = [NSURL URLWithString:URLString];
    if ([url.scheme.lowercaseString isEqualToString:@"http:"]) {
        return url;
    }
    else
    {
        NSURL * tempURL =[NSURL URLWithString:URLString relativeToURL:[NSURL URLWithString:self.baseURL]];
        return [NSURL URLWithString:[tempURL absoluteString]];
    }
}

/*********************************************************************************/
#pragma mark - Error Handler
/*********************************************************************************/
- (void)handleError:(NSError*)error task:(NSURLSessionDataTask*) task retryObject: (APCNetworkRetryObject*) retryObject
{
    NSInteger errorCode = error.code;
    NSError * apcError = [self generateAPCErrorForNSURLError:error isInternetConnected:self.isInternetConnected isServerReachable:self.isServerReachable];
    
    if (!self.isInternetConnected || !self.isServerReachable) {
        if (retryObject.failureBlock)
        {
            retryObject.failureBlock(task, apcError);
        }
        retryObject.retryBlock = nil;
    }
    
    if (errorCode == NSURLErrorTimedOut || errorCode == NSURLErrorCannotFindHost || errorCode == NSURLErrorCannotConnectToHost || errorCode == NSURLErrorNotConnectedToInternet || errorCode == NSURLErrorSecureConnectionFailed)
    {
        
        if (retryObject && retryObject.retryCount < MAX_RETRY_COUNT)
        {
            double delayInSeconds = pow(2.0, retryObject.retryCount + 1); //Exponential backoff
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                retryObject.retryBlock();
                retryObject.retryCount++;
            });
        }
        else
        {
            if (retryObject.failureBlock)
            {
                retryObject.failureBlock(task, apcError);
            }
            retryObject.retryBlock = nil;
        }
    }
}

/*********************************************************************************/
#pragma mark - Error Generators
/*********************************************************************************/

- (NSError *)generateAPCErrorForNSURLError:(NSError *)urlError isInternetConnected:(BOOL)internetConnected isServerReachable:(BOOL)isServerReachable
{
    if (!internetConnected) {
        return [NSError errorWithDomain:APC_ERROR_DOMAIN code:kAPCInternetNotConnected userInfo:@{NSLocalizedDescriptionKey: @"Internet Not Connected."}];
    }
    
    if (!isServerReachable) {
        return [NSError errorWithDomain:APC_ERROR_DOMAIN code:kAPCServerNotReachable userInfo:@{NSLocalizedDescriptionKey: @"Backend Server Not Reachable."}];
    }
    
    return [NSError errorWithDomain:APC_ERROR_DOMAIN code:kAPCUnknownError userInfo:urlError.userInfo];
}

- (NSError*) generateAPCErrorForHTTPResponse: (NSHTTPURLResponse*) response
{
    if (NSLocationInRange(response.statusCode, NSMakeRange(200, 99))) {
        return nil;
    }
    
    //TODO: Verify 3xx needs to be addressed
    
    if (response.statusCode == 401) {
        [NSError errorWithDomain:APC_ERROR_DOMAIN code:kAPCServerNotAuthenticated userInfo:@{NSLocalizedDescriptionKey: @"Backend Server Authentiction Error. Please sign in."}];
    }
    
    if (NSLocationInRange(response.statusCode, NSMakeRange(400, 99))) {
        return [NSError errorWithDomain:APC_ERROR_DOMAIN code:response.statusCode userInfo:@{NSLocalizedDescriptionKey: @"Client Error. Please contact SOMEBODY"}];
    }
    
    if (response.statusCode == 503) {
        [NSError errorWithDomain:APC_ERROR_DOMAIN code:kAPCServerUnderMaintenance userInfo:@{NSLocalizedDescriptionKey: @"Backend Server Under Maintenance."}];
    }
    
    if (NSLocationInRange(response.statusCode, NSMakeRange(500, 99))) {
        return [NSError errorWithDomain:APC_ERROR_DOMAIN code:response.statusCode userInfo:@{NSLocalizedDescriptionKey: @"Backend Server Error. Please contact SOMEBODY"}];
    }
    
    return nil;
}

/*********************************************************************************/
#pragma mark - Misc
/*********************************************************************************/
- (void)reachabilityChanged: (NSNotification*) notification
{
    //TODO: Figure out what needs to be done here
}

- (void)dealloc
{
    [_serverReachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:self];
}
@end
