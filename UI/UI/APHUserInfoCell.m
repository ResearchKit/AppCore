//
//  APHUserInfoCell.m
//  UI
//
//  Created by Karthik Keyan on 9/5/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHUserInfoCell.h"
#import "UITableView+AppearanceCategory.h"

@implementation APHUserInfoCell

- (UISegmentedControl *) segmentControl {
    UISegmentedControl *segmentControl = [super segmentControl];
    
    [segmentControl setTintColor:[UIColor whiteColor]];
    [segmentControl setTitleTextAttributes:@{ NSFontAttributeName : [UITableView segmentControlFont]} forState:UIControlStateNormal];
    [segmentControl setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UITableView segmentControlTextColor]} forState:UIControlStateNormal];
    [segmentControl setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UITableView segmentControlSelectedTextColor]} forState:UIControlStateSelected];
    
    return segmentControl;
}

@end
