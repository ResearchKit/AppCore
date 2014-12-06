// 
//  APCDataMonitor.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class APCDataSubstrate, APCScheduler;

@interface APCDataMonitor : NSObject


- (instancetype)initWithDataSubstrate: (APCDataSubstrate*) dataSubstrate scheduler: (APCScheduler*) scheduler;

- (void) appFinishedLaunching;
- (void) appBecameActive;
- (void) userConsented;

/*********************************************************************************/
#pragma mark - For Categories Only
/*********************************************************************************/

//Declaring as weak so as not to hold on to below objects
@property (weak, nonatomic) APCDataSubstrate * dataSubstrate;
@property (weak, nonatomic) APCScheduler * scheduler;
@property (nonatomic) BOOL batchUploadingInProgress;

@end
