//
//  APHNavigationFooter.m
//  mPowerSDK
//
//  Created by Shannon Young on 2/23/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

#import "APCNavigationFooter.h"
#import "APCLocalization.h"
#import <ResearchKit/ResearchKit.h>

@implementation APCNavigationFooter

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {

    // Add continue button and constraints
    _continueButton = [[ORKContinueButton alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"APC_NEXT_BUTTON", nil, APCBundle(), @"Next", "Default title for the next button") isDoneButton:NO];
    _continueButton.exclusiveTouch = YES;
    _continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_continueButton addTarget:self action:@selector(continueButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_continueButton];
    
    NSMutableArray *constraints = [NSMutableArray new];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_continueButton
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_continueButton
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:-20.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_continueButton
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)continueButtonTapped {
    [self.delegate goForward];
}

@end
