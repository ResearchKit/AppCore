//
//  APCHealthKitQuantityTypeTracker.m
//  APCAppCore
//
//  Created by Justin Warmkessel on 11/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppCore.h"
#import <HealthKit/HealthKit.h>
#import "APCHealthKitQuantityTracker.h"

NSString *const kIdentifierName                    = @"HKQuantityTypeIdentifierStepCount";
NSString *const kNotificationName                  = @"APCQuantityTypeIdentifierUpdated";

@interface APCHealthKitQuantityTracker()

@property (strong, nonatomic) HKHealthStore *healthStore;
@property (strong, nonatomic) HKObserverQuery *observerQuery;

@end

@implementation APCHealthKitQuantityTracker

- (instancetype) init {

    self = [self initWithIdentifier:kIdentifierName withNotificationName:kNotificationName];

    return self;
}

- (instancetype) initWithIdentifier:(NSString *)healthKitQuantityTypeIdentifier withNotificationName:(NSString *)name {
    self = [super init];
    
    if (self) {
        self.healthStore = [HKHealthStore new];
        self.quantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:healthKitQuantityTypeIdentifier];
        self.notificationName = name;
    }
    
    return self;
}

- (instancetype) initWithIdentifier:(NSString *)healthKitQuantityTypeIdentifier {
    self = [super init];
    
    if (self) {
        self.healthStore = [HKHealthStore new];
        self.quantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:healthKitQuantityTypeIdentifier];
    }
    
    return self;
}

- (void)start {
    
    self.totalUpdates = 0;
    
    //This is here as a fallback in case developer forgets to get permissions.
    NSSet *readTypes = [[NSSet alloc] initWithArray:@[self.quantityType]];
    
    [self.healthStore requestAuthorizationToShareTypes:nil readTypes:readTypes completion:nil];
    
    if ([HKHealthStore isHealthDataAvailable]) {
        
        NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:[NSDate date] endDate:nil options:HKQueryOptionNone];
        
        self.observerQuery = [[HKObserverQuery alloc] initWithSampleType:self.quantityType predicate:predicate updateHandler:^(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error) {
            if (!error) {
                
                [self.healthStore mostRecentQuantitySampleOfType:self.quantityType predicate:predicate completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
                    
                    if (mostRecentQuantity != nil) {
                        self.lastUpdate = [NSDate date];
                        self.totalUpdates++;
                        NSDictionary *quantityDict = @{@"mostRecentQuantity": mostRecentQuantity, @"timestamp" : self.lastUpdate};
                        NSLog(@"%@", mostRecentQuantity);
                        if (![self.notificationName isEqualToString:@""] && !self.notificationName) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:self.notificationName object:self userInfo:quantityDict];
                        }
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
}

@end
