// 
//  APCSignUpTask.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>

FOUNDATION_EXPORT NSString *const kAPCSignUpInclusionCriteriaStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignUpEligibleStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignUpIneligibleStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignUpGeneralInfoStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignUpMedicalInfoStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignUpCustomInfoStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignUpPasscodeStepIdentifier;
FOUNDATION_EXPORT NSString *const kAPCSignUpPermissionsStepIdentifier;

@interface APCSignUpTask : NSObject <RKSTTask>

@property BOOL eligible;

@property BOOL customStepIncluded;

@end
