// 
//  APCStepProgressBar+Appearance.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCStepProgressBar+Appearance.h"
#import "UIColor+APCAppearance.h"

@implementation APCStepProgressBar (Appearance)

// Left Label
+ (UIFont *) leftLabelFont {
    return [UIFont boldSystemFontOfSize:14.0];
}

+ (UIColor *) leftLabelTextColor {
    return [UIColor blackColor];
}


// Right Label
+ (UIFont *) rightLabelFont {
    return [UIFont systemFontOfSize:12.0];
}

+ (UIColor *) rightLabelTextColor {
    return [UIColor blackColor];
}


// Progress Bar
+ (UIColor *) progressBarTrackTintColor {
    return [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
}

+ (UIColor *) progressBarProgressTintColor {
    return [UIColor appTertiaryColor1];
}

@end
