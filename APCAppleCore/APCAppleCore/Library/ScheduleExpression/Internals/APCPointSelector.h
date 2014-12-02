//
//  APCPointSelector.h
//  Schedule
//
//  Created by Edward Cessna on 9/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTimeSelector.h"

//  Private implementation.


//    /**
//     Ron:  I've seen this format for Objective-C enums.  I think
//     it's easier to read, alphabetize, use in switch() statements,
//     etc.  It's also supported directly by Xcode:  type "enum" and
//     it auto-generates this template.
//
//     I won't check this in (yet?) -- it's functionally identical to
//     the existing code, could introduce bugs, and would make the
//     commit very confusing for other people to review.
//
//     ...or maybe I'll check it in immediately after my functional
//     work.  I just want to remember to discuss it with Ed.
//     */
//    typedef enum : NSInteger {
//        APCScheduleUnitMinute,
//        APCScheduleUnitHour,
//        APCScheduleUnitDayOfMonth,
//        APCScheduleUnitMonth,
//        APCScheduleUnitDayOfWeek,
//        APCScheduleUnitYear,
//        APCScheduleUnitUnknown
//    }	APCScheduleUnit;

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










