//
//  APCOnboarding.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "APCSignUpTask.h"
#import <ResearchKit/ResearchKit.h>

typedef NS_ENUM(NSUInteger, APCOnboardingScreenType) {
    kAPCOnboardingScreenTypeStudyOverview,
    kAPCOnboardingScreenTypeStudyDetails,
    kAPCOnboardingScreenTypeSignIn,
    kAPCOnboardingScreenTypeForgotPassword,
    kAPCOnboardingScreenTypeInclusionCriteria,
    kAPCOnboardingScreenTypeEligible,
    kAPCOnboardingScreenTypeIneligible,
    kAPCOnboardingScreenTypeShare,
    kAPCOnboardingScreenTypeGeneralInfo,
    kAPCOnboardingScreenTypeMedicalInfo,
    kAPCOnboardingScreenTypePasscode,
    kAPCOnboardingScreenTypePermissions
};

@interface APCOnboarding : NSObject

@property (nonatomic, strong) APCSignUpTask *signUpTask;

@property (nonatomic, strong) RKSTStep *currentStep;

@property (nonatomic, strong) NSArray *order;

- (UIViewController *)viewControllerForScreenType:(APCOnboardingScreenType)screenType;

- (void)setViewControllerWithScreenType:(APCOnboardingScreenType)screenType fromStoryboard:(UIStoryboard *)stodyboard inBundle:(NSBundle *)bundle;

- (UIViewController *)nextScreen;

@end
