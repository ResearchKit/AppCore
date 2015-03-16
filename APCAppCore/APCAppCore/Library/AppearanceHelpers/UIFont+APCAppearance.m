// 
//  UIFont+APCAppearance.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "UIFont+APCAppearance.h"
#import "APCAppearanceInfo.h"
#import "APCConstants.h"

@implementation UIFont (APCAppearance)

+ (UIFont*) appRegularFontWithSize: (CGFloat) size
{
    return [UIFont fontWithName:[APCAppearanceInfo valueForAppearanceKey:kRegularFontNameKey] size:size];
}

+ (UIFont*) appMediumFontWithSize: (CGFloat) size
{
    return [UIFont fontWithName:[APCAppearanceInfo valueForAppearanceKey:kMediumFontNameKey] size:size];
}

+ (UIFont*) appLightFontWithSize: (CGFloat) size
{
    return [UIFont fontWithName:[APCAppearanceInfo valueForAppearanceKey:kLightFontNameKey] size:size];
}

+ (UIFont*) appNavBarTitleFont {
    return [UIFont appMediumFontWithSize:17.0f];
}

+ (UIFont*) appQuestionLabelFont {
    return [UIFont appRegularFontWithSize:19.0f];
}

+ (UIFont*) appQuestionOptionFont {
    return [UIFont appRegularFontWithSize:44.0f];
}

@end
