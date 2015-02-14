// 
//  APCOnboarding.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ResearchKit/ResearchKit.h>

#import "APCSignUpTask.h"
#import "APCSignInTask.h"

typedef NS_ENUM(NSUInteger, APCOnboardingTaskType) {
    kAPCOnboardingTaskTypeSignUp,
    kAPCOnboardingTaskTypeSignIn,
};

@protocol APCOnboardingDelegate;
@class APCScene;

@interface APCOnboarding : NSObject

@property (nonatomic, readonly) APCOnboardingTask *onboardingTask;

@property (nonatomic, strong) RKSTStep *currentStep;

@property (nonatomic, strong) NSMutableDictionary *scenes;

@property (nonatomic, strong) NSMutableDictionary *sceneData;

@property (nonatomic, weak) id <APCOnboardingDelegate> delegate;

@property (nonatomic, readonly) APCOnboardingTaskType taskType;

- (instancetype)initWithDelegate:(id)object taskType:(APCOnboardingTaskType)taskType;

- (UIViewController *)viewControllerForSceneIdentifier:(NSString *)identifier;

- (void)setScene:(APCScene *)scene forIdentifier:(NSString *)identifier;

- (UIViewController *)nextScene;

- (void)popScene;

@end

@protocol APCOnboardingDelegate <NSObject>

@required

- (APCScene *)inclusionCriteriaSceneForOnboarding:(APCOnboarding *)onboarding;

@optional

- (APCScene *)customInfoSceneForOnboarding:(APCOnboarding *)onboarding;

@end

/*************************************/

@interface APCScene : NSObject

@property (nonatomic, strong) NSString *name; //Refers to StoryboardID
@property (nonatomic, strong) NSString *storyboardName;
@property (nonatomic, strong) NSBundle *bundle;

@end
