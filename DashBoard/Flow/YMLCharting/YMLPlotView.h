//
//  YMLPlotView.h
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/19/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLChartEnumerations.h"
#import "YMLAxisFormatter.h"

// base class for plots (chart content, i.e. actual bars, lines, or pies)
@class YMLAxisView;
@class YMLChartView;
@protocol YMLPlotDelegate;
@protocol YMLPlotTouchDelegate;
@protocol YMLPlotAccessoryDelegate;

@interface YMLPlotView : UIView

// margins
@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat topMargin;
@property (nonatomic, assign) CGFloat rightMargin;
@property (nonatomic, assign) CGFloat bottomMargin;

// orientation
@property (nonatomic, readonly) YMLChartOrientation orientation;

// array of values, each value may itself an array of subvalues (in case of stacked bar chart)
@property (nonatomic, strong) NSArray *values;

// weak reference to parent chart
@property (nonatomic, weak, readonly) YMLChartView *chart;

// reserved (extra space) in plot layout
@property (nonatomic, assign) CGFloat reservedWidth;

- (YMLAxisView *)scaleAxis;
- (YMLAxisView *)titleAxis;

@property (nonatomic, assign) YMLAxisPosition scalePosition;
@property (nonatomic, assign) YMLAxisPosition titlePosition;
@property (nonatomic, assign) NSUInteger scaleIndex;
@property (nonatomic, assign) NSUInteger titleIndex;
@property (nonatomic, weak) id<YMLPlotDelegate> delegate;
@property (nonatomic, weak) id<YMLPlotTouchDelegate> touchDelegate;
@property (nonatomic, weak) id<YMLPlotAccessoryDelegate> accessoryDelegate;

- (void)addedToChart:(YMLChartView *)chart;
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath notify:(BOOL)notify;

- (id)initWithOrientation:(YMLChartOrientation)orientation;

#pragma mark - Value labels

- (UIView *)valueLabel;

// whether to show value labels for each bar (default = NO)
@property (nonatomic, assign) BOOL showLabels;
// whether to show percentage along with the value labels for each bar (default = NO)
@property (nonatomic, assign) BOOL showInLinePercentage;
// color of value label text (default = black)
@property (nonatomic, strong) UIColor* textColor;
// color of text drop shadow (default = nil)
@property (nonatomic, strong) UIColor *shadowColor;
// drop shadow offset (default = {0,1} )
@property (nonatomic, assign) CGSize shadowOffset;
// gap between bar / point / line and value label (default = {10, 10}  )
@property (nonatomic, assign) CGSize labelGap;
// font to use for value labels (default = 15 point system font)
@property (nonatomic, strong) UIFont *font;
// formatter to use for value labels (default = nil)
@property (nonatomic, assign) id<YMLAxisFormatter> formatter;
// get display text for use in value label
- (NSString *)displayValueForValue:(id)value;

- (BOOL)updateValueLabel:(UIView *)labelView atIndexPath:(NSIndexPath *)indexPath;
- (NSString *)valueLabel:(UIView *)labelView textForIndexPath:(NSIndexPath *)indexPath;
- (void)valueLabelSetNoDataStyle:(UIView *)labelView;

// string to display in case of no data (default = "No Data")
@property (nonatomic, strong) NSString *noDataString;

#pragma mark - Title labels

// TODO: for titles
// 1. position enum (topleft, center, middle right, etc.)

- (UIView *)titleLabel;

// whether to show title labels for each bar (default = YES)
@property (nonatomic, assign) BOOL showTitles;
// color of title label text (default = black)
@property (nonatomic, strong) UIColor* titleTextColor;
// color of text drop shadow (default = nil)
@property (nonatomic, strong) UIColor *titleShadowColor;
// drop shadow offset (default = {0,1} )
@property (nonatomic, assign) CGSize titleShadowOffset;
// gap between bar / point / line and value label (default = {10, 0}  )
@property (nonatomic, assign) CGSize titleGap;
// font to use for title labels (default = 15 point system font)
@property (nonatomic, strong) UIFont *titleFont;
// formatter to use for title labels (default = nil)
@property (nonatomic, assign) id<YMLAxisFormatter> titleFormatter;
// get display text for use in title label
- (NSString *)displayValueForTitle:(id)value;

// array of titles to be placed on each bar (default = nil)
@property (nonatomic, strong) NSArray *titles;

- (BOOL)updateTitleLabel:(UIView *)titleView atIndexPath:(NSIndexPath *)indexPath;
- (NSString *)titleLabel:(UIView *)titleView textForIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Percent labels

- (UIView *)percentLabel;

@property(nonatomic, assign)CGFloat maximumLabelWidth;
@property(nonatomic, assign)CGFloat miniumLabelWidth;
// whether to show value labels for each segments (default = NO)
@property (nonatomic, assign) BOOL showPercentLabels;
// color of value label text (default = black)
@property (nonatomic, strong) UIColor* percentTextColor;
// color of text drop shadow (default = nil)
@property (nonatomic, strong) UIColor *percentShadowColor;
// drop shadow offset (default = {0,1} )
@property (nonatomic, assign) CGSize percentShadowOffset;
// font to use for value labels (default = 14 point system font)
@property (nonatomic, strong) UIFont *percentFont;
// formatter to use for value labels (default = nil)
@property (nonatomic, assign) id<YMLAxisFormatter> percentageFormatter;
// get display text for use in value label
- (NSString *)displayValueForPercentLabel:(id)value;

// array of percent label values to be placed on each bar (default = nil)
@property (nonatomic, strong) NSArray *percentageValues;

- (BOOL)updatePercentLabel:(UIView *)labelView atIndexPath:(NSIndexPath *)indexPath;
- (NSString *)percentLabel:(UIView *)labelView textForIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Accessory views

// TODO: for accessory labels
// 1. position enum (topleft, center, middle right, etc.)

// whether to show accessory views for each bar (default = YES)
@property (nonatomic, assign) BOOL showAccessoryViews;
// color of accessory label text (default = black)
@property (nonatomic, assign) CGSize accessoryGap;

#pragma mark - Tooltips

- (BOOL)isPointOverFeature:(CGPoint)point;

- (NSIndexPath *)featureIndexForPoint:(CGPoint)point;

- (UIView *)toolTipView;
- (UIView *)toolTipContainerView;
- (UILabel *)toolTipLabel;
- (BOOL)updateToolTip:(UIView *)toolTip atPosition:(CGPoint)position;

- (NSString *)toolTip:(UIView *)toolTip textForIndexPath:(NSIndexPath *)indexPath;

// whether to show tips on touch down (default = NO)
@property (nonatomic, assign) BOOL showTips;
// color of tip label text (default = black)
@property (nonatomic, strong) UIColor* tipTextColor;
// color of tip text drop shadow (default = nil)
@property (nonatomic, strong) UIColor *tipTextShadowColor;
// tip drop shadow offset (default = {0,1} )
@property (nonatomic, assign) CGSize tipTextShadowOffset;
// tip background color (default = 97.5% white at 85% opacity)
@property (nonatomic, strong) UIColor *tipBackgroundColor;
// margins around tip text (default = {10, 5}  )
@property (nonatomic, assign) CGSize tipGap;
// font to use for tip labels (default = 15 point system font)
@property (nonatomic, strong) UIFont *tipFont;
// formatter to use for tip labels (default = nil)
@property (nonatomic, assign) id<YMLAxisFormatter> tipFormatter;
// whether to show titles for tip instead of value (default = NO)
@property (nonatomic, assign) BOOL useTitleForTips;

// get display text for use in tip label
- (NSString *)displayValueForTip:(id)value;

@end

#pragma mark - Delegate protocol

@protocol YMLPlotDelegate<NSObject>

@optional

// value labels
- (UIView *)plotView:(YMLPlotView *)plotView labelForSliceAtIndex:(NSUInteger)slice;
- (void)plotView:(YMLPlotView *)plotView updateLabel:(UIView *)labelView forSliceAtIndex:(NSUInteger)slice;
- (BOOL)plotView:(YMLPlotView *)plotView label:(UIView *)label1 intersectsLabel:(UIView *)label2;
- (BOOL)plotView:(YMLPlotView *)plotView value:(id)value hasDataAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)plotView:(YMLPlotView *)plotView textForLabel:(UIView *)label withValue:(id)value atIndexPath:(NSIndexPath *)indexPath;

// for calculating position of label
- (CGFloat)plotView:(YMLPlotView *)plotView maxValueForIndexPath:(NSIndexPath *)indexPath;
// repositioning label
- (CGPoint)plotView:(YMLPlotView *)plotView newPositionForLabel:(UILabel *)label withPosition:(CGPoint)oldPosition atIndexPath:(NSIndexPath *)indexPath;

// title labels
- (UIView *)plotView:(YMLPlotView *)plotView titleForSliceAtIndex:(NSUInteger)slice;
- (void)plotView:(YMLPlotView *)plotView updateTitle:(UIView *)titleView forSliceAtIndex:(NSUInteger)slice maxWidth:(CGFloat)maxWidth rightSide:(BOOL)isRightSide;

// tip labels
- (UIView *)toolTipViewForPlotView:(YMLPlotView *)plotView;
- (BOOL)plotView:(YMLPlotView *)plotView updateToolTip:(UIView *)toolTip atIndexPath:(NSIndexPath *)indexPath;
- (NSString *)plotView:(YMLPlotView *)plotView textForToolTip:(UIView *)toolTip atIndexPath:(NSIndexPath *)indexPath;

// touch
- (void)plotView:(YMLPlotView *)plotView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol YMLPlotTouchDelegate<NSObject>

// touch
- (void)plotView:(YMLPlotView *)plotView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol YMLPlotAccessoryDelegate<NSObject>

// accessory views
- (CGFloat)plotView:(YMLPlotView *)plotView normalizedValueAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)accessoryViewForPlotView:(YMLPlotView *)plotView;
- (void)plotView:(YMLPlotView *)plotView updateAccessory:(UIView *)accessoryView atIndexPath:(NSIndexPath *)indexPath;

@optional
- (BOOL)accessoryViewAppearenceForPlotView:(YMLPlotView *)plotView atIndexPath:(NSIndexPath *)indexPath;
- (CGSize)labelSizeAtIndexPath:(NSIndexPath *)indexPath;

//for multiline plot views
//resolving overlaps b/w YMLPointLayers in individual bar
- (void)resolveOverlapsForLayers:(NSArray *)layers;
//reset all YMLPointLayer in the chart
- (void)resetLayers:(NSArray *)points;

@end
