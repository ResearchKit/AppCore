// 
//  APCUser.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface APCUser : NSObject

/*********************************************************************************/
#pragma mark - Designated Intializer
/*********************************************************************************/
- (instancetype)initWithContext: (NSManagedObjectContext*) context;

/*********************************************************************************/
#pragma mark - Stored Properties in Keychain
/*********************************************************************************/
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;

@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSString * sessionToken;

/*********************************************************************************/
#pragma mark - Stored Properties in Core Data
/*********************************************************************************/

@property (nonatomic, strong) NSData *profileImage;

@property (nonatomic, getter=isConsented) BOOL consented; //Confirmation that server is consented. Should be used in the app to test for user consent.
@property (nonatomic, getter=isUserConsented) BOOL userConsented; //User has consented though not communicated to the server.

@property (nonatomic, strong) NSString * medicalConditions;
@property (nonatomic, strong) NSString * medications;
@property (nonatomic, strong) NSString *ethnicity;

@property (nonatomic, strong) NSDate *sleepTime;
@property (nonatomic, strong) NSDate *wakeUpTime;

@property (nonatomic, strong) NSString *glucoseLevels;

@property (nonatomic, strong) NSString *homeLocationAddress;
@property (nonatomic, strong) NSNumber *homeLocationLat;
@property (nonatomic, strong) NSNumber *homeLocationLong;

/*********************************************************************************/
#pragma mark - Simulated Properties using HealthKit
/*********************************************************************************/
@property (nonatomic, strong) NSDate * birthDate;
@property (nonatomic) HKBiologicalSex biologicalSex;
@property (nonatomic) HKBloodType bloodType;

@property (nonatomic, strong) HKQuantity * height;
@property (nonatomic, strong) HKQuantity * weight;

@property (nonatomic, strong) HKQuantity *systolicBloodPressure;

/*********************************************************************************/
#pragma mark - NSUserDefaults Simulated Properties
/*********************************************************************************/
@property (nonatomic, getter=isSignedUp) BOOL signedUp;
@property (nonatomic, getter=isSignedIn) BOOL signedIn;

- (BOOL) isLoggedOut;

@end
