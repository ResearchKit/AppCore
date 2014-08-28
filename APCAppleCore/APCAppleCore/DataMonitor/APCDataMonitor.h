//
//  APCDataMonitor.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class APCDataSubstrate, APCSageNetworkManager;

//Assumes Network Manager is a Sage Network Manager

@interface APCDataMonitor : NSObject


- (instancetype)initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate networkManager: (APCSageNetworkManager*) networkManager;

- (void) appBecameActive;
- (void) backgroundFetch:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
