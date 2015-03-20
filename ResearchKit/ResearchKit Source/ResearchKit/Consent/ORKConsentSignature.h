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

#import <UIKit/UIKit.h>
#import <ResearchKit/ResearchKit.h>

ORK_ASSUME_NONNULL_BEGIN

/**
 The `ORKConsentSignature` class represents a signature on an `ORKConsentDocument`.
 This could either be the signature of an investigator, possibly pre-filled with
 an image, date, and first and last name; or it could be the details of a signature
 that needs to be collected.
 
 Signatures can be collected using `ORKConsentReviewStep`. Once a signature has
 been obtained, producing an `ORKConsentSignatureResult`, the resulting signature
 can be substituted into a copy of the document, for generating a PDF.
 
 Alternatively, the details of the signature obtained can be uploaded to a server
 for PDF generation elsewhere or simply as a record of having obtained consent.
 
 This signature object has no concept of a cryptographic signature -- it is merely
 a record of any input the user made during an `ORKConsentReviewStep`. It also
 does not verify nor vouch for user identity.
 */
ORK_CLASS_AVAILABLE
@interface ORKConsentSignature : NSObject <NSSecureCoding, NSCopying>

/// @name Factory methods

/**
 Returns a fully populated signature.
 
 This factory method should be used when including the investigator's signature pre-populated in a
 generated consent document.
 
 @param title               Title of the signatory.
 @param dateFormatString    Format string to use when formatting the date of signature.
 @param identifier          Identifier of the signature, unique within this document.
 @param givenName           The "given" name of the signatory.
 @param familyName          The "family" name of the signatory.
 @param signatureImage      An image of the signature.
 @param signatureDate       Date at which the signature was obtained, represented as a string.
 */
+ (ORKConsentSignature *)signatureForPersonWithTitle:(ORK_NULLABLE NSString *)title
                                    dateFormatString:(ORK_NULLABLE NSString *)dateFormatString
                                          identifier:(NSString *)identifier
                                           givenName:(ORK_NULLABLE NSString *)givenName
                                          familyName:(ORK_NULLABLE NSString *)familyName
                                      signatureImage:(ORK_NULLABLE UIImage *)signatureImage
                                          dateString:(ORK_NULLABLE NSString *)signatureDate;

/**
 Returns a signature to be collected.
 
 This factory method should be used when representing a request to collect a signature for an
 `ORKConsentReviewStep`.
 
 @param title               Title of the signatory.
 @param dateFormatString    Format string to use when formatting the date of signature.
 @param identifier          Identifier of the signature, unique within this document.
 */
+ (ORKConsentSignature *)signatureForPersonWithTitle:(ORK_NULLABLE NSString *)title
                                    dateFormatString:(ORK_NULLABLE NSString *)dateFormatString
                                          identifier:(NSString *)identifier;

/// @name Consent review configuration

/**
 A boolean value indicating whether the user needs to enter their name during consent review.
 
 This property defaults to `YES`. In `ORKConsentReviewStep`, if this is `NO` on the signature,
 the name entry screen is not displayed.
 */
@property (nonatomic, assign) BOOL requiresName;

/**
 A boolean value indicating whether the user needs to draw a signature during consent review.
 
 This property defaults to `YES`. In `ORKConsentReviewStep`, if this property is `NO`, the signature entry
 screen is not shown.
 */
@property (nonatomic, assign) BOOL requiresSignatureImage;


/// @name Identifying signatories

/**
 The identifier for this signature.
 
 The identifier should be unique in the document. It can be used to find or
 replace a specific signature on `ORKConsentDocument`. It is also reproduced on
 the `ORKConsentSignatureResult` produced by an `ORKConsentReviewStep`.
 */
@property (nonatomic, copy) NSString *identifier;

/// @name Personal information.

/// Title of the signatory.
@property (nonatomic, copy, ORK_NULLABLE) NSString *title;

/// Given name (first name in Western languages)
@property (nonatomic, copy, ORK_NULLABLE) NSString *givenName;

/// Family name (last name in Western languages)
@property (nonatomic, copy, ORK_NULLABLE) NSString *familyName;

/// Image of the signature, if any.
@property (nonatomic, copy, ORK_NULLABLE) UIImage *signatureImage;

/// Date string representing the signature.
@property (nonatomic, copy, ORK_NULLABLE) NSString *signatureDate;

/**
 Date format string to be used when producing a date string for the PDF
 or consent review.
 
 For example, @"yyyy-MM-dd 'at' HH:mm". If `nil`,
 the current locale is used.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *signatureDateFormatString;

@end

ORK_ASSUME_NONNULL_END
