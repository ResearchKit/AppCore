//
//  RKConsentDocument.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@interface RKConsentSignature : NSObject<NSSecureCoding>

+ (RKConsentSignature *)signatureForPersonWithTitle:(NSString *)title name:(NSString *)name signatureImage:(UIImage *)signatureImage dateString:(NSString *)signatureDate;

+ (RKConsentSignature *)signatureForPersonWithTitle:(NSString *)title dateFormatString:(NSString *)dateFormatString;

// Default YES
@property (nonatomic, assign) BOOL requiresName;

// Default YES
@property (nonatomic, assign) BOOL requiresSignatureImage;

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, strong) UIImage* signatureImage;
@property (nonatomic, copy) NSString* signatureDate;

/**
 * @example @"yyyy-MM-dd 'at' HH:mm"
 * If left with nil, use the user's system locale
 */
@property (nonatomic, copy) NSString* signatureDateFormatString;

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


/**
 *  @enum RKConsentSectionType
 */
typedef NS_ENUM(NSInteger, RKConsentSectionType) {
    RKConsentSectionTypeOverview,
    RKConsentSectionTypeActivity,
    RKConsentSectionTypeSensorData,
    RKConsentSectionTypeDeIdentification,
    RKConsentSectionTypeCombiningData,
    RKConsentSectionTypeUtilizingData,
    RKConsentSectionTypeImpactLifeTime,
    RKConsentSectionTypePotentialRiskUncomfortableQuestion,
    RKConsentSectionTypePotentialRiskSocial,
    RKConsentSectionTypeAllowWithdraw,
    RKConsentSectionTypeCustom,                                 // No predefined title/summary/content/animation.
    RKConsentSectionTypeOnlyInDocument                          // Section with this type only appears in pdf file.
};

/**
 *  @class RKConsentSection
 *  @abstract A section in the consent document.
 */
@interface RKConsentSection : NSObject<NSSecureCoding>

/**
 *  @brief Populates predefined title and summary for all types except for type RKConsentSectionTypeCustom and RKConsentSectionTypeOnlyInDocument.
 */
- (instancetype)initWithType:(RKConsentSectionType)type;

@property (nonatomic, readonly) RKConsentSectionType type;

/**
 *  @brief Printed as section title in the PDF file. Displayed as scene title in the animated consent sequence.
 *  @discussion Prefilled unless type is RKConsentSectionTypeCustom or RKConsentSectionTypeOnlyInDocument.
 *              Override allowed.
 */
@property (nonatomic, copy) NSString* title;

/**
 *  @brief Printed as section's first paragraph in the PDF file. Displayed as description text in the animated consent sequence.
 *  @discussion Prefilled unless type is type RKConsentSectionTypeCustom or RKConsentSectionTypeOnlyInDocument.
 *              Override allowed.
 */
@property (nonatomic, copy) NSString* summary;

/**
 *  @brief Printed as section's content in the PDF file. Displayed as learn more in the animated consent sequence.
 *  @discussion Not prefilled.
 */
@property (nonatomic, copy) NSString* content;

/**
 *  @brief User defined custom image to be displayed in the corresponding scene in the animated consent sequence. Ignored unless type is RKConsentSectionTypeCustom.
 */
@property (nonatomic, strong) UIImage* customImage;

@end


