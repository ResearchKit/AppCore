// 
//  APCPermissionsManager.m 
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
 
#import "APCPermissionsManager.h"
#import "APCUserInfoConstants.h"
#import "APCTasksReminderManager.h"
#import "APCAppDelegate.h"
#import "APCLocalization.h"

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <HealthKit/HealthKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


static NSString * const APCPermissionsManagerErrorDomain = @"APCPermissionsManagerErrorDomain";

typedef NS_ENUM(NSUInteger, APCPermissionsErrorCode) {
    kPermissionsErrorAccessDenied = -100,
};

/*
 * APCPermissionsManager should probably be a singleton itself, but to minimize changes
 * and work with priorities, we are only making coreMotionPermissionStatus be static
 * This solves the bug with it being reset to undetermined everytime a new instance is made
 */
static APCPermissionStatus coreMotionPermissionStatus;

@interface APCPermissionsManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) APCPermissionsBlock completionBlock;

@property (copy, nonatomic) NSArray *healthKitCharacteristicTypesToRead;
@property (copy, nonatomic) NSArray *healthKitTypesToRead;
@property (copy, nonatomic) NSArray *healthKitTypesToWrite;

@end


@implementation APCPermissionsManager


- (instancetype)init
{
    if (self = [super init]) {
        _motionActivityManager = [[CMMotionActivityManager alloc] init];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidRegisterForRemoteNotifications:) name:APCAppDidRegisterUserNotification object:nil];

        // Make sure coreMotionPermissionStatus is in a valid state, and it isn't overwritten
        // If we already have a value for it
        if (coreMotionPermissionStatus != kPermissionStatusAuthorized &&
            coreMotionPermissionStatus != kPermissionStatusDenied)
        {
            coreMotionPermissionStatus = kPermissionStatusNotDetermined;
        }
        
    }
    return self;
}

- (id)initWithHealthKitCharacteristicTypesToRead:(NSArray *)characteristicTypesToRead
                    healthKitQuantityTypesToRead:(NSArray *)quantityTypesToRead
                   healthKitQuantityTypesToWrite:(NSArray *)QuantityTypesToWrite
                               userInfoItemTypes:(NSArray *)userInfoItemTypes
                           signUpPermissionTypes:(NSArray *)signUpPermissionTypes
{
    self = [self init];
    
    if (self) {
        self.healthKitCharacteristicTypesToRead = characteristicTypesToRead;
        self.healthKitTypesToRead = quantityTypesToRead;
        self.healthKitTypesToWrite = QuantityTypesToWrite;
        self.signUpPermissionTypes = signUpPermissionTypes;
        self.userInfoItemTypes = userInfoItemTypes;
    }
    
    return self;
}

- (HKHealthStore *)healthStore
{
    return [[(APCAppDelegate*) ([UIApplication sharedApplication].delegate) dataSubstrate] healthStore];
}

- (BOOL)isPermissionsGrantedForType:(APCSignUpPermissionsType)type
{
    BOOL isGranted = NO;
    [[NSUserDefaults standardUserDefaults]synchronize];
    switch (type) {
        case kAPCSignUpPermissionsTypeNone:
            isGranted = YES;
            break;
        case kAPCSignUpPermissionsTypeHealthKit:
        {
            HKCharacteristicType *dateOfBirth = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
            HKAuthorizationStatus status = [self.healthStore authorizationStatusForType:dateOfBirth];

            isGranted = (status == HKAuthorizationStatusSharingAuthorized);
        }
            break;
        case kAPCSignUpPermissionsTypeLocation:
        {
#if TARGET_IPHONE_SIMULATOR
            isGranted = YES;
#else
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            
            if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
                isGranted = YES;
            }
            
            if (status == kCLAuthorizationStatusAuthorizedAlways) {
                isGranted = YES;
            }
#endif
        }
            break;
        case kAPCSignUpPermissionsTypeLocalNotifications:
        {
            isGranted = [[UIApplication sharedApplication] currentUserNotificationSettings].types != 0;
        }
            break;
        case kAPCSignUpPermissionsTypeCoremotion:
        {
#if TARGET_IPHONE_SIMULATOR
            isGranted = YES;
#else
            isGranted = coreMotionPermissionStatus == kPermissionStatusAuthorized;
#endif
        }
            break;
        case kAPCSignUpPermissionsTypeMicrophone:
        {
#if TARGET_IPHONE_SIMULATOR
            isGranted = YES;
#else
            isGranted = ([[AVAudioSession sharedInstance] recordPermission] == AVAudioSessionRecordPermissionGranted);
#endif
        }
            break;
        case kAPCSignUpPermissionsTypeCamera:
        {
#if TARGET_IPHONE_SIMULATOR
            isGranted = YES;
#else
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            isGranted = status == AVAuthorizationStatusAuthorized;  
#endif
        }
            break;
        case kAPCSignUpPermissionsTypePhotoLibrary:
        {
            ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
            isGranted = status == ALAuthorizationStatusAuthorized;
            break;
        }
        default:{
            isGranted = NO;
        }
            break;
    }
    
    return isGranted;
}

- (void)requestForPermissionForType:(APCSignUpPermissionsType)type
                     withCompletion:(APCPermissionsBlock)completion
{
    
    __weak typeof(self) weakSelf = self;
    switch (type) {
        case kAPCSignUpPermissionsTypeHealthKit:
        {
    
            //------READ TYPES--------
            NSMutableArray *dataTypesToRead = [NSMutableArray new];
            
            // Add Characteristic types
            for (NSString *typeIdentifier in _healthKitCharacteristicTypesToRead) {
                [dataTypesToRead addObject:[HKCharacteristicType characteristicTypeForIdentifier:typeIdentifier]];
            }
            
            //Add other quantity types
            for (id typeIdentifier in _healthKitTypesToRead) {
                if ([typeIdentifier isKindOfClass:[NSString class]]) {
                    [dataTypesToRead addObject:[HKQuantityType quantityTypeForIdentifier:typeIdentifier]];
                }
                else if ([typeIdentifier isKindOfClass:[NSDictionary class]])
                {
                    if (typeIdentifier[kHKWorkoutTypeKey])
                    {
                        [dataTypesToRead addObject:[HKObjectType workoutType]];
                    }
                    else
                    {
                        [dataTypesToRead addObject:[self objectTypeFromDictionary:typeIdentifier]];
                    }
                }
            }
            
            //-------WRITE TYPES--------
            NSMutableArray *dataTypesToWrite = [NSMutableArray new];
            
            for (id typeIdentifier in _healthKitTypesToWrite) {
                if ([typeIdentifier isKindOfClass:[NSString class]]) {
                    [dataTypesToWrite addObject:[HKQuantityType quantityTypeForIdentifier:typeIdentifier]];
                }
                else if ([typeIdentifier isKindOfClass:[NSDictionary class]])
                {
                    [dataTypesToWrite addObject:[self objectTypeFromDictionary:typeIdentifier]];
                }
            }
            
            [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithArray:dataTypesToWrite] readTypes:[NSSet setWithArray:dataTypesToRead] completion:^(BOOL success, NSError *error) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    completion(success, error);
                    });
                }
            }];

            
        }
            break;
        case kAPCSignUpPermissionsTypeLocation:
        {
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            
            if (status == kCLAuthorizationStatusNotDetermined) {
                weakSelf.completionBlock = completion;

                [self.locationManager requestAlwaysAuthorization];
                [self.locationManager requestWhenInUseAuthorization];
                
            } else{
                if (completion) {
                    completion(NO, [self permissionDeniedErrorForType:kAPCSignUpPermissionsTypeLocation]);
                }
            }
        }
            break;
        case kAPCSignUpPermissionsTypeLocalNotifications:
        {
            if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
                weakSelf.completionBlock = completion;
                
                UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert
                                                                                                     |UIUserNotificationTypeBadge
                                                                                                     |UIUserNotificationTypeSound)
																						 categories:[APCTasksReminderManager taskReminderCategories]];
                
                [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                [[NSUserDefaults standardUserDefaults]synchronize];
                /*in the case of notifications, callbacks are used to fire the completion block. Callbacks are delivered to appDidRegisterForRemoteNotifications:.
                 */
            }
        }
            break;
        case kAPCSignUpPermissionsTypeCoremotion:
        {
            // Usually this method is called on another thread, but since we are searching
            // within same date to same date, it will return immediately, so put it on the main thread
            [self.motionActivityManager queryActivityStartingFromDate:[NSDate date] toDate:[NSDate date] toQueue:[NSOperationQueue mainQueue] withHandler:^(NSArray * __unused activities, NSError *error) {
                if (!error) {
                    coreMotionPermissionStatus = kPermissionStatusAuthorized;
                    if (completion) {
                        completion(YES, nil);
                    }
                } else if (error != nil && error.code == CMErrorMotionActivityNotAuthorized) {
                    coreMotionPermissionStatus = kPermissionStatusDenied;
                    
                    if (completion) {
                        completion(NO, [self permissionDeniedErrorForType:kAPCSignUpPermissionsTypeCoremotion]);
                    }
                }
            }];
        }
            break;
        case kAPCSignUpPermissionsTypeMicrophone:
        {
            
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (granted) {
                    if (completion) {
                        completion(YES, nil);
                    }
                } else {
                    if (completion) {
                        completion(NO, [self permissionDeniedErrorForType:kAPCSignUpPermissionsTypeMicrophone]);
                    }
                }
            }];
        }
            break;
        case kAPCSignUpPermissionsTypeCamera:
        {
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    if (completion) {
                        completion(YES, nil);
                    }
                } else {
                    if (completion) {
                        completion(NO, [self permissionDeniedErrorForType:kAPCSignUpPermissionsTypeCamera]);
                    }
                }
            }];
        }
            break;
        case kAPCSignUpPermissionsTypePhotoLibrary:
        {
            
            ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
            
            [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL * __unused stop) {
                if (group == nil) {
                    // end of enumeration
                    if (completion) {
                        completion(YES, nil);
                    }
                }
                
            } failureBlock:^(NSError *error) {
                if (error.code == ALAssetsLibraryAccessUserDeniedError) {
                    if (completion) {
                        completion(NO, [self permissionDeniedErrorForType:kAPCSignUpPermissionsTypePhotoLibrary]);
                    }
                }
            }];
            
        }
            break;
        default:
            break;
    }
}

- (HKObjectType*) objectTypeFromDictionary: (NSDictionary*) dictionary
{
    NSString * key = [[dictionary allKeys] firstObject];
    HKObjectType * retValue;
    if ([key isEqualToString:kHKQuantityTypeKey])
    {
        retValue = [HKQuantityType quantityTypeForIdentifier:dictionary[key]];
    }
    else if ([key isEqualToString:kHKCategoryTypeKey])
    {
        retValue = [HKCategoryType categoryTypeForIdentifier:dictionary[key]];
    }
    else if ([key isEqualToString:kHKCharacteristicTypeKey])
    {
        retValue = [HKCharacteristicType characteristicTypeForIdentifier:dictionary[key]];
    }
    else if ([key isEqualToString:kHKCorrelationTypeKey])
    {
        retValue = [HKCorrelationType correlationTypeForIdentifier:dictionary[key]];
    }
    return retValue;
}

- (NSString *)permissionDescriptionForType:(APCSignUpPermissionsType)type {
    switch (type) {
        case kAPCSignUpPermissionsTypeHealthKit:
            return NSLocalizedStringWithDefaultValue(@"Press “Allow” to individually specify which general health information the app may read from and write to HealthKit", @"APCAppCore", APCBundle(), @"Press “Allow” to individually specify which general health information the app may read from and write to HealthKit", @"");
        case kAPCSignUpPermissionsTypeLocalNotifications:
            return NSLocalizedStringWithDefaultValue(@"Allowing notifications enables the app to show you reminders.", @"APCAppCore", APCBundle(), @"Allowing notifications enables the app to show you reminders.", @"");
        case kAPCSignUpPermissionsTypeLocation:
            return NSLocalizedStringWithDefaultValue(@"Using your GPS enables the app to accurately determine distances travelled. Your actual location will never be shared.", @"APCAppCore", APCBundle(), @"Using your GPS enables the app to accurately determine distances travelled. Your actual location will never be shared.", @"");
        case kAPCSignUpPermissionsTypeCoremotion:
            return NSLocalizedStringWithDefaultValue(@"Using the motion co-processor allows the app to determine your activity, helping the study better understand how activity level may influence disease.", @"APCAppCore", APCBundle(), @"Using the motion co-processor allows the app to determine your activity, helping the study better understand how activity level may influence disease.", @"");
        case kAPCSignUpPermissionsTypeMicrophone:
            return NSLocalizedStringWithDefaultValue(@"Access to microphone is required for your Voice Recording Activity.", @"APCAppCore", APCBundle(), @"Access to microphone is required for your Voice Recording Activity.", @"");
        case kAPCSignUpPermissionsTypeCamera:
        case kAPCSignUpPermissionsTypePhotoLibrary:
        default:
            return [NSString stringWithFormat:@"Unknown permission type: %u", (unsigned int)type];
    }
}

- (NSError *)permissionDeniedErrorForType:(APCSignUpPermissionsType)type
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *message;
    
    switch (type) {
        case kAPCSignUpPermissionsTypeHealthKit:
            message = [NSString localizedStringWithFormat:NSLocalizedStringWithDefaultValue(@"Please go to Settings -> Privacy -> Health -> %@ to re-enable.", @"APCAppCore", APCBundle(), @"Please go to Settings -> Privacy -> Health -> %@ to re-enable.", nil), appName];
            break;
        case kAPCSignUpPermissionsTypeLocalNotifications:
            message = [NSString localizedStringWithFormat:NSLocalizedStringWithDefaultValue(@"Tap on Settings -> Notifications and enable 'Allow Notifications'", @"APCAppCore", APCBundle(), @"Tap on Settings -> Notifications and enable 'Allow Notifications'", nil), appName];
            break;
        case kAPCSignUpPermissionsTypeLocation:
            message = [NSString localizedStringWithFormat:NSLocalizedStringWithDefaultValue(@"Tap on Settings -> Location and check 'Always'", @"APCAppCore", APCBundle(), @"Tap on Settings -> Location and check 'Always'", nil), appName];
            break;
        case kAPCSignUpPermissionsTypeCoremotion:
            message = [NSString localizedStringWithFormat:NSLocalizedStringWithDefaultValue(@"Tap on Settings and enable Motion Activity.", @"APCAppCore", APCBundle(), @"Tap on Settings and enable Motion Activity.", nil), appName];
            break;
        case kAPCSignUpPermissionsTypeMicrophone:
            message = [NSString localizedStringWithFormat:NSLocalizedStringWithDefaultValue(@"Tap on Settings and enable Microphone", @"APCAppCore", APCBundle(), @"Tap on Settings and enable Microphone", nil), appName];
            break;
        case kAPCSignUpPermissionsTypeCamera:
            message = [NSString localizedStringWithFormat:NSLocalizedStringWithDefaultValue(@"Tap on Settings and enable Camera", @"APCAppCore", APCBundle(), @"Tap on Settings and enable Camera", nil), appName];
            break;
        case kAPCSignUpPermissionsTypePhotoLibrary:
            message = [NSString localizedStringWithFormat:NSLocalizedStringWithDefaultValue(@"Tap on Settings and enable Photos", @"APCAppCore", APCBundle(), @"Tap on Settings and enable Photos", nil), appName];
            break;
        default:
            message = @"";
            break;
    }
    
    NSError *error = [NSError errorWithDomain:APCPermissionsManagerErrorDomain code:kPermissionsErrorAccessDenied userInfo:@{NSLocalizedDescriptionKey:message}];
    
    return error;
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *) __unused error
{
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *) __unused manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            [self.locationManager stopUpdatingLocation];
            if (self.completionBlock) {
                self.completionBlock(YES, nil);
            }
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            [self.locationManager stopUpdatingLocation];
            if (self.completionBlock) {
                self.completionBlock(YES, nil);
            }
        }
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted: {
            [self.locationManager stopUpdatingLocation];
            if (self.completionBlock) {
                self.completionBlock(NO, [self permissionDeniedErrorForType:kAPCSignUpPermissionsTypeLocation]);
                self.completionBlock = nil;
            }
            break;
        }
    }
    
    self.completionBlock = nil;
}

#pragma mark - Remote notifications methods

- (void)appDidRegisterForRemoteNotifications: (NSNotification *)notification
{
    UIUserNotificationSettings *settings = (UIUserNotificationSettings *)notification.object;
    
    if (settings.types != 0) {
        APCAppDelegate * delegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
        [delegate.tasksReminder setReminderOn:YES];
        
        if (self.completionBlock) {
            self.completionBlock(YES, nil);
            self.completionBlock = nil;
        }
    }
	else {
        if (self.completionBlock) {
            self.completionBlock(NO, [self permissionDeniedErrorForType:kAPCSignUpPermissionsTypeLocalNotifications]);
            self.completionBlock = nil;
        }
    }
}

#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _locationManager.delegate = nil;
}

@end
