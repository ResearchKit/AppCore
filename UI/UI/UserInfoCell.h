//
//  ProfileCell.h
//  Configuration
//
//  Created by Karthik Keyan on 8/11/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS (NSUInteger, ProfileCellType) {
    ProfileCellTypeNone = 0,
    ProfileCellTypeImageText,
    ProfileCellTypeSingleInputText,
    ProfileCellTypeSwitch,
    ProfileCellTypeDatePicker,
    ProfileCellTypeCustomPicker,
    ProfileCellTypeTitleValue,
    ProfileCellTypeSegment,
};

@protocol ProfileCellDelegate;

@interface UserInfoCell : UITableViewCell

@property (nonatomic, readonly) ProfileCellType type;

@property (nonatomic, strong) UIButton *profileImageButton;

@property (nonatomic, strong) NSString *valueTextRegularExpression;

@property (nonatomic, strong) UITextField *valueTextField;

@property (nonatomic, strong) UISwitch *switchView;

@property (nonatomic, strong) UISegmentedControl *segmentControl;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIPickerView *customPickerView;

@property (nonatomic, strong) NSArray *customPickerValues;

@property (nonatomic, weak) id<ProfileCellDelegate> delegate;

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier type:(ProfileCellType)type;

- (void) setNeedsHiddenField;

- (void) setNeedsCustomPicker;

@end


@protocol ProfileCellDelegate <NSObject>

@optional
- (void) profileCellValueChanged:(UserInfoCell *)cell;
- (void) profileCellDidSelectProfileImage:(UserInfoCell *)cell;

@end