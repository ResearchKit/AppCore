//
//  APCAppearanceInfo.m
//  APCAppCore
//
//  Created by Dhanush Balachandran on 10/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppearanceInfo.h"
#import "UIColor+APCAppearance.h"
#import "APCConstants.h"

static NSDictionary * localAppearanceDictionary;

@implementation APCAppearanceInfo

+ (void) setAppearanceDictionary: (NSDictionary*) appearanceDictionary
{
    localAppearanceDictionary = appearanceDictionary;
}

// This is per Parkinson's App
+ (NSDictionary *)defaultAppearanceDictionary
{
    return @{
             //Fonts
             kRegularFontNameKey                : @"HelveticaNeue",
             kMediumFontNameKey                 : @"HelveticaNeue-Medium",
             kLightFontNameKey                  : @"HelveticaNeue-Light",
             
             //Colors
             kPrimaryAppColorKey                : [UIColor colorWithRed:0.176 green:0.706 blue:0.980 alpha:1.000],  //#2db4fa
             
             kSecondaryColor1Key                : [UIColor colorWithRed:0.145 green:0.176 blue:0.204 alpha:1.000],  //#252d34
             kSecondaryColor2Key                : [UIColor colorWithWhite:0.392 alpha:1.000],                       //#646464
             kSecondaryColor3Key                : [UIColor colorWithRed:0.557 green:0.557 blue:0.573 alpha:1.000],  //#8e8e93
             kSecondaryColor4Key                : [UIColor colorWithWhite:0.973 alpha:1.000],                       //#f8f8f8
             
             kTertiaryColor1Key                 : [UIColor colorWithRed:0.267 green:0.824 blue:0.306 alpha:1.000],  //#44d24e
             kTertiaryColor2Key                 : [UIColor blackColor], //#ff0000
             
             kTertiaryGreenColorKey : [UIColor colorWithRed:0.195 green:0.830 blue:0.443 alpha:1.000],
             kTertiaryBlueColorKey : [UIColor colorWithRed:0.132 green:0.684 blue:0.959 alpha:1.000],
             kTertiaryRedColorKey : [UIColor colorWithRed:0.919 green:0.226 blue:0.342 alpha:1.000],
             kTertiaryYellowColorKey : [UIColor colorWithRed:0.994 green:0.709 blue:0.278 alpha:1.000],
             kTertiaryPurpleColorKey : [UIColor colorWithRed:0.574 green:0.252 blue:0.829 alpha:1.000],
             kTertiaryGrayColorKey : [UIColor colorWithRed:157/255.0f green:157/255.0f blue:157/255.0f alpha:1.000]
             };
}

+ (id)valueForAppearanceKey:(NSString *)key
{
    return localAppearanceDictionary[key] ?: [self defaultAppearanceDictionary][key];
}

@end
