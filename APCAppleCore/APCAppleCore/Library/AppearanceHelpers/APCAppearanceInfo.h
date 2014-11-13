//
//  APCAppearanceInfo.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//Fonts - should return UIFont
static NSString *const kRegularFontNameKey = @"RegularFontNameKey";
static NSString *const kMediumFontNameKey  = @"MediumFontNameKey";
static NSString *const kLightFontNameKey   = @"LightFontNameKey";

//Color - should return UIColor
static NSString *const kPrimaryAppColorKey = @"PrimaryAppColorKey";

static NSString *const kSecondaryColor1Key = @"SecondaryColor1Key";
static NSString *const kSecondaryColor2Key = @"SecondaryColor2Key";
static NSString *const kSecondaryColor3Key = @"SecondaryColor3Key";
static NSString *const kSecondaryColor4Key = @"SecondaryColor4Key";

static NSString *const kTertiaryColor1Key = @"TertiaryColor1Key";
static NSString *const kTertiaryColor2Key = @"TertiaryColor2Key";

static NSString *const kTertiaryGreenColorKey  = @"TertiaryGreenColorKey";
static NSString *const kTertiaryBlueColorKey   = @"TertiaryBlueColorKey";
static NSString *const kTertiaryRedColorKey    = @"TertiaryRedColorKey";
static NSString *const kTertiaryYellowColorKey = @"TertiaryYellowColorKey";
static NSString *const kTertiaryPurpleColorKey = @"TertiaryPurpleColorKey";
static NSString *const kTertiaryGrayColorKey   = @"TertiaryGrayColorKey";

@interface APCAppearanceInfo : NSObject

+ (void) setAppearanceDictionary: (NSDictionary*) appearanceDictionary;
+ (id) valueForAppearanceKey: (NSString*) key;
@end
