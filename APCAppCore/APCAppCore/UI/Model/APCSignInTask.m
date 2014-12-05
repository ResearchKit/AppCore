//
//  APCSignInTask.m
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 12/4/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSignInTask.h"

@interface APCSignInTask ()

@property (nonatomic, strong) RKSTStep *medicalInfoStep;

@property (nonatomic, strong) RKSTStep *customInfoStep;

@property (nonatomic, strong) RKSTStep *passcodeStep;

@property (nonatomic, strong) RKSTStep *permissionsStep;

@end

@implementation APCSignInTask

#pragma mark - RKSTTask methods

- (RKSTStep *)stepAfterStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    RKSTStep *nextStep;
    
    if (!step) {
        if (!self.secondaryInfoSaved) {
            nextStep = self.medicalInfoStep;
        } else{
            nextStep = self.passcodeStep;
        }
    } else if ([step.identifier isEqualToString:kAPCSignUpMedicalInfoStepIdentifier]) {
        if (self.customStepIncluded) {
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

- (RKSTStep *)stepBeforeStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    RKSTStep *prevStep;
    
    if ([step.identifier isEqualToString:kAPCSignUpMedicalInfoStepIdentifier]) {
        prevStep = nil;
    } else if ([step.identifier isEqualToString:kAPCSignUpCustomInfoStepIdentifier]) {
        prevStep = self.medicalInfoStep;
    } else if ([step.identifier isEqualToString:kAPCSignUpPasscodeStepIdentifier]) {
        if (!self.secondaryInfoSaved) {
            if (self.customStepIncluded) {
                prevStep = self.customInfoStep;
            } else {
                prevStep = self.medicalInfoStep;
            }
        } else {
            prevStep = nil;
        }
    } else if ([step.identifier isEqualToString:kAPCSignUpPermissionsStepIdentifier]) {
        prevStep = self.passcodeStep;
    }
    
    return prevStep;
}

- (NSString *)identifier
{
    return @"SignInTask";
}

#pragma mark - Getter methods

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
