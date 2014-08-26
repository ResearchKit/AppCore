//
//  YMLDateFormatter.h
//  Avero
//
//  Created by Mark Pospesel on 11/15/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLAxisFormatter.h"

@interface YMLDateFormatter : NSObject<YMLAxisFormatter>

- (id)initWithDateFormat:(NSString *)dateFormat;
- (id)initWithDateFormatTemplate:(NSString *)template;

+ (YMLDateFormatter *)defaultFormatter;

@end
