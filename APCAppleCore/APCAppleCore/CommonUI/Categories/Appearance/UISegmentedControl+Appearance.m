//
//  UISegmentedControl+Appearance.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/11/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UISegmentedControl+Appearance.h"

@implementation UISegmentedControl (Appearance)

+ (UIFont *) font {
    return [UIFont systemFontOfSize:16];
}

+ (UIColor *) textColor {
    return [UIColor colorWithRed:146/255.0 green:146/255.0 blue:146/255.0 alpha:1.0];
}

+ (UIColor *) selectedTextColor {
    return [UIColor colorWithRed:45/255.0 green:180/255.0 blue:251/255.0 alpha:1.0];
}

+ (UIColor *) borderColor {
    return [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0];
}


@end
