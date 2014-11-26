//
//  APCHealthKitQuantityTypeTracker.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 11/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//
#import <HealthKit/HealthKit.h>
#import "APCHealthKitQuantityTracker.h"
#import "APCAppleCore.h"

NSString *const kIdentifierName                    = @"HKQuantityTypeIdentifierStepCount";
NSString *const kNotificationName                  = @"APCQuantityTypeIdentifierUpdated";

@interface APCHealthKitQuantityTracker()

@property (strong, nonatomic) HKHealthStore *healthStore;
@property (strong, nonatomic) HKObserverQuery *observerQuery;

@end

@implementation APCHealthKitQuantityTracker

- (instancetype) init {

    self = [self initWithIdentifier:kIdentifierName withNotificationName:kNotificationName applicationDelegate:[UIApplication sharedApplication].delegate];

    return self;
}

- (instancetype) initWithIdentifier:(NSString *)identifier withNotificationName:(NSString *)name applicationDelegate:(UIResponder *)appDelegate {
    self = [super init];
    
    if (self) {
        APCAppDelegate * localAppDelegate = (APCAppDelegate *) appDelegate;
        self.healthStore = [HKHealthStore new];
        self.quantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:identifier];
        self.notificationName = name;
    }
    
    return self;
}

- (instancetype) initWithIdentifier:(NSString *)identifier applicationDelegate:(UIResponder *)appDelegate{
    self = [super init];
    
    if (self) {
        APCAppDelegate * localAppDelegate = (APCAppDelegate *) appDelegate;
        self.healthStore = [HKHealthStore new];
        self.quantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:identifier];
        self.totalUpdates = 0;
    }
    
    return self;
}

- (void)start {
    
    //This is here as a fallback in case developer forgets to get permissions.
    NSSet *readTypes = [[NSSet alloc] initWithArray:@[self.quantityType]];
    
    [self.healthStore requestAuthorizationToShareTypes:nil readTypes:readTypes completion:nil];
    
    if ([HKHealthStore isHealthDataAvailable]) {
        
        self.observerQuery = [[HKObserverQuery alloc] initWithSampleType:self.quantityType predicate:nil updateHandler:^(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error) {
            if (!error) {
                
                [self.healthStore mostRecentQuantitySampleOfType:self.quantityType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
                    
                    self.lastUpdate = [NSDate date];
                    self.totalUpdates++;
                    NSDictionary *quantityDict = @{@"mostRecentQuantity": mostRecentQuantity, @"timestamp" : self.lastUpdate};
                    NSLog(@"%@", mostRecentQuantity);
                    if (![self.notificationName isEqualToString:@""] && !self.notificationName) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:self.notificationName object:self userInfo:quantityDict];
                    }
                }];
                
                completionHandler();
                
            } else {
                
                [error handle];
            }
        }];
        
        //Execute query
        [self.healthStore executeQuery:self.observerQuery];
    }
}

- (void)stop {
    [self.healthStore stopQuery:self.observerQuery];
    self.lastUpdate = nil;
    self.totalUpdates = 0;
}

@end
