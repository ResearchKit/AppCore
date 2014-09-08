//
//  APHUserInfoCell.m
//  UI
//
//  Created by Karthik Keyan on 9/5/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHUserInfoCell.h"
#import "UITableView+AppearanceCategory.h"

static CGFloat const kAPHUserInfoCellTextFieldLeftMargin    = 125.0;
static CGFloat const kAPHUserInfoCellTextFieldRightMargin   = 10.0;

@implementation APHUserInfoCell

- (void) setType:(APCUserInfoCellType)type {
    [super setType:type];
    
    if (self.type == APCUserInfoCellTypeSegment) {
        [self.segmentControl setTintColor:[UIColor whiteColor]];
        [self.segmentControl setTitleTextAttributes:@{ NSFontAttributeName : [UITableView segmentControlFont]} forState:UIControlStateNormal];
        [self.segmentControl setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UITableView segmentControlTextColor]} forState:UIControlStateNormal];
        [self.segmentControl setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UITableView segmentControlSelectedTextColor]} forState:UIControlStateSelected];
    }
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (self.type == APCUserInfoCellTypeSingleInputText) {
        self.valueTextField.frame = CGRectMake(kAPHUserInfoCellTextFieldLeftMargin, (self.bounds.size.height - 30) * 0.5, self.bounds.size.width - (kAPHUserInfoCellTextFieldLeftMargin + kAPHUserInfoCellTextFieldRightMargin), 30);
    }
    else if (self.type == APCUserInfoCellTypeDatePicker) {
        self.valueTextField.frame = CGRectMake(kAPHUserInfoCellTextFieldLeftMargin, (self.bounds.size.height - 30) * 0.5, self.bounds.size.width - (kAPHUserInfoCellTextFieldLeftMargin + kAPHUserInfoCellTextFieldRightMargin), 30);
    }
    else if (self.type == APCUserInfoCellTypeSegment) {
        self.textLabel.frame = CGRectZero;
        
        CGRect frame = CGRectInset(self.bounds, -4, 0);
        self.segmentControl.frame = frame;
    }
}

@end
