//
//  SBBConsentManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/23/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "SBBBridgeAPIManager.h"

/*!
 * @typedef SBBConsentShareScope
 * @brief An enumeration of the choices for the scope of sharing collected data.
 * @constant SBBConsentShareScopeNone The user has not consented to sharing their data.
 * @constant SBBConsentShareScopeStudy The user has consented only to sharing their de-identified data with the sponsors and partners of the current research study.
 * @constant SBBConsentShareScopeAll The user has consented to sharing their de-identified data for current and future research, which may or may not involve the same institutions or investigators.
 */
typedef NS_ENUM(NSInteger, SBBConsentShareScope) {
    SBBConsentShareScopeNone = 0,
    SBBConsentShareScopeStudy,
    SBBConsentShareScopeAll
};

/*!
 Completion block for SBBConsentManagerProtocol methods.
 
 @param responseObject The JSON object returned in the HTTP response.
 @param error          An error that occurred during execution of the method for which this is a completion block, or nil.
 */
typedef void (^SBBConsentManagerCompletionBlock)(id responseObject, NSError *error);

/*!
 Completion block for retrieveConsentSignature.

 @param name           The user's name.
 @param birthdate      The user's birthday in the format "YYYY-MM-DD".
 @param signatureImage Image file of the user's signature. Should be less than 10kb. Optional, can be nil.
 @param error          An error that occurred during execution of the method for which this is a completion block, or
     nil.
 */
typedef void (^SBBConsentManagerRetrieveCompletionBlock)(NSString* name, NSString* birthdate, UIImage* signatureImage,
    NSError* error);

/*!
 This protocol defines the interface to the SBBConsentManager's non-constructor, non-initializer methods. The interface is
 abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBConsentManagerProtocol <SBBBridgeAPIManagerProtocol>

/*!
 *  Submit the user's "signature" and birthdate to indicate consent to participate in this research project.
 *
 *  @param name       The user's name.
 *  @param date       The user's birthday in the format "YYYY-MM-DD".
 *  @param signatureImage  Image file of the user's signature. Should be less than 10kb. Optional, can be nil.
 *  @param scope      The scope of data sharing to which the user has consented.
 *  @param completion An SBBConsentManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)consentSignature:(NSString *)name
                                 birthdate:(NSDate *)date
                            signatureImage:(UIImage*)signatureImage
                              dataSharing:(SBBConsentShareScope)scope
                                completion:(SBBConsentManagerCompletionBlock)completion;

/*!
 *  Retrieve the user's consent signature as previously submitted. If the user has not submitted a consent signature,
 *  this method throws an Entity Not Found error.
 *
 *  @param completion An SBBConsentManagerRetrieveCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask*)retrieveConsentSignatureWithCompletion:(SBBConsentManagerRetrieveCompletionBlock)completion;

/*!
 *  DEPRECATED: Suspend the user's previously-given consent to participate.
 *
 *  @warning This method is deprecated as of BridgeSDK version 2. You should call the dataSharing: method instead. This method is equivalent to calling dataSharing: with a scope of SBBConsentShareScopeNone.
 *
 *  @param completion An SBBConsentManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)suspendConsentWithCompletion:(SBBConsentManagerCompletionBlock)completion __deprecated;

/*!
 *  DEPRECATED: Resume the user's previously-suspended consent to participate.
 *
 *  @warning This method is deprecated as of BridgeSDK version 2. You should call the dataSharing: method instead. This method is equivalent to calling dataSharing: with a scope of SBBConsentShareScopeStudy.
 *
 *  @param completion An SBBConsentManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)resumeConsentWithCompletion:(SBBConsentManagerCompletionBlock)completion __deprecated;

/**
 *  Change the scope of data sharing for this user.
 *  This should only be done in response to an explicit choice on the part of the user to change the sharing scope.
 *
 *  @param scope The scope of data sharing to set for this user.
 *
 *  @param completion An SBBConsentManagerCompletionBlock to be called upon completion.
 *
 *  @return An NSURLSessionDataTask object so you can cancel or suspend/resume the request.
 */
- (NSURLSessionDataTask *)dataSharing:(SBBConsentShareScope)scope completion:(SBBConsentManagerCompletionBlock)completion;

@end

/*!
 *  This class handles communication with the Bridge Consent API.
 */
@interface SBBConsentManager : SBBBridgeAPIManager<SBBComponent, SBBConsentManagerProtocol>

@end
