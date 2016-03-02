//
//  APCOptionalStepViewController.m
//  APCAppCore
//
//  Created by Shannon Young on 3/2/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

#import "APCOptionalStepViewController.h"

@interface APCDummyStep : ORKStep
@end
@implementation APCDummyStep
@end

@implementation APCOptionalStepViewController

- (void)viewWillAppear:(BOOL)animated {
    
    // ResearchKit ORKStepViewController is designed to throw an assert if the step view controller
    // is used WITHOUT a step assigned. Because this view controller can be used without a step
    // (but needs to inherit from ORKStepViewController to be used by the ORKTaskViewController)
    // add a step here before calling through to super.
    if (self.step==nil) {
        self.step = [[APCDummyStep alloc] initWithIdentifier:@"NotUsed"];
    }
    
    [super viewWillAppear:animated];
}

@end

