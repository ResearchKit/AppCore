//
//  APCUserInfoCell.h
//  Configuration
//
//  Created by Karthik Keyan on 8/11/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

@import UIKit;

@protocol APCUserInfoCellDelegate;

@interface APCUserInfoCell : UITableViewCell

@property (nonatomic, strong) NSString *valueTextRegularExpression;

@property (nonatomic, strong) UITextField *valueTextField;

@property (nonatomic, strong) UISwitch *switchView;

@property (nonatomic, strong) UISegmentedControl *segmentControl;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIPickerView *customPickerView;

@property (nonatomic, weak) id<APCUserInfoCellDelegate> delegate;

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void) setSegments:(NSArray *)segments selectedIndex:(NSUInteger)selectedIndex;

- (void) setCustomPickerValues:(NSArray *)customPickerValues selectedRowIndices:(NSArray *)selectedRowIndices;

- (void) setNeedsHiddenField;

@end


@protocol APCUserInfoCellDelegate <NSObject>

@optional
- (void) userInfoCellDidBecomFirstResponder:(APCUserInfoCell *)cell;

- (void) userInfoCell:(APCUserInfoCell *)cell textValueChanged:(NSString *)text;

- (void) userInfoCell:(APCUserInfoCell *)cell switchValueChanged:(BOOL)isOn;

- (void) userInfoCell:(APCUserInfoCell *)cell segmentIndexChanged:(NSUInteger)index;

- (void) userInfoCell:(APCUserInfoCell *)cell dateValueChanged:(NSDate *)date;

- (void) userInfoCell:(APCUserInfoCell *)cell customPickerValueChanged:(NSArray *)selectedRowIndices;

@end