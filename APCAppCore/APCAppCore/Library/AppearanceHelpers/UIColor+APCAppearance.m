// 
//  UIColor+APCAppearance.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "UIColor+APCAppearance.h"
#import "APCAppearanceInfo.h"
#import "APCConstants.h"

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



+ (UIColor *)appTertiaryGreenColor
{
    return [APCAppearanceInfo valueForAppearanceKey:kTertiaryGreenColorKey];
}

+ (UIColor *)appTertiaryBlueColor
{
    return [APCAppearanceInfo valueForAppearanceKey:kTertiaryBlueColorKey];
}

+ (UIColor *)appTertiaryRedColor
{
    return [APCAppearanceInfo valueForAppearanceKey:kTertiaryRedColorKey];
}

+ (UIColor *)appTertiaryYellowColor
{
    return [APCAppearanceInfo valueForAppearanceKey:kTertiaryYellowColorKey];
}

+ (UIColor *)appTertiaryPurpleColor
{
    return [APCAppearanceInfo valueForAppearanceKey:kTertiaryPurpleColorKey];
}

+(UIColor *)appTertiaryGrayColor
{
    return [APCAppearanceInfo valueForAppearanceKey:kTertiaryGrayColorKey];
}

+ (UIColor *)tertiaryColorForString:(NSString *)colorName
{
    UIColor *color;
    
    if ([colorName isEqualToString:@"blue"]) {
        color = [UIColor appTertiaryBlueColor];
    } else if ([colorName isEqualToString:@"red"]){
        color = [UIColor appTertiaryRedColor];
    } else if ([colorName isEqualToString:@"green"]){
        color = [UIColor appTertiaryGreenColor];
    } else if ([colorName isEqualToString:@"yellow"]){
        color = [UIColor appTertiaryYellowColor];
    } else if ([colorName isEqualToString:@"purple"]){
        color = [UIColor appTertiaryPurpleColor];
    } else if ([colorName isEqualToString:@"appColor"]){
        color = [UIColor appPrimaryColor];
    } else {
        color = [UIColor appTertiaryGrayColor];
    }
    
    return color;
}


@end
