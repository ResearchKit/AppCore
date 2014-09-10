//
//  APCSchedule+AddOn.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSchedule+AddOn.h"
#import "APCModel.h"

@implementation APCSchedule (AddOn)

+(void)createSchedulesFromJSON:(NSArray *)schedulesArray inContext:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        for(NSDictionary *scheduleObj in schedulesArray) {
            
            APCTask * task = [APCTask newObjectForContext:context];
            task.taskType = scheduleObj[@"taskType"];
            
            APCSchedule * schedule = [APCSchedule newObjectForContext:context];
            schedule.scheduleExpression = [scheduleObj objectForKey:@"schedule"];
            schedule.reminder = [scheduleObj objectForKey:@"reminder"];
            schedule.task = task;
            
            [schedule saveToPersistentStore:NULL];
        }
    }];
}

/*********************************************************************************/
#pragma mark - Life Cycle Methods
/*********************************************************************************/
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveValue:[NSDate date] forKey:@"createdAt"];
}

- (void)willSave
{
    [self setPrimitiveValue:[NSDate date] forKey:@"updatedAt"];
}

@end
