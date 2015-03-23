// 
//  APCLozengeButton.m 
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
 
#import "APCLozengeButton.h"

#import "APCMedTrackerPrescription.h"
#import "APCMedTrackerPrescription+Helper.h"
#import "APCMedTrackerDailyDosageRecord.h"

static  CGFloat  kLayerBorderWidth   = 2.0;
static  CGFloat  kLayerCornerRadius  = 6.0;

@implementation APCLozengeButton

static  const  CGFloat  kDesignSpace = 1000.0;

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
    
    NSUInteger  numberOfTakenDoses = 0;
    if (self.dailyDosageRecord != nil) {
        numberOfTakenDoses = [self.dailyDosageRecord.numberOfDosesTakenForThisDate unsignedIntegerValue];
    }
    if (numberOfTakenDoses < [self.prescription.numberOfTimesPerDay unsignedIntegerValue]) {
        CALayer  *layer = self.layer;
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
        NSNumber  *numberOfTimes = self.prescription.numberOfTimesPerDay;
        NSString  *aTitle = [NSString stringWithFormat:@"%lu\u2009/\u2009%lu", (unsigned long)numberOfTakenDoses, (unsigned long)[numberOfTimes unsignedIntegerValue]];
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

- (void)setDailyDosageRecord:(APCMedTrackerDailyDosageRecord *)aDailyDosageRecord
{
    _dailyDosageRecord = aDailyDosageRecord;
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
