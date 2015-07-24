//
//  APCScheduleStartDateFilter.h
//  APCAppCore
//
//  Copyright (c) 2015, Apple Inc. All rights reserved. 
//  
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//  
//  1.  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  
//  2.  Redistributions in binary form must reproduce the above copyright notice, 
//  this list of conditions and the following disclaimer in the documentation and/or 
//  other materials provided with the distribution. 
//  
//  3.  Neither the name of the copyright holder(s) nor the names of any contributors 
//  may be used to endorse or promote products derived from this software without 
//  specific prior written permission. No license is granted to the trademarks of 
//  the copyright holders even if such marks are included in this software. 
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
//

#import "APCScheduleFilter.h"

/**
 Splits a set of schedules into three subsets:  those whose startsOn value is
 on the specified calendar date, those before that date, and those after that
 date.
 */
@interface APCScheduleStartDateFilter : APCScheduleFilter


/**
 Splits setOfSchedules into three subsets:  those whose startsOn value is on
 the specified calendar date, those before that date, and those after that
 date.  Those subsets are returned in -before, -during, and -after (not in
 -passed and -failed).

 @param setOfSchedules  The schedules to split.
 
 @param date  The date for which to perform this comparsion.
 */
- (void) split: (NSSet *) setOfSchedules
      withDate: (NSDate *) date;

/**
 After calling -split:withDate:, this property contains schedules
 whose start date is before the specified calendar day.
 */
@property (readonly) NSSet *before;

/**
 After calling -split:withDate:, this property contains schedules
 whose start date is on the specified calendar day.
 */
@property (readonly) NSSet *during;

/**
 After calling -split:withDate:, this property contains schedules
 whose start date is after the specified calendar day.
 */
@property (readonly) NSSet *after;

/**
 Unlike other APCScheduleFilters, this class does not use -passed
 and -failed.  Instead, it uses -before, -during, and -after.

 @see -split:withDate:
 */
- (NSSet *) passed __attribute__((unavailable("For StartDateFilter, please use the properties -before, -during, or -after instead of -passed and -failed.")));

/**
 Unlike other APCScheduleFilters, this class does not use -passed
 and -failed.  Instead, it uses -before, -during, and -after.

 @see -split:withDate:
 */
- (NSSet *) failed __attribute__((unavailable("For StartDateFilter, please use the properties -before, -during, or -after instead of -passed and -failed.")));

@end
