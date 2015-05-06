// 
//  APCSchedule+AddOn.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCSchedule+AddOn.h"
#import "APCModel.h"
#import "APCLog.h"
#import "NSDate+Helper.h"

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
