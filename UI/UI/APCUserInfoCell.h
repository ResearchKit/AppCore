//
//  APCUserInfoCell.h
//  Configuration
//
//  Created by Karthik Keyan on 8/11/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

@import UIKit;

typedef NS_OPTIONS (NSUInteger, APCUserInfoCellType) {
    APCUserInfoCellTypeNone = 0,
    APCUserInfoCellTypeSingleInputText,
    APCUserInfoCellTypeSwitch,
    APCUserInfoCellTypeDatePicker,
    APCUserInfoCellTypeCustomPicker,
    APCUserInfoCellTypeTitleValue,
    APCUserInfoCellTypeSegment,
};

@protocol APCUserInfoCellDelegate;

@interface APCUserInfoCell : UITableViewCell

@property (nonatomic, readwrite) APCUserInfoCellType type;

@property (nonatomic, strong) NSString *valueTextRegularExpression;

@property (nonatomic, strong) UITextField *valueTextField;

@property (nonatomic, strong) UISwitch *switchView;

@property (nonatomic, strong) UISegmentedControl *segmentControl;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIPickerView *customPickerView;

@property (nonatomic, strong) NSArray *customPickerValues;

@property (nonatomic, weak) id<APCUserInfoCellDelegate> delegate;

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void) setNeedsHiddenField;

- (void) setNeedsCustomPicker;

@end


@protocol APCUserInfoCellDelegate <NSObject>

@optional
- (void) userInfoCellDidBecomFirstResponder:(APCUserInfoCell *)cell;
- (void) userInfoCellValueChanged:(APCUserInfoCell *)cell;
- (void) userInfoCellDidSelectProfileImage:(APCUserInfoCell *)cell;

@end