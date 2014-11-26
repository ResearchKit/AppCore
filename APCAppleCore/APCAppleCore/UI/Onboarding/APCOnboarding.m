//
//  APCOnboarding.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCOnboarding.h"

@implementation APCOnboarding

- (instancetype)init
{
    self = [super init];
    if (self) {
        _signUpTask = [APCSignUpTask new];
    }
    
    return self;
}

- (UIViewController *)nextScreen
{
    self.currentStep = [self.signUpTask stepAfterStep:self.currentStep withResult:nil];
    
    
}

- (UIViewController *)viewControllerForScreenType:(APCOnboardingScreenType)screenType
@end
