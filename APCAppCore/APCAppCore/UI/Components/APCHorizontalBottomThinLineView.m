//
//  APCHorizontalBottomThinLineView.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCHorizontalBottomThinLineView.h"

@implementation APCHorizontalBottomThinLineView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
//    
//    CALayer *border = [CALayer layer];
//    CGFloat borderHeight = self.frame.size.height;
//    
//    border.borderColor = [UIColor darkGrayColor].CGColor;
//    border.frame = CGRectMake(0, self.frame.size.height - borderHeight, self.frame.size.width, self.frame.size.height);
//
//    border.borderWidth = 0.5;
//    [self.layer addSublayer:border];
//    self.layer.masksToBounds = YES;
    
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 0.2;
    border.borderColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1].CGColor;
    border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, self.frame.size.height);
    border.borderWidth = borderWidth;
    [self.layer addSublayer:border];
    self.layer.masksToBounds = YES;
}


@end
