//
//  APCNetworkManager.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCNetworkManager.h"
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
    return nil;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    return nil;
}


@end
