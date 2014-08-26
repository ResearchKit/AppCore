//
//  YMLPiePlotView.h
//  Avero
//
//  Created by Mark Pospesel on 12/3/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLPlotView.h"

@interface YMLPiePlotView : YMLPlotView

// scalar value for center of pie chart within the view, default is {0.5, 0.5} meaning center
@property (nonatomic, assign) CGPoint pieCenter;

// scalar value for radius of pie chart, default is 0.5
@property (nonatomic, assign) CGFloat radius;

// scalar value for radius of selected pie chart slices, default is 0.5 (i.e. no difference from unselected)
@property (nonatomic, assign) CGFloat selectedRadius;

// index of selected slice
@property (nonatomic, assign) NSInteger selectedIndex;

// Array of PieSliceLayer objects (i.e. layers that compose the pie chart)
//@property (nonatomic, readonly) NSArray *slices;

@property (nonatomic, strong) NSArray *gradients;

@property (nonatomic, assign) CGFloat strokeWidth;

// whether value label should be on the slice itself or off to side (default = YES)
@property (nonatomic, assign) BOOL positionLabelOnSlice;

// whether to show pie slice labels as percentages rather than actual values (default = NO)
@property (nonatomic, assign) BOOL labelByPercent;

// % of radius to use when placing labels on slices (default = 0.5)
@property (nonatomic, assign) CGFloat labelPosition;

@property (nonatomic, readonly) NSArray *percentValues;

// angle of 1st slice in radians, 0 = 3 o'clock (default = -M_PI/2 or 12 o'clock)
@property (nonatomic, assign) CGFloat startAngle;

// whether slices should be added from startAngle in clockwise or counterclockwise direction (default = YES)
@property (nonatomic, assign, getter = isClockwise) BOOL clockwise;

@property (nonatomic, assign) BOOL animateOnFirstLoad;

@end
