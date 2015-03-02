// 
//  APHTheme.m 
//  MyHeart Counts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APCTheme.h"

@implementation APCTheme

+ (UIColor *)colorForRightCellBorder
{
    return [UIColor colorWithRed:0.757 green:0.094 blue:0.129 alpha:1.000];
}

+ (CGFloat)widthForRightCellBorder
{
    return 4.0;
}

+ (UIColor *)colorForDividerLine
{
    return [UIColor colorWithWhite:0.836 alpha:1.000];
}

+ (CGFloat)widthForDividerLine
{
    return 0.5;
}

+ (UIColor *)colorForActivityOutline
{
    return [UIColor colorWithWhite:0.973 alpha:1.000];
}

+ (UIColor *)colorForActivitySleep
{
    return [UIColor colorWithRed:0.145 green:0.851 blue:0.443 alpha:1.000];
}

+ (UIColor *)colorForActivityInactive
{
    return [UIColor colorWithRed:0.176 green:0.706 blue:0.980 alpha:1.000];
}

+ (UIColor *)colorForActivitySedentary
{
    return [UIColor colorWithRed:0.608 green:0.196 blue:0.867 alpha:1.000];
}

+ (UIColor *)colorForActivityModerate
{
    return [UIColor colorWithRed:0.957 green:0.745 blue:0.290 alpha:1.000];
}

+ (UIColor *)colorForActivityVigorous
{
    return [UIColor colorWithRed:0.937 green:0.267 blue:0.380 alpha:1.000];
}

@end
