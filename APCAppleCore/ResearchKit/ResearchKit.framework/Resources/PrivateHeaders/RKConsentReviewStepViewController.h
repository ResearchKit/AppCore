//
//  RKConsentReviewStepViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@interface RKConsentReviewStepViewController : RKStepViewController

- (instancetype)initWithConsentReviewStep:(RKConsentReviewStep *)step result:(RKConsentSignatureResult *)result;

@end
