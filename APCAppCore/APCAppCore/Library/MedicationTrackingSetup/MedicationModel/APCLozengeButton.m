//
//  APCLozengeButton.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCLozengeButton.h"

#import "APCMedTrackerPrescription.h"
#import "APCMedTrackerPrescription+Helper.h"

static  CGFloat  kLayerBorderWidth  = 2.0;
static  CGFloat  kLayerCornerRadius = 6.0;

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

#pragma  mark  -  Initialisation

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

#pragma  mark  -  Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if ([self.numberOfDosesTaken unsignedIntegerValue] < [self.prescription.numberOfTimesPerDay unsignedIntegerValue]) {
        CALayer  *layer = self.layer;
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
        NSNumber  *numberOfTimes = self.prescription.numberOfTimesPerDay;
        NSString  *aTitle = [NSString stringWithFormat:@"%lu\u2009/\u2009%lu", (unsigned long)[self.numberOfDosesTaken unsignedIntegerValue], (unsigned long)[numberOfTimes unsignedIntegerValue]];
        [self setTitle:aTitle forState:UIControlStateNormal];
        [self setTitleColor:self.lozengeColor forState:UIControlStateNormal];
    } else {
        [self setTitle:@"" forState:UIControlStateNormal];
        UIColor  *background = [self.lozengeColor colorWithAlphaComponent:0.625];
        CALayer  *layer = self.layer;
        layer.backgroundColor = [background CGColor];
        
        UIBezierPath  *path = [UIBezierPath bezierPath];
        [self makePath:path withDimension:self.bounds];
        [[UIColor whiteColor] set];
        path.lineWidth = 1.0;
        [path fill];
        [path stroke];
    }
}

#pragma  mark  -  Custom Setters

- (void)setNumberOfDosesTaken:(NSNumber *)aNumber
{
    _numberOfDosesTaken = aNumber;
    [self setNeedsDisplay];
}

- (void)setLozengeColor:(UIColor *)lozengeColor
{
    _lozengeColor = lozengeColor;
    CALayer  *layer = self.layer;
    layer.borderColor = [_lozengeColor CGColor];
    [self setNeedsDisplay];
}

@end
