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
#import <ResearchKit/ORKConsentSignature.h>

ORK_ASSUME_NONNULL_BEGIN

/**
 The `ORKConsentDocument` class represents the content of an informed consent
 document, such as might be used to obtain informed consent from participants
 in a medical or other research study. ResearchKit uses an `ORKConsentDocument`
 to provide content for `ORKVisualConsentStep` and for `ORKConsentReviewStep`.
 
 The `sections` of the `ORKConsentDocument` are instances of `ORKConsentSection`.
 When an `ORKConsentDocument` is attached to an `ORKVisualConsentStep`, these
 sections provide the content for the visual consent screens, and for the
 "Learn More" pages accessible from them. When attached to an `ORKConsentReviewStep`,
 in some circumstances they provide the content for the consent document to
 be reviewed.
 
 In simple cases, it may be that all the sections in the consent may
 map to visual consent screens, and the formatting of the consent document may
 be sufficiently simple that it can be presented with only section headers and
 simple formatting. In this case, simply specifying the sections and
 the signatures can be sufficient to generate a document that to be signed.
 In that case there is no need to populate the `htmlReviewContent` property,
 and, when the consent review step is completed, the signatures can be
 populated into a copy of the document and a PDF generated.
 
 In more complex cases, it may be that the visual consent sections bear little
 relation to the formal consent document. In that case, the formal consent
 document content should be populated into `htmlReviewContent`. This will 
 override any content that would otherwise be generated from the consent
 sections.
 
 Normally the document should be in the user's language, and all the content of
 the document should be appropriately localized to that language.
 */
ORK_CLASS_AVAILABLE
@interface ORKConsentDocument : NSObject <NSSecureCoding, NSCopying>

/// @name Properties

/**
 The document's title.
 
 This appears only in the generated PDF for review, and is not used in the
 visual consent process.
 
 This string should be localized to the document language.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *title;

/// @name Visual consent sections

/**
 The sections to be in printed in the PDF file and and/or to be presented in the
 visual consent sequence.
 
 All sections appear in the animated process except those sections with 
 type `ORKConsentSectionTypeOnlyInDocument`.
 
 If the `htmlReviewContent` property is not set, this content is also used to
 populate the document for review in `ORKConsentReviewStep`.
 
 The PDF file contains all sections.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSArray /* <ORKConsentSection *> */ *sections;

/// @name Signatures for consent review

/**
 Title to be rendered on the signature page of the generated PDF.
 
 Ignored for visual consent. Ignored if `htmlReviewContent` is supplied.
 
 This string should be localized to the document language.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *signaturePageTitle;

/**
 Content to be rendered below the title on the signature page of the generated PDF.
 
 Ignored for visual consent. Ignored if `htmlReviewContent` is supplied.
 
 This string should be localized to the document language.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *signaturePageContent;

/**
 The set of signatures required or pre-populated on the document.
 
 To add a signature to the document after consent review, the signatures array
 needs to be modified to incorporate the new signature content, prior to PDF
 generation.
 
 See `[ORKConsentSignatureResult applyToDocument:]`.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSArray /* <ORKConsentSignature *> */ *signatures;

/**
 Adds a signature to the signatures array.
 
 @param signature    The signature object to add to the document.
 */
- (void)addSignature:(ORKConsentSignature *)signature;

/// @name Alternative content provision

/**
 Override HTML content for review.
 
 Normally, the review content is generated from `sections` and `signatures`
 properties.
 
 If this property is set, then the review content is reproduced exactly as provided,
 in the `ORKConsentReviewStep`, and the `sections` and `signatures` properties
 are ignored.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *htmlReviewContent;

/// @name PDF generation

/**
 Writes the document's content into a PDF file.
 
 The PDF is generated in a form suitable for printing. This is done asynchronously,
 so the PDF data is returned via a completion block.
 
 @param handler     Handler block for generated PDF data. On success, the returned
                    data represents a complete PDF document representing the consent.
 */
- (void)makePDFWithCompletionHandler:(void (^)(NSData * __ORK_NULLABLE PDFData, NSError * __ORK_NULLABLE error))handler;

@end


ORK_ASSUME_NONNULL_END


