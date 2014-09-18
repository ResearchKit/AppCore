//
//  RKConsentSection.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
@interface RKConsentSection : NSObject

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
