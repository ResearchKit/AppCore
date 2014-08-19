//
//  APCNetworkManager.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCNetworkManager : NSObject

/*********************************************************************************/
#pragma mark - Properties
/*********************************************************************************/
@property (nonatomic, copy) void (^reachabilityChanged)(void);

/*********************************************************************************/
#pragma mark - Init & Accessor Methods
/*********************************************************************************/
+ (APCNetworkManager*) sharedManager;
+ (void) setUpSharedNetworkManagerWithBaseURL:(NSString*) baseURL;
- (BOOL) isReachable;
- (BOOL) isServerReachable;

/*********************************************************************************/
#pragma mark - Basic HTTP Methods
/*********************************************************************************/
- (NSURLSessionDataTask* )GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask* )POST:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
