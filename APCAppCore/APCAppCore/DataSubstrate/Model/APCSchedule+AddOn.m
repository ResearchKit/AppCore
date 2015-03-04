// 
//  APCSchedule+AddOn.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
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
            
            NSError * error;
            [schedule saveToPersistentStore:&error];
            APCLogError2(error);
        }
    }];
}

+ (void) updateSchedulesFromJSON: (NSArray *)schedulesArray inContext:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        for(NSDictionary *scheduleDict in schedulesArray) {

            APCSchedule * schedule = [APCSchedule cannedScheduleForTaskID:scheduleDict[kTaskIDKey] inContext:context];
            if (schedule == nil) {
                schedule = [APCSchedule newObjectForContext:context];
                schedule.taskID = scheduleDict[kTaskIDKey];
            }
            
            schedule.scheduleType = [scheduleDict objectForKey:kScheduleTypeKey];
            schedule.scheduleString = [scheduleDict objectForKey:kScheduleStringKey];
            schedule.taskID = scheduleDict[kTaskIDKey];
            schedule.remoteUpdatable = scheduleDict[kRemoteUpdatable];
            schedule.expires = scheduleDict[kExpires];
            
            schedule.shouldRemind = [scheduleDict objectForKey:kScheduleShouldRemindKey];
            schedule.reminderOffset = [scheduleDict objectForKey:kScheduleReminderOffsetKey];
            schedule.reminderMessage = [scheduleDict objectForKey:kScheduleReminderMessageKey];
            
            NSError * error;
            [schedule saveToPersistentStore:&error];
            APCLogError2(error);
        }
    }];
}

//Returns only local canned schedule
+ (APCSchedule*) cannedScheduleForTaskID: (NSString*) taskID inContext:(NSManagedObjectContext *)context
{
    __block APCSchedule * retSchedule;
    [context performBlockAndWait:^{
        NSFetchRequest * request = [APCSchedule request];
        request.predicate = [NSPredicate predicateWithFormat:@"taskID == %@  && (remoteUpdatable == %@ || remoteUpdatable == nil)",taskID, @NO];
        NSError * error;
        retSchedule = [[context executeFetchRequest:request error:&error]firstObject];
    }];
    return retSchedule;
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

- (NSTimeInterval) expiresInterval {
    return [NSDate parseISO8601DurationString:self.expires];
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
