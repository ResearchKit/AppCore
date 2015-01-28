//
//  APCButton.m
//  APCAppCore
//
//  Created by Farhan Ahmed on 1/28/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCButton.h"
#import "UIColor+APCAppearance.h"

@implementation APCButton

- (void)sharedInit
{
    self.layer.cornerRadius = 5.0;
    //self.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    self.layer.borderColor = [[UIColor appPrimaryColor] CGColor];
    self.layer.borderWidth = 1.0;
    self.layer.masksToBounds = YES;
    
    // Appearance for normal state
    UIImage *normalBackground = [self imageWithColor:[UIColor whiteColor]];
    UIImage *selectedBackground = [self imageWithColor:[UIColor appPrimaryColor]];
    
    [self setTitleColor:[UIColor appPrimaryColor] forState:UIControlStateNormal];
    [self setBackgroundImage:normalBackground forState:UIControlStateNormal];
    
    // Highlight
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self setBackgroundImage:selectedBackground forState:UIControlStateHighlighted];
    
    // Appearance for selected state
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self setBackgroundImage:selectedBackground forState:UIControlStateSelected];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self sharedInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self sharedInit];
    }
    
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
