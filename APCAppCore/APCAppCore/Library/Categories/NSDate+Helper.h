// 
//  NSDate+Helper.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
@import Foundation;

extern NSString * const NSDateDefaultDateFormat;

@interface NSDate (Helper)

/**
 * @brief convert date to give format
 * @param format - format for the date to be converted, Use by NSDateFormatter, if format = nil then NSDateDefaultDateFormat will be use by this method
 */
- (NSString *) toStringWithFormat:(NSString *)format;

- (NSString *) friendlyDescription;
- (NSDate *) dateByAddingDays:(NSInteger)inDays;

+ (instancetype) startOfDay: (NSDate*) date;
+ (instancetype) endOfDay: (NSDate*) date;
+ (instancetype) startOfTomorrow: (NSDate*) date;

+(instancetype) todayAtMidnight;
+(instancetype) tomorrowAtMidnight;
+(instancetype)yesterdayAtMidnight;
+(instancetype) weekAgoAtMidnight;

+ (NSTimeInterval) parseISO8601DurationString: (NSString*) duration ;

@end
