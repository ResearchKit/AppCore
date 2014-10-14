//
//  UIFont+APCAppearance.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UIFont+APCAppearance.h"
#import "APCAppearanceInfo.h"

@implementation UIFont (APCAppearance)

+(id)appFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:[APCAppearanceInfo valueForAppearanceKey:kNormalFontNameKey] size:size];
}

+ (id)appBoldFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:[APCAppearanceInfo valueForAppearanceKey:kBoldFontNameKey] size:size];
}

@end
