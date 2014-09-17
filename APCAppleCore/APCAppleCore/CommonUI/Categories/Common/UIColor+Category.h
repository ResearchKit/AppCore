//
//  UIColor+Extension.h
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/11/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import UIKit;

@interface UIColor (Category)

+ (UIColor *) colorWith255Red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

- (BOOL) isEqualToColor:(UIColor *)otherColor;

@end
