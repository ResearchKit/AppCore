//
//  APCCriteriaCell.h
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import UIKit;

@protocol APCCriteriaCellDelegate;


@interface APCCriteriaCell : UITableViewCell

@property (nonatomic, strong) NSArray *choices;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

@property (weak, nonatomic) IBOutlet UILabel *captionLabel;

@property (weak, nonatomic) IBOutlet UITextField *answerTextField;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, weak) id<APCCriteriaCellDelegate> delegate;

- (void) setNeedsChoiceInputCell;

- (void) setNeedsTextInputCell;

- (void) setNeedsDateInputCell;

- (NSUInteger) selectedChoiceIndex;

- (void) setSelectedChoiceIndex:(NSUInteger)index;

@end


@protocol APCCriteriaCellDelegate <NSObject>

@optional
- (void) criteriaCellValueChanged:(APCCriteriaCell *)cell;


@end
