//
//  APCSignInTask.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCSignInTask.h"
#import "APCUser.h"

static NSInteger const kMinimumNumberOfSteps = 2; //MedicalInfo + Passcode

@interface APCSignInTask ()

@end

@implementation APCSignInTask

#pragma mark - ORKTask methods

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *) __unused result
{
    ORKStep *nextStep;
    
    if (!step) {
        nextStep = self.signInStep;
    } else if ([step.identifier isEqualToString:kAPCSignInStepIdentifier]) {
        nextStep = self.permissionsPrimingStep;
    } else if ([step.identifier isEqualToString:kAPCSignUpPermissionsPrimingStepIdentifier]) {
        if (self.user.isSecondaryInfoSaved) {
            nextStep = nil;
        } else{
            nextStep = self.medicalInfoStep;
            self.currentStepNumber += 1;
        }
        
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
    
    if ([step.identifier isEqualToString:kAPCSignUpMedicalInfoStepIdentifier]) {
        prevStep = nil;
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
    return @"SignInTask";
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
