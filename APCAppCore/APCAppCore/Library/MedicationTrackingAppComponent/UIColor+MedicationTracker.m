//
//  UIColor+MedicationTracker.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "UIColor+MedicationTracker.h"

@implementation UIColor (MedicationTracker)

+ (UIColor *)todaysDateBackgroundColor
{
    return  [UIColor redColor];
}

+ (UIColor *)todaysDateTextColor
{
    return  [UIColor whiteColor];
}

+ (UIColor *)selectedDateBackgroundColor
{
    return  [UIColor blackColor];
}

+ (UIColor *)selectedDateTextColor
{
    return  [UIColor whiteColor];
}

+ (UIColor *)regularDateBackgroundColor
{
    return  [UIColor clearColor];
}

+ (UIColor *)regularDateTextColor
{
    return  [UIColor blackColor];
}

@end
