//
//  SBBNetworkManager.h
//  SBBAppleCore
//
//  Created by Dhanush Balachandran on 8/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Typedef for SBBNetworkManager methods' completion block.
 *
 *  @param task           The NSURLSessionDataTask.
 *  @param responseObject The JSON object from the response, if any.
 *  @param error          Any error that occurred.
 */
typedef void (^SBBNetworkManagerCompletionBlock)(NSURLSessionDataTask *task, id responseObject, NSError *error);


@interface SBBNetworkManager : NSObject

#pragma mark - Init & Accessor Methods

- (instancetype) initWithBaseURL: (NSString*) baseURL;

- (BOOL) isInternetConnected;
- (BOOL) isServerReachable;

#pragma mark - Basic HTTP Methods

- (NSURLSessionDataTask* )get:(NSString *)URLString
                      headers:(NSDictionary *)headers
                   parameters:(id)parameters //NSDictionary or Array of NSDictionary
                   completion:(SBBNetworkManagerCompletionBlock)completion;

- (NSURLSessionDataTask* )post:(NSString *)URLString
                       headers:(NSDictionary *)headers
                    parameters:(id)parameters
                    completion:(SBBNetworkManagerCompletionBlock)completion;

- (NSURLSessionDataTask* )put:(NSString *)URLString
                      headers:(NSDictionary *)headers
                   parameters:(id)parameters
                   completion:(SBBNetworkManagerCompletionBlock)completion;

#ifdef __cplusplus
// delete is a C++ keyword
- (NSURLSessionDataTask *)delete_:(NSString *)URLString
#else
- (NSURLSessionDataTask *)delete:(NSString *)URLString
#endif
                         headers:(NSDictionary *)headers
                      parameters:(id)parameters
                      completion:(SBBNetworkManagerCompletionBlock)completion;

@end