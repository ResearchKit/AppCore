//
//  APCSignUpTask.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSignUpTask.h"

NSString *const kAPCSignUpInclusionCriteriaStepIdentifier = @"InclusionCriteria";
NSString *const kAPCSignUpEligibleStepIdentifier          = @"Eligible";
NSString *const kAPCSignUpIneligibleStepIdentifier        = @"Ineligible";
NSString *const kAPCSignUpGeneralInfoStepIdentifier       = @"GeneralInfo";
NSString *const kAPCSignUpMedicalInfoStepIdentifier       = @"MedicalInfo";
NSString *const kAPCSignUpCustomInfoStepIdentifier        = @"CustomInfo";
NSString *const kAPCSignUpPasscodeStepIdentifier          = @"Passcode";
NSString *const kAPCSignUpPermissionsStepIdentifier       = @"Permissions";

@interface APCSignUpTask ()

@property (nonatomic, strong) RKSTStep *inclusionCriteriaStep;

@property (nonatomic, strong) RKSTStep *eligibleStep;

@property (nonatomic, strong) RKSTStep *ineligibleStep;

@property (nonatomic, strong) RKSTStep *generalInfoStep;

@property (nonatomic, strong) RKSTStep *medicalInfoStep;

@property (nonatomic, strong) RKSTStep *customInfoStep;

@property (nonatomic, strong) RKSTStep *passcodeStep;

@property (nonatomic, strong) RKSTStep *permissionsStep;

@end

@implementation APCSignUpTask

- (RKSTStep *)stepAfterStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    RKSTStep *nextStep;
    
    if (!step) {
        nextStep = self.inclusionCriteriaStep;
    } else if ([step.identifier isEqualToString:kAPCSignUpInclusionCriteriaStepIdentifier]) {
        if (self.eligible) {
            nextStep = self.eligibleStep;
        } else{
            nextStep = self.ineligibleStep;
        }
    } else if ([step.identifier isEqualToString:kAPCSignUpEligibleStepIdentifier]) {
        nextStep = self.generalInfoStep;
    } else if ([step.identifier isEqualToString:kAPCSignUpGeneralInfoStepIdentifier]) {
        nextStep = self.medicalInfoStep;
    } else if ([step.identifier isEqualToString:kAPCSignUpMedicalInfoStepIdentifier]) {
        if (self.customInfoStep) {
            nextStep = self.customInfoStep;
        } else{
            nextStep = self.passcodeStep;
        }
    } else if ([step.identifier isEqualToString:kAPCSignUpCustomInfoStepIdentifier]) {
        nextStep = self.passcodeStep;
    } else if ([step.identifier isEqualToString:kAPCSignUpPasscodeStepIdentifier]) {
        nextStep = self.permissionsStep;
    }
    
    return nextStep;
}

- (RKSTStep *)inclusionCriteriaStep
{
    if (!_inclusionCriteriaStep) {
        _inclusionCriteriaStep = [[RKSTStep alloc] initWithIdentifier:kAPCSignUpInclusionCriteriaStepIdentifier];
    }
    
    return _inclusionCriteriaStep;
}

- (RKSTStep *)eligibleStep
{
    if (!_eligibleStep) {
        _eligibleStep = [[RKSTStep alloc] initWithIdentifier:kAPCSignUpEligibleStepIdentifier];
    }
    
    return _eligibleStep;
}

- (RKSTStep *)ineligibleStep
{
    if (!_ineligibleStep) {
        _ineligibleStep = [[RKSTStep alloc] initWithIdentifier:kAPCSignUpIneligibleStepIdentifier];
    }
    
    return _ineligibleStep;
}

- (RKSTStep *)generalInfoStep
{
    if (!_generalInfoStep) {
        _generalInfoStep = [[RKSTStep alloc] initWithIdentifier:kAPCSignUpGeneralInfoStepIdentifier];
    }
    
    return _generalInfoStep;
}

- (RKSTStep *)medicalInfoStep
{
    if (!_medicalInfoStep) {
        _medicalInfoStep = [[RKSTStep alloc] initWithIdentifier:kAPCSignUpMedicalInfoStepIdentifier];
    }
    
    return _medicalInfoStep;
}

- (RKSTStep *)customInfoStep
{
    if (!_customInfoStep) {
        _customInfoStep = [[RKSTStep alloc] initWithIdentifier:kAPCSignUpCustomInfoStepIdentifier];
    }
    
    return _customInfoStep;
}

- (RKSTStep *)passcodeStep
{
    if (!_passcodeStep) {
        _passcodeStep = [[RKSTStep alloc] initWithIdentifier:kAPCSignUpPasscodeStepIdentifier];
    }
    
    return _passcodeStep;
}

- (RKSTStep *)permissionsStep
{
    if (!_permissionsStep) {
        _permissionsStep = [[RKSTStep alloc] initWithIdentifier:kAPCSignUpPermissionsStepIdentifier];
    }
    
    return _permissionsStep;
}

@end
