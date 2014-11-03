//
//  APCLineGraphView.h
//  YMLCharts
//
//  Created by Ramsundar Shandilya on 10/2/14.
//  Copyright (c) 2014 Ramsundar Shandilya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCGraphConstants.h"

@protocol APCLineCharViewDataSource;
@protocol APCLineChartViewDelegate;

@interface APCLineGraphView : UIView

@property (nonatomic, weak) IBOutlet id <APCLineCharViewDataSource> datasource;

@property (nonatomic, weak) IBOutlet id <APCLineChartViewDelegate> delegate;

@property (nonatomic, readonly) CGFloat minimumValue;

@property (nonatomic, readonly) CGFloat maximumValue;

/* Appearance */

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, strong) UIColor *axisColor;

@property (nonatomic, strong) UIColor *axisTitleColor;

@property (nonatomic, strong) UIFont *axisTitleFont;

@property (nonatomic, strong) UIColor *referenceLineColor;

@property (nonatomic, strong) UIColor *scrubberThumbColor;

@property (nonatomic, strong) UIColor *scrubberLineColor;

- (NSInteger)numberOfPlots;

- (NSInteger)numberOfPointsinPlot:(NSInteger)plotIndex;

- (void)scrubReferenceLineForXPosition:(CGFloat)xPosition;

@end

@protocol APCLineCharViewDataSource <NSObject>

@required

- (NSInteger)lineGraph:(APCLineGraphView *)graphView numberOfPointsInPlot:(NSInteger)plotIndex;

- (CGFloat)lineGraph:(APCLineGraphView *)graphView plot:(NSInteger)plotIndex valueForPointAtIndex:(NSInteger)pointIndex;

@optional

- (NSInteger)numberOfPlotsInLineGraph:(APCLineGraphView *)graphView;

- (NSInteger)numberOfDivisionsInXAxisForGraph:(APCLineGraphView *)graphView;

@end


@protocol APCLineChartViewDelegate <NSObject>

- (CGFloat)maximumValueForLineGraph:(APCLineGraphView *)graphView;

- (CGFloat)minimumValueForLineGraph:(APCLineGraphView *)graphView;

- (NSString *)lineGraph:(APCLineGraphView *)graphView titleForXAxisAtIndex:(NSInteger)pointIndex;

- (void)lineGraph:(APCLineGraphView *)graphView didTouchGraphWithXPosition:(CGFloat)xPosition;
@end

