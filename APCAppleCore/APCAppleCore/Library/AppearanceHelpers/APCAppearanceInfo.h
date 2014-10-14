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
static NSString *const kNormalFontNameKey = @"NormalFontNameKey";
static NSString *const kBoldFontNameKey = @"BoldFontNameKey";

//Color - should return UIColor
static NSString *const kPrimaryColorKey = @"PrimaryColorKey";
static NSString *const kSecondaryColorKey = @"SecondaryColorKey";
static NSString *const kTextBodyColor1Key = @"TextBodyColor1Key";
static NSString *const kTextBodyColor2Key = @"TextBodyColor2Key";
static NSString *const kTextBodyColor3Key = @"TextBodyColor3Key";

@interface APCAppearanceInfo : NSObject

+ (void) setAppearanceDictionary: (NSDictionary*) appearanceDictionary;
+ (id) valueForAppearanceKey: (NSString*) key;
@end
