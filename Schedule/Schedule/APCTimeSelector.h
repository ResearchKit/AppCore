//
//  APCTimeSelector.h
//  Schedule
//
//  Created by Edward Cessna on 9/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APCTimeSelectorEnumerator;

@interface APCTimeSelector : NSObject

- (BOOL)matches:(NSNumber*)value;
- (NSNumber*)nextMomentAfter:(NSNumber*)point;

- (APCTimeSelectorEnumerator*)enumeratorBeginningAt:(NSNumber*)value;

- (NSNumber*)firstValidValue;

@end
