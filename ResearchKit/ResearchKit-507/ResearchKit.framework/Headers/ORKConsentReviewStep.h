//
//  ORKConsentReviewStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@class ORKConsentDocument;
@class ORKConsentSignature;

ORK_CLASS_AVAILABLE
@interface ORKConsentReviewStep : ORKStep

- (instancetype)initWithIdentifier:(NSString *)identifier
                         signature:(ORKConsentSignature *)signature
                        inDocument:(ORKConsentDocument *)consentDocument;

@property (nonatomic, strong, readonly) ORKConsentDocument *consentDocument;
@property (nonatomic, strong, readonly) ORKConsentSignature *signature;

/**
 * @brief User-visible description of reason for agreeing to consent.
 * 
 * @discussion This is presented in the confirmation dialog when obtaining
 * consent.
 *
 */
@property (nonatomic, copy) NSString *reasonForConsent;

@end
