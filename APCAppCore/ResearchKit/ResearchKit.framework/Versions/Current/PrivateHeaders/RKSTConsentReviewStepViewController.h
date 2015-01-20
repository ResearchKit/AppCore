//
//  RKSTConsentReviewStepViewController.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTConsentReviewStepViewController : RKSTStepViewController

- (instancetype)initWithConsentReviewStep:(RKSTConsentReviewStep *)step result:(RKSTConsentSignatureResult *)result;

@end
