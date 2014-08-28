//
//  YMLTimeLineChartView.h
//  Flow
//
//  Created by Karthik Keyan on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "YMLChartEnumerations.h"

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class YMLTimeLineChartBarLayer;

#pragma mark - YMLTimeLineChartView

@protocol YMLTimeLineChartViewDataSource, YMLTimeLineChartViewDelegate;

@interface YMLTimeLineChartView : UIView

@property (nonatomic, readonly) YMLChartOrientation orientation;

@property (nonatomic, readwrite) CGFloat distanceBetweenBars;

@property (nonatomic, weak) id<YMLTimeLineChartViewDataSource> datasource;

@property (nonatomic, weak) id<YMLTimeLineChartViewDelegate> delegate;


- (instancetype) initWithFrame:(CGRect)frame orientation:(YMLChartOrientation)orientation;

- (void) redrawCanvas;

- (void) addBar:(YMLTimeLineChartBarLayer *)barLayer fromUnit:(CGFloat)fromUnit toUnit:(CGFloat)toUnit animation:(BOOL)animation;

@end


@protocol YMLTimeLineChartViewDataSource <NSObject>

- (NSArray *) timeLineChartViewUnits:(YMLTimeLineChartView *)chartView;

- (NSString *) timeLineChartView:(YMLTimeLineChartView *)chartView titleAtIndex:(NSInteger)index;

@end


@protocol YMLTimeLineChartViewDelegate <NSObject>

- (void) timeLineChartView:(YMLTimeLineChartView *)chartView didBeginPointer:(YMLChartAxisPosition)axis;

@end


#pragma mark - YMLTimeLineChartBarLayer

@interface YMLTimeLineChartBarLayer : CAShapeLayer

@end
