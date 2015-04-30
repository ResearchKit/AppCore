// 
//  APCTableViewItem.m 
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
 
#import "APCTableViewItem.h"
#import "UIColor+APCAppearance.h"

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
        for (NSUInteger i = 0; i < self.selectedRowIndices.count; i++) {
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _permissionType = kAPCSignUpPermissionsTypeNone;
        _permissionGranted = NO;
    }
    return self;
}

@end

@implementation APCTableViewSwitchItem


@end

@implementation APCTableViewStudyDetailsItem

@end

/* ----------------------------- */

@implementation APCTableViewDashboardItem

- (UIColor *)tintColor
{
    if (!_tintColor) {
        _tintColor = [UIColor appTertiaryGrayColor];
    }
    
    return _tintColor;
}

@end

@implementation APCTableViewDashboardProgressItem

@end

@implementation APCTableViewDashboardGraphItem

@end

@implementation APCTableViewDashboardMessageItem

@end

@implementation APCTableViewDashboardInsightsItem

@end

@implementation APCTableViewDashboardInsightItem

@end

@implementation APCTableViewDashboardFoodInsightItem

@end


/* ----------------------------- */

@implementation APCTableViewSection

@end


@implementation APCTableViewRow

@end
