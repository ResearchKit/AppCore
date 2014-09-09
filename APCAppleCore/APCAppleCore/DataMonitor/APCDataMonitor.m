//
//  APCDataMonitor.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppleCore.h"

@interface APCDataMonitor ()

//Declaring as weak so as not to hold on to below objects
@property (weak, nonatomic) APCDataSubstrate * dataSubstrate;
@property (weak, nonatomic) APCSageNetworkManager * networkManager;
@property (weak, nonatomic) APCScheduler * scheduler;

@end

@implementation APCDataMonitor

- (instancetype)initWithDataSubstrate:(APCDataSubstrate *)dataSubstrate networkManager:(APCSageNetworkManager *)networkManager scheduler:(APCScheduler *)scheduler
{
    self = [super init];
    if (self) {
        self.dataSubstrate = dataSubstrate;
        self.networkManager = networkManager;
        self.scheduler = scheduler;
    }
    return self;
}

- (void)appBecameActive
{

}

- (void)backgroundFetch:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNoData);
}


/*********************************************************************************/
#pragma mark - First User Setup
/*********************************************************************************/

- (void) performFirstUserSetup:(NSString* ) jsonFileName
{
    [self loadTasksAndSchedules:jsonFileName];
}

- (void)loadTasksAndSchedules:(NSString *)fileName {
    
    NSArray *schedules = [self loadJSON:fileName][@"schedules"];
    NSManagedObjectContext * localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    localContext.parentContext = self.dataSubstrate.persistentContext;
    [localContext performBlock:^{
        for(NSDictionary *scheduleObj in schedules) {
            
            APCTask * task = [APCTask newObjectForContext:localContext];
            task.taskType = scheduleObj[@"taskType"];
            
            APCSchedule * schedule = [APCSchedule newObjectForContext:localContext];
            schedule.scheduleExpression = [scheduleObj objectForKey:@"schedule"];
            schedule.reminder = [scheduleObj objectForKey:@"reminder"];
            schedule.task = task;
            
            [schedule saveToPersistentStore:NULL];
        }
        [self.scheduler updateScheduledTasks];
    }];
}


- (NSDictionary *)loadJSON:(NSString *)fileName {
    
    //TODO This code below is used for unit testing.
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//    NSString *resource = [[NSBundle main] pathForResource:fileName ofType:@"json"];
    
    //TODO I believe I should just be using this to access the file.
    NSString *resource = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:resource];
    NSLog(@"json data %@", jsonData);
    
    id dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    NSAssert([dict isKindOfClass:[NSDictionary class]], @"Tasks & Schedule JSON ERROR: Needs to be a dictionary");
    return dict;
}


@end
