//
//  UIFont+APCAppearance.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UIFont+APCAppearance.h"
#import "APCAppearanceInfo.h"

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

@end
