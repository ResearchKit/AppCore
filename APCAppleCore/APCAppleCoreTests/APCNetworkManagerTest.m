//
//  APCNetworkManagerTest.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/19/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "APCAppleCore.h"
NSString* kBaseURL = @"http://localhost:4567/api/";
const double kTimeOut = 10.0;

//NOTE: Requires MockupServer to be running in the background!

@interface APCNetworkManagerTest : XCTestCase

@property (nonatomic, strong) APCNetworkManager * localNetworkManager;

@end

@implementation APCNetworkManagerTest

- (APCNetworkManager *)localNetworkManager
{
    if (!_localNetworkManager) {
        _localNetworkManager = [[APCNetworkManager alloc] initWithBaseURL:kBaseURL];
    }
    return _localNetworkManager;
}

- (void) testReachabilityWorks
{
    XCTAssertTrue(self.localNetworkManager.isInternetConnected, @"Not connected to Internet");
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
    
    [self.localNetworkManager get:@"test_pass" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        XCTAssertNotNil(responseObject, @"Response Object nil");
        NSLog(@"%@", responseObject);
        [expectation fulfill];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Received Failure in GET Method");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:kTimeOut handler:NULL];
}

- (void) testPOSTMethodforSuccess
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"POST Test"];
    [self.localNetworkManager post:@"test_pass" parameters:@{@"hello":@"world"} success:^(NSURLSessionDataTask *task, id responseObject) {
        XCTAssertNotNil(responseObject,@"Response Object nil");
        NSLog(@"%@", responseObject);
        [expectation fulfill];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Received Failure in POST Method");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:kTimeOut handler:NULL];
}

- (void) testGETWithAbsoluteURLforSuccess
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"GET Test with absolute URL"];
    [self.localNetworkManager get:@"http://api.openweathermap.org/data/2.5/weather?q=london,uk" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        XCTAssertNotNil(responseObject,@"Response Object nil");
        NSLog(@"%@", responseObject);
        [expectation fulfill];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Received Failure in GET Method");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:kTimeOut handler:NULL];
}

- (void) testGETMethodforFailure
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"GET Test for failure"];
    [self.localNetworkManager get:@"test_fail" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        XCTFail(@"Should not receive Success");
        NSLog(@"%@", responseObject);
        [expectation fulfill];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTAssertTrue([error.domain isEqualToString:APC_ERROR_DOMAIN], @"Wrong Error Domain");
        NSLog(@"%@", error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:kTimeOut handler:NULL];
}

- (void) testGETMethodforServerMaintenance
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"GET Test with Server Maintenance"];
    [self.localNetworkManager get:@"server_maintenance" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        XCTFail(@"Should not receive Success");
        NSLog(@"%@", responseObject);
        [expectation fulfill];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTAssertTrue([error.domain isEqualToString:APC_ERROR_DOMAIN], @"Wrong Error Domain");
        XCTAssertTrue(error.code == kAPCServerUnderMaintenance,@"Error not server maintenance");
        NSLog(@"%@", error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:kTimeOut handler:NULL];
}

@end
