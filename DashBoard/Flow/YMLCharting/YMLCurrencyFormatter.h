//
//  YMLCurrencyFormatter.h
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/17/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMLAxisFormatter.h"

@interface YMLCurrencyFormatter : NSObject<YMLAxisFormatter>

@property (nonatomic, copy, readonly) NSString *currencySymbol;

@property (nonatomic, copy) NSString *currencyCode;

@property (nonatomic, assign) BOOL shortenNumbers;

// number of decimal places to show when formating (default = 0)
@property (nonatomic, assign) NSUInteger minimumDecimalPlaces;

// (default = locale-specific)
@property (nonatomic, assign) NSUInteger maximumDecimalPlaces;

- (void)setNegativeFormat:(NSString *)negativeFormat;

@end
