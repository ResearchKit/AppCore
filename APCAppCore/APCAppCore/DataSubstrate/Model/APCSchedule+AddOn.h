//
//  APCSchedule+AddOn.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 8/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSchedule.h"
#import "APCScheduleExpression.h"

@interface APCSchedule (AddOn)

//Synchronous Method Call
+ (void) createSchedulesFromJSON: (NSArray*) schedulesArray inContext: (NSManagedObjectContext*) context;

- (BOOL) isOneTimeSchedule;
@property (nonatomic, readonly) APCScheduleExpression * scheduleExpression;

@end
