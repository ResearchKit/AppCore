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

@interface APCSchedulerTestCase : XCTestCase

@property  (nonatomic, strong)  APCScheduler  *scheduler;

@end

@implementation APCSchedulerTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _scheduler = [[APCScheduler alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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
    
//    @property (nonatomic, retain) NSDate * createdAt;
//    @property (nonatomic, retain) NSString * uid;
//    @property (nonatomic, retain) NSDate * updatedAt;
//    @property (nonatomic, retain) NSString * notificationMessage;
//    @property (nonatomic, retain) NSString * scheduleExpression;
//    @property (nonatomic, retain) NSString * reminder;
//    @property (nonatomic, retain) APCTask *task;
    
    
//    @property (nonatomic, retain) NSDate * createdAt;
//    @property (nonatomic, retain) NSString * taskDescription;
//    @property (nonatomic, retain) NSString * taskType;
//    @property (nonatomic, retain) NSString * uid;
//    @property (nonatomic, retain) NSDate * updatedAt;
//    @property (nonatomic, retain) NSSet *schedules;

    NSDictionary *task = @{ @"createdAt" : [NSDate date],
                            @"updatedAt" : [NSDate date],
                            @"taskDescription" : @"Walking and talking and stuff",
                            @"taskType" : @"WALKING",
                            @"uid" : @"1213"
                            };
    
    NSArray *schedules =@[
                            @{
                                @"createdAt" : [NSDate date],
                                @"uid" : @"12345",
                                @"updatedAt" : [NSDate date],
                                @"notificationMessage" : @"Eat your vegetables",
                                @"scheduleExpression" : @"4:7200:0",
                                @"reminder" : @"Eat your vegetables at dinner",
                                @"task" : task
                             },
                            @{
                                @"createdAt" : [NSDate date],
                                @"uid" : @"6789",
                                @"updatedAt" : [NSDate date],
                                @"notificationMessage" : @"Time to strut your stuff",
                                @"scheduleExpression" : @"2:3600:1, 3:3600:1, 4:0:1",
                                @"reminder" : @"Remember to walk",
                                @"task" : task
                             },
                            @{
                                @"createdAt" : [NSDate date],
                                @"uid" : @"1011",
                                @"updatedAt" : [NSDate date],
                                @"notificationMessage" : @"Sleep early",
                                @"scheduleExpression" : @"5:0:0",
                                @"reminder" : @"Remember to sleep early",
                                @"task" : task
                             }
                            ];

    [_scheduler updateScheduledTasks:schedules];
}

@end
