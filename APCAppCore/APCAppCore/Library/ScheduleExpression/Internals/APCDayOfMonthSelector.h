// 
//  APCDayOfMonthSelector.h 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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

/**
 True if this selector contains any legal days for the current month and year.
 Call this after calling -recompute.
 */
@property (readonly) BOOL hasAnyLegalDays;

@end
