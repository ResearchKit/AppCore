//
//  UIColor+APCAppearance.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 10/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (APCAppearance)

//Appearance Methods
+ (UIColor*) appPrimaryColor;

+ (UIColor*) appSecondaryColor1;
+ (UIColor*) appSecondaryColor2;
+ (UIColor*) appSecondaryColor3;
+ (UIColor*) appSecondaryColor4;

+ (UIColor *) appTertiaryColor1;
+ (UIColor *) appTertiaryColor2;

+ (UIColor *) appTertiaryGreenColor;
+ (UIColor *) appTertiaryPurpleColor;
+ (UIColor *) appTertiaryBlueColor;
+ (UIColor *) appTertiaryRedColor;
+ (UIColor *) appTertiaryYellowColor;
+ (UIColor *) appTertiaryGrayColor;

+ (UIColor *)tertiaryColorForString:(NSString *)colorName;

@end
