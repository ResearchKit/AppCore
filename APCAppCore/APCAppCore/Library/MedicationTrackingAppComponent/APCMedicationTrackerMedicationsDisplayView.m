//
//  APCMedicationTrackerMedicationsDisplayView.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationTrackerMedicationsDisplayView.h"

@implementation APCMedicationTrackerMedicationsDisplayView

- (void)drawRect:(CGRect)rect
{
    CGContextRef  context = UIGraphicsGetCurrentContext();

    CGRect  bounds = self.bounds;

    CGFloat  disp = CGRectGetWidth(bounds) / 7.0;

    CGFloat  y1 = CGRectGetMinY(bounds) + 1.0;
    CGFloat  y2 = CGRectGetMaxY(bounds);
    for (NSUInteger  i = 0;  i < 7;  i++) {
        CGFloat  x = (i + 1) * disp - disp / 2.0;
        CGContextMoveToPoint(context, x, y1);
        CGContextAddLineToPoint(context, x, y2);
    }
    [[UIColor lightGrayColor] set];
    CGContextSetLineWidth(context, 2.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGFloat  dashes[] = { 0.0, 8.0 };
    CGContextSetLineDash (context, 0.0, dashes, 2);
    CGContextStrokePath(context);
}

@end
