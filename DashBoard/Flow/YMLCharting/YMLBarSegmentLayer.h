//
//  YMLBarSegmentLayer.h
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/4/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "YMLChartEnumerations.h"
#import "YMLBaseBarLayer.h"

@interface YMLBarSegmentLayer : YMLBaseBarLayer

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *separatorColor;
@property (nonatomic, assign) CGFloat separatorWidth;
@property (nonatomic, assign) SegmentPosition segmentPosition;

@end
