//
//  ORKConsentReviewStepViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

ORK_CLASS_AVAILABLE
@interface ORKConsentReviewStepViewController : ORKStepViewController

- (instancetype)initWithConsentReviewStep:(ORKConsentReviewStep *)step result:(ORKConsentSignatureResult *)result;

@end
