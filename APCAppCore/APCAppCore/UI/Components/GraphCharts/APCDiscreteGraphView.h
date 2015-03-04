//
//  APCDiscreteGraphView.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCBaseGraphView.h"

FOUNDATION_EXPORT NSString * const kAPCDiscreteGraphViewTriggerAnimationsNotification;
FOUNDATION_EXPORT NSString * const kAPCDiscreteGraphViewRefreshNotification;

@protocol APCDiscreteGraphViewDataSource;
@protocol APCDiscreteGraphViewDelegate;
@class APCRangePoint;

@interface APCDiscreteGraphView : APCBaseGraphView

@property (nonatomic, weak) IBOutlet id <APCDiscreteGraphViewDataSource> datasource;

@property (nonatomic) BOOL shouldConnectRanges;

@end

@protocol APCDiscreteGraphViewDataSource <NSObject>

@required

- (NSInteger)discreteGraph:(APCDiscreteGraphView *)graphView numberOfPointsInPlot:(NSInteger)plotIndex;

- (APCRangePoint *)discreteGraph:(APCDiscreteGraphView *)graphView plot:(NSInteger)plotIndex valueForPointAtIndex:(NSInteger)pointIndex;

@optional

- (NSInteger)numberOfPlotsInDiscreteGraph:(APCDiscreteGraphView *)graphView;

- (NSInteger)numberOfDivisionsInXAxisForGraph:(APCDiscreteGraphView *)graphView;

- (CGFloat)maximumValueForDiscreteGraph:(APCDiscreteGraphView *)graphView;

- (CGFloat)minimumValueForDiscreteGraph:(APCDiscreteGraphView *)graphView;

- (NSString *)discreteGraph:(APCDiscreteGraphView *)graphView titleForXAxisAtIndex:(NSInteger)pointIndex;

@end

/******************************/
/*  Range Point Interface     */
/******************************/

@interface APCRangePoint : NSObject

@property (nonatomic) CGFloat maximumValue;

@property (nonatomic) CGFloat minimumValue;

@property (nonatomic, getter=isEmpty) BOOL empty;

- (instancetype)initWithMinimumValue:(CGFloat)minValue maximumValue:(CGFloat)maxValue;

- (BOOL)isRangeZero;

@end

