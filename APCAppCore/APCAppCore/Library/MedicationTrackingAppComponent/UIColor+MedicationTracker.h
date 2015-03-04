//
//  UIColor+MedicationTracker.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (MedicationTracker)

+ (UIColor *)todaysDateBackgroundColor;
+ (UIColor *)todaysDateTextColor;

+ (UIColor *)selectedDateBackgroundColor;
+ (UIColor *)selectedDateTextColor;

+ (UIColor *)regularDateBackgroundColor;
+ (UIColor *)regularDateTextColor;

@end
