//
//  APCTableViewItem.h
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UITextField.h>
#import <UIKit/UIDatePicker.h>
#import <UIKit/UITableViewCell.h>

@interface APCTableViewItem : NSObject

@property (nonatomic, readwrite) UITableViewCellStyle style;

@property (nonatomic, readwrite) UITableViewCellSelectionStyle selectionStyle;

@property (nonatomic, readwrite) NSTextAlignment textAlignnment;

@property (nonatomic, copy) NSString *caption;

@property (nonatomic, copy) NSString *detailText;

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, copy) NSString *regularExpression;

@end



@interface APCTableViewTextFieldItem : APCTableViewItem

@property (nonatomic, readwrite) UIKeyboardType keyboardType;

@property (nonatomic, readwrite) UIReturnKeyType returnKeyType;

@property (nonatomic, readwrite) UITextFieldViewMode clearButtonMode;

@property (nonatomic, readwrite, getter = isSecure) BOOL secure;

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, copy) NSString *value;

@end



@interface APCTableViewPickerItem : APCTableViewItem

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, readwrite, getter = isDetailDiscloserStyle) BOOL detailDiscloserStyle;

@end



@interface APCTableViewDatePickerItem : APCTableViewPickerItem

@property (nonatomic, copy) NSString *dateFormat;

@property (nonatomic, readwrite) UIDatePickerMode datePickerMode;

@property (nonatomic, strong) NSDate *date;

@end



@interface APCTableViewCustomPickerItem : APCTableViewPickerItem

@property (nonatomic, strong) NSArray *selectedRowIndices;

@property (nonatomic, strong) NSArray *pickerData;

- (NSString *) stringValue;

@end



@interface APCTableViewSegmentItem : APCTableViewItem

@property (nonatomic, readwrite) NSUInteger selectedIndex;

@property (nonatomic, strong) NSArray *segments;

@end



@interface APCTableViewSwitchItem : APCTableViewItem

@property (nonatomic, readwrite, getter = isOn) BOOL on;

@end

//Permission Types
typedef NS_ENUM(NSUInteger, APCSignUpPermissionsType) {
    kSignUpPermissionsTypeHealthKit,
    kSignUpPermissionsTypeLocation,
    kSignUpPermissionsTypePushNotifications,
    kSignUpPermissionsTypeCoremotion,
};

@interface APCTableViewPermissionsItem : APCTableViewItem

@property (nonatomic) APCSignUpPermissionsType permissionType;

@property (nonatomic, readwrite, getter=isPermissionGranted) BOOL permissionGranted;

@end
