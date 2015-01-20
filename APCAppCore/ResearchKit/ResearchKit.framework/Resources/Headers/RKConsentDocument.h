//
//  RKConsentDocument.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKConsentSignature : NSObject<NSSecureCoding, NSCopying>

+ (RKConsentSignature *)signatureForPersonWithTitle:(NSString *)title
                                   dateFormatString:(NSString *)dateFormatString
                                         identifier:(NSString *)identifier
                                          firstName:(NSString *)firstName
                                           lastName:(NSString *)lastName
                                     signatureImage:(UIImage *)signatureImage
                                         dateString:(NSString *)signatureDate;

+ (RKConsentSignature *)signatureForPersonWithTitle:(NSString *)title
                                   dateFormatString:(NSString *)dateFormatString
                                         identifier:(NSString *)identifier;

// Default YES
@property (nonatomic, assign) BOOL requiresName;

// Default YES
@property (nonatomic, assign) BOOL requiresSignatureImage;

/**
 * @brief Unique identifier
 */
@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *firstName; // "first" name (the name part displayed first)
@property (nonatomic, copy) NSString *lastName; // "last" name (the name part displayed second)
@property (nonatomic, copy) UIImage *signatureImage;
@property (nonatomic, copy) NSString *signatureDate;

/**
 * @example @"yyyy-MM-dd 'at' HH:mm"
 * If left with nil, use the user's system locale
 */
@property (nonatomic, copy) NSString *signatureDateFormatString;

@end


/**
 * @brief RKConsentDocument models elements to be presented in animated sequence and PDF document.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKConsentDocument : NSObject<NSSecureCoding, NSCopying>

/**
 * @brief Document's title only appears in the PDF file.
 */
@property (nonatomic, copy) NSString *title;

/**
 * @brief Document's sections
 * @abstract Sections to be in printed in the PDF file and to be presented in the animated sequence.
 * @discussion All sections appear in the animated process except those sections with type RKConsentSectionTypeOnlyInDocument.
                The PDF file contains all sections.
 */
@property (nonatomic, copy) NSArray /* <RKConsentSection> */ *sections;

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
 * The signature object itself may be filled in or modified when running an RKConsentReviewStep
 */
@property (nonatomic, copy) NSArray /* <RKConsentSignature *> */ *signatures;
- (void)addSignature:(RKConsentSignature *)signature;

/**
 * @brief Write document into a PDF file. PDF data will be returned in async block callback.
 */
- (void)makePDFWithCompletionHandler:(void (^)(NSData *PDFData, NSError *error))handler;

@end


/**
 *  @enum RKConsentSectionType
 */
typedef NS_ENUM(NSInteger, RKConsentSectionType) {
    RKConsentSectionTypeOverview,
    RKConsentSectionTypeDataGathering,
    RKConsentSectionTypePrivacy,
    RKConsentSectionTypeDataUse,
    RKConsentSectionTypeTimeCommitment,
    RKConsentSectionTypeStudySurvey,
    RKConsentSectionTypeStudyTasks,
    RKConsentSectionTypeWithdrawing,
    RKConsentSectionTypeCustom,                                 // No predefined title/summary/content/animation.
    RKConsentSectionTypeOnlyInDocument                          // Section with this type only appears in pdf file.
} RK_ENUM_AVAILABLE_IOS(8_3);

/**
 *  @class RKConsentSection
 *  @abstract A section in the consent document.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKConsentSection : NSObject<NSSecureCoding, NSCopying>

/**
 *  @brief Populates predefined title and summary for all types except for type RKConsentSectionTypeCustom and RKConsentSectionTypeOnlyInDocument.
 */
- (instancetype)initWithType:(RKConsentSectionType)type;

@property (nonatomic, readonly) RKConsentSectionType type;

/**
 *  @brief Displayed as scene title in the animated consent sequence.
 *  @discussion Prefilled unless type is RKConsentSectionTypeCustom or RKConsentSectionTypeOnlyInDocument.
 *              Also included in the PDF file, unless -formalTitle is set.
 */
@property (nonatomic, copy) NSString *title;

/**
 * @brief Formal title of the section, for use in the legal document.
 * @discussion If nil, the title is used in the legal document instead.
 */
@property (nonatomic, copy) NSString *formalTitle;

/**
 *  @brief Displayed as description text in the animated consent sequence.
 *  @discussion Not prefilled.
 */
@property (nonatomic, copy) NSString *summary;

/**
 *  @brief Printed as section's content in the PDF file. Displayed as learn more in the animated consent sequence.
 *  @discussion Not prefilled. If both content and htmlContent are non-nil, htmlContent field will be used.
 */
@property (nonatomic, copy) NSString *content;

/**
 *  @brief Printed as section's content in the PDF file. Displayed as learn more in the animated consent sequence.
 *  @discussion Accepts text with HTML annotations. If both content and htmlContent are non-nil, htmlContent field will be used.
 */
@property (nonatomic, copy) NSString *htmlContent;

/**
 *  @brief User defined custom image to be displayed in the corresponding scene in the animated consent sequence. Ignored unless type is RKConsentSectionTypeCustom.
 */
@property (nonatomic, copy) UIImage *customImage;

@end


