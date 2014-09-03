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

@interface APCSchedulerTestCase : XCTestCase

@property  (nonatomic, strong)  APCScheduler  *scheduler;
@property  (nonatomic, strong)  APCScheduleInterpreter  *schedulerInterpreter;

@end

@implementation APCSchedulerTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _scheduler = [[APCScheduler alloc] init];
    _schedulerInterpreter = [[APCScheduleInterpreter alloc] init];
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
    NSMutableArray *array = [_schedulerInterpreter taskDates:@"1:1,2,12"];
    
    NSLog(@"array %@", array);
    

}

@end
