// 
//  UIColor+APCAppearance.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
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

+ (UIColor *) appBorderLineColor;

+ (UIColor *)tertiaryColorForString:(NSString *)colorName;

+ (UIColor *)colorForTaskId:(NSString *)taskId;

@end
