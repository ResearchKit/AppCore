// 
//  APCConfirmationView.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCConfirmationView.h"
#import "UIColor+APCAppearance.h"

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

- (instancetype)init
{
    if (self = [super init]) {
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

- (void)sharedInit
{
    self.incompleteBackgroundColor = [UIColor grayColor];
    self.completedBackgroundColor = [UIColor appTertiaryColor1];
    self.completedTickColor = [UIColor whiteColor];
}

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

- (void)drawRect:(CGRect) __unused rect
{
    CGRect  bounds = self.bounds;
    
    self.backgroundColor = [UIColor clearColor];
    
    UIEdgeInsets  insets = UIEdgeInsetsMake(insetForBorder, insetForBorder, insetForBorder, insetForBorder);
    bounds = UIEdgeInsetsInsetRect(bounds, insets);
    
    UIBezierPath  *path = [UIBezierPath bezierPathWithOvalInRect:bounds];
    
    if (self.isCompleted == NO) {
        [self.incompleteBackgroundColor set];
        [path stroke];
    } else {
        [self.completedBackgroundColor set];
        [path fill];
        [path stroke];
        [self createPath:path withDimension:CGRectGetWidth(bounds)];
        [self.completedTickColor set];
        [path fill];
    }
}

- (void)setCompleted:(BOOL)completed
{
    _completed = completed;
    [self setNeedsDisplay];
}

@end
