//
//  UIColor+TertiaryColors.m
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UIColor+TertiaryColors.h"
#import "UIColor+APCAppearance.h"

@implementation UIColor (TertiaryColors)

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
    } else {
        color = [UIColor appTertiaryGrayColor];
    }
    
    return color;
}
@end
