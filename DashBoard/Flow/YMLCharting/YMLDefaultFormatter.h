//
//  YMLDefaultFormatter.h
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/17/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLAxisFormatter.h"

@interface YMLDefaultFormatter : NSObject<YMLAxisFormatter>

+ (YMLDefaultFormatter *)defaultFormatter;

@end
