// 
//  APCUser.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCUser.h"
#import "APCStoredUserData.h"
#import "APCAppDelegate.h"
#import "APCDataSubstrate.h"
#import "APCKeychainStore.h"
#import "APCLog.h"
#import "APCUtilities.h"
#import "NSManagedObject+APCHelper.h"
#import "HKHealthStore+APCExtensions.h"


static NSString *const kNamePropertytName = @"name";
static NSString *const kFirstNamePropertytName = @"firstName";
static NSString *const kLastNamePropertyName = @"lastName";
static NSString *const kEmailPropertyName = @"email";
static NSString *const kPasswordPropertyName = @"password";
static NSString *const kSessionTokenPropertyName = @"sessionToken";

static NSString *const kSharedOptionSelection = @"sharedOptionSelection";
static NSString *const kTaskCompletion = @"taskCompletion";
static NSString *const kHasHeartDisease = @"hasHeartDisease";
static NSString *const kDailyScalesCompletionCounterPropertyName = @"dailyScalesCompletionCounter";
static NSString *const kCustomSurveyQuestionPropertyName = @"customSurveyQuestion";
static NSString *const kPhoneNumberPropertyName = @"phoneNumber";
static NSString *const kAllowContactPropertyName = @"allowContact";
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

static NSString *const kConsentSignatureNamePropertyName = @"consentSignatureName";
static NSString *const kConsentSignatureDatePropertyName = @"consentSignatureDate";
static NSString *const kConsentSignatureImagePropertyName = @"consentSignatureImage";

static NSString *const kSignedUpKey = @"SignedUp";
static NSString *const kSignedInKey = @"SignedIn";

@interface APCUser ()
{
    NSDate *_birthDate;
    HKBiologicalSex _biologicalSex;
    HKBloodType _bloodType;
}
@property (nonatomic, readonly) HKHealthStore *healthStore;
@end


@implementation APCUser

/*********************************************************************************/
#pragma mark - Initialization Methods
/*********************************************************************************/

- (instancetype)initWithContext:(NSManagedObjectContext*)context
{
    self = [super init];
    [self loadStoredUserData:context];
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\
            Name : %@\n\
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
            ", self.name, self.email, self.birthDate, (int) self.biologicalSex, @(self.isSignedUp), @(self.isUserConsented), @(self.isSignedIn), @(self.isConsented), self.medicalConditions, self.medications, (int) self.bloodType, self.height, self.weight, self.wakeUpTime, self.sleepTime, self.homeLocationAddress, self.homeLocationLat, self.homeLocationLong];
}

- (void)loadStoredUserData:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        APCStoredUserData * storedUserData = [self loadStoredUserDataInContext:context];
        [self copyPropertiesFromStoredUserData:storedUserData];
    }];
}

- (APCStoredUserData *)loadStoredUserDataInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [APCStoredUserData request];
    NSError *error;
    APCStoredUserData *storedUserData = [[context executeFetchRequest:request error:&error] firstObject];
    APCLogError2 (error);
    if (!storedUserData) {
        storedUserData = [APCStoredUserData newObjectForContext:context];
        NSError * saveError;
        [storedUserData saveToPersistentStore:&saveError];
        APCLogError2 (saveError);
    }
    return storedUserData;
}

- (void)copyPropertiesFromStoredUserData:(APCStoredUserData*)storedUserData
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
    
    _consentSignatureName = [storedUserData.consentSignatureName copy];
    _consentSignatureDate = [storedUserData.consentSignatureDate copy];
    _consentSignatureImage = [storedUserData.consentSignatureImage copy];
    
    _dailyScalesCompletionCounter = [[storedUserData.dailyScalesCompletionCounter copy] integerValue];
    _customSurveyQuestion = [storedUserData.customSurveyQuestion copy];
    _hasHeartDisease = [[storedUserData.hasHeartDisease copy] integerValue];
    _taskCompletion = [storedUserData.taskCompletion copy];
    _sharedOptionSelection = [storedUserData.sharedOptionSelection copy];
}

- (void)updateStoredProperty:(NSString *)propertyName withValue:(id)value
{
    NSManagedObjectContext * context = [(APCAppDelegate*) [UIApplication sharedApplication].delegate dataSubstrate].persistentContext;
    [context performBlockAndWait:^{
        APCStoredUserData *storedUserData = [self loadStoredUserDataInContext:context];
        [storedUserData setValue:value forKey:propertyName];
        NSError *saveError;
        [storedUserData saveToPersistentStore:&saveError];
        APCLogError2(saveError);
    }];
}

- (HKHealthStore *)healthStore
{
    return [[(APCAppDelegate*) ([UIApplication sharedApplication].delegate) dataSubstrate] healthStore];
}

/*********************************************************************************/
#pragma mark - Properties from Key Chain
/*********************************************************************************/

- (NSString *)name
{
    return [APCKeychainStore stringForKey:kNamePropertytName];
}

- (void)setName:(NSString *)name
{
    if (name != nil) {
        [APCKeychainStore setString:name forKey:kNamePropertytName];
    }
    else {
        [APCKeychainStore removeValueForKey:kNamePropertytName];
    }
}

- (NSString *)firstName
{
    return [APCKeychainStore stringForKey:kFirstNamePropertytName];
}

- (void)setFirstName:(NSString *)firstName
{
    if (firstName != nil) {
        [APCKeychainStore setString:firstName forKey:kFirstNamePropertytName];
    }
    else {
        [APCKeychainStore removeValueForKey:kFirstNamePropertytName];
    }
}

- (NSString *)lastName
{
    return [APCKeychainStore stringForKey:kLastNamePropertyName];
}

- (void)setLastName:(NSString *)lastName
{
    if (lastName != nil) {
        [APCKeychainStore setString:lastName forKey:kLastNamePropertyName];
    }
    else {
        [APCKeychainStore removeValueForKey:kLastNamePropertyName];
    }
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

- (NSDate *) estimatedConsentDate
{
    NSDate *consentDate = self.consentSignatureDate;

    if (! consentDate)
    {
        consentDate = [[self class] proxyForConsentDate];
    }

    return consentDate;
}

+ (NSDate *) proxyForConsentDate
{
    NSDate *bestGuessConsentDate = [APCUtilities firstKnownFileAccessDate];

    if (! bestGuessConsentDate)
    {
        bestGuessConsentDate = [NSDate date];
    }

    return bestGuessConsentDate;
}


/*********************************************************************************/
#pragma mark - Setters for Properties in Core Data
/*********************************************************************************/

- (void)setSharingScope:(APCUserConsentSharingScope)sharingScope
{
    _sharingScope = sharingScope;
    switch (sharingScope) {
        case APCUserConsentSharingScopeNone:
            self.sharedOptionSelection = [NSNumber numberWithInteger:0];    // SBBConsentShareScopeNone
            break;
        case APCUserConsentSharingScopeStudy:
            self.sharedOptionSelection = [NSNumber numberWithInteger:1];    // SBBConsentShareScopeStudy
            break;
        case APCUserConsentSharingScopeAll:
            self.sharedOptionSelection = [NSNumber numberWithInteger:2];    // SBBConsentShareScopeAll
            break;
    }
}

- (void)setSharedOptionSelection:(NSNumber *)sharedOptionSelection
{
    switch (sharedOptionSelection.integerValue) {
        case 0:
            _sharingScope = APCUserConsentSharingScopeNone;
            break;
        case 1:
            _sharingScope = APCUserConsentSharingScopeStudy;
            break;
        case 2:
            _sharingScope = APCUserConsentSharingScopeAll;
            break;
    }
    
    _sharedOptionSelection = sharedOptionSelection;
    [self updateStoredProperty:kSharedOptionSelection withValue:sharedOptionSelection];
}

- (void)setTaskCompletion:(NSDate *)taskCompletion
{
    _taskCompletion = taskCompletion;
    [self updateStoredProperty:kTaskCompletion withValue:taskCompletion];
}

- (void)setHasHeartDisease:(NSInteger)hasHeartDisease
{
    _hasHeartDisease = hasHeartDisease;
    [self updateStoredProperty:kHasHeartDisease withValue:@(hasHeartDisease)];
}

- (void)setAllowContact:(BOOL)allowContact
{
    _allowContact = allowContact;
    [self updateStoredProperty:kAllowContactPropertyName withValue:@(allowContact)];
}

- (void)setCustomSurveyQuestion:(NSString *)customSurveyQuestion
{
    _customSurveyQuestion = customSurveyQuestion;
    [self updateStoredProperty:kCustomSurveyQuestionPropertyName withValue:customSurveyQuestion];
}

- (void)setDailyScalesCompletionCounter:(NSInteger)dailyScalesCompletionCounter
{
    _dailyScalesCompletionCounter = dailyScalesCompletionCounter;
    [self updateStoredProperty:kDailyScalesCompletionCounterPropertyName withValue:@(dailyScalesCompletionCounter)];
}

- (void)setPhoneNumber:(NSString *)phoneNumber
{
    _phoneNumber = phoneNumber;
    [self updateStoredProperty:kPhoneNumberPropertyName withValue:phoneNumber];
}

- (void)setProfileImage:(NSData *)profileImage
{
    _profileImage = profileImage;
    [self updateStoredProperty:kProfileImagePropertyName withValue:profileImage];
}

- (void)setConsented:(BOOL)consented
{
    _consented = consented;
    [self updateStoredProperty:kConsentedPropertyName withValue:@(consented)];
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

- (void)setConsentSignatureName:(NSString *)consentSignatureName
{
    _consentSignatureName = consentSignatureName;
    [self updateStoredProperty:kConsentSignatureNamePropertyName withValue:consentSignatureName];
}

- (void)setConsentSignatureDate:(NSDate *)consentSignatureDate
{
    _consentSignatureDate = consentSignatureDate;
    [self updateStoredProperty:kConsentSignatureDatePropertyName withValue:consentSignatureDate];
}

- (void)setConsentSignatureImage:(NSData *)consentSignatureImage
{
    _consentSignatureImage = consentSignatureImage;
    [self updateStoredProperty:kConsentSignatureImagePropertyName withValue:consentSignatureImage];
}

/*********************************************************************************/
#pragma mark - Simulated Properties using HealthKit
/*********************************************************************************/

- (NSDate *)birthDate
{
    NSError *error;
    NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];
    APCLogError2 (error);
    return dateOfBirth ?: _birthDate;
}

- (void)setBirthDate:(NSDate *)birthDate
{
    _birthDate = birthDate;
    [self updateStoredProperty:kBirthDatePropertyName withValue:birthDate];
}

- (HKBiologicalSex)biologicalSex
{
    NSError *error;
    HKBiologicalSexObject * sexObject = [self.healthStore biologicalSexWithError:&error];
    APCLogError2 (error);
    return sexObject.biologicalSex?:_biologicalSex;
}

- (void)setBiologicalSex:(HKBiologicalSex)biologicalSex
{
    _biologicalSex = biologicalSex;
    [self updateStoredProperty:kBiologicalSexPropertyName withValue:@(biologicalSex)];
}

- (HKBloodType)bloodType
{
    NSError *error;
    HKBloodTypeObject * bloodObject = [self.healthStore bloodTypeWithError:&error];
    APCLogError2 (error);
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
        APCLogError2 (error);
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
    
    [self.healthStore saveObject:heightSample withCompletion:^(BOOL __unused success, NSError *error) {
        APCLogError2 (error);
    }];
}

//Weight
- (HKQuantity *)weight
{
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block HKQuantity * weight;
    [self.healthStore mostRecentQuantitySampleOfType:weightType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        APCLogError2 (error);
        weight = mostRecentQuantity;
        dispatch_semaphore_signal(sema);
    }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    sema = NULL;
    return weight;
}

- (void)setWeight:(HKQuantity *)weight
{
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    NSDate *now = [NSDate date];
    
    HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weight startDate:now endDate:now];
    
    [self.healthStore saveObject:weightSample withCompletion:^(BOOL __unused success, NSError *error) {
        APCLogError2 (error);
    }];
}

// Systolic Blood Pressure
- (HKQuantity *)systolicBloodPressure
{
    HKQuantityType *bloodPressureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block HKQuantity *systolicBloodPressure;
    [self.healthStore mostRecentQuantitySampleOfType:bloodPressureType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        APCLogError2 (error);
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
    
    [self.healthStore saveObject:systolicBloodPressureSample withCompletion:^(BOOL __unused success, NSError *error) {
        APCLogError2 (error);
    }];
}

/*********************************************************************************/
#pragma mark - NSUserDefault Simulated Methods
/*********************************************************************************/
- (void)setSignedUp:(BOOL)signedUp
{
    [[NSUserDefaults standardUserDefaults] setBool:signedUp forKey:kSignedUpKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isSignedUp
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSignedUpKey];
}

- (void)setSignedIn:(BOOL)signedIn
{
    [[NSUserDefaults standardUserDefaults] setBool:signedIn forKey:kSignedInKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isSignedIn
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSignedInKey];
}

- (BOOL)isLoggedOut
{
    return self.email.length && !self.isSignedIn && !self.isSignedUp;
}

@end
