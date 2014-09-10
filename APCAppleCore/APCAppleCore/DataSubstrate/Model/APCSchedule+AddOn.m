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
        for(NSDictionary *scheduleDict in schedulesArray) {
            
            APCSchedule * schedule = [APCSchedule newObjectForContext:context];
            schedule.scheduleExpression = [scheduleDict objectForKey:@"schedule"];
            schedule.reminder = [scheduleDict objectForKey:@"reminder"];
            schedule.task = [APCTask taskWithTaskID:scheduleDict[@"taskID"] inContext:context];
            
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
