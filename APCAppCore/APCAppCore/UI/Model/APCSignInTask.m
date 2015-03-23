// 
//  APCSignInTask.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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
    } else if ([step.identifier isEqualToString:kAPCSignUpPermissionsStepIdentifier]) {
        nextStep = self.thankyouStep;
        self.currentStepNumber += 1;
    } else if ([step.identifier isEqualToString:kAPCSignUpThankYouStepIdentifier]) {
        nextStep = nil;
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
