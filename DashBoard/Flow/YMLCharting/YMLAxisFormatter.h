//
//  YMLAxisFormatter.h
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/17/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YMLAxisFormatter <NSObject>

@required

// returns the value formated for display as an axis label
- (NSString *)displayValueForValue:(id)value;

@optional
-(id)valueForDisplayValue:(NSString *)displayValue;

@end
