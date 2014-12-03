//
//  APCDataMonitor.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class APCDataSubstrate, APCScheduler;

@interface APCDataMonitor : NSObject


- (instancetype)initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate scheduler: (APCScheduler*) scheduler;

- (void) appBecameActive;
- (void) backgroundFetch:(void (^)(UIBackgroundFetchResult))completionHandler;

/*********************************************************************************/
#pragma mark - For Categories Only
/*********************************************************************************/

//Declaring as weak so as not to hold on to below objects
@property (weak, nonatomic) APCDataSubstrate * dataSubstrate;
@property (weak, nonatomic) APCScheduler * scheduler;

@end
