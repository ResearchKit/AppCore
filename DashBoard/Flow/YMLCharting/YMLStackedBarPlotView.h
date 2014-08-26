//
//  YMLStackedBarPlotView.h
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/30/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import "YMLChartEnumerations.h"
#import "YMLAxisFormatter.h"
#import "YMLBaseBarPlotView.h"

@class YMLAxisView;
@interface YMLStackedBarPlotView : YMLBaseBarPlotView

// space between the end (or top) of a bar and the total value label, default = 10
@property (nonatomic, assign) CGFloat totalLabelGap;
// colors to use for bar segments, default = nil (uses stock solid colors)
@property (nonatomic, strong) NSArray *barColors;
// whether to show a total value label at end of bar or not, default = YES
@property (nonatomic, assign) BOOL showTotalLabel;

//for adjusting multiple graphs on same chart never to be modified directly
@property (nonatomic, assign) CGFloat maxTotalValue;
//to be modified for normalization
@property (nonatomic, strong) NSMutableArray *normalizedValues;
//needed to calculate normalizedValues
@property (nonatomic, strong, readonly) NSMutableArray *barTotals;

//both needed to repostion labels in case of multiple graphs
@property (nonatomic, strong) NSMutableArray *valueLabels;
@property (nonatomic, strong, readonly) NSMutableArray *bars;

- (void)setBarShapeByRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)radii;
- (id)totalAtIndex:(NSUInteger)index;

//to reposition labels if multiple graphs on same chart
- (void)updateTotalLabels;

@end
