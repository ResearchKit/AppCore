//
//  RKSTConsentReviewStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@class RKSTConsentDocument;
@class RKSTConsentSignature;

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTConsentReviewStep : RKSTStep

- (instancetype)initWithIdentifier:(NSString *)identifier
                         signature:(RKSTConsentSignature *)signature
                        inDocument:(RKSTConsentDocument *)consentDocument;

@property (nonatomic, strong, readonly) RKSTConsentDocument *consentDocument;
@property (nonatomic, strong, readonly) RKSTConsentSignature *signature;

/**
 * @brief User-visible description of reason for agreeing to consent.
 * 
 * @discussion This is presented in the confirmation dialog when obtaining
 * consent.
 *
 */
@property (nonatomic, copy) NSString *reasonForConsent;

@end
