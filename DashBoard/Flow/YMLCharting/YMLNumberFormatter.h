//
//  YMLNumberFormatter.h
//  Avero
//
//  Created by Mark Pospesel on 12/7/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLAxisFormatter.h"

@interface YMLNumberFormatter : NSObject<YMLAxisFormatter>

// minimum number of decimal places to show when formating (default = 0)
@property (nonatomic, assign) NSUInteger minimumDecimalPlaces;
// maximum number of decimal places to show when formating (default = 2)
@property (nonatomic, assign) NSUInteger maximumDecimalPlaces;

@end
