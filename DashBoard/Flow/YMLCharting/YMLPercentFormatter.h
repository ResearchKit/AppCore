//
//  YMLPercentFormatter.h
//  Avero
//
//  Created by Mark Pospesel on 11/27/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLAxisFormatter.h"

@interface YMLPercentFormatter : NSObject<YMLAxisFormatter>

// whether to include the % sign (default = yes)
@property (nonatomic, assign) BOOL includeSymbol;

// number of decimal places to show when formating (default = 1)
@property (nonatomic, assign) NSUInteger decimalPlaces;

- (void)setMinimumDecimalPlaces:(NSUInteger)number;

@end
