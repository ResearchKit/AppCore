//
//  YMLLinePlotView.h
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/22/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import "YMLPlotView.h"

@interface YMLLinePlotView : YMLPlotView

@property (nonatomic, assign) CGSize pointSize;
@property (nonatomic, assign) CGFloat barWidth;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *pointColor;
@property (nonatomic, assign) YMLPointSymbol symbol;
@property (nonatomic, strong) NSMutableArray *points;

@property (nonatomic, assign, readonly) CGFloat maxTotalValue;

- (void)updatePoints;
- (void)normalize:(CGFloat)maxValue;
- (NSArray *)returnNormalizedValues;

@end
