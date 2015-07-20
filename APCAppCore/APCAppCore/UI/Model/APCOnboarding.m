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


@interface APCOnboarding ()

@property (nonatomic, strong) NSMutableDictionary *__nullable scenes;

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
    
    APCScene *signUp = [self.delegate onboarding:self sceneOfType:kAPCSignUpInclusionCriteriaStepIdentifier];
    if (signUp) {
        scenes[kAPCSignUpInclusionCriteriaStepIdentifier] = signUp;
    }
    
    APCScene *eligible = [self.delegate onboarding:self sceneOfType:kAPCSignUpEligibleStepIdentifier];
    if (eligible) {
        scenes[kAPCSignUpEligibleStepIdentifier] = eligible;
    }
    
    APCScene *ineligible = [self.delegate onboarding:self sceneOfType:kAPCSignUpIneligibleStepIdentifier];
    if (ineligible) {
        scenes[kAPCSignUpIneligibleStepIdentifier] = ineligible;
    }
    
    APCScene *permissionPriming = [self.delegate onboarding:self sceneOfType:kAPCSignUpPermissionsPrimingStepIdentifier];
    if (permissionPriming) {
        scenes[kAPCSignUpPermissionsPrimingStepIdentifier] = permissionPriming;
    }
    
    APCScene *generalInfo = [self.delegate onboarding:self sceneOfType:kAPCSignUpGeneralInfoStepIdentifier];
    if (generalInfo) {
        scenes[kAPCSignUpGeneralInfoStepIdentifier] = generalInfo;
    }
    
    APCScene *medical = [self.delegate onboarding:self sceneOfType:kAPCSignUpMedicalInfoStepIdentifier];
    if (medical) {
        scenes[kAPCSignUpMedicalInfoStepIdentifier] = medical;
    }
    
    APCScene *custom = [self.delegate onboarding:self sceneOfType:kAPCSignUpCustomInfoStepIdentifier];
    if (custom) {
        scenes[kAPCSignUpCustomInfoStepIdentifier] = custom;
    }
    
    APCScene *passcode = [self.delegate onboarding:self sceneOfType:kAPCSignUpPasscodeStepIdentifier];
    if (passcode) {
        scenes[kAPCSignUpPasscodeStepIdentifier] = passcode;
    }
    
    APCScene *permissions = [self.delegate onboarding:self sceneOfType:kAPCSignUpPermissionsStepIdentifier];
    if (permissions) {
        scenes[kAPCSignUpPermissionsStepIdentifier] = permissions;
    }
    
    APCScene *thankYou = [self.delegate onboarding:self sceneOfType:kAPCSignUpThankYouStepIdentifier];
    if (thankYou) {
        scenes[kAPCSignUpThankYouStepIdentifier] = thankYou;
    }
    
    APCScene *signIn = [self.delegate onboarding:self sceneOfType:kAPCSignInStepIdentifier];
    if (signIn) {
        scenes[kAPCSignInStepIdentifier] = signIn;
    }
    
    return scenes;
}

- (UIViewController *)nextScene {
    ORKTaskResult *result = nil;
    self.currentStep = [self.onboardingTask stepAfterStep:self.currentStep withResult:result];
    
    // If the task asks for a step that we don't have a scene for, we skip the step and move on to the next
    UIViewController *nextViewController = [self viewControllerForSceneIdentifier:self.currentStep.identifier];
    if (nextViewController) {
        return nextViewController;
    }
    if (_currentStep) {
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
    
    if (nil != _scenes[kAPCSignUpInclusionCriteriaStepIdentifier]) {
        _onboardingTask.inclusionCriteriaStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpInclusionCriteriaStepIdentifier];
    }
    if (nil != _scenes[kAPCSignUpEligibleStepIdentifier]) {
        _onboardingTask.eligibleStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpEligibleStepIdentifier];
    }
    if (nil != _scenes[kAPCSignUpIneligibleStepIdentifier]) {
        _onboardingTask.ineligibleStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpIneligibleStepIdentifier];
    }
    if (nil != _scenes[kAPCSignUpPermissionsPrimingStepIdentifier]) {
        _onboardingTask.permissionsPrimingStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpPermissionsPrimingStepIdentifier];
    }
    if (nil != _scenes[kAPCSignUpGeneralInfoStepIdentifier]) {
        _onboardingTask.generalInfoStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpGeneralInfoStepIdentifier];
    }
    if (nil != _scenes[kAPCSignUpMedicalInfoStepIdentifier]) {
        _onboardingTask.medicalInfoStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpMedicalInfoStepIdentifier];
    }
    if (nil != _scenes[kAPCSignUpCustomInfoStepIdentifier]) {
        _onboardingTask.customInfoStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpCustomInfoStepIdentifier];
    }
    if (nil != _scenes[kAPCSignUpPasscodeStepIdentifier]) {
        _onboardingTask.passcodeStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpPasscodeStepIdentifier];
    }
    if (nil != _scenes[kAPCSignUpPermissionsStepIdentifier]) {
        _onboardingTask.permissionsStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpPermissionsStepIdentifier];
    }
    if (nil != _scenes[kAPCSignUpThankYouStepIdentifier]) {
        _onboardingTask.thankyouStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpThankYouStepIdentifier];
    }
    if (nil != _scenes[kAPCSignInStepIdentifier]) {
        _onboardingTask.signInStep = [[ORKStep alloc] initWithIdentifier:kAPCSignInStepIdentifier];
    }
}

@end


@implementation APCScene

- (nonnull instancetype)initWithName:(NSString *)name inStoryboard:(NSString *)storyboardName {
    NSParameterAssert([name length] > 0);
    NSParameterAssert([storyboardName length] > 0);
    self = [super init];
    if (self) {
        self.name = name;
        self.storyboardName = storyboardName;
    }
    return self;
}

- (nonnull NSBundle *)bundle {
    if (!_bundle) {
        _bundle = [NSBundle bundleForClass:[self class]];
    }
    return _bundle;
}

- (nullable UIViewController *)instantiateViewController {
    return [[UIStoryboard storyboardWithName:self.storyboardName bundle:self.bundle] instantiateViewControllerWithIdentifier:self.name];
}

@end
