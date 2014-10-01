//
//  SBBAuthManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/11/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBBComponent.h"
#import "SBBNetworkManager.h"

/// Global prefix for Bridge API URLs, specific to each app. Must be set before attempting to access Bridge APIs.
extern NSString *gSBBAppURLPrefix;

/**
 *  This protocol defines the interface to the SBBAuthManager's non-constructor, non-initializer methods. The interface is
 *  abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBAuthManagerProtocol <NSObject>

/*!
 * Sign up for an account with an email address, userName, and password. An email will be sent to the
 * specified email address containing a link to verify that this is indeed that person's email. The
 * userName and password won't be valid for signing in until the email has been verified.
 *
 * @param email The email address to be associated with the account.
 * @param userName The username to use for the account.
 * @param password The password to use for the account.
 * @param completion A SBBNetworkManagerCompletionBlock to be called upon completion.
 * @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)signUpWithEmail:(NSString *)email username:(NSString *)username password:(NSString *)password completion:(SBBNetworkManagerCompletionBlock)completion;

/*!
 * Sign in to an existing account with a userName and password.
 *
 * @param userName The username of the account being signed into.
 * @param password The password of the account.
 * @param completion A SBBNetworkManagerCompletionBlock to be called upon completion. The responseObject will be an NSDictionary containing a Bridge API <a href="https://sagebionetworks.jira.com/wiki/display/BRIDGE/UserSessionInfo"> UserSessionInfo</a> object in case you need to refer to it, but the SBBAuthManager handles the session token for all Bridge API access via this SDK, so you can generally ignore it if you prefer.
 * @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)signInWithUsername:(NSString *)username password:(NSString *)password completion:(SBBNetworkManagerCompletionBlock)completion;

/*!
 * Sign out of the user's Bridge account.
 *
 * @param completion A SBBNetworkManagerCompletionBlock to be called upon completion.
 * @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)signOutWithCompletion:(SBBNetworkManagerCompletionBlock)completion;

/*!
 * Call this at app launch to ensure the user is logged in to their account (if any).
 *
 * The completion block should check for error code kSBBNoCredentialsAvailable and ask the user to sign up/sign in.
 *
 * @param completion A SBBNetworkManagerCompletionBlock to be called upon completion.
 */
- (void)ensureSignedInWithCompletion:(SBBNetworkManagerCompletionBlock)completion;

/**
 *  This method is used by other API manager components to inject the session token header for authentication.
 *
 *  @param headers A mutable dictionary containing HTTP header key-value (string) pairs, to which to add the auth header.
 */
- (void)addAuthHeaderToHeaders:(NSMutableDictionary *)headers;

@end

/*!
 * This class handles communication with the Bridge authentication API, as well as maintaining
 * authentication credentials obtained therefrom.
 */
@interface SBBAuthManager : NSObject<SBBComponent, SBBAuthManagerProtocol>

/*!
 * Return the default (shared) component of this type (SBBAuthManager), configured with the gSBBAppURLPrefix and
 * the default environment. In debug builds, this is SBBEnvironmentStaging; in release builds, SBBEnvironmentProd.
 * Also configures the component to use the SBBNetworkManager currently registered the first time this is called,
 * or the default if none was registered yet.
 *
 * @warning gSBBAppURLPrefix *must* be set before calling this method, or it will return nil.
 * @return The default (shared) SBBAuthManager component.
 */
+ (instancetype)defaultComponent;

/*!
 * Return an SBBAuthManager component configured for the specified environment, appURLPrefix, and baseURLPath
 * with a default network manager.
 * 
 * Use this method directly only if you need to redirect your Bridge API accesses to a test server.
 *
 * @param environment The SBBEnvironment to use (prod, staging, dev).
 * @param prefix The app-specific URL prefix to use (typically set in gSBBAppURLPrefix).
 * @param baseURLPath The URL path to prefix with the appURLPrefix and environment string (e.g. @"sagebridge.org")
 * @return An SBBAuthManager component configured for an environment, appURLPrefix, and baseURLPath.
 */
+ (instancetype)authManagerForEnvironment:(SBBEnvironment)environment appURLPrefix:(NSString *)prefix baseURLPath:(NSString *)baseURLPath;

/*!
 * Return an SBBAuthManager component configured for the specified baseURL with a default network manager.
 *
 * Use this if you need to test against a custom server. Implies a custom environment for credential storage purposes.
 *
 * @param networkManager The SBBNetworkManager to use.
 * @return An SBBAuthManager component configured with a specific network manager.
 */
+ (instancetype)authManagerWithBaseURL:(NSString *)baseURL;

/*!
 * Return an SBBAuthManager component configured with the specified network manager.
 *
 * Use this if you need to run with a custom network manager. Also implies a custom environment for credential storage purposes.
 *
 * @param networkManager The SBBNetworkManager to use.
 * @return An SBBAuthManager component configured with a specific network manager.
 */
+ (instancetype)authManagerWithNetworkManager:(id<SBBNetworkManagerProtocol>)networkManager;

@end
