//
//  RKSTConsentReviewStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@class RKSTConsentDocument;
@class RKSTConsentSignature;

@interface RKSTConsentReviewStep : RKSTStep

- (instancetype)initWithSignature:(RKSTConsentSignature *)signature inDocument:(RKSTConsentDocument *)consentDocument;

@property (nonatomic, strong, readonly) RKSTConsentDocument *consentDocument;
@property (nonatomic, strong, readonly) RKSTConsentSignature *signature;


@end
