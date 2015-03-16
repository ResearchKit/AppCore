// 
//  UIFont+APCAppearance.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

@interface UIFont (APCAppearance)

+ (UIFont*) appRegularFontWithSize: (CGFloat) size;
+ (UIFont*) appMediumFontWithSize: (CGFloat) size;
+ (UIFont*) appLightFontWithSize: (CGFloat) size;
+ (UIFont*) appNavBarTitleFont;
+ (UIFont*) appQuestionLabelFont;
+ (UIFont*) appQuestionOptionFont;

@end
