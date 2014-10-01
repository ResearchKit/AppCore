//
//  APCAppDelegate.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APCDataSubstrate, APCDataMonitor, APCScheduler;
@interface APCAppDelegate : UIResponder <UIApplicationDelegate>

@property  (strong, nonatomic)  UIWindow * window;

//APC Related Properties & Methods
@property (strong, nonatomic) APCDataSubstrate * dataSubstrate;
@property (strong, nonatomic) APCDataMonitor * dataMonitor;
@property (strong, nonatomic) APCScheduler * scheduler;

@end
