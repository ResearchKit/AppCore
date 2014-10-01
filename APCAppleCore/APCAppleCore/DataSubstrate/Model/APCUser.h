//
//  APCUser.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@interface APCUser : NSObject

/*********************************************************************************/
#pragma mark - Stored Properties in Core Data
/*********************************************************************************/
@property (nonatomic, getter=isConsented) BOOL consented;

@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;

@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSString * email;

@property (nonatomic, strong) NSString * medicalConditions;
@property (nonatomic, strong) NSString * medications;

@property (nonatomic, strong) NSDate *sleepTime;
@property (nonatomic, strong) NSDate *wakeUpTime;

/*********************************************************************************/
#pragma mark - Simulated Properties using HealthKit
/*********************************************************************************/
@property (nonatomic, readonly) NSDate * birthDate;
@property (nonatomic, readonly) HKBiologicalSex biologicalSex;
@property (nonatomic, readonly) HKBloodType bloodType;

@property (nonatomic, strong) HKQuantity * height;
@property (nonatomic, strong) HKQuantity * weight;

/*********************************************************************************/
#pragma mark - Methods
/*********************************************************************************/
- (BOOL) isLoggedIn;

@end
