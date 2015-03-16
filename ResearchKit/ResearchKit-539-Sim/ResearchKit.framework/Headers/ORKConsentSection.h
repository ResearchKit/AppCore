//
//  ORKConsentSection.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @enum ORKConsentSectionType
 */
typedef NS_ENUM(NSInteger, ORKConsentSectionType) {
    ORKConsentSectionTypeOverview,
    ORKConsentSectionTypeDataGathering,
    ORKConsentSectionTypePrivacy,
    ORKConsentSectionTypeDataUse,
    ORKConsentSectionTypeTimeCommitment,
    ORKConsentSectionTypeStudySurvey,
    ORKConsentSectionTypeStudyTasks,
    ORKConsentSectionTypeWithdrawing,
    ORKConsentSectionTypeCustom,                                 // No predefined title/summary/content/animation.
    ORKConsentSectionTypeOnlyInDocument                          // Section with this type only appears in pdf file.
} ORK_ENUM_AVAILABLE;

/**
 *  @class ORKConsentSection
 *  @abstract A section in the consent document.
 */
ORK_CLASS_AVAILABLE
@interface ORKConsentSection : NSObject<NSSecureCoding, NSCopying>

/**
 *  @brief Populates predefined title and summary for all types except for type ORKConsentSectionTypeCustom and ORKConsentSectionTypeOnlyInDocument.
 */
- (instancetype)initWithType:(ORKConsentSectionType)type;

@property (nonatomic, readonly) ORKConsentSectionType type;

/**
 *  @brief Displayed as scene title in the animated consent sequence.
 *  @discussion Prefilled unless type is ORKConsentSectionTypeCustom or ORKConsentSectionTypeOnlyInDocument.
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
 *  @brief User defined custom image to be displayed in the corresponding scene in the animated consent sequence. Ignored unless type is ORKConsentSectionTypeCustom.
 */
@property (nonatomic, copy) UIImage *customImage;

/**
 * @brief Override for learn more button title.
 */
@property (nonatomic, copy) NSString *customLearnMoreButtonTitle;

/**
 * @brief File URL to custom animation video
 * If supplied, transition animation is loaded from here.
 */
@property (nonatomic, copy) NSURL *customAnimationURL;

@end

