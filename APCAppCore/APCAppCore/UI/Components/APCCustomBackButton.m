//
//  APCCustomBackButton.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCCustomBackButton.h"

static  const  CGFloat  kButtonWidth  = 30.0;
static  const  CGFloat  kButtonHeight = 44.0;
static  const  CGFloat  kLayerWidth   = 30.0;
static  const  CGFloat  kLayerHeight  = 44.0;

@implementation APCCustomBackButton

+ (APCCustomBackButton *)customBackButtonWithTarget:(id)aTarget action:(SEL)anAction tintColor:(UIColor *)aTintColor
{
    APCCustomBackButton  *button = [APCCustomBackButton buttonWithType:UIButtonTypeCustom];
    CGRect  frame = CGRectMake(0.0, 0.0, kButtonWidth, kButtonHeight);
    button.frame = frame;
    [button addTarget:aTarget action:anAction forControlEvents:UIControlEventTouchUpInside];
    
    CGMutablePathRef  path = CGPathCreateMutable();
    
    CGPoint  p0 = CGPointMake(13.0, 12.0);
    CGPathMoveToPoint(path, NULL, p0.x, p0.y);
    
    CGPoint  p1 = CGPointMake(2.0, 22.0);
    CGPathAddLineToPoint(path, NULL, p1.x, p1.y);
    
    CGPoint  p2 = CGPointMake(13.0, 32.0);
    CGPathAddLineToPoint(path, NULL, p2.x, p2.y);
    
    CALayer  *layer = button.layer;
    CAShapeLayer  *shaper = [[CAShapeLayer alloc] init];
    shaper.frame = CGRectMake(0.0, 0.0, kLayerWidth, kLayerHeight);
    shaper.bounds = CGRectMake(0.0, 0.0, kLayerWidth, kLayerHeight);
    shaper.path = path;
    shaper.lineWidth = 3.0;
    shaper.fillColor = [[UIColor clearColor] CGColor];
    shaper.contentsScale = [[UIScreen mainScreen] scale];
    shaper.strokeColor = aTintColor.CGColor;
    [layer addSublayer:shaper];
    return  button;
}

+ (UIBarButtonItem *)customBackBarButtonItemWithTarget:(id)aTarget action:(SEL)anAction tintColor:(UIColor *)aTintColor
{
    APCCustomBackButton  *button = [self customBackButtonWithTarget:aTarget action:anAction tintColor:aTintColor];
    UIBarButtonItem  *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    return  barButton;
}

@end
