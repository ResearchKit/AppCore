//
//  YMLMultiLinePlotView.h
//  Avero
//
//  Created by Mahesh on 4/29/14.
//  Copyright (c) 2014 ymedialabs.com. All rights reserved.
//

#import "YMLPlotView.h"

@protocol YMLMultiLInePlotDelegate;

@interface YMLMultiLinePlotView : YMLPlotView

@property (nonatomic, assign) CGSize pointSize;
@property (nonatomic, assign) CGFloat barWidth;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *pointColor;
@property (nonatomic, assign) YMLPointSymbol symbol;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *accessoryViews;
@property (nonatomic, assign, readonly) CGFloat maxTotalValue;

// gives max number of points per row (default = 1)
@property (nonatomic, assign) NSUInteger pointsPerRow;
// the for the points (default = pointColor)
@property (nonatomic, strong) NSArray *pointsColor;

- (void)updatePoints;
- (void)normalize:(CGFloat)maxValue;
- (NSArray *)returnNormalizedValues;

@end