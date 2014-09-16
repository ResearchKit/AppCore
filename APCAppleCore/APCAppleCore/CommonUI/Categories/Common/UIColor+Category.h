//
//  UIColor+Extension.h
//  Tourean
//
//  Created by Karthik Keyan B on 10/30/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

@import UIKit;

@interface UIColor (Category)

+ (UIColor *) colorWith255Red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

- (BOOL) isEqualToColor:(UIColor *)otherColor;

@end
