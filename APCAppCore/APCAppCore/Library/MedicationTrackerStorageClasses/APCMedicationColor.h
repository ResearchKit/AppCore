//
//  APCMedicationColor.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationUltraSimpleSelfInflator.h"

@interface APCMedicationColor : APCMedicationUltraSimpleSelfInflator

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *argbValues;

@property (readonly) CGFloat red;
@property (readonly) CGFloat green;
@property (readonly) CGFloat blue;
@property (readonly) CGFloat alpha;

@property (readonly) UIColor *UIColor;

@end
