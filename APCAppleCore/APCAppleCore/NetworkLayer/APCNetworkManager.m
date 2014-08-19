//
//  APCNetworkManager.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppleCore.h"
#import "Reachability.h"

static APCNetworkManager * sharedInstance;
NSString * kBackgroundSessionIdentifier = @"com.ymedialabs.backgroundsession";

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

+(APCNetworkManager *)sharedManager
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

- (BOOL)isReachable
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
-(NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" URLString:URLString parameters:parameters error:nil];
    
    NSURLSessionDataTask *task = [self.mainSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse * httpresponse = (NSHTTPURLResponse*)response;
        NSError * networkError = [self generateNetworkErrorIfNecessary:httpresponse];
        if (error)
        {
            if (failure) {
                failure(task, error);
            }
        }
        else if (networkError)
        {
            if (failure) {
                failure(task, networkError);
            }
        }
        else
        {
            NSError * JSONError;
            NSDictionary * responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
            if (JSONError) {
                NSLog(@"%@",JSONError);
            }
            if (success) {
                success(task, responseObject);
            }
        }
    }];

    [task resume];
    
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" URLString:URLString parameters:parameters error:nil];
    
    NSURLSessionDataTask *task = [self.mainSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse * httpresponse = (NSHTTPURLResponse*)response;
        NSError * networkError = [self generateNetworkErrorIfNecessary:httpresponse];
        if (error)
        {
            if (failure) {
                failure(task, error);
            }
        }
        else if (networkError)
        {
            if (failure) {
                failure(task, networkError);
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

/*********************************************************************************/
#pragma mark - Helper Methods
/*********************************************************************************/

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

- (NSError*) generateNetworkErrorIfNecessary: (NSHTTPURLResponse*) response
{
    return NSLocationInRange(response.statusCode, NSMakeRange(200, 99)) ? nil : [NSError errorWithDomain:APC_ERROR_DOMAIN code:APC_SERVER_ERROR userInfo:nil];
}

/*********************************************************************************/
#pragma mark - Misc
/*********************************************************************************/
- (void)reachabilityChanged: (NSNotification*) notification
{
    if (self.reachabilityChanged) {
        self.reachabilityChanged();
    }
}

- (void)dealloc
{
    [_serverReachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:self];
}

@end
