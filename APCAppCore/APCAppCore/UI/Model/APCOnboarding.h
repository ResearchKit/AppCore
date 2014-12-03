// 
//  APCOnboarding.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "APCSignUpTask.h"
#import <ResearchKit/ResearchKit.h>

@protocol APCOnboardingDelegate;
@class APCScene;

@interface APCOnboarding : NSObject

@property (nonatomic, strong) APCSignUpTask *signUpTask;

@property (nonatomic, strong) RKSTStep *currentStep;

@property (nonatomic, strong) NSMutableDictionary *scenes;

@property (nonatomic, weak) id <APCOnboardingDelegate> delegate;

- (instancetype)initWithDelegate:(id)object;

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
