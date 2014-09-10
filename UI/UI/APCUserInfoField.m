//
//  APCUserInfoField.m
//  UI
//
//  Created by Karthik Keyan on 9/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCUserInfoField.h"

@implementation APCUserInfoField

- (NSString *) identifier {
    return @"cell";
}

@end



@implementation APCUserInfoTextField

@end



@implementation APCUserInfoDatePickerField

@end



@implementation APCUserInfoCustomPickerField

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



@implementation APCUserInfoSegmentField

@end