//
//  APCTasksAndSchedulesMigrationUtility.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCTasksAndSchedulesMigrationUtility.h"
#import "APCAppDelegate.h"

NSString *const kTasksAndSchedulesJSONFileName   = @"APHTasksAndSchedules";

@implementation APCTasksAndSchedulesMigrationUtility

- (instancetype)init {

    self = [super init];
    if (self)
    {
        self.tasksAndSchedules = [self sharedInit:kTasksAndSchedulesJSONFileName];
    }

    return self;
}

- (instancetype)initWithFileName:(NSString *)tasksAndSchedulesFileName {

    self = [super init];
    if (self)
    {
        self.tasksAndSchedules = [self sharedInit:tasksAndSchedulesFileName];
    }
    
    return self;
}

- (NSDictionary *)sharedInit:(NSString *)tasksAndSchedulesFileName {
    
    self.dataSubstrate  = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate;
    self.needsMigration = NO;
    
    NSString*       resource = [[NSBundle mainBundle] pathForResource:tasksAndSchedulesFileName ofType:@"json"];
    NSData*         jsonData = [NSData dataWithContentsOfFile:resource];
    NSError*        error;
    NSDictionary*   taskAndSchedules = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                       options:NSJSONReadingMutableContainers
                                                                         error:&error];
    
    if (taskAndSchedules == nil)
    {
        APCLogError(@"Empty or non-existent file");
    }
    
    APCLogError2 (error);
    
    return taskAndSchedules;
}

- (void)migrateScheduleAndTasks {
    //TODO check for tasks that are in the datasubstrate
    /* Compare schedule expression if they exist */
    /* Delete if they exist in the datasubstrate and if they are no longer in the JSON */
    
    
    //TODO check for tasks in the dictionary that are not in the datasubstrate
    /* Create if they are in the JSON and do not exist in the datasubstrate */

    //    jsonDictionary[@"tasks"]
    //    jsonDictionary[@"schedules"]
    
    if (self.needsMigration) {
        [self.dataSubstrate loadStaticTasksAndSchedules:@{@"BLAH" : @"BLAH"}];
    }
}

// This will eventually become code
//- (void)modifyTask:(NSString *)taskIdentifier scheduleExpression:(NSString *)expression {
//    
//}
//
//- (void)deleteScheduledTask:(NSString *)taskIdentifier {
//    
//}
//
//- (void)createTaskAndSchedule:(NSDictionary *)taskAndSchedule {
//    
//}


@end
