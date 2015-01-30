// 
//  APCHealthKitQuantityTracker.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>
#import "APCDataTracker.h"

@interface APCHealthKitQuantityTracker : APCDataTracker

@property (strong, nonatomic) __block NSDate *lastUpdate;
@property (assign) NSInteger __block totalUpdates;

@property (assign) __block double stepCount;
@property (strong, nonatomic) HKQuantityType *quantityType;
@property (strong, nonatomic) NSString *notificationName;

- (instancetype) initWithIdentifier:(NSString *)healthKitQuantityTypeIdentifier
               withNotificationName:(NSString *)name;

- (instancetype) initWithIdentifier:(NSString *)healthKitQuantityTypeIdentifier;

- (void)start;

- (void)stop;

@end
