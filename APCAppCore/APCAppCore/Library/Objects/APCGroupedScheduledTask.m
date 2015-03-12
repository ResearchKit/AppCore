// 
//  APCGroupedScheduledTask.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCScheduledTask+AddOn.h"
#import "APCTask+AddOn.h"
#import "APCGroupedScheduledTask.h"

@implementation APCGroupedScheduledTask

- (instancetype)init
{
    if (self = [super init]) {
        _scheduledTasks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (APCTask *) task
{
    //We are assuming that this will return an APCTask.
    return (APCTask *)[[[self scheduledTasks] firstObject] task];
}

- (NSDate *)startOn
{
    APCScheduledTask * scheduledTask = [self.scheduledTasks firstObject];
    return scheduledTask.startOn;
}
- (NSString *)completeByDateString
{
    APCScheduledTask * scheduledTask = [self.scheduledTasks firstObject];
    return scheduledTask.completeByDateString;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"Task Title : %@\nTask Type : %@\nTasks : %@", self.taskTitle, self.taskType, self.scheduledTasks];
}

- (NSUInteger)completedTasksCount
{
    NSUInteger count = 0;
    
    for (APCScheduledTask *scheduledTask in self.scheduledTasks) {
        if (scheduledTask.completed.boolValue) {
            count++;
        }
    }
    
    return count;
}

- (BOOL)isComplete
{
    if (self.scheduledTasks.count > 0) {
        return ([self completedTasksCount]/self.scheduledTasks.count);
    }
    return NO;
}

@end
