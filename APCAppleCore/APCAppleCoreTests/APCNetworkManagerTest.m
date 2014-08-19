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
#define BASE_URL @"http://api.openweathermap.org/data/2.5/weather?q="

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

@end
