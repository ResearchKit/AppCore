/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import <ResearchKit/ResearchKit.h>

ORK_ASSUME_NONNULL_BEGIN

@class ORKConsentDocument;
@class ORKConsentSignature;


/**
 The `ORKConsentReviewStep` class is used to represent a consent review process.
 This process consists of several sub-screens:
 
 1. Consent document review. This displays the consent document for review. The user
 must "Agree" to the consent in order to proceed.
 
 2. Name entry (optional). The user is asked to enter their first and last name. To
 request name entry, the step's `signature` property must be set, the signature's
 `requiresName` property must be YES.
 
 3. Signature (optional). The user is asked to draw their signature with a finger.
 To request signature entry, the step's `signature` property must be set, and the
 signature's `requiresSignature
 
 The content for the consent comes from a consent document (`ORKConsentDocument`)
 provided during initialization.
 
 To use a consent review step, configure it and include it in a task. Then
 present the task with in a task view controller.
 */
ORK_CLASS_AVAILABLE
@interface ORKConsentReviewStep : ORKStep

/// @name Initialization.

/**
 Convenience initializer.

 @param identifier      The identifier for this step.
 @param signature       Signature to be collected, if any.
 @param consentDocument Consent document to be reviewed.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                         signature:(ORK_NULLABLE ORKConsentSignature *)signature
                        inDocument:(ORKConsentDocument *)consentDocument;

/// @name Properties

/**
 The consent document to be reviewed (read-only).
 */
@property (nonatomic, strong, readonly) ORKConsentDocument *consentDocument;

/**
 The signature object from the document which should be collected (read-only).
 
 If the signature is `nil`, then neither name nor finger scrawl are collected.
 Otherwise, the requiresName and requiresSignatureImage properties of the 
 signature determine which screens are presented.
 
 The identifier of the signature is expected to match one of the signature objects on
 the consent document.
 */
@property (nonatomic, strong, readonly, ORK_NULLABLE) ORKConsentSignature *signature;

/**
 A user-visible description of reason for agreeing to consent.
 
 This is presented in the confirmation dialog when obtaining
 consent.
 
 This string should be localized to the user's language.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *reasonForConsent;

@end

ORK_ASSUME_NONNULL_END
