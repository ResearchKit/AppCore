//
//  APCMedicationTrackerMedicationsDisplayView.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationTrackerMedicationsDisplayView.h"

#import "APCMedicationModel.h"
#import "APCMedicationFollower.h"

#import "APCLozengeButton.h"

static  CGFloat  kLozengeButtonWidth     = 40.0;
static  CGFloat  kLozengeButtonHeight    = 25.0;
static  CGFloat  kLozengeBaseYCoordinate = 10.0;
static  CGFloat  kLozengeBaseYStepOver   = 45.0;

static  NSString   *daysOfWeekNames[]    = { @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday" };
static  NSUInteger  numberOfDaysOfWeek   = (sizeof(daysOfWeekNames) / sizeof(NSString *));

@interface  APCMedicationTrackerMedicationsDisplayView  ( )

@property  (nonatomic, strong)  NSDictionary  *colormap;

@end

@implementation APCMedicationTrackerMedicationsDisplayView

#pragma   mark  -  Initialisation

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self commonInit];
    }
    return  self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self != nil) {
        [self commonInit];
    }
    return  self;
}

- (void)commonInit
{
    self.colormap = @{
                      @"Gray"    : [UIColor grayColor],
                      @"Red"     : [UIColor redColor],
                      @"Green"   : [UIColor greenColor],
                      @"Blue"    : [UIColor blueColor],
                      @"Cyan"    : [UIColor cyanColor],
                      @"Magenta" : [UIColor magentaColor],
                      @"Yellow"  : [UIColor yellowColor],
                      @"Orange"  : [UIColor orangeColor],
                      @"Purple"  : [UIColor purpleColor]
                    };
    [self makeLozengesLayout];
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

#pragma   mark  -  Custom Setter Method for Medication Models

- (void)setMedicationModels:(NSArray *)models
{
    _medicationModels = models;
    [self makeLozengesLayout];
}

#pragma   mark  -  Create Lozenge Button

- (APCLozengeButton *)medicationLozengeCenteredAtPoint:(CGPoint)point andColor:(UIColor *)color withTitle:(NSString *)title
{
    APCLozengeButton  *button = [APCLozengeButton buttonWithType:UIButtonTypeCustom];
    CGRect  frame = CGRectMake(0.0, 0.0, kLozengeButtonWidth, kLozengeButtonHeight);
    frame.origin = point;
    frame.origin.x = point.x - (kLozengeButtonWidth / 2.0);
    button.frame = frame;
    
    button.backgroundColor = [UIColor whiteColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    button.incompleteBorderColor = color;
    
    [button addTarget:self action:@selector(lozengeButtonWasTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return  button;
}

#pragma   mark  -  Create Lozenge Buttons

- (APCMedicationFollower *)makeMedicationFollowerWithModel:(APCMedicationModel *)model forDayOfWeek:(NSString *)weekday
{
    APCMedicationFollower  *follower = [[APCMedicationFollower alloc] init];
    follower.medicationName = model.medicationName;
    NSDictionary  *dictionary = model.frequencyAndDays;
    follower.numberOfDosesPrescribed = dictionary[weekday];
    return  follower;
}

- (void)makeLozengesLayout
{
    NSDictionary  *map = @{ @"Monday" : @(0.0), @"Tuesday" : @(1.0), @"Wednesday" : @(2.0), @"Thursday" : @(3.0), @"Friday" : @(4.0), @"Saturday" : @(5.0), @"Sunday" : @(6.0), };
    
    CGFloat  disp = CGRectGetWidth(self.bounds) / 7.0;
    CGFloat  baseYCoordinate = kLozengeBaseYCoordinate;
        //
        //    NSNumber objects in the code below are initalised with integer values
        //
    for (APCMedicationModel  *model  in  self.medicationModels) {
        NSDictionary  *dictionary = model.frequencyAndDays;
        for (NSUInteger  day = 0;  day < numberOfDaysOfWeek;  day++) {
            NSString  *dayOfWeek = daysOfWeekNames[day];
            NSNumber  *number = dictionary[dayOfWeek];
            if ([number integerValue] > 0) {
                CGFloat  xPosition = ([map[dayOfWeek] floatValue] + 1) * disp - disp / 2.0;
                NSString  *colorName = model.medicationLabelColor;
                UIColor  *color = self.colormap[colorName];
                APCLozengeButton  *button = [self medicationLozengeCenteredAtPoint:CGPointMake(xPosition, baseYCoordinate) andColor:color withTitle:@"0\u2009/\u20093"];
                button.follower = [self makeMedicationFollowerWithModel:model forDayOfWeek:dayOfWeek];
                button.model = model;
                [self addSubview:button];
            }
        }
        baseYCoordinate = baseYCoordinate + kLozengeBaseYStepOver;
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
    CGContextSetLineWidth(context, 2.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGFloat  dashes[] = { 0.0, 8.0 };
    CGContextSetLineDash (context, 0.0, dashes, 2);
    CGContextStrokePath(context);
}

@end
