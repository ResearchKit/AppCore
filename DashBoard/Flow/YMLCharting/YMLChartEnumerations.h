//
//  YMLChartEnumerations.h
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/5/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#ifndef PieChartDemo_YMLChartEnumerations_h
#define PieChartDemo_YMLChartEnumerations_h

#import <CoreFoundation/CoreFoundation.h>

enum {
    YMLChartOrientationVertical,
    YMLChartOrientationHorizontal
} typedef YMLChartOrientation;

enum {
    YMLAxisPositionNone,
    YMLAxisPositionLeft,
    YMLAxisPositionTop,
    YMLAxisPositionRight,
    YMLAxisPositionBottom,
} typedef YMLAxisPosition;

enum {
    YMLPointSymbolCircle,
    YMLPointSymbolBar
    
    // TODO: implement more types (e.g. Square, Diamond)
    
} typedef YMLPointSymbol;

enum {
    SegmentPositionFirst = 1 << 0,
    SegmentPositionMid = 0,
    SegmentPositionLast = 1 << 1,
};
typedef NSUInteger SegmentPosition;

// rounds to int on non-retina, rounds to .5 on retina
#define scaled_roundf(x) (roundf((x) * [[UIScreen mainScreen] scale]) / [[UIScreen mainScreen] scale])

#endif
