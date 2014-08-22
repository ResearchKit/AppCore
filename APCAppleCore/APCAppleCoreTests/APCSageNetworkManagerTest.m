//
//  APCSageNetworkManagerTest.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "APCAppleCore.h"

#define BASE_URL @"http://localhost:4567/api/v1/"
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

- (void)setUp
{
    NSLog(@"Setting Up");
    XCTestExpectation * expectation = [self expectationWithDescription:@"SignUp&SignIn"];
    [self.localNetworkManager signUpAndSignIn:@"email@email.com" username:@"username" password:@"password" success:^(NSURLSessionDataTask * task, id responseObject) {
        XCTAssertTrue([responseObject[@"sessionToken"] isEqualToString:@"sessionToken"], @"sessionToken Missing");
        [expectation fulfill];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Received Failure in Sign up & sign In");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:TIME_OUT handler:NULL];
    [self.localNetworkManager clearSessionToken];
}

- (void) tearDown
{
    NSLog(@"Tearing Down");
    XCTestExpectation * expectation = [self expectationWithDescription:@"Authenticate"];
    [self.localNetworkManager signOutWithSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [expectation fulfill];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Received Failure in SignOut: %@", error );
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:TIME_OUT handler:NULL];
}

- (void)testAuthenticateIfNecessary
{
    XCTestExpectation * expectation = [self expectationWithDescription:@"Authenticate"];
    [self.localNetworkManager authenticateWithExistingCredentialsIfNecessaryWithSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [expectation fulfill];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Received Failure in Authenticate: %@", error );
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:TIME_OUT handler:NULL];
}



@end
