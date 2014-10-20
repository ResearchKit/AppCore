//
//  UIColor+APCAppearance.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UIColor+APCAppearance.h"
#import "APCAppearanceInfo.h"

@implementation UIColor (APCAppearance)

//Appearance Methods
+ (UIColor *)appPrimaryColor
{
    return [APCAppearanceInfo valueForAppearanceKey:kPrimaryAppColorKey];
}

+ (UIColor *)appSecondaryColor1
{
    return [APCAppearanceInfo valueForAppearanceKey:kSecondaryColor1Key];
}

+ (UIColor *)appSecondaryColor2
{
    return [APCAppearanceInfo valueForAppearanceKey:kSecondaryColor2Key];
}

+ (UIColor *)appSecondaryColor3
{
    return [APCAppearanceInfo valueForAppearanceKey:kSecondaryColor3Key];
}

+ (UIColor *)appSecondaryColor4
{
    return [APCAppearanceInfo valueForAppearanceKey:kSecondaryColor4Key];
}

+ (UIColor *) appTertiaryColor1
{
    return [APCAppearanceInfo valueForAppearanceKey:kTertiaryColor1Key];
}
+ (UIColor *) appTertiaryColor2
{
    return [APCAppearanceInfo valueForAppearanceKey:kTertiaryColor2Key];
}

@end
