//
//  APCAppearanceInfo.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppearanceInfo.h"

static NSDictionary * localAppearanceDictionary;

@implementation APCAppearanceInfo

+ (void) setAppearanceDictionary: (NSDictionary*) appearanceDictionary
{
    localAppearanceDictionary = appearanceDictionary;
}

+ (NSDictionary *)defaultAppearanceDictionary
{
    return @{
             //Fonts
             kNormalFontNameKey             : @"HelveticaNeue",
             kBoldFontNameKey               : @"HelveticaNeue-Bold",
             
             //Colors - Loaded Parkinson Colors as Default
             kPrimaryColorKey               : [UIColor colorWithRed:0.167 green:0.688 blue:0.954 alpha:1.000],
             kSecondaryColorKey             : [UIColor colorWithRed:0.296 green:0.307 blue:0.326 alpha:1.000],
             
             kTextBodyColor1Key             : [UIColor colorWithWhite:0.098 alpha:1.000],
             kTextBodyColor2Key             : [UIColor colorWithWhite:0.253 alpha:1.000],
             kTextBodyColor3Key             : [UIColor colorWithWhite:0.500 alpha:1.000]
             };
}

+ (id)valueForAppearanceKey:(NSString *)key
{
    return localAppearanceDictionary[key] ?: [self defaultAppearanceDictionary][key];
}

@end
