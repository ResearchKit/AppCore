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

static NSString *const kLoggedInKey = @"LoggedIn";
static NSString *const kConsentedPropertyName = @"consented";
static NSString *const kFirstNamePropertyName = @"firstName";
static NSString *const kLastNamePropertyName = @"lastName";
static NSString *const kMedicalConditionsPropertyName = @"medicalConditions";
static NSString *const kMedicationsPropertyName = @"medications";

@interface APCUser ()
@property (nonatomic, readonly) HKHealthStore * healthStore;
@end


@implementation APCUser

- (BOOL)isLoggedIn
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kLoggedInKey];
}

/*********************************************************************************/
#pragma mark - Initialization Methods
/*********************************************************************************/

- (instancetype)init
{
    self = [super init];
    [self loadStoredUserData];
    return self;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"\
            First Name : %@\n\
            Last Name : %@\n\
            Username : %@\n\
            Email : %@\n\
            DOB : %@\n\
            Biological Sex : %d\n\
            -----------------------\n\
            Medical Conditions : %@\n\
            Medications : %@\n\
            Blood Type : %d\n\
            Height : %@ \n\
            Weight : %@ \n\
            Wake Up Time : %@ \n\
            Sleep time : %@ \n\
            ", self.firstName, self.lastName, self.userName, self.email, self.birthDate, self.biologicalSex, self.medicalConditions, self.medications, self.bloodType, self.height, self.weight, self.wakeUpTime, self.sleepTime];
}

- (void) loadStoredUserData
{
    NSManagedObjectContext * context = [(APCAppDelegate*) [UIApplication sharedApplication].delegate dataSubstrate].persistentContext;
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
    _consented = [storedUserData.consented boolValue];
    _firstName = [storedUserData.firstName copy];
    _lastName = [storedUserData.lastName copy];
    _medicalConditions = [storedUserData.medicalConditions copy];
    _medications = [storedUserData.medications copy];
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
#pragma mark - Setters for Properties in Core Data
/*********************************************************************************/

- (void)setConsented:(BOOL)consented
{
    _consented = consented;
    [self updateStoredProperty:kConsentedPropertyName withValue:@(consented)];
    [[NSNotificationCenter defaultCenter] postNotificationName:APCUserDidConsentNotification object:nil];
}

- (void) setFirstName:(NSString *)firstName
{
    _firstName = firstName;
    [self updateStoredProperty:kFirstNamePropertyName withValue:firstName];
}

- (void)setLastName:(NSString *)lastName
{
    _lastName = lastName;
    [self updateStoredProperty:kLastNamePropertyName withValue:lastName];
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

@end
