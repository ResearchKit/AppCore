//
//  APCVerticalThinLineView.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCVerticalThinLineView.h"

static CGFloat const kLineThickness = 0.5f;

@implementation APCVerticalThinLineView

- (void)layoutSubviews {
    CALayer *TopBorder = [CALayer layer];
    TopBorder.frame = CGRectMake(0.0f, 0.0f, kLineThickness, self.frame.size.height);
    TopBorder.backgroundColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1].CGColor;
    [self.layer addSublayer:TopBorder];
}

@end
