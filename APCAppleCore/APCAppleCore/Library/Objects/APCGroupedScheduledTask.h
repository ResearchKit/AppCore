//
//  APCGroupedScheduledTask.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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

@end
