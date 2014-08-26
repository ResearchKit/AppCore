//
//  YMLBarLayer.h
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/4/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "YMLBaseBarLayer.h"

@interface YMLBarLayer : YMLBaseBarLayer

@property (nonatomic, strong) NSArray *subValues;

@property (nonatomic, strong) NSArray *barColors;

// Array of YMLBarSegmentLayer objects
@property (nonatomic, readonly) NSArray *segments;

@end
