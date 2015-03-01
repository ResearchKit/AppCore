//
//  NSDate+MedicationTracker.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MedicationTracker)

- (NSDate *)getWeekStartDate: (NSInteger)weekStartIndex;
- (NSString *)getDayOfWeekShortString;
- (NSString *)getDateOfMonth;
- (BOOL)isSameDateWith:(NSDate *)dt;
- (BOOL)isDateToday;
- (BOOL)isWithinDate: (NSDate *)earlierDate toDate:(NSDate *)laterDate;
- (BOOL)isPastDate;

@end
