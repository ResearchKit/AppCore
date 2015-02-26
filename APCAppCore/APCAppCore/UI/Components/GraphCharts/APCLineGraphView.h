//
//  APCLineGraphView.h
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCBaseGraphView.h"

FOUNDATION_EXPORT NSString * const kAPCLineGraphViewTriggerAnimationsNotification;
FOUNDATION_EXPORT NSString * const kAPCLineGraphViewRefreshNotification;

@protocol APCLineGraphViewDataSource;
@protocol APCLineGraphViewDelegate;

@interface APCLineGraphView : APCBaseGraphView

@property (nonatomic, weak) IBOutlet id <APCLineGraphViewDataSource> datasource;

@end

@protocol APCLineGraphViewDataSource <NSObject>

@required

- (NSInteger)lineGraph:(APCLineGraphView *)graphView numberOfPointsInPlot:(NSInteger)plotIndex;

- (CGFloat)lineGraph:(APCLineGraphView *)graphView plot:(NSInteger)plotIndex valueForPointAtIndex:(NSInteger)pointIndex;

@optional

- (NSInteger)numberOfPlotsInLineGraph:(APCLineGraphView *)graphView;

- (NSInteger)numberOfDivisionsInXAxisForGraph:(APCLineGraphView *)graphView;

- (CGFloat)maximumValueForLineGraph:(APCLineGraphView *)graphView;

- (CGFloat)minimumValueForLineGraph:(APCLineGraphView *)graphView;

- (NSString *)lineGraph:(APCLineGraphView *)graphView titleForXAxisAtIndex:(NSInteger)pointIndex;

@end


