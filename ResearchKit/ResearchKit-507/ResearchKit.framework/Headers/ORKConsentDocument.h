//
//  ORKConsentDocument.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>
#import "ORKConsentSignature.h"


/**
 * @brief ORKConsentDocument models elements to be presented in animated sequence and PDF document.
 */
ORK_CLASS_AVAILABLE
@interface ORKConsentDocument : NSObject<NSSecureCoding, NSCopying>

/**
 * @brief Document's title only appears in the PDF file.
 */
@property (nonatomic, copy) NSString *title;

/**
 * @brief Document's sections
 * @abstract Sections to be in printed in the PDF file and to be presented in the animated sequence.
 * @discussion All sections appear in the animated process except those sections with type ORKConsentSectionTypeOnlyInDocument.
                The PDF file contains all sections.
 */
@property (nonatomic, copy) NSArray /* <ORKConsentSection> */ *sections;

/**
 * @brief Section title to be rendered on PDF file's signature page. Not in the animated sequence.
 */
@property (nonatomic, copy) NSString *signaturePageTitle;

/**
 * @brief Section content to be rendered on PDF file's signature page. Not in the animated sequence.
 */
@property (nonatomic, copy) NSString *signaturePageContent;

/**
 * @brief Set of signatures required or provided
 * The signature object itself may be filled in or modified when running an ORKConsentReviewStep
 */
@property (nonatomic, copy) NSArray /* <ORKConsentSignature *> */ *signatures;
- (void)addSignature:(ORKConsentSignature *)signature;

/**
 * @brief Write document into a PDF file. PDF data will be returned in async block callback.
 */
- (void)makePDFWithCompletionHandler:(void (^)(NSData *PDFData, NSError *error))handler;

@end



