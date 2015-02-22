//
//  APCLozengeButton.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCLozengeButton.h"
#import "APCMedicationFollower.h"

static  CGFloat  kLayerBorderWidth  = 3.0;
static  CGFloat  kLayerCornerRadius = 4.0;

@implementation APCLozengeButton

static  const  CGFloat  kDesignSpace   = 1000.0;

static  short  coordinates[] = {
    'm', 252, 550,
    'l', 425, 730,
    'l', 816, 342,
    'l', 776, 300,
    'l', 425, 633,
    'l', 297, 503,
    'z'
};


+ (instancetype)buttonWithType:(UIButtonType)buttonType
{
    APCLozengeButton  *button = [super buttonWithType:buttonType];
    CALayer  *layer    = button.layer;
    layer.borderWidth  = kLayerBorderWidth;
    layer.cornerRadius = kLayerCornerRadius;
    return  button;
}

- (void)makePath:(UIBezierPath *)path withDimension:(CGRect)bounds
{
    CGFloat  dimension = CGRectGetWidth(bounds);
    CGFloat  xTranslate = 0.0;
    CGFloat  yTranslate = 0.0;
    if (CGRectGetWidth(bounds) > CGRectGetHeight(bounds)) {
        dimension = CGRectGetHeight(bounds);
        xTranslate = (CGRectGetWidth(bounds) - CGRectGetHeight(bounds)) / 2.0;
    } else if (CGRectGetWidth(bounds) < CGRectGetHeight(bounds)) {
        dimension = CGRectGetWidth(bounds);
        yTranslate = (CGRectGetHeight(bounds) - CGRectGetWidth(bounds)) / 2.0;
    }
    
    [path removeAllPoints];
    
    NSUInteger  numberOfElements = sizeof(coordinates) / sizeof(short);
    NSUInteger  position = 0;
    while (position < numberOfElements) {
        NSUInteger  delta = 0;
        short  element = coordinates[position];
        if (element == 'm' || element == 'l') {
            CGFloat  x = (coordinates[position + 1] * dimension / kDesignSpace) + xTranslate;
            CGFloat  y = (coordinates[position + 2] * dimension / kDesignSpace) + yTranslate;
            CGPoint  p = CGPointMake(x, y);
            if (element == 'm') {
                [path moveToPoint:p];
            } else {
                [path addLineToPoint:p];
            }
            delta = 3;
        } else  if (element == 'z') {
            [path closePath];
            delta = 1;
        }
        position = position + delta;
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    self.backgroundColor = [UIColor clearColor];
    
    UIBezierPath  *path = [UIBezierPath bezierPath];
    
    if (self.isCompleted == NO) {
        [self.incompleteBackgroundColor set];
        [path stroke];
    } else {
        [self.completedBackgroundColor set];
        [path fill];
        [path stroke];
        [self makePath:path withDimension:self.bounds];
        [self.completedTickColor set];
        [path fill];
    }
}

- (void)setIncompleteBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    _incompleteBackgroundColor = backgroundColor;
    CALayer  *layer = self.layer;
    layer.backgroundColor = [backgroundColor CGColor];
    [self setNeedsDisplay];
}

- (void)setIncompleteBorderColor:(UIColor *)borderColor
{
    _incompleteBorderColor = borderColor;
    CALayer  *layer = self.layer;
    layer.borderColor = [borderColor CGColor];
    [self setNeedsDisplay];
}

- (void)setIncompleteTickColor:(UIColor *)tickColor
{
    _incompleteTickColor = tickColor;
    CALayer  *layer = self.layer;
    layer.backgroundColor = [tickColor CGColor];
    [self setNeedsDisplay];
}

- (void)setCompletedBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    _completedBackgroundColor = backgroundColor;
    CALayer  *layer = self.layer;
    layer.backgroundColor = [backgroundColor CGColor];
    [self setNeedsDisplay];
}

- (void)setCompletedBorderColor:(UIColor *)borderColor
{
    _completedBorderColor = borderColor;
    CALayer  *layer = self.layer;
    layer.borderColor = [borderColor CGColor];
    [self setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    CALayer  *layer = self.layer;
    layer.backgroundColor = [self.backgroundColor CGColor];
    [self setNeedsDisplay];
}

- (void)setCompleted:(BOOL)completed
{
    _completed = completed;
    [self setNeedsDisplay];
}

@end
