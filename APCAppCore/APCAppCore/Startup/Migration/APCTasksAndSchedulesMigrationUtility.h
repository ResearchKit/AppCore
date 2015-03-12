//
//  APCTasksAndSchedulesMigrationUtility.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "APCAppCore.h"

@interface APCTasksAndSchedulesMigrationUtility : NSObject


@property (nonatomic, strong)   NSDictionary        *tasksAndSchedules;
@property (nonatomic, strong)   NSString            *tasksAndSchedulesFileName;
@property (strong, nonatomic)   APCDataSubstrate    *dataSubstrate;
@property (nonatomic)           BOOL                needsMigration;

- (instancetype)initWithFileName:(NSDictionary *)newTasksAndSchedules;

- (void)migrateScheduleAndTasks;

- (void)modifyTask:(NSString *)taskIdentifier scheduleExpression:(NSString *)expression;

- (void)deleteScheduledTask:(NSString *)taskIdentifier;

- (void)createTaskAndSchedule:(NSDictionary *)taskAndSchedule;


@end
