//
//  APCThinLineView.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCHorizontalThinLineView.h"
#import <QuartzCore/QuartzCore.h>

@implementation APCHorizontalThinLineView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    CALayer *TopBorder = [CALayer layer];
    TopBorder.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 0.2f);
    TopBorder.backgroundColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1].CGColor;
    [self.layer addSublayer:TopBorder];
}


@end
