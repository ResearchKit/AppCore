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
#import "APCSignUpTask.h"
#import "APCSignInTask.h"
#import "APCLog.h"
#import "APCScene.h"


@interface APCOnboarding () <ORKStepViewControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary <NSString*, APCScene *> * __nullable scenes;

@property (nonatomic, readwrite) APCOnboardingTask *onboardingTask;

@property (nonatomic, readwrite) APCOnboardingTaskType taskType;

@end


@implementation APCOnboarding

- (instancetype)initWithDelegate:(id<APCOnboardingDelegate>)object taskType:(APCOnboardingTaskType)taskType {
    self = [super init];
    if (self) {
        _taskType = taskType;
        
        // create appropriate onboarding task
        if (taskType == kAPCOnboardingTaskTypeSignIn) {
            self.onboardingTask = [APCSignInTask new];
        }
        else {
            self.onboardingTask = [APCSignUpTask new];
        }
        _onboardingTask.delegate = object;
        
        // create delegate and ask it for scenes, then create steps from supplied scenes
        self.delegate = object;
        self.sceneData = [NSMutableDictionary new];
        self.scenes = [[self prepareScenes] mutableCopy] ?: [NSMutableDictionary dictionaryWithCapacity:1];
        [self createStepsFromScenes];
    }
    
    return self;
}


#pragma mark - Scenes

- (NSDictionary *)prepareScenes {
    NSMutableDictionary *scenes = [NSMutableDictionary new];
    
    BOOL (^addScene)(NSString *) = ^BOOL(NSString * sceneType){
        APCScene *scene = [self.delegate onboarding:self sceneOfType:sceneType];
        if (scene) {
            if (scene.step == nil) {
                scene.step = [[ORKStep alloc] initWithIdentifier:sceneType];
            }
            // Map the scene to both the sceneType and the step identifier in case
            // they are not the same.
            scenes[sceneType] = scene;
            scenes[scene.step.identifier] = scene;
        }
        return (scene != nil);
    };
    
    addScene(kAPCSignUpInclusionCriteriaStepIdentifier);
    addScene(kAPCSignUpEligibleStepIdentifier);
    addScene(kAPCSignUpIneligibleStepIdentifier);
    addScene(kAPCSignUpPermissionsPrimingStepIdentifier);
    addScene(kAPCSignUpDataGroupsStepIdentifier);
    addScene(kAPCSignUpGeneralInfoStepIdentifier);
    addScene(kAPCSignUpMedicalInfoStepIdentifier);
    self.onboardingTask.customStepIncluded = addScene(kAPCSignUpCustomInfoStepIdentifier);
    addScene(kAPCSignUpPasscodeStepIdentifier);
    addScene(kAPCSignUpPermissionsStepIdentifier);
    addScene(kAPCSignUpThankYouStepIdentifier);
    addScene(kAPCSignInStepIdentifier);
    addScene(kAPCSignUpShareAppStepIdentifier);
    
    return scenes;
}

- (BOOL)hasNextStep:(ORKStep *)step {
    ORKTaskResult *result = nil;
    return [self.onboardingTask stepAfterStep:step withResult:result] != nil;
}

- (BOOL)hasPreviousStep:(ORKStep *)step {
    ORKTaskResult *result = nil;
    return [self.onboardingTask stepBeforeStep:step withResult:result] != nil;
}

- (UIViewController *)nextScene {
    ORKTaskResult *result = nil;
    ORKStep *nextStep = [self.onboardingTask stepAfterStep:self.currentStep withResult:result];

    // If the task asks for a step that we don't have a scene for, we skip the step and move on to the next
    UIViewController *nextViewController = [self viewControllerForSceneIdentifier:nextStep.identifier];
    if ([nextViewController isKindOfClass:[ORKStepViewController class]]) {
        ((ORKStepViewController*)nextViewController).delegate = self;
    }
    
    self.currentStep = nextStep;
    if (nextViewController) {
        return nextViewController;
    }
    if (self.currentStep != nil) {
        APCLogDebug(@"No scene for next step \"%@\", skipping", _currentStep.identifier);
        return [self nextScene];
    }
    
    APCLogDebug(@"Last onboarding scene reached");
    return nil;
}

- (void)popScene {
    ORKTaskResult *result = nil;
    if (![self.currentStep.identifier isEqualToString:kAPCSignUpMedicalInfoStepIdentifier]) {
        self.currentStep = [self.onboardingTask stepBeforeStep:self.currentStep withResult:result];
    }
}

- (UIViewController *)viewControllerForSceneIdentifier:(NSString *)identifier {
    APCScene *scene = self.scenes[identifier];
    return [scene instantiateViewController];
}

- (void)setScene:(APCScene *)scene forIdentifier:(NSString *)identifier {
    [self.scenes setObject:scene forKey:identifier];
}

- (BOOL)isSignInSupported {
    return (nil != self.scenes[kAPCSignInStepIdentifier]);
}


#pragma mark - Steps

/**
 *  Depending on the scenes we have, create the corresponding steps in the sign-in/-up task.
 */
- (void)createStepsFromScenes {
    NSAssert(_scenes, @"Only call this once we have scenes");
    NSAssert(_onboardingTask, @"Need to have an onboarding task before creating steps from scenes");
    
    _onboardingTask.inclusionCriteriaStep = _scenes[kAPCSignUpInclusionCriteriaStepIdentifier].step;
    _onboardingTask.eligibleStep = _scenes[kAPCSignUpEligibleStepIdentifier].step;
    _onboardingTask.ineligibleStep = _scenes[kAPCSignUpIneligibleStepIdentifier].step;
    _onboardingTask.permissionsPrimingStep = _scenes[kAPCSignUpPermissionsPrimingStepIdentifier].step;
    _onboardingTask.dataGroupsStep = _scenes[kAPCSignUpDataGroupsStepIdentifier].step;
    _onboardingTask.generalInfoStep = _scenes[kAPCSignUpGeneralInfoStepIdentifier].step;
    _onboardingTask.medicalInfoStep = _scenes[kAPCSignUpMedicalInfoStepIdentifier].step;
    _onboardingTask.customInfoStep = _scenes[kAPCSignUpCustomInfoStepIdentifier].step;
    _onboardingTask.passcodeStep = _scenes[kAPCSignUpPasscodeStepIdentifier].step;
    _onboardingTask.permissionsStep = _scenes[kAPCSignUpPermissionsStepIdentifier].step;
    _onboardingTask.thankyouStep = _scenes[kAPCSignUpThankYouStepIdentifier].step;
    _onboardingTask.signInStep = _scenes[kAPCSignInStepIdentifier].step;
}

#pragma mark - ORKStepViewControllerDelegate

- (void)stepViewController:(ORKStepViewController * __unused)stepViewController didFinishWithNavigationDirection:(ORKStepViewControllerNavigationDirection)direction {
    if (direction == ORKStepViewControllerNavigationDirectionForward) {
        
        // Let the delegate handle the change
        if ([self.delegate respondsToSelector:@selector(onboarding:didFinishStepWithResult:)]) {
            [self.delegate onboarding:self didFinishStepWithResult:stepViewController.result];
        }
        
        UIViewController *nextVC = [self nextScene];
        if (nextVC) {
            // go forward
            [stepViewController.navigationController pushViewController:nextVC animated:YES];
        }
        else if ([self.delegate respondsToSelector:@selector(onboardingDidFinish)]) {
            [self.delegate onboardingDidFinish];
        }
    }
    else {
        // go back
        [stepViewController.navigationController popViewControllerAnimated:YES];
    }
}

- (void)stepViewControllerResultDidChange:(ORKStepViewController * __unused)stepViewController {
    // Do nothing
}

- (void)stepViewControllerDidFail:(ORKStepViewController * __unused)stepViewController withError:(nullable NSError * __unused)error {
    // Do  nothing
}

- (void)stepViewController:(ORKStepViewController * __unused)stepViewController recorder:(ORKRecorder * __unused)recorder didFailWithError:(NSError * __unused)error {
    // Do  nothing
}

- (BOOL)stepViewControllerHasPreviousStep:(ORKStepViewController *  __unused)stepViewController {
    BOOL ret = [self hasPreviousStep:stepViewController.step];
    return ret;
}

- (BOOL)stepViewControllerHasNextStep:(ORKStepViewController *  __unused)stepViewController {
    BOOL ret =  [self hasNextStep:stepViewController.step];
    return ret;
}

@end



