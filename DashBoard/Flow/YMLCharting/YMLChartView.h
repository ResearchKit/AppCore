//
//  YMLChartView.h
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/19/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLChartEnumerations.h"
#import "YMLAxisFormatter.h"

extern NSString * const kYMLChartToolTipWillAppear;
extern NSString * const kYMLChartToolTipDidAppear;

@class YMLAxisView;
@class YMLPlotView;
@interface YMLChartView : UIView

// optional custom background view (guaranteed to be behind other layers), default = nil
@property (nonatomic, strong) UIView *backgroundView;
// view that holds value labels for all plots (guaranteed to be above all plots), to be used only by YMLPlotView subclasses
@property (nonatomic, strong, readonly) UIView *labelContainerView;
//tool tip view might need repositioning in subclasses
@property (nonatomic, strong) UIView *toolTip;
// show/hide no data label
- (void)showNoDataLabel:(BOOL)show;
- (void)showNoDataLabel:(BOOL)show animated:(BOOL)animated;
- (BOOL)updateToolTip:(id)recognizer;
- (void)removeToolTip;

@property (nonatomic) UIFont *noDataFont;
@property (nonatomic) UIColor *noDataTextColor;
@property (nonatomic) UIColor *noDataShadowColor;
@property (nonatomic) CGSize noDataShadowOffset;
@property (nonatomic, strong) UILabel *noDataLabel;

@property (nonatomic) BOOL supportsToolTips;
@property (nonatomic) BOOL showToolTipOnTouchDown;
// Whether individual chart items can be selected with a tap (default NO)
@property (nonatomic, assign) BOOL supportsSelection;

// if parent is scroll view and we're using a pan gesture recognizer, we need to not conflict with scroll view panning
// If YES we'll ignore pan gestures that have sufficient initial velocity (and assume user is panning scroll view)
// default = NO for both
@property (nonatomic, assign, getter = isInHorizontalScrollView) BOOL inHorizontalScrollView;
@property (nonatomic, assign, getter = isInVerticalScrollView) BOOL inVerticalScrollView;

- (void)addPlot:(YMLPlotView *)plot withScaleAxis:(YMLAxisPosition)scalePosition titleAxis:(YMLAxisPosition)titlePosition;

// fetch the axis along the specified side
- (YMLAxisView *)axisViewForPosition:(YMLAxisPosition)position;
- (YMLAxisView *)axisViewForPosition:(YMLAxisPosition)position atIndex:(NSUInteger)index;

// fetch the axis along the specified side
- (NSArray *)axisViewsForPosition:(YMLAxisPosition)position;

- (void)addAxisView:(YMLAxisView *)axisView toPosition:(YMLAxisPosition)position;

// set an axis formatter for specified side
- (void)setAxisFormatter:(id<YMLAxisFormatter>)axisFormatter forPosition:(YMLAxisPosition)position;

- (NSArray *)plots;

@end
