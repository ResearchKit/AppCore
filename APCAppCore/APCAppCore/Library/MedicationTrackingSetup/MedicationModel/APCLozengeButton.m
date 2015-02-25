//
//  APCLozengeButton.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCLozengeButton.h"

#import "APCMedTrackerPrescription.h"
#import "APCMedTrackerPrescription+Helper.h"

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

#pragma  mark  -  Initialisation

+ (instancetype)buttonWithType:(UIButtonType)buttonType
{
    APCLozengeButton  *button = [super buttonWithType:buttonType];
    CALayer  *layer    = button.layer;
    layer.borderWidth  = kLayerBorderWidth;
    layer.cornerRadius = kLayerCornerRadius;
    return  button;
}

#pragma  mark  -  Custom Setter for Prescription

- (void)assignPrescription:(APCMedTrackerPrescription *)aPrescription forDate:(NSDate *)aDate
{
    _prescription = aPrescription;
    self.dailyDosageRecord = nil;
    
    [aPrescription fetchDosesTakenFromDate: aDate
                                    toDate: aDate
                           andUseThisQueue: [NSOperationQueue mainQueue]
                          toDoThisWhenDone: ^(APCMedTrackerPrescription *prescription,
                                              NSArray *dailyDosageRecords,
                                              NSTimeInterval operationDuration,
                                              NSError *error)
     {
         if ([dailyDosageRecords count] == 0) {
             NSLog(@"APCLozengeButton dailyDosageRecords count = 0, error = %@", error);
         } else {
             self.dailyDosageRecord = dailyDosageRecords.firstObject;
         }
     }];
        // Concept:
//    self.numPillsSoFarToday = [prescription numPillsForDate: aDate];
//    
//    
//    [_prescription recordThisManyDoses: 0
//        takenOnDate: aDate
//   andUseThisQueue: [NSOperationQueue mainQueue]
//  toDoThisWhenDone: ^(NSTimeInterval operationDuration,
//                                          NSError *error)
//     {
//     }];
}

#pragma  mark  -  Assign Prescription Information

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
    
    self.backgroundColor = [UIColor clearColor];
    
    UIBezierPath  *path = [UIBezierPath bezierPath];
    
    if ([self.numberOfDosesTaken unsignedIntegerValue] == [self.prescription.numberOfTimesPerDay unsignedIntegerValue]) {
        [self setTitle:@"" forState:UIControlStateNormal];
        UIColor  *background = [self.completedBorderColor colorWithAlphaComponent:0.75];
        CALayer  *layer = self.layer;
        layer.backgroundColor = [background CGColor];
        
        [self.completedBorderColor set];
        [path stroke];
        
        [self makePath:path withDimension:self.bounds];
        [[UIColor whiteColor] set];
        [path fill];
    } else {
        NSNumber  *numberOfTimes = self.prescription.numberOfTimesPerDay;
        NSString  *aTitle = [NSString stringWithFormat:@"%lu\u2009/\u2009%lu", [self.numberOfDosesTaken unsignedIntegerValue], [numberOfTimes unsignedIntegerValue]];
        [self setTitle:aTitle forState:UIControlStateNormal];
    }
}

#pragma  mark  -  Custom Setters

- (void)setNumberOfDosesTaken:(NSNumber *)aNumber
{
    _numberOfDosesTaken = aNumber;
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
