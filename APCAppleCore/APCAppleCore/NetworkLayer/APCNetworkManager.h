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
#pragma mark - Init & Accessor Methods
/*********************************************************************************/
- (instancetype) initWithBaseURL: (NSString*) baseURL;

- (BOOL) isInternetConnected;
- (BOOL) isServerReachable;

/*********************************************************************************/
#pragma mark - Basic HTTP Methods
/*********************************************************************************/
- (NSURLSessionDataTask* )get:(NSString *)URLString
                   parameters:(id)parameters //NSDictionary or Array of NSDictionary
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask* )post:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end