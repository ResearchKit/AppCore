// 
//  APCTableViewItem.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UITextField.h>
#import <UIKit/UIDatePicker.h>
#import <UIKit/UITableViewCell.h>
#import "APCUserInfoConstants.h"
#import "APCConstants.h"

@interface APCTableViewItem : NSObject

@property (nonatomic, readwrite) UITableViewCellStyle style;

@property (nonatomic, readwrite) UITableViewCellSelectionStyle selectionStyle;

@property (nonatomic, readwrite) NSTextAlignment textAlignnment;

@property (nonatomic, copy) NSString *caption;

@property (nonatomic, copy) NSString *detailText;

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, copy) NSString *regularExpression;

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, readwrite, getter=isEditable) BOOL editable;

@end



@interface APCTableViewTextFieldItem : APCTableViewItem

@property (nonatomic, readwrite) UIKeyboardType keyboardType;

@property (nonatomic, readwrite) UIReturnKeyType returnKeyType;

@property (nonatomic, readwrite) UITextFieldViewMode clearButtonMode;

@property (nonatomic, readwrite, getter = isSecure) BOOL secure;

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

@property (nonatomic, strong) NSDate *minimumDate;

@property (nonatomic, strong) NSDate *maximumDate;

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



@interface APCTableViewPermissionsItem : APCTableViewItem

@property (nonatomic) APCSignUpPermissionsType permissionType;

@property (nonatomic, readwrite, getter=isPermissionGranted) BOOL permissionGranted;

@end


@interface APCTableViewStudyDetailsItem : APCTableViewItem

@property (nonatomic, strong) NSString *imageName;

@property (nonatomic, strong) NSString *videoName;

@property (nonatomic, strong) UIImage *iconImage;

@property (nonatomic, strong) UIColor *tintColor;

@end

/* ----------------------------------------------- */

@interface APCTableViewDashboardItem : APCTableViewItem

@property (nonatomic, strong) UIColor *tintColor;

@end

@interface APCTableViewDashboardProgressItem : APCTableViewDashboardItem

@property (nonatomic) CGFloat progress;

@end


@interface APCTableViewDashboardGraphItem : APCTableViewDashboardItem

@property (nonatomic) id graphData; //TODO: Set class later

@property (nonatomic) APCDashboardGraphType graphType;

@end

@interface APCTableViewDashboardMessageItem : APCTableViewDashboardItem

@property (nonatomic) APCDashboardMessageType messageType;

@end

/* ----------------------------------------------- */

@interface APCTableViewSection : NSObject

@property (nonatomic, strong) NSArray *rows;

@property (nonatomic, strong) NSString *sectionTitle;

@end

@interface APCTableViewRow : NSObject

@property (nonatomic, strong) APCTableViewItem *item;

@property (nonatomic, readwrite) APCTableViewItemType itemType;

@end


