//
//  APCUserInfoField.h
//  UI
//
//  Created by Karthik Keyan on 9/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import UIKit;

@interface APCUserInfoField : NSObject

@property (nonatomic, readwrite) UITableViewCellStyle style;

@property (nonatomic, readwrite) UITableViewCellSelectionStyle selectionStyle;

@property (nonatomic, readwrite) NSTextAlignment textAlignnment;

@property (nonatomic, copy) NSString *caption;

@property (nonatomic, copy) NSString *detailText;

@property (nonatomic, copy) NSString *identifier;

@end



@interface APCUserInfoTextField : APCUserInfoField

@property (nonatomic, readwrite) UIKeyboardType keyboardType;

@property (nonatomic, readwrite, getter = isSecure) BOOL secure;

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, copy) NSString *value;

@end



@interface APCUserInfoDatePickerField : APCUserInfoField

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, copy) NSString *dateFormate;

@property (nonatomic, strong) NSDate *date;

@end



@interface APCUserInfoCustomPickerField : APCUserInfoField

@property (nonatomic, readwrite, getter = isDetailDiscloserStyle) BOOL detailDiscloserStyle;

@property (nonatomic, strong) NSArray *selectedRowIndices;

@property (nonatomic, strong) NSArray *pickerData;

- (NSString *) stringValue;

@end



@interface APCUserInfoSegmentField : APCUserInfoField

@property (nonatomic, readwrite) NSUInteger selectedIndex;

@property (nonatomic, strong) NSArray *segments;

@end



@interface APCUserInfoSwitchField : APCUserInfoField

@property (nonatomic, readwrite, getter = isOn) BOOL on;

@end
