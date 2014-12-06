//
//  APCOnboardingTask.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 12/5/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>

@class APCUser;

FOUNDATION_EXPORT NSString *const kAPCSignUpInclusionCriteriaStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignUpEligibleStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignUpIneligibleStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignUpGeneralInfoStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignUpMedicalInfoStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignUpCustomInfoStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignUpPasscodeStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignUpPermissionsStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignInStepIdentifier;

@protocol APCOnboardingTaskDelegate;

@interface APCOnboardingTask : NSObject <RKSTTask>

@property (nonatomic, weak) id <APCOnboardingTaskDelegate> delegate;

@property (nonatomic) BOOL eligible;

@property (nonatomic) BOOL customStepIncluded;

@property (nonatomic) APCUser *user;

/**
 *  When the list of Services required in zero, we can skip
 */
@property (nonatomic,readonly) BOOL permissionScreenSkipped;

@property (nonatomic) NSInteger currentStepNumber;

@property (nonatomic) NSInteger numberOfSteps;

@property (nonatomic, strong) RKSTStep *inclusionCriteriaStep;

@property (nonatomic, strong) RKSTStep *eligibleStep;

@property (nonatomic, strong) RKSTStep *ineligibleStep;

@property (nonatomic, strong) RKSTStep *generalInfoStep;

@property (nonatomic, strong) RKSTStep *medicalInfoStep;

@property (nonatomic, strong) RKSTStep *customInfoStep;

@property (nonatomic, strong) RKSTStep *passcodeStep;

@property (nonatomic, strong) RKSTStep *permissionsStep;

@property (nonatomic, strong) RKSTStep *signInStep;

@end

@protocol APCOnboardingTaskDelegate <NSObject>

- (APCUser *)userForOnboardingTask:(APCOnboardingTask *)task;

- (NSInteger)numberOfServicesInPermissionsListForOnboardingTask:(APCOnboardingTask *)task;

@end