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
 Session identifier for the Bridge SDK's background session.
 */
extern NSString * kBackgroundSessionIdentifier;

/*!
 *  Typedef for SBBNetworkManager data methods' completion block.
 *
 *  @param task           The NSURLSessionDataTask.
 *  @param responseObject The JSON object from the response, if any.
 *  @param error          Any error that occurred.
 */
typedef void (^SBBNetworkManagerCompletionBlock)(NSURLSessionDataTask *task, id responseObject, NSError *error);

/*!
 *  Typedef for SBBNetworkManager upload completion block.
 *
 *  @param task           The NSURLSessionUploadTask.
 *  @param response       The HTTP response, if any.
 *  @param error          Any error that occurred.
 */
typedef void (^SBBNetworkManagerUploadCompletionBlock)(NSURLSessionUploadTask *task, NSHTTPURLResponse *response, NSError *error);

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

/*!
 Perform a background upload of a file to a given URL with provided HTTP headers.
 
 @param fileUrl   The URL of the file to be uploaded.
 @param headers   An NSDictionary containing the HTTP headers as key-value pairs.
 @param urlString The URL (as a string) to which to upload the file.
 @param completion A block to be called upon completion of the upload.
 
 @return The NSURLSessionUploadTask used to make the request, so you can cancel or suspend/resume the request.
 */
- (NSURLSessionUploadTask *)uploadFile:(NSURL *)fileUrl httpHeaders:(NSDictionary *)headers toUrl:(NSString *)urlString completion:(SBBNetworkManagerUploadCompletionBlock)completion;

/*!
 This method should be called from your app delegate's
 application:handleEventsForBackgroundURLSession:completionHandler: method when the identifier passed in there matches
 kBackgroundSessionIdentifier.
 
 If you are setting up and registering your own custom NetworkManager instance rather than using one of the BridgeSDK's
 +setupWithAppPrefix: methods, you will also need to call this from your app delegate's
 application:didFinishLaunchingWithOptions: method with kBackgroundSessionIdentifier as the identifier, and nil for the
 completion handler.
 
 @param identifier        The session identifier, as passed in to your app delegate's
 application:handleEventsForBackgroundURLSession:completionHandler: method.
 @param completionHandler The completion handler, as passed in to your app delegate's
 application:handleEventsForBackgroundURLSession:completionHandler: method.
 */
- (void)restoreBackgroundSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler;

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