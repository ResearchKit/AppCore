//
//  RKSTAppearance.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @brief This is a list of UI component interfaces to allow customization through UIAppearance proxy.
 *  @attention UIAppearance compatible attributes are those marked with UI_APPEARANCE_SELECTOR in this file or in its parent classes.
 *  @example [[RKSTHeadlineLabel appearance] setLabelTextColor:myColor];  //new attribute marked with UI_APPEARANCE_SELECTOR in RKSTAppearance.h
 *  @example [[RKSTHeadlineLabel appearance] setBackgroundColor:myColor]; //parent class attribute marked with UI_APPEARANCE_SELECTOR
 */

/**
 *  @brief This is a base class, not being used directly. 
 *  @discussion Can be used to customize all labels in ResearchKit
 *  @example [[RKSTLabel appearance] setLabelTextColor:myColor];
 */
@interface RKSTLabel : UILabel

@property (nonatomic ,strong) UIFont* labelFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* labelTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief Primary title for any step view controller.
 */
@interface RKSTHeadlineLabel : RKSTLabel

@end

/**
 *  @brief Step's details text under title.
 */
@interface RKSTSubheadlineLabel : RKSTLabel

@end

/**
 *  @brief Intro step's first piece details text.
 */
@interface RKSTCaption1Label : RKSTLabel

@end

/**
 *  @brief Intro step's second piece details text.
 */
@interface RKSTCaption2Label : RKSTLabel

@end

/**
 *  @brief Title line in selection question's choice cell.
 */
@interface RKSTSelectionTitleLabel : RKSTLabel

@end

/**
 *  @brief Details text in selection question's choice cell.
 */
@interface RKSTSelectionSubTitleLabel : RKSTLabel

@end

/**
 *  @brief Start/End of the range in scale slider.
 */
@interface RKSTScaleRangeLabel : RKSTLabel

@end

/**
 *  @brief Large label shown separately from the scale slider to indicate the current value.
 */
@interface RKSTScaleValueLabel : RKSTLabel

@end

/**
 *  @brief Coundown label in active steps
 */
@interface RKSTCountdownLabel : RKSTLabel

@end

/**
 *  @brief Text label for units during numeric value entry
 */
@interface RKSTUnitLabel : RKSTLabel

@end

/**
 *  @brief Text label in single selection question's picker
 */
@interface RKSTPickerLabel : RKSTLabel

@end

/**
 *  @brief Text label under image answer option icon
 */
@interface RKSTImageAnswerOptionLabel : RKSTLabel

@end

/**
 *  @brief Answer's text field.
 */
@interface RKSTAnswerTextField : UITextField

@property (nonatomic ,strong) UIFont* fieldFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* fieldTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 * @brief Text field for use in forms
 */
@interface RKSTFormTextField : RKSTAnswerTextField

// No new properties, but provided so that appearance properties can be set specifically for this field.

@end

/**
 *  @brief Answer's text view.
 */
@interface RKSTAnswerTextView : UITextView

@property (nonatomic ,strong) UIFont* fieldFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* fieldTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief Text view for use in forms
 */
@interface RKSTFormTextView : RKSTAnswerTextView

@end

/**
 *  @brief "Skip" button or "Learn More" button.
 */
@interface RKSTTextButton : UIButton

@property (nonatomic ,strong) UIFont* titleFont UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief Base class, not being used directly.
 */
@interface RKSTTableViewCell : UITableViewCell

@property (nonatomic ,strong) UIFont* labelFont UI_APPEARANCE_SELECTOR;

@property (nonatomic ,strong) UIColor* labelTextColor UI_APPEARANCE_SELECTOR;

@end

/**
 *  @brief "Continue" button cell.
 */
@interface RKSTBoldTextCell : RKSTTableViewCell

@end

/**
 *  @brief "Done" button cell
 */
@interface RKSTRegularTextCell : RKSTTableViewCell

@end



