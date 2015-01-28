// 
//  APCOnboarding.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCOnboarding.h"
#import "APCEligibleViewController.h"
#import "APCInEligibleViewController.h"
#import "APCSignUpGeneralInfoViewController.h"
#import "APCSignUpMedicalInfoViewController.h"
#import "APCSignupPasscodeViewController.h"
#import "APCSignUpPermissionsViewController.h"
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
        scene.name = NSStringFromClass([APCSignInViewController class]);
        scene.storyboardName = kOnboardingStoryboardName;
        scene.bundle = [NSBundle appleCoreBundle];
        
        [scenes setObject:scene forKey:kAPCSignInStepIdentifier];
    }
    
    return scenes;
}

- (UIViewController *)nextScene
{
    
    self.currentStep = [self.onboardingTask stepAfterStep:self.currentStep withResult:nil];
    
    UIViewController *nextViewController = [self viewControllerForSceneIdentifier:self.currentStep.identifier];
    
    return nextViewController;
}

- (void)popScene
{
    self.currentStep = [self.onboardingTask stepBeforeStep:self.currentStep withResult:nil];
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
