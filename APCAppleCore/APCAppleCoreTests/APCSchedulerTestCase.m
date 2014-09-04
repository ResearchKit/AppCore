//
//  APCSchedulerTestCase.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 8/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "APCScheduler.h"
#import "APCScheduleInterpreter.h"

#import <CoreData/CoreData.h>
#import "APCSchedule.h"
#import "APCScheduledTask.h"
#import "APCTask.h"

@interface APCSchedulerTestCase : XCTestCase

@property  (nonatomic, strong)  APCScheduler  *scheduler;
@property  (nonatomic, strong)  APCScheduleInterpreter  *schedulerInterpreter;

@property (nonatomic,retain) NSManagedObjectContext *moc;
@end

@implementation APCSchedulerTestCase

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _scheduler = [[APCScheduler alloc] init];
    _schedulerInterpreter = [[APCScheduleInterpreter alloc] init];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *modelURL = [bundle URLForResource:@"APCModel" withExtension:@"momd"];

    
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    XCTAssertTrue([psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL] ? YES : NO, @"Should be able to add in-memory store");
    self.moc = [[NSManagedObjectContext alloc] init];
    self.moc.persistentStoreCoordinator = psc;
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    self.moc = nil;
    
//    [ctx release];
//    ctx = nil;
//    NSError *error = nil;
//    STAssertTrue([coord removePersistentStore: store error: &error],
//                 @"couldn't remove persistent store: %@", error);
//    store = nil;
//    [coord release];
//    coord = nil;
//    [model release];
//    model = nil;
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testUpdateScheduledTasks {
    NSMutableArray *array = [_schedulerInterpreter taskDates:@"1:1,2,12"];
    
    NSLog(@"array %@", array);
    

}

- (void)testLocalizedHour {
    [_schedulerInterpreter localizedAbsoluteHour];
    
    
}

- (void)testCreateScheduleEntity {
    
    APCSchedule *schedule = [NSEntityDescription insertNewObjectForEntityForName:@"APCSchedule" inManagedObjectContext:self.moc];
    
    APCTask *task = [NSEntityDescription insertNewObjectForEntityForName:@"APCTask" inManagedObjectContext:self.moc];
    
    schedule.createdAt = [NSDate date];
    schedule.updatedAt = [NSDate date];
    schedule.scheduleExpression = @"1:6,7,8";
    schedule.reminder = @"0";
    schedule.task = task;
    
    // Save the context.
    NSError *error = nil;
    if (![self.moc save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        XCTFail(@"Error saving in \"%s\" : %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
    }
    XCTAssertFalse(self.moc.hasChanges,"All the changes should be saved");
    
    
 
    //[_scheduler scheduleUpdated:schedule];
}

- (void)testScheduleUpdated {
    
    
    APCSchedule *schedule = [NSEntityDescription insertNewObjectForEntityForName:@"APCSchedule" inManagedObjectContext:self.moc];
    
    APCTask *task = [NSEntityDescription insertNewObjectForEntityForName:@"APCTask" inManagedObjectContext:self.moc];
    
    schedule.createdAt = [NSDate date];
    schedule.updatedAt = [NSDate date];
    schedule.scheduleExpression = @"1:6,7,8";
    schedule.reminder = @"0";
    schedule.task = task;
    
    // Save the context.
    NSError *error = nil;
    if (![self.moc save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        XCTFail(@"Error saving in \"%s\" : %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
    }
    XCTAssertFalse(self.moc.hasChanges,"All the changes should be saved");
    
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc]
//                                   initWithConcurrencyType:NSConfinementConcurrencyType];
    
    //moc.parentContext = self.moc;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"APCScheduledTask"
                                              inManagedObjectContext:self.moc ];
   
    [request setEntity:entity];
    
    NSMutableArray *dates = [_schedulerInterpreter taskDates:@"1:1,2,12"];
    
    NSDate *date0 = [dates objectAtIndex:0];
    

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dueOn == %@ AND task == %@", date0, @"TASK"];
    
    [request setPredicate:predicate];
    
    NSError *error2;
    NSArray *array = [self.moc executeFetchRequest:request error:&error2];
    
    if (!array.count) {
        NSLog(@"NO");
        //return NO;
    }
    NSLog(@"YES");
    //return YES;
}

- (void)testSetScheduledTask {
    APCSchedule *schedule = [NSEntityDescription insertNewObjectForEntityForName:@"APCSchedule" inManagedObjectContext:self.moc];
    
    APCTask *task = [NSEntityDescription insertNewObjectForEntityForName:@"APCTask" inManagedObjectContext:self.moc];
    
    schedule.createdAt = [NSDate date];
    schedule.updatedAt = [NSDate date];
    schedule.scheduleExpression = @"1:6,7,8";
    schedule.reminder = @"0";
    schedule.task = task;
    
    // Save the context.
    NSError *error = nil;
    if (![self.moc save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        XCTFail(@"Error saving in \"%s\" : %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
    }
    XCTAssertFalse(self.moc.hasChanges,"All the changes should be saved");
    
    [_scheduler setScheduledTask:schedule];
    
    
}

- (void)testSetLocalNotification {
    [_scheduler scheduleLocalNotification:@"Hello, world" withDate:[NSDate date] withTaskType:@"WALK" withAPCScheduleTaskId:@"12345" andReminder:1];
}

@end
