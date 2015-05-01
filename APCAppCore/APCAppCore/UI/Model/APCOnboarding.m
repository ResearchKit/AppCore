// 
//  APCOnboarding.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
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
 
#import "APCOnboarding.h"
#import "APCEligibleViewController.h"
#import "APCInEligibleViewController.h"
#import "APCPermissionPrimingViewController.h"
#import "APCSignUpGeneralInfoViewController.h"
#import "APCSignUpMedicalInfoViewController.h"
#import "APCSignupPasscodeViewController.h"
#import "APCSignUpPermissionsViewController.h"
#import "APCThankYouViewController.h"
#import "APCSignInViewController.h"
#import "NSBundle+Helper.h"

static NSString * const kOnboardingStoryboardName = @"APCOnboarding";

@interface APCOnboarding ()

@property (nonatomic, readwrite) APCOnboardingTask *onboardingTask;

@property (nonatomic, readwrite) APCOnboardingTaskType taskType;;

@end

@implementation APCOnboarding

- (instancetype)initWithDelegate:(id)object  taskType:(APCOnboardingTaskType)taskType
{
    self = [super init];
    if (self) {
        
        _taskType = taskType;
        
        if (taskType == kAPCOnboardingTaskTypeSignIn) {
            _onboardingTask = [APCSignInTask new];
        } else {
            _onboardingTask = [APCSignUpTask new];
        }
        
        _sceneData = [NSMutableDictionary new];
        
        _delegate = object;
        _onboardingTask.delegate = object;
        
        _scenes = [self prepareScenes];
    }
    
    return self;
}

- (NSMutableDictionary *)prepareScenes
{
    NSMutableDictionary *scenes = [NSMutableDictionary new];
    
    
    {
        if ([self.delegate respondsToSelector:@selector(inclusionCriteriaSceneForOnboarding:)]) {
            APCScene *scene = [self.delegate inclusionCriteriaSceneForOnboarding:self];
            [scenes setObject:scene forKey:kAPCSignUpInclusionCriteriaStepIdentifier];
        }
    }
    {
        APCScene *scene = [APCScene new];
        scene.name = NSStringFromClass([APCEligibleViewController class]);
        scene.storyboardName = kOnboardingStoryboardName;
        scene.bundle = [NSBundle appleCoreBundle];
        
        [scenes setObject:scene forKey:kAPCSignUpEligibleStepIdentifier];
    }
    {
        APCScene *scene = [APCScene new];
        scene.name = NSStringFromClass([APCInEligibleViewController class]);
        scene.storyboardName = kOnboardingStoryboardName;
        scene.bundle = [NSBundle appleCoreBundle];
        
        [scenes setObject:scene forKey:kAPCSignUpIneligibleStepIdentifier];
    }
    {
        APCScene *scene = [APCScene new];
        scene.name = NSStringFromClass([APCPermissionPrimingViewController class]);
        scene.storyboardName = kOnboardingStoryboardName;
        scene.bundle = [NSBundle appleCoreBundle];
        
        [scenes setObject:scene forKey:kAPCSignUpPermissionsPrimingStepIdentifier];
    }
    {
        APCScene *scene = [APCScene new];
        scene.name = NSStringFromClass([APCSignUpGeneralInfoViewController class]);
        scene.storyboardName = kOnboardingStoryboardName;
        scene.bundle = [NSBundle appleCoreBundle];
        
        [scenes setObject:scene forKey:kAPCSignUpGeneralInfoStepIdentifier];
    }
    {
        APCScene *scene = [APCScene new];
        scene.name = NSStringFromClass([APCSignUpMedicalInfoViewController class]);
        scene.storyboardName = kOnboardingStoryboardName;
        scene.bundle = [NSBundle appleCoreBundle];
        
        [scenes setObject:scene forKey:kAPCSignUpMedicalInfoStepIdentifier];
    }
    {
        if ([self.delegate respondsToSelector:@selector(customInfoSceneForOnboarding:)]) {
            APCScene *scene = [self.delegate customInfoSceneForOnboarding:self];
            [scenes setObject:scene forKey:kAPCSignUpCustomInfoStepIdentifier];
            self.onboardingTask.customStepIncluded = YES;
        }
    }
    {
        APCScene *scene = [APCScene new];
        scene.name = NSStringFromClass([APCSignupPasscodeViewController class]);
        scene.storyboardName = kOnboardingStoryboardName;
        scene.bundle = [NSBundle appleCoreBundle];
        
        [scenes setObject:scene forKey:kAPCSignUpPasscodeStepIdentifier];
    }
    {
        APCScene *scene = [APCScene new];
        scene.name = NSStringFromClass([APCSignUpPermissionsViewController class]);
        scene.storyboardName = kOnboardingStoryboardName;
        scene.bundle = [NSBundle appleCoreBundle];
        
        [scenes setObject:scene forKey:kAPCSignUpPermissionsStepIdentifier];
    }
    {
        APCScene *scene = [APCScene new];
        scene.name = NSStringFromClass([APCThankYouViewController class]);
        scene.storyboardName = kOnboardingStoryboardName;
        scene.bundle = [NSBundle appleCoreBundle];
        
        [scenes setObject:scene forKey:kAPCSignUpThankYouStepIdentifier];
    }
    {
        APCScene *scene = [APCScene new];
        scene.name = NSStringFromClass([APCSignInViewController class]);
        scene.storyboardName = kOnboardingStoryboardName;
        scene.bundle = [NSBundle appleCoreBundle];
        
        [scenes setObject:scene forKey:kAPCSignInStepIdentifier];
    }
    
    return scenes;
}

- (UIViewController *)nextScene
{
    ORKTaskResult* result = nil;
    self.currentStep = [self.onboardingTask stepAfterStep:self.currentStep withResult:result];
    
    UIViewController *nextViewController = [self viewControllerForSceneIdentifier:self.currentStep.identifier];
    
    return nextViewController;
}

- (void)popScene
{
    ORKTaskResult* result = nil;
    if (![self.currentStep.identifier isEqualToString:kAPCSignUpMedicalInfoStepIdentifier]) {
        self.currentStep = [self.onboardingTask stepBeforeStep:self.currentStep withResult:result];
    }
}

- (UIViewController *)viewControllerForSceneIdentifier:(NSString *)identifier
{
    APCScene *scene = self.scenes[identifier];
    
    UIViewController *viewController = [[UIStoryboard storyboardWithName:scene.storyboardName bundle:scene.bundle] instantiateViewControllerWithIdentifier:scene.name];
    return viewController;
}

- (void)setScene:(APCScene *)scene forIdentifier:(NSString *)identifier
{
    [self.scenes setObject:scene forKey:identifier];
}

@end


@implementation APCScene

@end
