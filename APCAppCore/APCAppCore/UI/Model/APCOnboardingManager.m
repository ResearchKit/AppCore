//
//  APCOnboardingManager.m
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

#import "APCOnboardingManager.h"
#import "APCDataGroupsManager.h"
#import "APCPermissionsManager.h"
#import "APCUserInfoConstants.h"
#import "APCLog.h"
#import "APCScene.h"
#import "APCPasscodeViewController.h"
#import "APCChangePasscodeViewController.h"
#import "NSBundle+Helper.h"

#import <HealthKit/HealthKit.h>


NSString * const kAPCOnboardingStoryboardName = @"APCOnboarding";


@interface APCOnboardingManager ()

@property (weak, nonatomic) id<APCOnboardingManagerProvider> provider;

@property (strong, nonatomic, readwrite) APCUser *user;

@property (strong, nonatomic, readwrite) APCPermissionsManager *permissionsManager;

@property (strong, nonatomic, readwrite) APCDataGroupsManager *dataGroupsManager;

@end


@implementation APCOnboardingManager


- (instancetype)initWithProvider:(id<APCOnboardingManagerProvider>)provider user:(APCUser * __nonnull)user {
    if ((self = [super init])) {
        self.provider = provider;
        self.user = user;
        _signInSupported = YES;
    }
    return self;
}

+ (instancetype)managerWithProvider:(id<APCOnboardingManagerProvider>)provider user:(APCUser * __nonnull)user {
    return [[self alloc] initWithProvider:provider user:user];
}


#pragma mark - Onboarding

- (void)instantiateOnboardingForType:(APCOnboardingTaskType)type {
    if (self.onboarding) {
        self.onboarding.delegate = nil;
        self.onboarding = nil;
    }
    self.onboarding = [[APCOnboarding alloc] initWithDelegate:self taskType:type];
}

- (void)userDidConsentWithResult:(ORKConsentSignatureResult *)consentResult sharingScope:(APCUserConsentSharingScope)sharingScope {
    NSString *signatureName = [consentResult.signature.givenName stringByAppendingFormat:@" %@",consentResult.signature.familyName];
    NSData *signatureImage = UIImagePNGRepresentation(consentResult.signature.signatureImage);
    
    _user.consentSignatureName = signatureName;
    _user.consentSignatureImage = signatureImage;
    _user.consentSignatureDate = consentResult.startDate;
    _user.sharingScope = sharingScope;
    _user.userConsented = YES;
}

- (void)userDeclinedConsent {
    [[NSNotificationCenter defaultCenter] postNotificationName:APCUserDidDeclineConsentNotification object:self];
}

- (void)onboardingDidFinish {
    [self completeOnboardingAsSignIn:(self.onboarding.taskType == kAPCOnboardingTaskTypeSignIn)];
}

- (void)onboardingDidFinishAsSignIn {
    [self completeOnboardingAsSignIn:YES];
}

- (void)completeOnboardingAsSignIn:(BOOL)wasSignIn {
    if (wasSignIn) {
        self.user.signedIn = YES;
        //[(APCAppDelegate *)[UIApplication sharedApplication].delegate afterOnBoardProcessIsFinished];     // TODO: Untwine this spaghetti
        [[NSNotificationCenter defaultCenter] postNotificationName:APCUserSignedInNotification object:self];
    } else {
        self.user.signedUp = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:APCUserSignedUpNotification object:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:APCUserDidConsentNotification object:self];
}


#pragma mark - Permissions

- (APCPermissionsManager *)permissionsManager {
    if (!_permissionsManager) {
        _permissionsManager = [self.provider permissionsManager];
    }
    return _permissionsManager;
}

- (APCDataGroupsManager *)dataGroupsManager {
    if (!_dataGroupsManager) {
        _dataGroupsManager = [self.provider dataGroupsManagerForUser:self.user];
    }
    return _dataGroupsManager;
}

#pragma mark - APCOnboardingDelegate

- (APCScene *)onboarding:(APCOnboarding * __nonnull)onboarding sceneOfType:(NSString * __nonnull)type {
    NSParameterAssert(onboarding);
    NSParameterAssert([type length] > 0);
    
    // Sign Up
    if ([type isEqualToString:kAPCSignUpInclusionCriteriaStepIdentifier]) {
        if ([_provider respondsToSelector:@selector(inclusionCriteriaSceneForOnboarding:)]) {
            return [_provider performSelector:@selector(inclusionCriteriaSceneForOnboarding:) withObject:onboarding];
        }
        return nil;
    }
    if ([type isEqualToString:kAPCSignUpEligibleStepIdentifier]) {
        return [[APCScene alloc] initWithName:@"APCEligibleViewController" inStoryboard:kAPCOnboardingStoryboardName];
    }
    if ([type isEqualToString:kAPCSignUpIneligibleStepIdentifier]) {
        return [[APCScene alloc] initWithName:@"APCInEligibleViewController" inStoryboard:kAPCOnboardingStoryboardName];
    }
    if ([type isEqualToString:kAPCSignUpPermissionsPrimingStepIdentifier]) {
        return [[APCScene alloc] initWithName:@"APCPermissionPrimingViewController" inStoryboard:kAPCOnboardingStoryboardName];     // "What to Expect" screen
    }
    if ([type isEqualToString:kAPCSignUpDataGroupsStepIdentifier]) {
        if ([self.dataGroupsManager needsUserInfoDataGroups]) {
            ORKStep *step = [self.dataGroupsManager surveyStep];
            if (step != nil) {
                return [[APCScene alloc] initWithStep:step];
            }            
        }
        return nil;
    }
    if ([type isEqualToString:kAPCSignUpGeneralInfoStepIdentifier]) {
        return [[APCScene alloc] initWithName:@"APCSignUpGeneralInfoViewController" inStoryboard:kAPCOnboardingStoryboardName];
    }
    if ([type isEqualToString:kAPCSignUpMedicalInfoStepIdentifier]) {
        return [[APCScene alloc] initWithName:@"APCSignUpMedicalInfoViewController" inStoryboard:kAPCOnboardingStoryboardName];
    }
    if ([type isEqualToString:kAPCSignUpCustomInfoStepIdentifier]) {
        // Check if there is a custom step
        if ([_provider respondsToSelector:@selector(customInfoSceneForOnboarding:)]) {
            return [_provider performSelector:@selector(customInfoSceneForOnboarding:) withObject:onboarding];
        }
        return nil;
    }
    if ([type isEqualToString:kAPCSignUpPasscodeStepIdentifier]) {
        return [[APCScene alloc] initWithName:@"APCSignupPasscodeViewController" inStoryboard:kAPCOnboardingStoryboardName];
    }
    if ([type isEqualToString:kAPCSignUpPermissionsStepIdentifier]) {
        return [[APCScene alloc] initWithName:@"APCSignUpPermissionsViewController" inStoryboard:kAPCOnboardingStoryboardName];
    }
    if ([type isEqualToString:kAPCSignUpThankYouStepIdentifier]) {
        return [[APCScene alloc] initWithName:@"APCThankYouViewController" inStoryboard:kAPCOnboardingStoryboardName];
    }
    if ([type isEqualToString:kAPCSignUpShareAppStepIdentifier]) {
        return [[APCScene alloc] initWithName:@"APCShareViewController" inStoryboard:kAPCOnboardingStoryboardName];
    }
    
    // Sign In
    if ([type isEqualToString:kAPCSignInStepIdentifier]) {
        return [[APCScene alloc] initWithName:@"APCSignInViewController" inStoryboard:kAPCOnboardingStoryboardName];
    }
    
    APCLogDebug(@"Unknown onboarding scene type \"%@\"", type);
    return nil;
}

- (APCUser *)userForOnboardingTask:(APCOnboardingTask *)__unused task {
    return self.user;
}

- (NSInteger)numberOfServicesInPermissionsListForOnboardingTask:(APCOnboardingTask *)__unused task {
    return [self.permissionsManager.signUpPermissionTypes count];
}

- (void)onboarding:(APCOnboarding * __unused)onboarding didFinishStepWithResult:(ORKStepResult*)stepResult {
    if ([stepResult.identifier isEqualToString:APCDataGroupsStepIdentifier]) {
        [self.dataGroupsManager setSurveyAnswerWithStepResult:stepResult];
        self.user.dataGroups = self.dataGroupsManager.dataGroups;
    }
}

#pragma mark - passcode

- (BOOL)hasPasscode {
    return self.user.isSignedIn;
}

- (UIViewController*)instantiatePasscodeViewControllerWithDelegate:(id)delegate {
    APCPasscodeViewController *passcodeVC = [[UIStoryboard storyboardWithName:@"APCPasscode" bundle:[NSBundle appleCoreBundle]] instantiateInitialViewController];
    passcodeVC.passcodeViewControllerDelegate = delegate;
    return passcodeVC;
}

- (UIViewController*)instantiateChangePasscodeViewController {
    APCChangePasscodeViewController *changePasscodeViewController = [[UIStoryboard storyboardWithName:@"APCProfile" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"ChangePasscodeVC"];
    return changePasscodeViewController;
}

#pragma mark - handle user consent

- (ORKConsentSignatureResult *)findConsentSignatureResult:(ORKTaskResult*)taskResult {
    for (ORKStepResult *stepResult in taskResult.results) {
        for (ORKResult *result in stepResult.results) {
            if ([result isKindOfClass:[ORKConsentSignatureResult class]]) {
                return (ORKConsentSignatureResult*)result;
            }
        }
    }
    return nil;
}

- (ORKConsentSharingStep *)findConsentSharingStep:(ORKTaskViewController *)taskViewController {
    NSArray *steps = ((ORKOrderedTask*)taskViewController.task).steps;
    for (ORKStep *step in steps) {
        if ([step isKindOfClass:[ORKConsentSharingStep class]]) {
            return (ORKConsentSharingStep*)step;
        }
    }
    return nil;
}

- (BOOL)checkForConsentWithTaskViewController:(ORKTaskViewController *)taskViewController {
    
    // search for the consent signature
    ORKConsentSignatureResult *consentResult = [self findConsentSignatureResult:taskViewController.result];
    
    //  if no signature (no consent result) then assume the user failed the quiz
    if (consentResult != nil && consentResult.signature.requiresName && (consentResult.signature.givenName && consentResult.signature.familyName)) {
        
        // extract the user's sharing choice
        ORKConsentSharingStep *sharingStep = [self findConsentSharingStep:taskViewController];
        APCUserConsentSharingScope sharingScope = APCUserConsentSharingScopeNone;
        
        for (ORKStepResult* result in taskViewController.result.results) {
            if ([result.identifier isEqualToString:sharingStep.identifier]) {
                for (ORKChoiceQuestionResult *choice in result.results) {
                    if ([choice isKindOfClass:[ORKChoiceQuestionResult class]]) {
                        NSNumber *answer = [choice.choiceAnswers firstObject];
                        if ([answer isKindOfClass:[NSNumber class]]) {
                            if (0 == answer.integerValue) {
                                sharingScope = APCUserConsentSharingScopeStudy;
                            }
                            else if (1 == answer.integerValue) {
                                sharingScope = APCUserConsentSharingScopeAll;
                            }
                            else {
                                APCLogDebug(@"Unknown sharing choice answer: %@", answer);
                            }
                        }
                        else {
                            APCLogDebug(@"Unknown sharing choice answer(s): %@", choice.choiceAnswers);
                        }
                    }
                }
                break;
            }
        }
        
        // User has consented - continue
        [self userDidConsentWithResult:consentResult sharingScope:sharingScope];
        return YES;
        
    } else {
        // User declined consent - sign out
        [self userDeclinedConsent];
        return NO;
    }
}


@end
