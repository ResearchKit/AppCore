//
//  APCTableViewItem.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTableViewItem.h"

@implementation APCTableViewItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        _style = UITableViewCellStyleValue1;
        _selectionStyle = UITableViewCellSelectionStyleGray;
        _editable = YES;
    }
    return self;
}

@end



@implementation APCTableViewTextFieldItem

@end



@implementation APCTableViewPickerItem

@end



@implementation APCTableViewDatePickerItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        _datePickerMode = UIDatePickerModeDateAndTime;
    }
    return self;
}

@end



@implementation APCTableViewCustomPickerItem

- (NSString *) stringValue {
    NSMutableString *string = [NSMutableString string];
    
    if (self.pickerData.count > 0) {
        for (int i = 0; i < self.selectedRowIndices.count; i++) {
            NSArray *component = self.pickerData[i];
            
            NSInteger selectedRowInComponent = [self.selectedRowIndices[i] integerValue];
            
            [string appendString:component[selectedRowInComponent]];
            
            if (i < (self.pickerData.count - 1)) {
                [string appendString:@" "];
            }
        }
    }
    
    return string;
}

@end



@implementation APCTableViewSegmentItem

@end

@implementation APCTableViewPermissionsItem

@synthesize permissionType = _permissionType;

@end
