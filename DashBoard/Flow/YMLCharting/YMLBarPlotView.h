//
//  YMLBarPlotView.h
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/1/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLChartEnumerations.h"
#import "YMLAxisFormatter.h"
#import "YMLBaseBarPlotView.h"

@class YMLAxisView;
@interface YMLBarPlotView : YMLBaseBarPlotView

// selected bar index
@property (nonatomic, assign) NSInteger selectedIndex;

// bar color
@property (nonatomic, strong) UIColor *barColor;


// whether value label should be on the bar itself or off to side (default = YES)
@property (nonatomic, assign) BOOL positionLabelOnBar;
// alignment of value label (when positionLabelOnBar == YES) (default = NSTextAlignmentCenter)
@property (nonatomic, assign) NSTextAlignment labelAlignment;
// whether to show No Data label or zero value for all bars (default = YES)
@property (nonatomic, assign) BOOL shouldShowNoDataLabel;
@property (nonatomic, assign, readonly) CGFloat maxTotalValue;

@property (nonatomic, strong) UIColor *barShadowColor;
@property (nonatomic, strong) UIColor *selectedBarShadowColor;
@property (nonatomic, assign) CGFloat barShadowOpacity;
@property (nonatomic, assign) CGFloat selectedBarShadowOpacity;
@property (nonatomic, assign) CGSize barShadowOffset;
@property (nonatomic, assign) CGSize selectedBarShadowOffset;
@property (nonatomic, assign) CGFloat barShadowRadius;
@property (nonatomic, assign) CGFloat selectedBarShadowRadius;


- (void)setBarImage:(UIImage *)image capInsets:(UIEdgeInsets)insets;
- (void)setBarShapeByRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)radii;

- (void)normalize:(CGFloat)maxValue;

@end
