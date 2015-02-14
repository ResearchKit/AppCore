//
//  RKConsentReviewStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@class RKConsentDocument;
@class RKConsentSignature;

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKConsentReviewStep : RKStep

- (instancetype)initWithIdentifier:(NSString *)identifier
                         signature:(RKConsentSignature *)signature
                        inDocument:(RKConsentDocument *)consentDocument;

@property (nonatomic, strong, readonly) RKConsentDocument *consentDocument;
@property (nonatomic, strong, readonly) RKConsentSignature *signature;

/**
 * @brief User-visible description of reason for agreeing to consent.
 * 
 * @discussion This is presented in the confirmation dialog when obtaining
 * consent.
 *
 */
@property (nonatomic, copy) NSString *reasonForConsent;

@end
