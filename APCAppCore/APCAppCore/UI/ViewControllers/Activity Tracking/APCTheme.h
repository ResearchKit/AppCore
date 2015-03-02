// 
//  APHTheme.h 
//  MyHeart Counts 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

@interface APCTheme : NSObject

+ (UIColor *)colorForRightCellBorder;
+ (CGFloat)widthForRightCellBorder;

+ (UIColor *)colorForDividerLine;
+ (CGFloat)widthForDividerLine;

+ (UIColor *)colorForActivityOutline;
+ (UIColor *)colorForActivitySleep;
+ (UIColor *)colorForActivityInactive;
+ (UIColor *)colorForActivitySedentary;
+ (UIColor *)colorForActivityModerate;
+ (UIColor *)colorForActivityVigorous;

@end
