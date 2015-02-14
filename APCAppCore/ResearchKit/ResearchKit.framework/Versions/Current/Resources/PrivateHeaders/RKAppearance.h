//
//  RKAppearance.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/RKDefines.h>

/**
 *  @brief This is a list of UI component interfaces to allow customization through UIAppearance proxy.
 *  @attention UIAppearance compatible attributes are those marked with UI_APPEARANCE_SELECTOR in this file or in its parent classes.
 *  @example [[RKHeadlineLabel appearance] setLabelTextColor:myColor];  //new attribute marked with UI_APPEARANCE_SELECTOR in RKAppearance.h
 *  @example [[RKHeadlineLabel appearance] setBackgroundColor:myColor]; //parent class attribute marked with UI_APPEARANCE_SELECTOR
 */

@protocol RKSkin <NSObject>

+ (UIFont *)defaultFont;

@end

/**
 *  @brief This is a base class, not being used directly. 
 *  @discussion Can be used to customize all labels in ResearchKit
 *  @example [[RKLabel appearance] setLabelTextColor:myColor];
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKLabel : UILabel <RKSkin>

@property (nonatomic ,strong) UIFont* labelFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* labelTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief Primary title for any step view controller.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKHeadlineLabel : RKLabel

@end

/**
 *  @brief Step's details text under title.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSubheadlineLabel : RKLabel

@end

/**
 *  @brief Intro step's first piece details text.
 *  @note Used as cell's caption text: in _RKConsentDocumentCell and _RKFormItemCell
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKCaption1Label : RKLabel

@end

/**
 *  @brief Title line in selection question's choice cell.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSelectionTitleLabel : RKLabel

@end

/**
 *  @brief Details text in selection question's choice cell.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSelectionSubTitleLabel : RKLabel

@end

/**
 *  @brief Start/End of the range in scale slider.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKScaleRangeLabel : RKLabel

@end

/**
 *  @brief Large label shown separately from the scale slider to indicate the current value.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKScaleValueLabel : RKLabel

@end

/**
 *  @brief Coundown label in active steps
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKCountdownLabel : RKLabel

@end

/**
 *  @brief Text label for units during numeric value entry
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKUnitLabel : RKLabel

@end

/**
 *  @brief Text label in single selection question's picker
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKPickerLabel : RKLabel

@end

/**
 *  @brief Text label under image answer option icon
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKImageChoiceLabel : RKLabel

@end

/**
 *  @brief Display tapping count in tapping interval active task
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTapCountLabel : RKLabel

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKFormSectionTitleLabel : RKLabel

@end

/**
 *  @brief Answer's text field.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKAnswerTextField : UITextField <RKSkin>

@property (nonatomic ,strong) UIFont* fieldFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* fieldTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief Answer's text view.
 *  @note Used in answer page and form page.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKAnswerTextView : UITextView <RKSkin>

@property (nonatomic ,strong) UIFont* fieldFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* fieldTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief Text view for use in forms
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKFormTextView : RKAnswerTextView

@end

/**
 *  @brief "Skip" button or "Learn More" button.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTextButton : UIButton <RKSkin>

@property (nonatomic ,strong) UIFont* titleFont UI_APPEARANCE_SELECTOR;

@end


RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKBorderedButton : RKTextButton

@property (nonatomic, assign) NSTimeInterval fadeDelay;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKContinueButton : RKBorderedButton

@property (nonatomic) BOOL isDoneButton;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKRoundTappingButton : RKBorderedButton

@end

/**
 *  @brief Base class, not being used directly.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKTableViewCell : UITableViewCell

@property (nonatomic ,strong) UIFont* labelFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* labelTextColor UI_APPEARANCE_SELECTOR;

@end




