//
//  YMLChartUnitsView.h
//  Flow
//
//  Created by Karthik Keyan on 8/27/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "YMLChartEnumerations.h"

#import <UIKit/UIKit.h>

FOUNDATION_EXTERN CGFloat const kYMLChartUnitsViewMinumumHeight;
FOUNDATION_EXTERN CGFloat const kYMLChartUnitsViewMinumumWidth;

@interface YMLChartUnitsView : UIView

- (instancetype) initWithFrame:(CGRect)frame axisPosition:(YMLChartAxisPosition)position;

@property (nonatomic, readonly) YMLChartAxisPosition position;

@property (nonatomic, strong) NSArray *units;

@property (nonatomic, strong) NSArray *labels;

- (CGFloat) locationForUnit:(CGFloat)unit;

- (CGFloat) unitAtLocation:(CGFloat)location;

- (void) clear;

@end
