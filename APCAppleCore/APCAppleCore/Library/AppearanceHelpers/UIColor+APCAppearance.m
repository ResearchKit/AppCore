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
    return [APCAppearanceInfo valueForAppearanceKey:kPrimaryColorKey];
}

+(UIColor *)appSecondaryColor
{
    return [APCAppearanceInfo valueForAppearanceKey:kSecondaryColorKey];
}

+ (UIColor *)appTextBodyColor1
{
    return [APCAppearanceInfo valueForAppearanceKey:kTextBodyColor1Key];
}

+ (UIColor *)appTextBodyColor2
{
    return [APCAppearanceInfo valueForAppearanceKey:kTextBodyColor2Key];
}

+ (UIColor *)appTextBodyColor3
{
    return [APCAppearanceInfo valueForAppearanceKey:kTextBodyColor3Key];
}

//Helper Methods
+ (UIColor *) colorWith255Red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

+ (UIColor *)confirmationColor
{
    return [UIColor colorWithRed:68/255.0f green:210/255.0f blue:70/255.0f alpha:1.0];
}



@end
