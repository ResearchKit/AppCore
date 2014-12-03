//
//  APCOnboarding.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCOnboarding.h"
#import "APCEligibleViewController.h"
#import "APCInEligibleViewController.h"
#import "APCSignUpGeneralInfoViewController.h"
#import "APCSignUpMedicalInfoViewController.h"
#import "APCSignupPasscodeViewController.h"
#import "APCSignUpPermissionsViewController.h"
#import "NSBundle+Helper.h"

static NSString * const kOnboardingStoryboardName = @"APCOnboarding";

@implementation APCOnboarding

- (instancetype)initWithDelegate:(id)object
{
    self = [super init];
    if (self) {
        _signUpTask = [APCSignUpTask new];
        _delegate = object;
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
            self.signUpTask.customStepIncluded = YES;
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
    
    return scenes;
}

- (UIViewController *)nextScene
{
    self.currentStep = [self.signUpTask stepAfterStep:self.currentStep withResult:nil];
    
    UIViewController *nextViewController = [self viewControllerForSceneIdentifier:self.currentStep.identifier];
    
    return nextViewController;
}

- (void)popScene
{
    self.currentStep = [self.signUpTask stepBeforeStep:self.currentStep withResult:nil];
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
