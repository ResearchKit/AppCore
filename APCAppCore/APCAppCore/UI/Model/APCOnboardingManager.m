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
#import "APCLog.h"


NSString * const kAPCOnboardingStoryboardName = @"APCOnboarding";


@interface APCOnboardingManager ()

@property (weak, nonatomic) id<APCOnboardingManagerProvider> provider;

@property (strong, nonatomic, readwrite) APCUser *user;

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
    if ([type isEqualToString:kAPCSignUpGeneralInfoStepIdentifier]) {
        return [[APCScene alloc] initWithName:@"APCSignUpGeneralInfoViewController" inStoryboard:kAPCOnboardingStoryboardName];
    }
    if ([type isEqualToString:kAPCSignUpMedicalInfoStepIdentifier]) {
        return [[APCScene alloc] initWithName:@"APCSignUpMedicalInfoViewController" inStoryboard:kAPCOnboardingStoryboardName];
    }
    if ([type isEqualToString:kAPCSignUpCustomInfoStepIdentifier]) {
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
    return [_provider numberOfServicesInPermissionsList];
}

@end
