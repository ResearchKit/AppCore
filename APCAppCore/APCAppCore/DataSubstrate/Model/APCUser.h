// 
//  APCUser.h 
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
 
#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, APCUserConsentSharingScope) {
    APCUserConsentSharingScopeNone = 0,
    APCUserConsentSharingScopeStudy,
    APCUserConsentSharingScopeAll,
};


@interface APCUser : NSObject

/*********************************************************************************/
#pragma mark - Designated Intializer
/*********************************************************************************/
- (instancetype)initWithContext: (NSManagedObjectContext*) context;

/*********************************************************************************/
#pragma mark - Stored Properties in Keychain
/*********************************************************************************/

@property (nonatomic, strong) NSString * name;

@property (nonatomic, strong) NSString * firstName DEPRECATED_ATTRIBUTE;
@property (nonatomic, strong) NSString * lastName DEPRECATED_ATTRIBUTE;

@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSString * sessionToken;

/*********************************************************************************/
#pragma mark - Stored Properties in Core Data
/*********************************************************************************/
@property (nonatomic) APCUserConsentSharingScope sharingScope;      // NOT stored to CoreData, reflected in "sharedOptionSelection"
@property (nonatomic) NSNumber *sharedOptionSelection;
@property (nonatomic, strong) NSData *profileImage;

@property (nonatomic, getter=isConsented) BOOL consented; //Confirmation that server is consented. Should be used in the app to test for user consent.
@property (nonatomic, getter=isUserConsented) BOOL userConsented; //User has consented though not communicated to the server.

@property (nonatomic, strong) NSDate * taskCompletion;
@property (nonatomic) NSInteger hasHeartDisease;
@property (nonatomic) NSInteger dailyScalesCompletionCounter;
@property (nonatomic, strong) NSString *customSurveyQuestion;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic) BOOL allowContact;
@property (nonatomic, strong) NSString * medicalConditions;
@property (nonatomic, strong) NSString * medications;
@property (nonatomic, strong) NSString *ethnicity;

@property (nonatomic, strong) NSDate *sleepTime;
@property (nonatomic, strong) NSDate *wakeUpTime;

@property (nonatomic, strong) NSString *glucoseLevels;

@property (nonatomic, strong) NSString *homeLocationAddress;
@property (nonatomic, strong) NSNumber *homeLocationLat;
@property (nonatomic, strong) NSNumber *homeLocationLong;

@property (nonatomic, strong) NSString *consentSignatureName;
@property (nonatomic, strong) NSDate *consentSignatureDate;
@property (nonatomic, strong) NSData *consentSignatureImage;

@property (nonatomic, getter=isSecondaryInfoSaved) BOOL secondaryInfoSaved;

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

/**
 Returns our best approximation of the user's "date of
 consent" -- the date they agreed to start the study.
 
 These days, we track the date the user signs up.  In
 earlier versions of the apps, we didn't.  This method
 represents a set of next-best-guesses about that date,
 for users who signed up before we started tracking it.
 */
@property (readonly) NSDate *estimatedConsentDate;

/**
 Returns the best approximation we have for a user-consent
 date if we don't yet have any user data.  This is a
 static method so that it can be used during database
 migration, when we attach start dates to existing
 schedules, as well as during normal operation.
 */
+ (NSDate *) proxyForConsentDate;

@end
