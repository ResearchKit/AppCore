//
//  YMLLineChartView.h
//  Flow
//
//  Created by Karthik Keyan on 8/27/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YMLChartUnitsView;

@interface YMLLineChartView : UIView

@property (nonatomic, readwrite) NSUInteger markerRadius;

@property (nonatomic, strong) NSArray *xUnits;

@property (nonatomic, strong) NSArray *yUnits;

// Array of NSValue(CGPoint)
@property (nonatomic, strong) NSArray *values;

@property (nonatomic, strong) UIColor *markerColor;

@property (nonatomic, strong) CAShapeLayer *lineLayer;

@property (nonatomic, strong) YMLChartUnitsView *xAxisUnitsView;

@property (nonatomic, strong) YMLChartUnitsView *yAxisUnitsView;

- (void) draw;

@end
