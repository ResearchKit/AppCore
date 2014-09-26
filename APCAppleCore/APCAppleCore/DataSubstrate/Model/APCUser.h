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
@property (nonatomic, getter=isLoggedIn) BOOL loggedIn;
@property (nonatomic, getter=isUserConsented) BOOL userConsented;

@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;

@property (nonatomic, strong) NSString * medicalConditions;
@property (nonatomic, strong) NSString * medications;

/*********************************************************************************/
#pragma mark - Simulated Properties using HealthKit
/*********************************************************************************/
@property (nonatomic, strong) NSDate * birthDate;
@property (nonatomic, strong) NSNumber * biologicalSex;
@property (nonatomic, strong) NSNumber * bloodType;

@property (nonatomic, strong) HKQuantity * height;
@property (nonatomic, strong) HKQuantity * weight;

@end
