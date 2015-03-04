// 
//  APCSchedule+AddOn.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCSchedule.h"
#import "APCScheduleExpression.h"

@interface APCSchedule (AddOn)

//Synchronous Method Call
+ (void) createSchedulesFromJSON: (NSArray*) schedulesArray inContext: (NSManagedObjectContext*) context;
+ (void) updateSchedulesFromJSON: (NSArray *)schedulesArray inContext:(NSManagedObjectContext *)context;

- (BOOL) isOneTimeSchedule;
@property (nonatomic, readonly) APCScheduleExpression * scheduleExpression;
- (NSTimeInterval) expiresInterval;

@end
