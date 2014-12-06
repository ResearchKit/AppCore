//
//  APCOnboardingTask.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCOnboardingTask.h"

NSString *const kAPCSignUpInclusionCriteriaStepIdentifier = @"InclusionCriteria";
NSString *const kAPCSignUpEligibleStepIdentifier          = @"Eligible";
NSString *const kAPCSignUpIneligibleStepIdentifier        = @"Ineligible";
NSString *const kAPCSignUpGeneralInfoStepIdentifier       = @"GeneralInfo";
NSString *const kAPCSignUpMedicalInfoStepIdentifier       = @"MedicalInfo";
NSString *const kAPCSignUpCustomInfoStepIdentifier        = @"CustomInfo";
NSString *const kAPCSignUpPasscodeStepIdentifier          = @"Passcode";
NSString *const kAPCSignUpPermissionsStepIdentifier       = @"Permissions";
NSString *const kAPCSignInStepIdentifier                  = @"SignIn";

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

#pragma mark - RKSTTask methods

- (RKSTStep *)stepAfterStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    RKSTStep *nextStep;
    
    NSAssert(FALSE, @"Override this delegate method by using either APCSignUpTask or APCSignInTask");
    
    return nextStep;
}

- (RKSTStep *)stepBeforeStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    RKSTStep *prevStep;
    
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
    BOOL skip;
    
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

- (RKSTStep *)signInStep
{
    if (!_signInStep) {
        _signInStep = [[RKSTStep alloc] initWithIdentifier:kAPCSignInStepIdentifier];
    }
    
    return _signInStep;
}


@end
