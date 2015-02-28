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
#import "APCScoring.h"

@interface APCTableViewItem : NSObject

@property (nonatomic, readwrite) UITableViewCellStyle style;

@property (nonatomic, readwrite) UITableViewCellSelectionStyle selectionStyle;

@property (nonatomic, readwrite) NSTextAlignment textAlignnment;

@property (nonatomic, copy) NSString *caption;

@property (nonatomic, copy) NSString *detailText;

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, copy) NSString *regularExpression;

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic) BOOL showChevron;

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

@property (nonatomic) BOOL showsConsent;

@end

/* ----------------------------------------------- */

@interface APCTableViewDashboardItem : APCTableViewItem

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) NSString *info;
@property (nonatomic, strong) NSString *taskId;

@end

@interface APCTableViewDashboardProgressItem : APCTableViewDashboardItem

@property (nonatomic) CGFloat progress;

@end


@interface APCTableViewDashboardGraphItem : APCTableViewDashboardItem

@property (nonatomic, strong) APCScoring *graphData;

@property (nonatomic) APCDashboardGraphType graphType;

@property (nonatomic, strong) UIImage *minimumImage;

@property (nonatomic, strong) UIImage *maximumImage;

@property (nonatomic, strong) UIImage *averageImage;

@end

@interface APCTableViewDashboardMessageItem : APCTableViewDashboardItem

@property (nonatomic) APCDashboardMessageType messageType;

@end

@interface APCTableViewDashboardInsightsItem : APCTableViewDashboardItem

@property (nonatomic, strong) UIColor *sidebarColor;
@property (nonatomic, strong) NSString *titleCaption;
@property (nonatomic, strong) NSString *subtitleCaption;

@end

@interface APCTableViewDashboardInsightItem : APCTableViewDashboardItem

@property (nonatomic, strong) NSString *goodCaption;
@property (nonatomic, strong) NSString *badCaption;
@property (nonatomic, strong) NSNumber *goodBar;
@property (nonatomic, strong) NSNumber *badBar;
@property (nonatomic, strong) UIImage *insightImage;

@end

@interface APCTableViewDashboardFoodInsightItem : APCTableViewDashboardItem

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) NSString *titleCaption;
@property (nonatomic, strong) NSString *subtitleCaption;
@property (nonatomic, strong) NSNumber *frequency;
@property (nonatomic, strong) UIImage *foodInsightImage;

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


