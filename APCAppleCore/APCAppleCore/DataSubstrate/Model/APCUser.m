//
//  APCUser.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCUser.h"
#import "APCAppleCore.h"
#import <HealthKit/HealthKit.h>


static NSString *const kFirstNamePropertyName = @"firstName";
static NSString *const kLastNamePropertyName = @"lastName";
static NSString *const kUserNamePropertyName = @"userName";
static NSString *const kEmailPropertyName = @"email";
static NSString *const kPasswordPropertyName = @"password";

static NSString *const kConsentedPropertyName = @"consented";
static NSString *const kUserConsentedPropertyName = @"userConsented";
static NSString *const kMedicalConditionsPropertyName = @"medicalConditions";
static NSString *const kMedicationsPropertyName = @"medications";
static NSString *const kWakeUpTimePropertyName = @"wakeUpTime";
static NSString *const kSleepTimePropertyName = @"sleepTime";

static NSString *const kSignedUpKey = @"SignedUp";
static NSString *const kSignedInKey = @"SignedIn";

@interface APCUser ()
@property (nonatomic, readonly) HKHealthStore * healthStore;
@end


@implementation APCUser

/*********************************************************************************/
#pragma mark - Initialization Methods
/*********************************************************************************/

- (instancetype)initWithContext: (NSManagedObjectContext*) context
{
    self = [super init];
    [self loadStoredUserData:context];
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\
            First Name : %@\n\
            Last Name : %@\n\
            Username : %@\n\
            Email : %@\n\
            DOB : %@\n\
            Biological Sex : %d\n\
            -----------------------\n\
            SignedUp? :%@\n\
            UserConsented? : %@\n\
            LoggedIn? :%@\n\
            serverConsented? : %@\n\
            -----------------------\n\
            Medical Conditions : %@\n\
            Medications : %@\n\
            Blood Type : %d\n\
            Height : %@ \n\
            Weight : %@ \n\
            Wake Up Time : %@ \n\
            Sleep time : %@ \n\
            ", self.firstName, self.lastName, self.userName, self.email, self.birthDate, (int) self.biologicalSex, @(self.isSignedUp), @(self.isUserConsented), @(self.isSignedIn), @(self.isConsented), self.medicalConditions, self.medications, (int) self.bloodType, self.height, self.weight, self.wakeUpTime, self.sleepTime];
}

- (void) loadStoredUserData: (NSManagedObjectContext*) context
{
    [context performBlockAndWait:^{
        APCStoredUserData * storedUserData = [self loadStoredUserDataInContext:context];
        [self copyPropertiesFromStoredUserData:storedUserData];
    }];
}

- (APCStoredUserData *) loadStoredUserDataInContext: (NSManagedObjectContext *) context
{
    NSFetchRequest * request = [APCStoredUserData request];
    NSError * error;
    APCStoredUserData * storedUserData = [[context executeFetchRequest:request error:&error] firstObject];
    [error handle];
    if (!storedUserData) {
        storedUserData = [APCStoredUserData newObjectForContext:context];
        NSError * saveError;
        [storedUserData saveToPersistentStore:&saveError];
        [saveError handle];
    }
    return storedUserData;
}

- (void) copyPropertiesFromStoredUserData: (APCStoredUserData*) storedUserData
{
    _consented = [storedUserData.serverConsented boolValue];
    _userConsented = [storedUserData.userConsented boolValue];
    _medicalConditions = [storedUserData.medicalConditions copy];
    _medications = [storedUserData.medications copy];
    _wakeUpTime = [storedUserData.wakeUpTime copy];
    _sleepTime = [storedUserData.sleepTime copy];
}

- (void) updateStoredProperty:(NSString*) propertyName withValue: (id) value
{
    NSManagedObjectContext * context = [(APCAppDelegate*) [UIApplication sharedApplication].delegate dataSubstrate].persistentContext;
    [context performBlockAndWait:^{
        APCStoredUserData * storedUserData = [self loadStoredUserDataInContext:context];
        [storedUserData setValue:value forKey:propertyName];
        NSError * saveError;
        [storedUserData saveToPersistentStore:&saveError];
        [saveError handle];
    }];
}

- (HKHealthStore *)healthStore
{
    return [[(APCAppDelegate*) ([UIApplication sharedApplication].delegate) dataSubstrate] healthStore];
}

/*********************************************************************************/
#pragma mark - Properties from Key Chain
/*********************************************************************************/

- (NSString *)firstName
{
    return [APCKeychainStore stringForKey:kFirstNamePropertyName];
}

- (void)setFirstName:(NSString *)firstName
{
    [APCKeychainStore setString:firstName forKey:kFirstNamePropertyName];
}

- (NSString *)lastName
{
    return [APCKeychainStore stringForKey:kLastNamePropertyName];
}

- (void)setLastName:(NSString *)lastName
{
    [APCKeychainStore setString:lastName forKey:kLastNamePropertyName];
}

- (NSString *)userName
{
    return [APCKeychainStore stringForKey:kUserNamePropertyName];
}

- (void)setUserName:(NSString *)userName
{
    [APCKeychainStore setString:userName forKey:kUserNamePropertyName];
}

- (NSString *)email
{
      return [APCKeychainStore stringForKey:kEmailPropertyName];
}

-(void)setEmail:(NSString *)email
{
    [APCKeychainStore setString:email forKey:kEmailPropertyName];
}

- (NSString *)password
{
    return [APCKeychainStore stringForKey:kPasswordPropertyName];
}

-(void)setPassword:(NSString *)password
{
    [APCKeychainStore setString:[self hashIfNeeded:password] forKey:kPasswordPropertyName];
}

- (NSString*) hashIfNeeded: (NSString*) password
{
    //TODO: Implement hashing method
    return password;
}


/*********************************************************************************/
#pragma mark - Setters for Properties in Core Data
/*********************************************************************************/

- (void)setConsented:(BOOL)consented
{
    _consented = consented;
    [self updateStoredProperty:kConsentedPropertyName withValue:@(consented)];
    [[NSNotificationCenter defaultCenter] postNotificationName:APCUserDidConsentNotification object:nil];
}

- (void)setUserConsented:(BOOL)userConsented
{
    _userConsented = userConsented;
    [self updateStoredProperty:kUserConsentedPropertyName withValue:@(userConsented)];
}

- (void)setMedicalConditions:(NSString *)medicalConditions
{
    _medicalConditions = medicalConditions;
    [self updateStoredProperty:kMedicalConditionsPropertyName withValue:medicalConditions];
}

- (void)setMedications:(NSString *)medications
{
    _medications = medications;
    [self updateStoredProperty:kMedicationsPropertyName withValue:medications];
}

- (void)setWakeUpTime:(NSDate *)wakeUpTime{
    _wakeUpTime = wakeUpTime;
    [self updateStoredProperty:kWakeUpTimePropertyName withValue:wakeUpTime];
}

- (void)setSleepTime:(NSDate *)sleepTime
{
    _sleepTime = sleepTime;
    [self updateStoredProperty:kSleepTimePropertyName withValue:sleepTime];
}

/*********************************************************************************/
#pragma mark - Simulated Properties using HealthKit
/*********************************************************************************/

- (NSDate *)birthDate
{
    NSError *error;
    NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];
    [error handle];
    return dateOfBirth;
}

- (HKBiologicalSex) biologicalSex
{
    NSError *error;
    HKBiologicalSexObject * sexObject = [self.healthStore biologicalSexWithError:&error];
    [error handle];
    return sexObject.biologicalSex;
}

- (HKBloodType) bloodType
{
    NSError *error;
    HKBloodTypeObject * bloodObject = [self.healthStore bloodTypeWithError:&error];
    [error handle];
    return bloodObject.bloodType;
}

//Height
- (HKQuantity *)height
{
    
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block HKQuantity * height;
    [self.healthStore mostRecentQuantitySampleOfType:heightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        [error handle];
        height = mostRecentQuantity;
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    sema = NULL;
    return height;
    
}

- (void)setHeight:(HKQuantity *)height
{
    
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    NSDate *now = [NSDate date];
    
    HKQuantitySample *heightSample = [HKQuantitySample quantitySampleWithType:heightType quantity:height startDate:now endDate:now];
    
    [self.healthStore saveObject:heightSample withCompletion:^(BOOL success, NSError *error) {
        [error handle];
    }];
}

//Weight
- (HKQuantity *)weight
{
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block HKQuantity * weight;
    [self.healthStore mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        [error handle];
        weight = mostRecentQuantity;
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    sema = NULL;
    return weight;
}

-(void)setWeight:(HKQuantity *)weight
{
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    NSDate *now = [NSDate date];
    
    HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weight startDate:now endDate:now];
    
    [self.healthStore saveObject:weightSample withCompletion:^(BOOL success, NSError *error) {
        [error handle];
    }];
}

/*********************************************************************************/
#pragma mark - NSUserDefault Simulated Methods
/*********************************************************************************/
-(void)setSignedUp:(BOOL)signedUp
{
    [[NSUserDefaults standardUserDefaults] setBool:signedUp forKey:kSignedUpKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (signedUp) {
        [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)APCUserSignedUpNotification object:nil];
    }
}

- (BOOL) isSignedUp
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSignedUpKey];
}

- (void)setSignedIn:(BOOL)signedIn
{
    [[NSUserDefaults standardUserDefaults] setBool:signedIn forKey:kSignedInKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (signedIn) {
        [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)APCUserSignedInNotification object:nil];
    }
}

- (BOOL) isSignedIn
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSignedInKey];
}

- (BOOL)isLoggedOut
{
    return self.userName.length && !self.isSignedIn && !self.isSignedUp;
}

@end
