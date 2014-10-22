//
//  APCPointSelector.h
//  Schedule
//
//  Created by Edward Cessna on 9/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTimeSelector.h"


typedef NS_ENUM(NSInteger, UnitType)
{
    kMinutes,
    kHours,
    kDayOfMonth,
    kMonth,
    kDayOfWeek,
    kYear,
    kUnknown
};

@interface APCPointSelector : APCTimeSelector

@property (nonatomic, assign) UnitType  unitType;
@property (nonatomic, strong) NSNumber* begin;
@property (nonatomic, strong) NSNumber* end;
@property (nonatomic, strong) NSNumber* step;

- (instancetype)initWithUnit:(UnitType)unitType;

- (instancetype)initWithUnit:(UnitType)unitType
                  beginRange:(NSNumber*)begin
                    endRange:(NSNumber*)end
                        step:(NSNumber*)step;

- (NSNumber*)defaultBeginPeriod;
- (NSNumber*)defaultEndPeriod;

@end
