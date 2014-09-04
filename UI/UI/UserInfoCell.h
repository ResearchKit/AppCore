//
//  UserInfoCell.h
//  Configuration
//
//  Created by Karthik Keyan on 8/11/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS (NSUInteger, UserInfoCellType) {
    UserInfoCellTypeNone = 0,
    UserInfoCellTypeImageText,
    UserInfoCellTypeSingleInputText,
    UserInfoCellTypeSwitch,
    UserInfoCellTypeDatePicker,
    UserInfoCellTypeCustomPicker,
    UserInfoCellTypeTitleValue,
    UserInfoCellTypeSegment,
};

@protocol UserInfoCellDelegate;

@interface UserInfoCell : UITableViewCell

@property (nonatomic, readonly) UserInfoCellType type;

@property (nonatomic, strong) UIButton *profileImageButton;

@property (nonatomic, strong) NSString *valueTextRegularExpression;

@property (nonatomic, strong) UITextField *valueTextField;

@property (nonatomic, strong) UISwitch *switchView;

@property (nonatomic, strong) UISegmentedControl *segmentControl;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIPickerView *customPickerView;

@property (nonatomic, strong) NSArray *customPickerValues;

@property (nonatomic, weak) id<UserInfoCellDelegate> delegate;

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(UserInfoCellType)type;

- (void) setNeedsHiddenField;

- (void) setNeedsCustomPicker;

@end


@protocol UserInfoCellDelegate <NSObject>

@optional
- (void) userInfoCellValueChanged:(UserInfoCell *)cell;
- (void) userInfoCellDidSelectProfileImage:(UserInfoCell *)cell;

@end