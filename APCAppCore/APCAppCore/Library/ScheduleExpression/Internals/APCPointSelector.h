// 
//  APCPointSelector.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCTimeSelector.h"

//  Private implementation.


typedef NS_ENUM(NSInteger, UnitType)
{
	kSeconds,
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
@property (nonatomic, strong) NSNumber* position;

- (instancetype) initWithRangeStart: (NSNumber*) begin
						   rangeEnd: (NSNumber*) end
							   step: (NSNumber*) step;

- (instancetype) initWithValue: (NSNumber*) value
					  position: (NSNumber*) position;

- (NSNumber*)defaultBeginPeriod;
- (NSNumber*)defaultEndPeriod;

@end










