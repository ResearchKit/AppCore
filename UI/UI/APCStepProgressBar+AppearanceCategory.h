//
//  APCStepProgressBar+AppearanceCategory.h
//  UI
//
//  Created by Karthik Keyan on 9/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCStepProgressBar.h"

@interface APCStepProgressBar (AppearanceCategory)

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
