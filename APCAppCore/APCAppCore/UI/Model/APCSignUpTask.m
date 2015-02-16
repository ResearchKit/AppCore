// 
//  APCSignUpTask.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCSignUpTask.h"
#import "APCUser.h"

static NSInteger const kMinimumNumberOfSteps = 3; //Gen Info + MedicalInfo + Passcode

@implementation APCSignUpTask

#pragma mark - ORKTask methods

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *) __unused result
{
    ORKStep *nextStep;
    
    if (!step) {
        nextStep = self.inclusionCriteriaStep;
    } else if ([step.identifier isEqualToString:kAPCSignUpInclusionCriteriaStepIdentifier]) {
        if (self.eligible) {
            nextStep = self.eligibleStep;
        } else{
            nextStep = self.ineligibleStep;
        }
    } else if ([step.identifier isEqualToString:kAPCSignUpEligibleStepIdentifier]) {
        self.currentStepNumber += 1;
        nextStep = self.generalInfoStep;
        
    } else if ([step.identifier isEqualToString:kAPCSignUpGeneralInfoStepIdentifier]) {
        self.currentStepNumber += 1;
        nextStep = self.medicalInfoStep;
        
    } else if ([step.identifier isEqualToString:kAPCSignUpMedicalInfoStepIdentifier]) {
        if (self.customStepIncluded) {
            nextStep = self.customInfoStep;
        } else{
            nextStep = self.passcodeStep;
            self.user.secondaryInfoSaved = YES;
        }
        self.currentStepNumber += 1;
    } else if ([step.identifier isEqualToString:kAPCSignUpCustomInfoStepIdentifier]) {
        nextStep = self.passcodeStep;
        self.user.secondaryInfoSaved = YES;
        self.currentStepNumber += 1;
    } else if ([step.identifier isEqualToString:kAPCSignUpPasscodeStepIdentifier]) {
        if (self.permissionScreenSkipped) {
            nextStep = nil;
        } else {
            nextStep = self.permissionsStep;
            self.currentStepNumber += 1;
        }
    }
    
    return nextStep;
}

- (ORKStep *)stepBeforeStep:(ORKStep *)step withResult:(ORKTaskResult *) __unused result
{
    ORKStep *prevStep;
    
    if ([step.identifier isEqualToString:kAPCSignUpInclusionCriteriaStepIdentifier]) {
        prevStep = nil;
    } else if ([step.identifier isEqualToString:kAPCSignUpEligibleStepIdentifier]) {
        prevStep = self.inclusionCriteriaStep;
    } else if ([step.identifier isEqualToString:kAPCSignUpIneligibleStepIdentifier]) {
        prevStep = self.inclusionCriteriaStep;
    } else if ([step.identifier isEqualToString:kAPCSignUpGeneralInfoStepIdentifier]) {
        prevStep = self.eligibleStep;
    } else if ([step.identifier isEqualToString:kAPCSignUpMedicalInfoStepIdentifier]) {
        prevStep = self.generalInfoStep;
        self.currentStepNumber -= 1;
    } else if ([step.identifier isEqualToString:kAPCSignUpCustomInfoStepIdentifier]) {
        prevStep = self.medicalInfoStep;
        self.currentStepNumber -= 1;
    } else if ([step.identifier isEqualToString:kAPCSignUpPasscodeStepIdentifier]) {
        if (self.customStepIncluded) {
            prevStep = self.customInfoStep;
        } else {
            prevStep = self.medicalInfoStep;
        }
        self.currentStepNumber -= 1;
    } else if ([step.identifier isEqualToString:kAPCSignUpPermissionsStepIdentifier]) {
        prevStep = self.passcodeStep;
        self.currentStepNumber -= 1;
    }
    
    return prevStep;
}

- (NSString *)identifier
{
    return @"SignUpTask";
}

#pragma mark - Overriden Methods

- (NSInteger)numberOfSteps
{
    NSInteger count = kMinimumNumberOfSteps;
    
    if (self.customStepIncluded) {
        count += 1;
    }
    if (!self.permissionScreenSkipped) {
        count += 1;
    }
    
    return count;
}

@end
