// 
//  APCGroupedScheduledTask.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>

@interface APCGroupedScheduledTask : NSObject

@property (strong, nonatomic) NSMutableArray *scheduledTasks;

@property (strong, nonatomic) NSString *taskType;
@property (strong, nonatomic) NSString *taskTitle;
@property (strong, nonatomic) NSString *taskClassName;
@property (strong, nonatomic) NSString *taskCompletionTimeString;
@property (nonatomic, readonly) NSUInteger completedTasksCount;
@property (nonatomic, readonly, getter=isComplete) BOOL complete;

@property (nonatomic, readonly) NSDate * startOn;
@property (nonatomic, readonly) NSString * completeByDateString;

@end
