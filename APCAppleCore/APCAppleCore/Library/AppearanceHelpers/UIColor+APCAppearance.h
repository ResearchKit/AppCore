//
//  UIColor+APCAppearance.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (APCAppearance)

//Appearance Methods
+ (UIColor*) appPrimaryColor;
+ (UIColor*) appSecondaryColor;

+ (UIColor*) appTextBodyColor1;
+ (UIColor*) appTextBodyColor2;
+ (UIColor*) appTextBodyColor3;

//Helper Methods
+ (UIColor *) colorWith255Red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (UIColor *) confirmationColor;

@end
