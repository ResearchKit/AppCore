//
//  SBBConsentManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/23/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBBComponent.h"

@class SBBAuthManager;
@protocol SBBNetworkManagerProtocol;

typedef void (^SBBConsentManagerCompletionBlock)(id responseObject, NSError *error);

@protocol SBBConsentManagerProtocol <NSObject>

/**
 *  Submit the user's "signature" and birthdate to indicate consent to participate in this research project.
 *
 *  @param name       The user's "signature", recorded exactly as entered.
 *  @param birthdate  The user's birthday in the format "YYYY-MM-DD".
 *  @param completion An SBBConsentManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)consentSignature:(NSString *)name birthdate:(NSDate *)birthdate completion:(SBBConsentManagerCompletionBlock)completion;

/**
 *  Suspend the user's previously-given consent to participate.
 *
 *  @param completion An SBBConsentManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)suspendConsentWithCompletion:(SBBConsentManagerCompletionBlock)completion;

/**
 *  Resume the user's previously-suspended consent to participate.
 *
 *  @param completion An SBBConsentManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)resumeConsentWithCompletion:(SBBConsentManagerCompletionBlock)completion;

@end

/*!
 *  This class handles communication with the Bridge Consent API.
 */
@interface SBBConsentManager : NSObject<SBBComponent, SBBConsentManagerProtocol>

/*!
 *  Return an SBBConsentManager component configured to use the specified auth manager, network manager, and object manager.
 *
 *  Use this method to build a custom configuration, e.g. for testing.
 *
 *  @param authManager    The auth manager to use for authentication. Must implement the SBBAuthManagerProtocol.
 *  @param networkManager The network manager to use for making REST API requests. Must implement the SBBNetworkManagerProtocol.
 *
 *  @return An SBBConsentManager injected with the specified dependencies.
 */
+ (instancetype)consentManagerWithAuthManager:(SBBAuthManager *)authManager networkManager:(id<SBBNetworkManagerProtocol>)networkManager;

@end
