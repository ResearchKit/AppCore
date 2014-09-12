//
//  APCParameters.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 9/11/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "APCParameters.h"

@interface APCParametersTest : XCTestCase
@property  (nonatomic, strong)  APCParameters  *parameters;
@end

@implementation APCParametersTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.parameters = [[APCParameters alloc] initWithFileName:@"parameters.json"];
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


- (void)testInit {

    self.parameters = [[APCParameters alloc] initWithFileName:@"parameters.json"];

}

- (void)testReset {

    [self.parameters reset];
}

- (void)testSettingDouble {

    double aDouble = FLT_MAX;
    [self.parameters setDouble:aDouble forKey:@"Justin"];
    
}

- (void)testSettingInt {
    
    //NSInteger anInteger = NSIntegerMax;
    [self.parameters integerForKey:@"Justin"];
    
}

- (void)testDoubleForKey {
    
    [self.parameters doubleForKey:@"Justin"];
}

- (void)testIsNumber {
    //[self.parameters loadValuesFromBundle:@"parameters.json"];
    
//    id knob = [self.parameters objectForKey:@"knob"];
//    [self.parameters setObject:@1000 forKey:@"knob"];
//    
    
}

- (void)testCFNumber {
    NSNumber*   doubleNumber = [NSNumber numberWithDouble:100];
    CFNumberType doubleType = CFNumberGetType((CFNumberRef)doubleNumber);
    NSLog(@"Type: %ld", doubleType);
    
    CFNumberType numberType = CFNumberGetType((CFNumberRef)@(100.03456789));
    
    if (numberType == kCFNumberFloat64Type) {
        NSLog(@"Yes");
    }
    
}
@end
