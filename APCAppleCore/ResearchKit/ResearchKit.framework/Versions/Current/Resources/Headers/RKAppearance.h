//
//  RKAppearance.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @brief This is a list of UI component interfaces to allow customization through UIAppearance proxy.
 *  @attention UIAppearance compatible attributes are those marked with UI_APPEARANCE_SELECTOR in this file or in its parent classes.
 *  @example [[RKHeadlineLabel appearance] setLabelTextColor:myColor];  //new attribute marked with UI_APPEARANCE_SELECTOR in RKAppearance.h
 *  @example [[RKHeadlineLabel appearance] setBackgroundColor:myColor]; //parent class attribute marked with UI_APPEARANCE_SELECTOR
 */

/**
 *  @brief This is a base class, not being used directly. 
 *  @discussion Can be used to customize all labels in ResearchKit
 *  @example [[RKLabel appearance] setLabelTextColor:myColor];
 */
@interface RKLabel : UILabel

@property (nonatomic ,strong) UIFont* labelFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* labelTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief Primary title for any step view controller.
 */
@interface RKHeadlineLabel : RKLabel

@end

/**
 *  @brief Step's details text under title.
 */
@interface RKSubheadlineLabel : RKLabel

@end

/**
 *  @brief Intro step's first piece details text.
 */
@interface RKCaption1Label : RKLabel

@end

/**
 *  @brief Intro step's second piece details text.
 */
@interface RKCaption2Label : RKLabel

@end

/**
 *  @brief Title line in selection question's choice cell.
 */
@interface RKSelectionTitleLabel : RKLabel

@end

/**
 *  @brief Details text in selection question's choice cell.
 */
@interface RKSelectionSubTitleLabel : RKLabel

@end

/**
 *  @brief Start/End of the range in scale slider.
 */
@interface RKScaleRangeLabel : RKLabel

@end

/**
 *  @brief Large label shown separately from the scale slider to indicate the current value.
 */
@interface RKScaleValueLabel : RKLabel

@end

/**
 *  @brief Coundown label in active steps
 */
@interface RKCountdownLabel : RKLabel

@end

/**
 *  @brief Text label for units during numeric value entry
 */
@interface RKUnitLabel : RKLabel

@end

/**
 *  @brief Text label in single selection question's picker
 */
@interface RKPickerLabel : RKLabel

@end

/**
 *  @brief Answer's text field.
 */
@interface RKAnswerTextField : UITextField

@property (nonatomic ,strong) UIFont* fieldFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* fieldTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 * @brief Text field for use in forms
 */
@interface RKFormTextField : RKAnswerTextField

@property (nonatomic ,strong) UIFont* fieldFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* fieldTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief Answer's text view.
 */
@interface RKAnswerTextView : UITextView

@property (nonatomic ,strong) UIFont* fieldFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* fieldTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief "Skip" button or "Learn More" button.
 */
@interface RKTextButton : UIButton

@property (nonatomic ,strong) UIFont* titleFont UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief Base class, not being used directly.
 */
@interface RKTableViewCell : UITableViewCell

@property (nonatomic ,strong) UIFont* labelFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* labelTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief "Continue" button cell.
 */
@interface RKBoldTextCell : RKTableViewCell

@end

/**
 *  @brief "Done" button cell
 */
@interface RKRegularTextCell : RKTableViewCell

@end



