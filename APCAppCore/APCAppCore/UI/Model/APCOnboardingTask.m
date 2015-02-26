//
//  APCOnboardingTask.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCOnboardingTask.h"

NSString *const kAPCSignUpInclusionCriteriaStepIdentifier   = @"InclusionCriteria";
NSString *const kAPCSignUpEligibleStepIdentifier            = @"Eligible";
NSString *const kAPCSignUpIneligibleStepIdentifier          = @"Ineligible";
NSString *const kAPCSignUpGeneralInfoStepIdentifier         = @"GeneralInfo";
NSString *const kAPCSignUpMedicalInfoStepIdentifier         = @"MedicalInfo";
NSString *const kAPCSignUpCustomInfoStepIdentifier          = @"CustomInfo";
NSString *const kAPCSignUpPasscodeStepIdentifier            = @"Passcode";
NSString *const kAPCSignUpPermissionsStepIdentifier         = @"Permissions";
NSString *const kAPCSignInStepIdentifier                    = @"SignIn";
NSString *const kAPCSignUpPermissionsPrimingStepIdentifier  = @"PermissionsPriming";

@implementation APCOnboardingTask

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentStepNumber = 0;
    }
    
    return self;
}

#pragma mark - ORKTask methods

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *) __unused result
{
    ORKStep *nextStep;
    
    NSAssert(FALSE, @"Override this delegate method by using either APCSignUpTask or APCSignInTask");
    
    return nextStep;
}

- (ORKStep *)stepBeforeStep:(ORKStep *)step withResult:(ORKTaskResult *) __unused result
{
    ORKStep *prevStep;
    
    NSAssert(FALSE, @"Override this delegate method by using either APCSignUpTask or APCSignInTask");
    
    return prevStep;
}

- (NSString *)identifier
{
    return @"OnboaringTask";
}

#pragma mark - Getter methods

- (BOOL)permissionScreenSkipped
{
    BOOL skip = NO;
    
    if ([self.delegate respondsToSelector:@selector(numberOfServicesInPermissionsListForOnboardingTask:)]) {
        NSInteger count = [self.delegate numberOfServicesInPermissionsListForOnboardingTask:self];
        skip = (count == 0);
    }
    
    return skip;
}

- (APCUser *)user
{
    if ([self.delegate respondsToSelector:@selector(userForOnboardingTask:)]) {
        _user = [self.delegate userForOnboardingTask:self];
    }
    
    return _user;
}

#pragma mark Steps

- (ORKStep *)inclusionCriteriaStep
{
    if (!_inclusionCriteriaStep) {
        _inclusionCriteriaStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpInclusionCriteriaStepIdentifier];
    }
    
    return _inclusionCriteriaStep;
}

- (ORKStep *)eligibleStep
{
    if (!_eligibleStep) {
        _eligibleStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpEligibleStepIdentifier];
    }
    
    return _eligibleStep;
}

- (ORKStep *)ineligibleStep
{
    if (!_ineligibleStep) {
        _ineligibleStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpIneligibleStepIdentifier];
    }
    
    return _ineligibleStep;
}

- (ORKStep *)permissionsPrimingStep
{
    if (!_permissionsPrimingStep) {
        _permissionsPrimingStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpPermissionsPrimingStepIdentifier];
    }
    
    return _permissionsPrimingStep;
}

- (ORKStep *)generalInfoStep
{
    if (!_generalInfoStep) {
        _generalInfoStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpGeneralInfoStepIdentifier];
    }
    
    return _generalInfoStep;
}

- (ORKStep *)medicalInfoStep
{
    if (!_medicalInfoStep) {
        _medicalInfoStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpMedicalInfoStepIdentifier];
    }
    
    return _medicalInfoStep;
}

- (ORKStep *)customInfoStep
{
    if (!_customInfoStep) {
        _customInfoStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpCustomInfoStepIdentifier];
    }
    
    return _customInfoStep;
}

- (ORKStep *)passcodeStep
{
    if (!_passcodeStep) {
        _passcodeStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpPasscodeStepIdentifier];
    }
    
    return _passcodeStep;
}

- (ORKStep *)permissionsStep
{
    if (!_permissionsStep) {
        _permissionsStep = [[ORKStep alloc] initWithIdentifier:kAPCSignUpPermissionsStepIdentifier];
    }
    
    return _permissionsStep;
}

- (ORKStep *)signInStep
{
    if (!_signInStep) {
        _signInStep = [[ORKStep alloc] initWithIdentifier:kAPCSignInStepIdentifier];
    }
    
    return _signInStep;
}


@end
