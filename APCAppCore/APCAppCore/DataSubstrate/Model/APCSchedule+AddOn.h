// 
//  APCSchedule+AddOn.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCSchedule.h"
#import "APCScheduleExpression.h"

@interface APCSchedule (AddOn)

//Synchronous Method Call
+ (void) createSchedulesFromJSON: (NSArray*) schedulesArray inContext: (NSManagedObjectContext*) context;

- (BOOL) isOneTimeSchedule;
@property (nonatomic, readonly) APCScheduleExpression * scheduleExpression;
- (NSTimeInterval) expiresInterval;

@end
