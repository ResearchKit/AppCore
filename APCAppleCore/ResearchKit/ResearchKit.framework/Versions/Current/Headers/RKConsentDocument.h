//
//  RKConsentDocument.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 * @brief RKConsentDocument models elements to be presented in animated sequence and PDF document.
 */
@interface RKConsentDocument : NSObject

/**
 * @brief Document's title only appears in the PDF file.
 */
@property (nonatomic, copy) NSString* title;

/**
 * @brief Document's sections
 * @abstract Sections to be in printed in the PDF file and to be presented in the animated sequence.
 * @discussion All sections appear in the animated process except those sections with type RKConsentSectionTypeOnlyInDocument.
                The PDF file contains all sections.
 */
@property (nonatomic, copy) NSArray /* <RKConsentSection> */* sections;

/**
 * @brief Section title to be rendered on PDF file's signature page. Not in the animated sequence.
 */
@property (nonatomic, copy) NSString* signaturePageTitle;

/**
 * @brief Section content to be rendered on PDF file's signature page. Not in the animated sequence.
 */
@property (nonatomic, copy) NSString* signaturePageContent;

/**
 * @brief Participant related fields will be filled in by RKConsentViewController.
 */
@property (nonatomic, copy) NSString* participantNamePrinted;
@property (nonatomic, strong) UIImage* participantSignatureImage;
@property (nonatomic, copy) NSString* participantSignatureDate;

/**
 * @brief Investigator related fields
 */
@property (nonatomic, copy) NSString* investigatorNamePrinted;
@property (nonatomic, strong) UIImage* investigatorSignatureImage;
@property (nonatomic, copy) NSString* investigatorSignatureDate;

/**
 * @brief Write document into a PDF file. PDF data will be returned in async block callback.
 */
- (void)makePdfWithCompletionBlock:(void (^)(NSData* pdfData, NSError* error))completionBlock;

@end
