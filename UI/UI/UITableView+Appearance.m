//
//  UITableView+AppearanceCategory.m
//  UI
//
//  Created by Karthik Keyan on 9/5/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UITableView+Appearance.h"

@implementation UITableView (Appearance)

+ (UIFont *) footerFont {
    return [UIFont systemFontOfSize:14];
}

+ (UIColor *) footerTextColor {
    return [UIColor lightGrayColor];
}

+ (UIFont *) textLabelFont {
    return [UIFont systemFontOfSize:16];
}

+ (UIColor *) textLabelTextColor {
    return [UIColor colorWithRed:45/255.0 green:180/255.0 blue:251/255.0 alpha:1.0];
}

+ (UIFont *) detailLabelFont {
    return [UIFont systemFontOfSize:16];
}

+ (UIColor *) detailLabelTextColor {
    return [UIColor grayColor];
}

+ (UIFont *) textFieldFont {
    return [UIFont systemFontOfSize:16];
}

+ (UIColor *) textFieldTextColor {
    return [UIColor colorWithRed:37/255.0 green:45/255.0 blue:52/255.0 alpha:1.0];
}

+ (UIFont *) segmentControlFont {
    return [UIFont systemFontOfSize:16];
}

+ (UIColor *) segmentControlTextColor {
    return [UIColor colorWithRed:146/255.0 green:146/255.0 blue:146/255.0 alpha:1.0];
}

+ (UIColor *) segmentControlSelectedTextColor {
    return [UIColor colorWithRed:45/255.0 green:180/255.0 blue:251/255.0 alpha:1.0];
}

+ (CGFloat) controlsBorderWidth {
    return 1.0;
}

+ (UIColor *) controlsBorderColor {
    return [UIColor colorWithWhite:0.8 alpha:0.5];
}

@end
