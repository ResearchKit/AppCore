//
//  UIColor+Extension.m
//  Tourean
//
//  Created by Karthik Keyan B on 10/30/12.
//  Copyright (c) 2012 vivekrajanna@gmail.com. All rights reserved.
//

#import "UIColor+Category.h"

@implementation UIColor (Category)

+ (UIColor *) colorWith255Red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

+ (UIColor *) titleColor {
    UIColor *color;
    if (!color) {
        color = [UIColor colorWith255Red:60 green:61 blue:160 alpha:1.0];
    }
    
    return color;
}

+ (UIColor *) textColor {
    UIColor *color;
    if (!color) {
        color = [UIColor colorWith255Red:102 green:102 blue:102 alpha:1.0];
    }
    
    return color;
}

+ (UIColor *) errorTextColor {
    UIColor *color;
    if (!color) {
        color = [UIColor colorWith255Red:204 green:0 blue:0 alpha:1.0];
    }
    
    return color;
}

+ (UIColor *) textInputColor {
    UIColor *color;
    if (!color) {
        color = [UIColor colorWith255Red:70 green:70 blue:70 alpha:1.0];
    }
    
    return color;
}

+ (UIColor *) placeHolderColor {
    UIColor *color;
    if (!color) {
        color = [UIColor colorWith255Red:70 green:70 blue:70 alpha:1.0];
    }
    
    return color;
}

+ (UIColor *) hintTextColor {
    UIColor *color;
    if (!color) {
        color = [UIColor colorWith255Red:120 green:120 blue:120 alpha:1.0];
    }
    
    return color;
}

- (BOOL)isEqualToColor:(UIColor *)otherColor {
    CGColorSpaceRef colorSpaceRGB = CGColorSpaceCreateDeviceRGB();
    
    UIColor *(^convertColorToRGBSpace)(UIColor*) = ^(UIColor *color) {
        if(CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelMonochrome) {
            const CGFloat *oldComponents = CGColorGetComponents(color.CGColor);
            CGFloat components[4] = {oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1]};
            CGColorRef colorRef = CGColorCreate( colorSpaceRGB, components );
            
            UIColor *color = [UIColor colorWithCGColor:colorRef];
            CGColorRelease(colorRef);
            return color;
        } else
            return color;
    };
    
    UIColor *selfColor = convertColorToRGBSpace(self);
    otherColor = convertColorToRGBSpace(otherColor);
    CGColorSpaceRelease(colorSpaceRGB);
    
    return [selfColor isEqual:otherColor];
}

@end
