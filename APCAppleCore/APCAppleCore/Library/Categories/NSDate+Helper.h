//
//  NSDate+Helper.h
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/11/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import Foundation;

extern NSString * const NSDateDefaultDateFormat;

@interface NSDate (Helper)

/**
 * @brief convert date to give format
 * @param format - format for the date to be converted, Use by NSDateFormatter, if format = nil then NSDateDefaultDateFormat will be use by this method
 */
- (NSString *) toStringWithFormat:(NSString *)format;

@end
