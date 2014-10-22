//
//  APCSelectorId.h
//  Schedule
//
//  Created by Edward Cessna on 9/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

typedef NS_ENUM(NSInteger, APCSelectorId)
{
    //  Explicity initalization of enumerations as their values reflect the physical order of
    //  fields within a schedule expression.
    kRelativeSelector   = 0,
    kMinutesSelector    = 1,
    kHoursSelector      = 2,
    kDayOfMonthSelector = 3,
    kMonthSelector      = 4,
    kDayOfWeekSelector  = 5
};
