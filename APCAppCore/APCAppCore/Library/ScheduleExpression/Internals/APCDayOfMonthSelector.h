// 
//  APCDayOfMonthSelector.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCTimeSelector.h"

/**
 A wrapper around two lower-level selectors, day-of-month and day-of-week.
 This higher-level selector merges (unions, ORs) the dates of a particular
 month specified by those lower-level items and lets us iterate through
 those.
 
 Therefore, everytime it gets "reset," it also needs to be fed the
 year and month we're about to iterate through.
 */
@interface APCDayOfMonthSelector : APCTimeSelector

- (id) initWithFreshlyParsedDayOfMonthSelector: (APCTimeSelector *) dayOfMonthSelector
						  andDayOfWeekSelector: (APCTimeSelector *) dayOfWeekSelector;

- (void) recomputeDaysBasedOnMonth: (NSNumber *) month
							  year: (NSNumber *) year;

@end
