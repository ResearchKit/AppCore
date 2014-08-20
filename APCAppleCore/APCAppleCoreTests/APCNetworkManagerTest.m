//
//  APCNetworkManagerTest.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/19/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "APCNetworkManager.h"
#define BASE_URL @"http://localhost:4567/api/" //@"http://api.openweathermap.org/data/2.5/weather?q="
#define TIME_OUT 10.0

//NOTE: Requires MockupServer to be running in the background!

@interface APCNetworkManagerTest : XCTestCase

@property (readonly) APCNetworkManager * localNetworkManager;

@end

@implementation APCNetworkManagerTest

- (APCNetworkManager *)localNetworkManager
{
    if (![APCNetworkManager sharedManager]) {
        [APCNetworkManager setUpSharedNetworkManagerWithBaseURL:BASE_URL];
    }
    return [APCNetworkManager sharedManager];
}

- (void)testSingletonCreated {
    XCTAssertNotNil(self.localNetworkManager);
}

- (void) testReachabilityWorks
{
    XCTAssertTrue(self.localNetworkManager.isReachable, @"Not connected to Internet");
    XCTAssertTrue(self.localNetworkManager.isServerReachable, @"Test Server Not Reachable");
}

//TODO: Lower Priority. Find a way to reliably test reachability notifications.
//- (void) testReachabilityChangedBlockWorks
//{
//    XCTestExpectation * expectation = [self expectationWithDescription:@"Reachability"];
//    self.localNetworkManager.reachabilityChanged = ^ () {
//        [expectation fulfill];
//    };
//    [self waitForExpectationsWithTimeout:5.0 handler:NULL];
//}

- (void) testGETMethodforSuccess
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"GET Test"];
    [self.localNetworkManager GET:@"test_pass" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        XCTAssertNotNil(responseObject,@"Response Object nil");
        NSLog(@"%@", responseObject);
        [expectation fulfill];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Received Failure in GET Method");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:TIME_OUT handler:NULL];
}

- (void) testPOSTMethodforSuccess
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"POST Test"];
    [self.localNetworkManager POST:@"test_pass" parameters:@{@"hello":@"world"} success:^(NSURLSessionDataTask *task, id responseObject) {
        XCTAssertNotNil(responseObject,@"Response Object nil");
        NSLog(@"%@", responseObject);
        [expectation fulfill];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Received Failure in POST Method");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:TIME_OUT handler:NULL];
}

- (void) testGETWithAbsoluteURLforSuccess
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"GET Test with absolute URL"];
    [self.localNetworkManager GET:@"http://api.openweathermap.org/data/2.5/weather?q=london,uk" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        XCTAssertNotNil(responseObject,@"Response Object nil");
        NSLog(@"%@", responseObject);
        [expectation fulfill];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Received Failure in GET Method");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:TIME_OUT handler:NULL];
}

- (void) testGETMethodforFailure
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"GET Test for failure"];
    [self.localNetworkManager GET:@"test_fail" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        XCTFail(@"Should not receive Success");
        NSLog(@"%@", responseObject);
        [expectation fulfill];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTAssertNotNil(error, @"Error is NIL!");
        NSLog(@"%@", error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:TIME_OUT handler:NULL];
}

- (void) testGETMethodforServerMaintenance
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"GET Test with Server Maintenance"];
    [self.localNetworkManager GET:@"server_maintenance" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        XCTFail(@"Should not receive Success");
        NSLog(@"%@", responseObject);
        [expectation fulfill];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTAssertNotNil(error, @"Error is NIL!");
        XCTAssertTrue(error.code == 503,@"Error not server maintenance");
        NSLog(@"%@", error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:TIME_OUT handler:NULL];
}

@end
