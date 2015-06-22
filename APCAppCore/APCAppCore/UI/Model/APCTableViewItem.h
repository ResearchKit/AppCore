// 
//  APCTableViewItem.h 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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

@property (nonatomic, assign) BOOL permissionGranted;

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

@property (nonatomic, strong) NSAttributedString *legend;

+(NSAttributedString *)legendForSeries1:(NSString *)series1 series2:(NSString *)series2;

@end

@interface APCTableViewDashboardMessageItem : APCTableViewDashboardItem

@property (nonatomic) APCDashboardMessageType messageType;

@end

@interface APCTableViewDashboardInsightsItem : APCTableViewDashboardItem

@property (nonatomic, strong) UIColor *sidebarColor;
@property (nonatomic, strong) NSString *titleCaption;
@property (nonatomic, strong) NSString *subtitleCaption;
@property (nonatomic) BOOL showTopSeparator;

@end

@interface APCTableViewDashboardInsightItem : APCTableViewDashboardItem

@property (nonatomic, strong) NSString *goodCaption;
@property (nonatomic, strong) NSString *badCaption;
@property (nonatomic, strong) NSNumber *goodBar;
@property (nonatomic, strong) NSNumber *badBar;
@property (nonatomic, strong) UIImage *insightImage;

@end

@interface APCTableViewDashboardFoodInsightItem : APCTableViewDashboardItem

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


