//
//  APCOnboardingManager.h
//  APCAppCore
//
// Copyright (c) 2015, Apple Inc. All rights reserved.
// Copyright (c) 2015, Boston Children's Hospital. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>
#import "APCOnboarding.h"
#import "APCUser.h"

@class APCOnboardingManager;
@class APCPermissionsManager;
@class APCDataGroupsManager;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol, implemented by the app delegate, to obtain the app's onboarding manager.
 */
@protocol APCOnboardingManagerProvider <NSObject>

@required
/** The onboarding manager for the app. */
- (APCOnboardingManager *)onboardingManager;
/** The permissions manager for the app. */
- (APCPermissionsManager *)permissionsManager;
/** The data groups manager for the app. */
- (APCDataGroupsManager *)dataGroupsManagerForUser:(APCUser * _Nullable)user;
@optional
/**
 *  Kept for backwards compatibility: return the inclusion criteria scene.
 */
- (nullable APCScene *)inclusionCriteriaSceneForOnboarding:(APCOnboarding *)onboarding;

/**
 *  Kept for backwards compatibility: return a custom info scene.
 */
- (nullable APCScene *)customInfoSceneForOnboarding:(APCOnboarding *)onboarding;

/**
 * Allow for a custom handling of onboarding
 */
- (BOOL)didHandleSignupFromViewController:(UIViewController*)viewController;

@end

/**
 *  Manager to configure and handle the onboarding process.
 *
 *  This superclass returns all scenes present in the "APCOnboarding" storyboard. It is missing an inclusion criteria
 *  scene that you should provide by implementing `inclusionCriteriaSceneForOnboarding:` in APCOnboardingManagerProvider
 *  or by creating a subclass and overriding `onboarding:sceneOfType:`.
 */
@interface APCOnboardingManager : NSObject <APCOnboardingDelegate>

/// The onboarding currently in use; can only have one at a time.
@property (strong, nonatomic, nullable) APCOnboarding *onboarding;

/// The user/subject that is onboarding.
@property (strong, nonatomic, readonly) APCUser *user;

/// The permissions manager defining and requesting needed permissions.
@property (strong, nonatomic, readonly) APCPermissionsManager *permissionsManager;

/// The data groups manager defining data groups mapping
@property (strong, nonatomic, readonly) APCDataGroupsManager *dataGroupsManager;

/// Whether a sign-in action, to resume a study previously enrolled in, is supported. Defaults to YES.
@property (nonatomic, getter=isSignInSupported) BOOL signInSupported;

/// Whether the app should display 'share this app' options in onboarding. Defaults to NO.
@property (nonatomic) BOOL showShareAppInOnboarding;

+ (instancetype)managerWithProvider:(id<APCOnboardingManagerProvider>)provider user:(APCUser * __nonnull)user;

/** Designated initializer. */
- (instancetype)initWithProvider:(id<APCOnboardingManagerProvider>)provider user:(APCUser * __nonnull)user;

- (void)instantiateOnboardingForType:(APCOnboardingTaskType)type;

- (BOOL)hasPasscode;
- (UIViewController*)instantiatePasscodeViewControllerWithDelegate:(id)delegate;
- (UIViewController*)instantiateChangePasscodeViewController;


#pragma mark Onboarding

/** Called when the user has agreed to and completed all consenting steps. */
- (void)userDidConsentWithResult:(ORKConsentSignatureResult *)consentResult sharingScope:(APCUserConsentSharingScope)sharingScope;

/** Called when the user does not agree to the consent. */
- (void)userDeclinedConsent;

/** Called when the onboarding's last step has concluded. */
- (void)onboardingDidFinish;

/** Kept for compatibility reason; no matter the receiver's onboarding type, this will finish onboarding as a user-sign-in. */
- (void)onboardingDidFinishAsSignIn;

@end

NS_ASSUME_NONNULL_END
