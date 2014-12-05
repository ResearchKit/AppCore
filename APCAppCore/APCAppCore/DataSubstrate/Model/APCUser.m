// 
//  APCUser.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCUser.h"
#import "APCAppCore.h"
#import <HealthKit/HealthKit.h>


static NSString *const kFirstNamePropertytName = @"firstName";
static NSString *const kLastNamePropertyName = @"lastName";
static NSString *const kEmailPropertyName = @"email";
static NSString *const kPasswordPropertyName = @"password";
static NSString *const kSessionTokenPropertyName = @"sessionToken";

static NSString *const kProfileImagePropertyName = @"profileImage";
static NSString *const kBirthDatePropertyName = @"birthDate";
static NSString *const kBiologicalSexPropertyName = @"BiologicalSex";
static NSString *const kBloodTypePropertyName = @"bloodType";
static NSString *const kConsentedPropertyName = @"serverConsented";
static NSString *const kUserConsentedPropertyName = @"userConsented";
static NSString *const kMedicalConditionsPropertyName = @"medicalConditions";
static NSString *const kMedicationsPropertyName = @"medications";
static NSString *const kWakeUpTimePropertyName = @"wakeUpTime";
static NSString *const kSleepTimePropertyName = @"sleepTime";
static NSString *const kEthnicityPropertyName = @"ethnicity";
static NSString *const kGlucoseLevelsPropertyName = @"glucoseLevels";
static NSString *const kHomeLocationAddressPropertyName = @"homeLocationAddress";
static NSString *const kHomeLocationLatPropertyName = @"homeLocationLat";
static NSString *const kHomeLocationLongPropertyName = @"homeLocationLong";
static NSString *const kSecondaryInfoSavedPropertyName = @"secondaryInfoSaved";

static NSString *const kSignedUpKey = @"SignedUp";
static NSString *const kSignedInKey = @"SignedIn";

@interface APCUser ()
{
    NSDate * _birthDate;
    HKBiologicalSex _biologicalSex;
    HKBloodType _bloodType;
}
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
            Home Address : %@ \n\
            Home Location Lat : %@ \n\
            Home Location Long : %@ \n\
            ", self.firstName, self.lastName, self.email, self.birthDate, (int) self.biologicalSex, @(self.isSignedUp), @(self.isUserConsented), @(self.isSignedIn), @(self.isConsented), self.medicalConditions, self.medications, (int) self.bloodType, self.height, self.weight, self.wakeUpTime, self.sleepTime, self.homeLocationAddress, self.homeLocationLat, self.homeLocationLong];
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
    _profileImage = [storedUserData.profileImage copy];
    _birthDate = [storedUserData.birthDate copy];
    _biologicalSex = (HKBiologicalSex)[storedUserData.biologicalSex integerValue];
    _bloodType = (HKBloodType) [storedUserData.bloodType integerValue];
    _consented = [storedUserData.serverConsented boolValue];
    _userConsented = [storedUserData.userConsented boolValue];
    _medicalConditions = [storedUserData.medicalConditions copy];
    _medications = [storedUserData.medications copy];
    _wakeUpTime = [storedUserData.wakeUpTime copy];
    _sleepTime = [storedUserData.sleepTime copy];
    _ethnicity = [storedUserData.ethnicity copy];
    _glucoseLevels = [storedUserData.glucoseLevels copy];
    _homeLocationAddress = [storedUserData.homeLocationAddress copy];
    _homeLocationLat = [storedUserData.homeLocationLat copy];
    _homeLocationLong = [storedUserData.homeLocationLong copy];
    _secondaryInfoSaved = [storedUserData.secondaryInfoSaved boolValue];
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
    return [APCKeychainStore stringForKey:kFirstNamePropertytName];
}

- (void)setFirstName:(NSString *)firstName
{
    [APCKeychainStore setString:firstName forKey:kFirstNamePropertytName];
}

- (NSString *)lastName
{
    return [APCKeychainStore stringForKey:kLastNamePropertyName];
}

- (void)setLastName:(NSString *)lastName
{
    [APCKeychainStore setString:lastName forKey:kLastNamePropertyName];
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

- (NSString *)sessionToken
{
    return [APCKeychainStore stringForKey:kSessionTokenPropertyName];
}

- (void)setSessionToken:(NSString *)sessionToken
{
    [APCKeychainStore setString:sessionToken forKey:kSessionTokenPropertyName];
}


/*********************************************************************************/
#pragma mark - Setters for Properties in Core Data
/*********************************************************************************/

- (void)setProfileImage:(NSData *)profileImage
{
    _profileImage = profileImage;
    [self updateStoredProperty:kProfileImagePropertyName withValue:profileImage];
}

- (void)setConsented:(BOOL)consented
{
    _consented = consented;
    [self updateStoredProperty:kConsentedPropertyName withValue:@(consented)];
    if (consented) {
        [[NSNotificationCenter defaultCenter] postNotificationName:APCUserDidConsentNotification object:nil];
    }

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

- (void)setEthnicity:(NSString *)ethnicity
{
    _ethnicity = ethnicity;
    [self updateStoredProperty:kEthnicityPropertyName withValue:ethnicity];
}

- (void)setGlucoseLevels:(NSString *)glucoseLevels
{
    _glucoseLevels = glucoseLevels;
    [self updateStoredProperty:kGlucoseLevelsPropertyName withValue:glucoseLevels];
}

- (void)setHomeLocationAddress:(NSString *)homeLocationAddress
{
    _homeLocationAddress = homeLocationAddress;
    [self updateStoredProperty:kHomeLocationAddressPropertyName withValue:homeLocationAddress];
}

- (void)setHomeLocationLat:(NSNumber *)homeLocationLat
{
    _homeLocationLat = homeLocationLat;
    [self updateStoredProperty:kHomeLocationLatPropertyName withValue:homeLocationLat];
}

- (void)setHomeLocationLong:(NSNumber *)homeLocationLong
{
    _homeLocationLong = homeLocationLong;
    [self updateStoredProperty:kHomeLocationLongPropertyName withValue:homeLocationLong];
    
}

- (void)setSecondaryInfoSaved:(BOOL)secondaryInfoSaved
{
    _secondaryInfoSaved = secondaryInfoSaved;
    [self updateStoredProperty:kSecondaryInfoSavedPropertyName withValue:@(secondaryInfoSaved)];
}

/*********************************************************************************/
#pragma mark - Simulated Properties using HealthKit
/*********************************************************************************/

- (NSDate *)birthDate
{
    NSError *error;
    NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];
    [error handle];
    return dateOfBirth ?: _birthDate;
}

-(void)setBirthDate:(NSDate *)birthDate
{
    _birthDate = birthDate;
    [self updateStoredProperty:kBirthDatePropertyName withValue:birthDate];
}

- (HKBiologicalSex) biologicalSex
{
    NSError *error;
    HKBiologicalSexObject * sexObject = [self.healthStore biologicalSexWithError:&error];
    [error handle];
    return sexObject.biologicalSex?:_biologicalSex;
}

- (void)setBiologicalSex:(HKBiologicalSex)biologicalSex
{
    _biologicalSex = biologicalSex;
    [self updateStoredProperty:kBiologicalSexPropertyName withValue:@(biologicalSex)];
}

- (HKBloodType) bloodType
{
    NSError *error;
    HKBloodTypeObject * bloodObject = [self.healthStore bloodTypeWithError:&error];
    [error handle];
    return bloodObject.bloodType?: _bloodType;
}

- (void)setBloodType:(HKBloodType)bloodType
{
    _bloodType = bloodType;
    [self updateStoredProperty:kBloodTypePropertyName withValue:@(bloodType)];
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

// Systolic Blood Pressure
- (HKQuantity *)systolicBloodPressure
{
    HKQuantityType *bloodPressureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block HKQuantity *systolicBloodPressure;
    [self.healthStore mostRecentQuantitySampleOfType:bloodPressureType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        [error handle];
        systolicBloodPressure = mostRecentQuantity;
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    sema = NULL;
    return systolicBloodPressure;
}

- (void)setSystolicBloodPressure:(HKQuantity *)systolicBloodPressure
{
    HKQuantityType *bloodPressureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    NSDate *now = [NSDate date];
    
    HKQuantitySample *systolicBloodPressureSample = [HKQuantitySample quantitySampleWithType:bloodPressureType quantity:systolicBloodPressure startDate:now endDate:now];
    
    [self.healthStore saveObject:systolicBloodPressureSample withCompletion:^(BOOL success, NSError *error) {
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
    return self.email.length && !self.isSignedIn && !self.isSignedUp;
}

@end
