//
//  APCMedTrackerScheduleColor+Helper.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerScheduleColor+Helper.h"
#include <UIKit/UIKit.h>

@implementation APCMedTrackerScheduleColor (Helper)

- (UIColor *) UIColor
{
    UIColor *color = nil;

    color = [UIColor colorWithRed: self.redAsInteger.floatValue / 255
                            green: self.greenAsInteger.floatValue / 255
                             blue: self.blueAsInteger.floatValue / 255
                            alpha: self.alphaAsFloat.floatValue];

    return color;
}

@end
