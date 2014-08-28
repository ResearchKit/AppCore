//
//  YMLChartEnumerations.h
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/5/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YMLChartOrientation) {
    YMLChartOrientationVertical = 0,
    YMLChartOrientationHorizontal
};

typedef NS_ENUM (NSUInteger, YMLChartAxisPosition) {
    YMLChartAxisPositionNone = 0,
    YMLChartAxisPositionLeft,
    YMLChartAxisPositionTop,
    YMLChartAxisPositionRight,
    YMLChartAxisPositionBottom,
};
