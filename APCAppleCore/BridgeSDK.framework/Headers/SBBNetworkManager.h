//
//  SBBNetworkManager.h
//  SBBAppleCore
//
//  Created by Dhanush Balachandran on 8/15/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBBComponent.h"

/*!
 *  Typedef for SBBNetworkManager methods' completion block.
 *
 *  @param task           The NSURLSessionDataTask.
 *  @param responseObject The JSON object from the response, if any.
 *  @param error          Any error that occurred.
 */
typedef void (^SBBNetworkManagerCompletionBlock)(NSURLSessionDataTask *task, id responseObject, NSError *error);

/*!
 * @typedef SBBEnvironment
 * @brief An enumeration of the available server environments.
 * @constant SBBEnvironmentProd The production environment.
 * @constant SBBEnvironmentStaging The staging environment, used for testing before releasing to production.
 * @constant SBBEnvironmentDev The development environment, for Sage Bionetworks internal use only.
 * @constant SBBEnvironmentCustom A custom environment for testing purposes.
 */
typedef NS_ENUM(NSInteger, SBBEnvironment) {
  SBBEnvironmentProd,
  SBBEnvironmentStaging,
  SBBEnvironmentDev,
  SBBEnvironmentCustom
};

/*!
 This protocol defines the interface to the SBBNetworkManager's non-constructor, non-initializer methods. The interface is
 abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBNetworkManagerProtocol <NSObject>

@property (nonatomic) SBBEnvironment environment;

#pragma mark - Basic HTTP Methods

/*!
 *  Perform an HTTP GET with the specified URL, HTTP headers, parameters, and completion handler.
 *
 *  @param URLString  The URL to which you are making this HTTP request.
 *  @param headers    The HTTP headers for this request.
 *  @param parameters The parameters for this request, to be passed in the query portion of the request.
 *  @param completion A block to be executed on completion of the request (successful or otherwise), of type SBBNetworkManagerCompletionBlock.
 *
 *  @return The NSURLSessionDataTask used to make the request, so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask* )get:(NSString *)URLString
                      headers:(NSDictionary *)headers
                   parameters:(id)parameters
                   completion:(SBBNetworkManagerCompletionBlock)completion;

/*!
 *  Perform an HTTP POST with the specified URL, HTTP headers, parameters, and completion handler.
 *
 *  @param URLString  The URL to which you are making this HTTP request.
 *  @param headers    The HTTP headers for this request.
 *  @param parameters The parameters for this request, to be passed in the request body as JSON. May be nil.
 *  @param completion A block to be executed on completion of the request (successful or otherwise), of type SBBNetworkManagerCompletionBlock.
 *
 *  @return The NSURLSessionDataTask used to make the request, so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask* )post:(NSString *)URLString
                       headers:(NSDictionary *)headers
                    parameters:(id)parameters
                    completion:(SBBNetworkManagerCompletionBlock)completion;

/*!
 *  Perform an HTTP PUT with the specified URL, HTTP headers, parameters, and completion handler.
 *
 *  @param URLString  The URL to which you are making this HTTP request.
 *  @param headers    The HTTP headers for this request.
 *  @param parameters The parameters for this request, to be passed in the request body as JSON. May be nil.
 *  @param completion A block to be executed on completion of the request (successful or otherwise), of type SBBNetworkManagerCompletionBlock.
 *
 *  @return The NSURLSessionDataTask used to make the request, so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask* )put:(NSString *)URLString
                      headers:(NSDictionary *)headers
                   parameters:(id)parameters
                   completion:(SBBNetworkManagerCompletionBlock)completion;

#ifdef __cplusplus
// delete is a C++ keyword
- (NSURLSessionDataTask *)delete_:(NSString *)URLString
                          headers:(NSDictionary *)headers
                       parameters:(id)parameters
                       completion:(SBBNetworkManagerCompletionBlock)completion;
#else
/*!
 *  Perform an HTTP DELETE with the specified URL, HTTP headers, parameters, and completion handler.
 *
 *  @note Since delete is a C++ keyword, when calling this method from Objective-C++ you must use the selector delete_:headers:parameters:completion: instead of delete:headers:parameters:completion:.
 *  @param URLString  The URL to which you are making this HTTP request.
 *  @param headers    The HTTP headers for this request.
 *  @param parameters The parameters for this request, to be passed in the request body as JSON. Usually for a DELETE this will be nil.
 *  @param completion A block to be executed on completion of the request (successful or otherwise), of type SBBNetworkManagerCompletionBlock.
 *
 *  @return The NSURLSessionDataTask used to make the request, so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)delete:(NSString *)URLString
                         headers:(NSDictionary *)headers
                      parameters:(id)parameters
                      completion:(SBBNetworkManagerCompletionBlock)completion;
#endif

@end


/*!
 This class handles HTTP networking with the Bridge REST API.
 */
@interface SBBNetworkManager : NSObject<SBBComponent, SBBNetworkManagerProtocol>

+ (instancetype)networkManagerForEnvironment:(SBBEnvironment)environment appURLPrefix:(NSString *)prefix baseURLPath:(NSString *)baseURLPath;

#pragma mark - Init & Accessor Methods

- (instancetype) initWithBaseURL: (NSString*) baseURL;

- (BOOL) isInternetConnected;
- (BOOL) isServerReachable;

@end