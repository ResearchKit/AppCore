//
//  RKConsentReviewStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@class RKConsentDocument;
@class RKConsentSignature;

@interface RKConsentReviewStep : RKStep

- (instancetype)initWithSignature:(RKConsentSignature *)signature inDocument:(RKConsentDocument *)consentDocument;

@property (nonatomic, strong, readonly) RKConsentDocument *consentDocument;
@property (nonatomic, strong, readonly) RKConsentSignature *signature;

/// Title to be shown on the consent review screen
@property (nonatomic, copy) NSString *title;

/// Prompt to be shown on the consent review screen
@property (nonatomic, copy) NSString *prompt;

@end
