//
//  APHUserInfoCell.m
//  UI
//
//  Created by Karthik Keyan on 9/5/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APHUserInfoCell.h"

@implementation APHUserInfoCell

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UISegmentedControl class]]) {
        [(UISegmentedControl *)self.segmentControl setFrame:self.bounds];
    }
}

@end
