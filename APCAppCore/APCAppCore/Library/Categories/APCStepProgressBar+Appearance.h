// 
//  APCStepProgressBar+Appearance.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCStepProgressBar.h"

@interface APCStepProgressBar (Appearance)

// Left Label
+ (UIFont *) leftLabelFont;

+ (UIColor *) leftLabelTextColor;


// Right Label
+ (UIFont *) rightLabelFont;

+ (UIColor *) rightLabelTextColor;


// Progress Bar
+ (UIColor *) progressBarTrackTintColor;

+ (UIColor *) progressBarProgressTintColor;

@end
