//
//  APCThinLineView.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCHorizontalThinLineView.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kLineThickness = 0.5f;
@implementation APCHorizontalThinLineView

- (void)layoutSubviews {
    CALayer *TopBorder = [CALayer layer];
    TopBorder.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, kLineThickness);
    TopBorder.backgroundColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1].CGColor;
    [self.layer addSublayer:TopBorder];
}

@end
