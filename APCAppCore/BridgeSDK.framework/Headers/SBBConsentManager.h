//
//  SBBConsentManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/23/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeAPIManager.h"

/*!
 Completion block for SBBConsentManagerProtocol methods.
 
 @param responseObject The JSON object returned in the HTTP response.
 @param error          An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBConsentManagerCompletionBlock)(id responseObject, NSError *error);

/*!
 This protocol defines the interface to the SBBConsentManager's non-constructor, non-initializer methods. The interface is
 abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBConsentManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 *  Submit the user's "signature" and birthdate to indicate consent to participate in this research project.
 *
 *  @param name       The user's "signature", recorded exactly as entered.
 *  @param birthdate  The user's birthday in the format "YYYY-MM-DD".
 *  @param completion An SBBConsentManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)consentSignature:(NSString *)name birthdate:(NSDate *)birthdate completion:(SBBConsentManagerCompletionBlock)completion;

/*!
 *  Suspend the user's previously-given consent to participate.
 *
 *  @param completion An SBBConsentManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)suspendConsentWithCompletion:(SBBConsentManagerCompletionBlock)completion;

/*!
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
@interface SBBConsentManager : SBBBridgeAPIManager<SBBComponent, SBBConsentManagerProtocol>

@end
