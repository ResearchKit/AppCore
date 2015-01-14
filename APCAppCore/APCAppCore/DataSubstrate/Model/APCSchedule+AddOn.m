// 
//  APCSchedule+AddOn.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCSchedule+AddOn.h"
#import "APCModel.h"

static NSString * const kScheduleShouldRemindKey = @"shouldRemind";
static NSString * const kScheduleReminderOffsetKey = @"reminderOffset";
static NSString * const kScheduleReminderMessageKey = @"reminderMessage";

static NSString * const kTaskIDKey = @"taskID";
static NSString * const kScheduleStringKey = @"scheduleString";
static NSString * const kScheduleTypeKey = @"scheduleType";
static NSString * const kRemoteUpdatable = @"remoteUpdatable";
static NSString * const kExpires = @"expires";

static NSString * const kOneTimeSchedule = @"once";

@implementation APCSchedule (AddOn)

+(void)createSchedulesFromJSON:(NSArray *)schedulesArray inContext:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        for(NSDictionary *scheduleDict in schedulesArray) {
            
            APCSchedule * schedule = [APCSchedule newObjectForContext:context];
            
            schedule.scheduleType = [scheduleDict objectForKey:kScheduleTypeKey];
            schedule.scheduleString = [scheduleDict objectForKey:kScheduleStringKey];
            schedule.taskID = scheduleDict[kTaskIDKey];
            schedule.remoteUpdatable = scheduleDict[kRemoteUpdatable];
            schedule.expires = scheduleDict[kExpires];
            
            schedule.shouldRemind = [scheduleDict objectForKey:kScheduleShouldRemindKey];
            schedule.reminderOffset = [scheduleDict objectForKey:kScheduleReminderOffsetKey];
            schedule.reminderMessage = [scheduleDict objectForKey:kScheduleReminderMessageKey];
            
            [schedule saveToPersistentStore:NULL];
        }
    }];
}

- (BOOL)isOneTimeSchedule
{
    return [self.scheduleType isEqualToString:kOneTimeSchedule];
}

- (APCScheduleExpression *)scheduleExpression
{
    //TODO: Schedule interval is 0
    return [[APCScheduleExpression alloc] initWithExpression:self.scheduleString timeZero:0];
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
