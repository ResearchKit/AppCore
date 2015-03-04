//
//  APCMedicationTrackerMedicationsDisplayView.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationTrackerMedicationsDisplayView.h"

#import "APCMedTrackerPrescription.h"

#import "APCMedTrackerMedication+Helper.h"
#import "APCMedTrackerPrescription+Helper.h"
#import "APCMedTrackerPossibleDosage+Helper.h"
#import "APCMedTrackerPrescriptionColor+Helper.h"

#import "APCMedTrackerDailyDosageRecord.h"

#import "UIFont+APCAppearance.h"
#import "NSDate+MedicationTracker.h"
#import "NSDate+Helper.h"

#import "APCLozengeButton.h"

#import "APCAppCore.h"

static  CGFloat  kLozengeButtonWidth     = 38.0;
static  CGFloat  kLozengeButtonHeight    = 29.0;
static  CGFloat  kLozengeBaseYCoordinate = 10.0;
static  CGFloat  kLozengeBaseYStepOver   = 49.0;

static  CGFloat  kWaterfallDashOnValue   = 11.0;
static  CGFloat  kWaterfallDashOffValue  =  7.0;

static  CGFloat  kLozengeTextPointSize   = 14.0;

static  NSString   *daysOfWeekNames[]    = { @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday" };
static  NSUInteger  numberOfDaysOfWeek   = (sizeof(daysOfWeekNames) / sizeof(NSString *));

@interface  APCMedicationTrackerMedicationsDisplayView  ( )

@end

@implementation APCMedicationTrackerMedicationsDisplayView

#pragma   mark  -  Initialisation

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
    }
    return  self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self != nil) {
    }
    return  self;
}

#pragma   mark  -  Lozenge Button Action Method

- (void)lozengeButtonWasTapped:(APCLozengeButton *)sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(displayView:lozengeButtonWasTapped:)] == YES) {
            [self.delegate performSelector:@selector(displayView:lozengeButtonWasTapped:) withObject:sender];
        }
    }
}

#pragma   mark  -  Custom Initialisation Method for Medication Models

- (void)makePrescriptionDisplaysWithPrescriptions:(NSArray *)thePrescriptions andDate:(NSDate *)aDate
{
    self.prescriptions = thePrescriptions;
    self.startOfWeekDate = aDate;
    
    for (APCMedTrackerPrescription *prescription in self.prescriptions) {
        
        [prescription fetchDosesTakenFromDate: self.startOfWeekDate
                                       toDate: [self.startOfWeekDate dateByAddingDays: 6]
                              andUseThisQueue: [NSOperationQueue mainQueue]
                             toDoThisWhenDone: ^(APCMedTrackerPrescription *prescriptionBeingFetched,
                                                 NSArray *dailyDosageRecords,
                                                 NSTimeInterval __unused operationDuration,
                                                 NSError *error)
         {
             if (error)
             {
                 APCLogError2(error);
             }
             else
             {
                 [self makeLozengesLayoutForPrescription: prescriptionBeingFetched
                                 usingDailyDosageRecords: dailyDosageRecords];
             }
         }];
    }
}

#pragma   mark  -  Refesh Method for Medication Models

- (void)refreshWithPrescriptions:(NSArray *)thePrescriptions andDate:(NSDate *)aDate
{
    NSArray  *subviews = self.subviews;
    [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self makePrescriptionDisplaysWithPrescriptions:thePrescriptions andDate:aDate];
}

#pragma   mark  -  Create Lozenge Button

- (APCLozengeButton *)medicationLozengeCenteredAtPoint:(CGPoint)point andColor:(UIColor *)color
{
    APCLozengeButton  *lozenge = [APCLozengeButton buttonWithType:UIButtonTypeCustom];
    CGRect  frame = CGRectMake(0.0, 0.0, kLozengeButtonWidth, kLozengeButtonHeight);
    frame.origin = point;
    frame.origin.x = point.x - (kLozengeButtonWidth / 2.0);
    lozenge.frame = frame;
    
    [lozenge setTitleColor:color forState:UIControlStateNormal];
    [[lozenge titleLabel] setFont:[UIFont appRegularFontWithSize:kLozengeTextPointSize]];
    lozenge.lozengeColor = color;
    
    [lozenge addTarget:self action:@selector(lozengeButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return  lozenge;
}

#pragma   mark  -  Create Lozenge Buttons     kLozengeTextPointSize

- (void)makeLozengesLayoutForPrescription: (APCMedTrackerPrescription *) prescription
                  usingDailyDosageRecords: (NSArray *) dailyDosageRecords

{
    NSDictionary  *map = @{ @"Monday" : @(0.0), @"Tuesday" : @(1.0), @"Wednesday" : @(2.0), @"Thursday" : @(3.0), @"Friday" : @(4.0), @"Saturday" : @(5.0), @"Sunday" : @(6.0) };
    
    CGFloat  displacement = CGRectGetWidth(self.bounds) / 7.0;
    
    CGFloat  baseYCoordinate = kLozengeBaseYCoordinate;
    
    NSUInteger lozengeRow = [self.prescriptions indexOfObject: prescription];
    CGFloat  yCoordinate = baseYCoordinate + lozengeRow * kLozengeBaseYStepOver;
    
    NSDictionary  *dictionary = prescription.frequencyAndDays;
    
    for (NSUInteger  day = 0;  day < numberOfDaysOfWeek;  day++) {
        NSDate  *currentDate = [self.startOfWeekDate dateByAddingDays:day];
        NSString  *dayOfWeek = daysOfWeekNames[day];
        NSNumber  *number = dictionary[dayOfWeek];
        if ([number integerValue] > 0) {
            CGFloat  xPosition = ([map[dayOfWeek] floatValue] + 1) * displacement - displacement / 2.0;
            UIColor  *color = prescription.color.UIColor;
            
            APCLozengeButton  *lozenge = [self medicationLozengeCenteredAtPoint:CGPointMake(xPosition, yCoordinate) andColor:color];
            
            APCMedTrackerDailyDosageRecord  *record = nil;
            
            for (APCMedTrackerDailyDosageRecord *thisRecord in dailyDosageRecords) {
                if ([thisRecord.dateThisRecordRepresents.startOfDay isEqualToDate: currentDate.startOfDay]) {
                    record = thisRecord;
                    break;
                }
            }
            if (record != nil) {
                lozenge.dailyDosageRecord = record;
            } else {
                lozenge.dailyDosageRecord = nil;
            }
            lozenge.prescription = prescription;
            lozenge.currentDate = currentDate;
            [self addSubview:lozenge];
        }
    }
}

#pragma   mark  -  Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef  context = UIGraphicsGetCurrentContext();

    CGRect  bounds = self.bounds;

    CGFloat  disp = CGRectGetWidth(bounds) / 7.0;

    CGFloat  y1 = CGRectGetMinY(bounds) + 1.0;
    CGFloat  y2 = CGRectGetMaxY(bounds);
    for (NSUInteger  i = 0;  i < 7;  i++) {
        CGFloat  x = (i + 1) * disp - disp / 2.0;
        CGContextMoveToPoint(context, x, y1);
        CGContextAddLineToPoint(context, x, y2);
    }
    [[UIColor lightGrayColor] set];
    CGContextSetLineWidth(context, 1.0);
    CGContextSetLineCap(context, kCGLineCapButt);
    CGFloat  dashes[] = { kWaterfallDashOnValue, kWaterfallDashOffValue };
    CGContextSetLineDash(context, 0.0, dashes, (sizeof(dashes) / sizeof(CGFloat)));
    CGContextStrokePath(context);
}

@end
