//
//  APCHorizontalBottomThinLineView.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCHorizontalBottomThinLineView.h"

static CGFloat const kLineThickness = 0.5f;

@implementation APCHorizontalBottomThinLineView

- (void)layoutSubviews {
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = kLineThickness;
    border.borderColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1].CGColor;
    border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, self.frame.size.height);
    border.borderWidth = borderWidth;
    [self.layer addSublayer:border];
    self.layer.masksToBounds = YES;
}

@end
