//
//  SBBNetworkManager.h
//  SBBAppleCore
//
//  Created by Dhanush Balachandran on 8/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBBComponent.h"

/**
 *  Typedef for SBBNetworkManager methods' completion block.
 *
 *  @param task           The NSURLSessionDataTask.
 *  @param responseObject The JSON object from the response, if any.
 *  @param error          Any error that occurred.
 */
typedef void (^SBBNetworkManagerCompletionBlock)(NSURLSessionDataTask *task, id responseObject, NSError *error);

/*!
 * @brief An enumeration of the available server environments.
 */
typedef NS_ENUM(NSInteger, SBBEnvironment) {
  /// Production environment
  SBBEnvironmentProd,
  
  /// Staging environment, for testing before deploying to production.
  SBBEnvironmentStaging,
  
  /// Development environment, for running against the latest unreleased platform code.
  SBBEnvironmentDev,
  
  /// Custom environment for testing.
  SBBEnvironmentCustom
};

@protocol SBBNetworkManagerProtocol <NSObject>

@property (nonatomic) SBBEnvironment environment;

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


@interface SBBNetworkManager : NSObject<SBBComponent, SBBNetworkManagerProtocol>

+ (instancetype)networkManagerForEnvironment:(SBBEnvironment)environment appURLPrefix:(NSString *)prefix baseURLPath:(NSString *)baseURLPath;

#pragma mark - Init & Accessor Methods

- (instancetype) initWithBaseURL: (NSString*) baseURL;

- (BOOL) isInternetConnected;
- (BOOL) isServerReachable;

@end