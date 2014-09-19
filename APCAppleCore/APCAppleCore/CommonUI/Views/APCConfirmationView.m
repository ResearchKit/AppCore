//
//  APHConfirmationView.m
//  Parkinson
//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCConfirmationView.h"
#import "UIColor+Parkinson.h"

static  const  CGFloat  insetForBorder = 0.5;
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

@implementation APCConfirmationView

- (void)createPath:(UIBezierPath *)path withDimension:(CGFloat)dimension
{
    [path removeAllPoints];
    
    NSUInteger  numberOfElements = sizeof(coordinates) / sizeof(short);
    
    NSUInteger  position = 0;
    while (position < numberOfElements) {
        NSUInteger  delta = 0;
        short  element = coordinates[position];
        if (element == 'm' || element == 'l') {
            CGFloat  x = coordinates[position + 1] * dimension / kDesignSpace;
            CGFloat  y = coordinates[position + 2] * dimension / kDesignSpace;
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
    CGRect  bounds = self.bounds;
    
    self.backgroundColor = [UIColor clearColor];
    
    UIEdgeInsets  insets = UIEdgeInsetsMake(insetForBorder, insetForBorder, insetForBorder, insetForBorder);
    bounds = UIEdgeInsetsInsetRect(bounds, insets);
    
    UIBezierPath  *path = [UIBezierPath bezierPathWithOvalInRect:bounds];
    
    if (self.isCompleted == NO) {
        [[UIColor grayColor] set];
        [path stroke];
    } else {
        [[UIColor parkinsonGreenColor] set];
        [path fill];
        [path stroke];
        [self createPath:path withDimension:CGRectGetWidth(bounds)];
        [[UIColor whiteColor] set];
        [path fill];
    }
}

- (void)setCompleted:(BOOL)completed
{
    _completed = completed;
    [self setNeedsDisplay];
}

@end
