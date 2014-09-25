//
//  BridgeSDK.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/8/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
  
//! Project version number for BridgeSDK.
extern double BridgeSDKVersionNumber;

//! Project version string for BridgeSDK.
extern const unsigned char BridgeSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <BridgeSDK/PublicHeader.h>
  
#import <BridgeSDK/SBBAuthManager.h>
#import <BridgeSDK/SBBComponent.h>
#import <BridgeSDK/SBBComponentManager.h>
#import <BridgeSDK/SBBNetworkManager.h>
#import <BridgeSDK/SBBNetworkErrors.h>
  
// This sets the default environment at app (not SDK) compile time to Staging for debug builds and Production for non-debug.
#if DEBUG
#define kDefaultEnvironment SBBEnvironmentStaging
#else
#define kDefaultEnvironment SBBEnvironmentProd
#endif
static SBBEnvironment gDefaultEnvironment = kDefaultEnvironment;
  
@interface BridgeSDK : NSObject

/**
 *  Set up the Bridge SDK for the given app prefix and server environment. Usually you would only call this version
 * of the method from test suites, or if you have a non-DEBUG build configuration that you don't want running against
 * the production server environment. Otherwise call the version of the setupWithAppPrefix: method that doesn't
 * take an environment parameter, and let the SDK use the default environment.
 *
 *  @param appPrefix   A string prefix for your app's Bridge server URLs, assigned to you by Sage Bionetworks.
 *  @param environment Which server environment to run against.
 */
+ (void)setupWithAppPrefix:(NSString *)appPrefix environment:(SBBEnvironment)environment;

/*!
 * Set up the Bridge SDK for the given app prefix and the appropriate server environment based on whether this is
 * a debug or release build.
 *
 *  @param appPrefix   A string prefix for your app's Bridge server URLs, assigned to you by Sage Bionetworks.
 */
+ (void)setupWithAppPrefix:(NSString *)appPrefix;

@end

#ifdef __cplusplus
}
#endif

