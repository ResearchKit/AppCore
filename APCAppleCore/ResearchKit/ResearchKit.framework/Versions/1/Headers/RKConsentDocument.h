//
//  RKConsentDocument.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@interface RKConsentSignature : NSObject<NSSecureCoding>

+ (RKConsentSignature *)signatureForPersonWithTitle:(NSString *)title name:(NSString *)name signatureImage:(UIImage *)signatureImage dateString:(NSString *)signatureDate;

// Default YES
@property (nonatomic, assign) BOOL requiresName;

// Default YES
@property (nonatomic, assign) BOOL requiresSignatureImage;

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, strong) UIImage* signatureImage;
@property (nonatomic, copy) NSString* signatureDate;

@end


/**
 * @brief RKConsentDocument models elements to be presented in animated sequence and PDF document.
 */
@interface RKConsentDocument : NSObject<NSSecureCoding>

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
 * @brief Set of signatures required or provided
 * The signature object itself may be filled in or modified when running an RKConsentReviewStep
 */
@property (nonatomic, copy) NSArray /* <RKConsentSignature *> */ *signatures;
- (void)addSignature:(RKConsentSignature *)signature;

/**
 * @brief Write document into a PDF file. PDF data will be returned in async block callback.
 */
- (void)makePdfWithCompletionBlock:(void (^)(NSData* pdfData, NSError* error))completionBlock;

@end
