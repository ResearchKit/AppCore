// 
//  APCStepProgressBar+Appearance.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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
