//
//  APCSageNetworkManagerTest.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "APCAppleCore.h"

#define BASE_URL @"http://pd-staging.sagebridge.org/api/v1/"
#define TIME_OUT 10.0

@interface APCSageNetworkManagerTest : XCTestCase

@property (nonatomic, strong) APCSageNetworkManager * localNetworkManager;

@end

@implementation APCSageNetworkManagerTest

- (APCNetworkManager *)localNetworkManager
{
    if (!_localNetworkManager) {
        _localNetworkManager = [[APCSageNetworkManager alloc] initWithBaseURL:BASE_URL];
    }
    return _localNetworkManager;
}

- (void) testSignUp
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Authenticate"];
    NSString * testName = [NSString stringWithFormat:@"test%d",arc4random()];
    [self.localNetworkManager signUp:[NSString stringWithFormat:@"%@@%@.com",testName,testName]
                            username:testName
                            password:@"Password123"
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 [expectation fulfill];
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 XCTFail(@"Received Failure: %@", error );
                                 [expectation fulfill];
                             }];
    [self waitForExpectationsWithTimeout:TIME_OUT handler:NULL];
}

- (void) testSignIn
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Authenticate"];
    [self.localNetworkManager signIn:@"dhanush"
                            password:@"Password123"
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 NSLog(@"Success");
                                 [expectation fulfill];
                             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 XCTFail(@"Received Failure: %@", error );
                                 [expectation fulfill];
                             }];

    [self waitForExpectationsWithTimeout:TIME_OUT handler:NULL];
}

@end
