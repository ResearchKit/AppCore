//
//  APCOnboardingTask.h
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
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
FOUNDATION_EXPORT NSString *const kAPCSignUpPermissionsPrimingStepIdentifier;

@protocol APCOnboardingTaskDelegate;

@interface APCOnboardingTask : NSObject <ORKTask>

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

@property (nonatomic, strong) ORKStep *inclusionCriteriaStep;

@property (nonatomic, strong) ORKStep *eligibleStep;

@property (nonatomic, strong) ORKStep *ineligibleStep;

@property (nonatomic, strong) ORKStep *permissionsPrimingStep;

@property (nonatomic, strong) ORKStep *generalInfoStep;

@property (nonatomic, strong) ORKStep *medicalInfoStep;

@property (nonatomic, strong) ORKStep *customInfoStep;

@property (nonatomic, strong) ORKStep *passcodeStep;

@property (nonatomic, strong) ORKStep *permissionsStep;

@property (nonatomic, strong) ORKStep *signInStep;

@end

@protocol APCOnboardingTaskDelegate <NSObject>

- (APCUser *)userForOnboardingTask:(APCOnboardingTask *)task;

- (NSInteger)numberOfServicesInPermissionsListForOnboardingTask:(APCOnboardingTask *)task;

@end