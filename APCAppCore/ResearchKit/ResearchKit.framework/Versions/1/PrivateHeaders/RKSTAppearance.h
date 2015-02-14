//
//  RKSTAppearance.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ResearchKit/RKSTDefines.h>

/**
 *  @brief This is a list of UI component interfaces to allow customization through UIAppearance proxy.
 *  @attention UIAppearance compatible attributes are those marked with UI_APPEARANCE_SELECTOR in this file or in its parent classes.
 *  @example [[RKSTHeadlineLabel appearance] setLabelTextColor:myColor];  //new attribute marked with UI_APPEARANCE_SELECTOR in RKSTAppearance.h
 *  @example [[RKSTHeadlineLabel appearance] setBackgroundColor:myColor]; //parent class attribute marked with UI_APPEARANCE_SELECTOR
 */

@protocol RKSTSkin <NSObject>

+ (UIFont *)defaultFont;

@end

/**
 *  @brief This is a base class, not being used directly. 
 *  @discussion Can be used to customize all labels in ResearchKit
 *  @example [[RKSTLabel appearance] setLabelTextColor:myColor];
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTLabel : UILabel <RKSTSkin>

@property (nonatomic ,strong) UIFont* labelFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* labelTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief Primary title for any step view controller.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTHeadlineLabel : RKSTLabel

@end

/**
 *  @brief Step's details text under title.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTSubheadlineLabel : RKSTLabel

@end

/**
 *  @brief Intro step's first piece details text.
 *  @note Used as cell's caption text: in _RKSTConsentDocumentCell and _RKSTFormItemCell
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTCaption1Label : RKSTLabel

@end

/**
 *  @brief Title line in selection question's choice cell.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTSelectionTitleLabel : RKSTLabel

@end

/**
 *  @brief Details text in selection question's choice cell.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTSelectionSubTitleLabel : RKSTLabel

@end

/**
 *  @brief Start/End of the range in scale slider.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTScaleRangeLabel : RKSTLabel

@end

/**
 *  @brief Large label shown separately from the scale slider to indicate the current value.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTScaleValueLabel : RKSTLabel

@end

/**
 *  @brief Coundown label in active steps
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTCountdownLabel : RKSTLabel

@end

/**
 *  @brief Text label for units during numeric value entry
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTUnitLabel : RKSTLabel

@end

/**
 *  @brief Text label in single selection question's picker
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTPickerLabel : RKSTLabel

@end

/**
 *  @brief Text label under image answer option icon
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTImageChoiceLabel : RKSTLabel

@end

/**
 *  @brief Display tapping count in tapping interval active task
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTTapCountLabel : RKSTLabel

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTFormSectionTitleLabel : RKSTLabel

@end

/**
 *  @brief Answer's text field.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTAnswerTextField : UITextField <RKSTSkin>

@property (nonatomic ,strong) UIFont* fieldFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* fieldTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief Answer's text view.
 *  @note Used in answer page and form page.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTAnswerTextView : UITextView <RKSTSkin>

@property (nonatomic ,strong) UIFont* fieldFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* fieldTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief Text view for use in forms
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTFormTextView : RKSTAnswerTextView

@end

/**
 *  @brief "Skip" button or "Learn More" button.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTTextButton : UIButton <RKSTSkin>

@property (nonatomic ,strong) UIFont* titleFont UI_APPEARANCE_SELECTOR;

@end


RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTBorderedButton : RKSTTextButton

@property (nonatomic, assign) NSTimeInterval fadeDelay;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTContinueButton : RKSTBorderedButton

@property (nonatomic) BOOL isDoneButton;

@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTRoundTappingButton : RKSTBorderedButton

@end

/**
 *  @brief Base class, not being used directly.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTTableViewCell : UITableViewCell

@property (nonatomic ,strong) UIFont* labelFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* labelTextColor UI_APPEARANCE_SELECTOR;

@end




