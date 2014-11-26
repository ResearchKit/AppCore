//
//  APCHealthKitQuantityTypeTracker.h
//  APCAppleCore
//
//  Created by Justin Warmkessel on 11/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCHealthKitQuantityTracker : NSObject

@property (strong, nonatomic) __block NSDate *lastUpdate;
@property (assign) NSInteger __block totalUpdates;

@property (assign) __block double stepCount;
@property (strong, nonatomic) HKQuantityType *quantityType;
@property (strong, nonatomic) NSString *notificationName;

- (instancetype) initWithIdentifier:(NSString *)identifier
               withNotificationName:(NSString *)name
                applicationDelegate:(UIResponder *)appDelegate;

- (instancetype) initWithIdentifier:(NSString *)identifier
                applicationDelegate:(UIResponder *)appDelegate;
- (void)start;

- (void)stop;

@end