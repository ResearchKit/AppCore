//
//  APCTimePeriod.h
//  Schedule
//
//  Created by Edward Cessna on 9/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCTimePeriod : NSObject

@property (nonatomic, strong) NSDate*   startDate;
@property (nonatomic, strong) NSDate*   endDate;

- (instancetype)initWithStartDate:(NSDate*)startDate endDate:(NSDate*)endDate;
- (instancetype)initWithStartDate:(NSDate*)startDate duration:(NSTimeInterval)duration;

@end
