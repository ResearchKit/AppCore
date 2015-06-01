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

@interface APCPermissionsManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic) APCPermissionStatus coreMotionPermissionStatus;

@property (nonatomic, copy) APCPermissionsBlock completionBlock;

@end


@implementation APCPermissionsManager


- (instancetype)init
{
    if (self = [super init]) {
        _motionActivityManager = [[CMMotionActivityManager alloc] init];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidRegisterForRemoteNotifications:) name:APCAppDidRegisterUserNotification object:nil];

        _coreMotionPermissionStatus = kPermissionStatusNotDetermined;
                
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
            isGranted = self.coreMotionPermissionStatus == kPermissionStatusAuthorized;
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
    
    self.completionBlock = completion;
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
                [self.locationManager requestAlwaysAuthorization];
                [self.locationManager requestWhenInUseAuthorization];
                
            } else{
                if (weakSelf.completionBlock) {
                    weakSelf.completionBlock(NO, [self permissionDeniedErrorForType:kAPCSignUpPermissionsTypeLocation]);
                    weakSelf.completionBlock = nil;
                }
            }
        }
            break;
        case kAPCSignUpPermissionsTypeLocalNotifications:
        {
            if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
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
            
            
            [self.motionActivityManager queryActivityStartingFromDate:[NSDate date] toDate:[NSDate date] toQueue:[NSOperationQueue new] withHandler:^(NSArray * __unused activities, NSError *error) {
                if (!error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.coreMotionPermissionStatus = kPermissionStatusAuthorized;
                    weakSelf.completionBlock(YES, nil);
                    weakSelf.completionBlock = nil;
                    });
                } else if (error != nil && error.code == CMErrorMotionActivityNotAuthorized) {
                    weakSelf.coreMotionPermissionStatus = kPermissionStatusDenied;
                    
                    if (weakSelf.completionBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.completionBlock(NO, [self permissionDeniedErrorForType:kAPCSignUpPermissionsTypeCoremotion]);
                        weakSelf.completionBlock = nil;
                        });
                    }
                    
                }
            }];
            
        }
            break;
        case kAPCSignUpPermissionsTypeMicrophone:
        {
            
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (granted) {
                    weakSelf.completionBlock(YES, nil);
                    weakSelf.completionBlock = nil;
                } else {
                    if (weakSelf.completionBlock) {
                        weakSelf.completionBlock(NO, [self permissionDeniedErrorForType:kAPCSignUpPermissionsTypeMicrophone]);
                        weakSelf.completionBlock = nil;
                    }
                }
            }];
        }
            break;
        case kAPCSignUpPermissionsTypeCamera:
        {
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    weakSelf.completionBlock(YES, nil);
                    weakSelf.completionBlock = nil;
                } else {
                    if (weakSelf.completionBlock) {
                        weakSelf.completionBlock(NO, [self permissionDeniedErrorForType:kAPCSignUpPermissionsTypeCamera]);
                        weakSelf.completionBlock = nil;
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
                    weakSelf.completionBlock(YES, nil);
                    weakSelf.completionBlock = nil;
                }
                
            } failureBlock:^(NSError *error) {
                if (error.code == ALAssetsLibraryAccessUserDeniedError) {
                    if (weakSelf.completionBlock) {
                        weakSelf.completionBlock(NO, [self permissionDeniedErrorForType:kAPCSignUpPermissionsTypePhotoLibrary]);
                        weakSelf.completionBlock = nil;
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
            return NSLocalizedString(@"Press “Allow” to individually specify which general health information the app may read from and write to HealthKit", @"");
        case kAPCSignUpPermissionsTypeLocalNotifications:
            return NSLocalizedString(@"Allowing notifications enables the app to show you reminders.", @"");
        case kAPCSignUpPermissionsTypeLocation:
            return NSLocalizedString(@"Using your GPS enables the app to accurately determine distances travelled. Your actual location will never be shared.", @"");
        case kAPCSignUpPermissionsTypeCoremotion:
            return NSLocalizedString(@"Using the motion co-processor allows the app to determine your activity, helping the study better understand how activity level may influence disease.", @"");
        case kAPCSignUpPermissionsTypeMicrophone:
            return NSLocalizedString(@"Access to microphone is required for your Voice Recording Activity.", @"");
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
            message = [NSString localizedStringWithFormat:NSLocalizedString(@"Please go to Settings -> Privacy -> Health -> %@ to re-enable.", nil), appName];
            break;
        case kAPCSignUpPermissionsTypeLocalNotifications:
            message = [NSString localizedStringWithFormat:NSLocalizedString(@"Tap on Settings -> Notifications and enable 'Allow Notifications'", nil), appName];
            break;
        case kAPCSignUpPermissionsTypeLocation:
            message = [NSString localizedStringWithFormat:NSLocalizedString(@"Tap on Settings -> Location and check 'Always'", nil), appName];
            break;
        case kAPCSignUpPermissionsTypeCoremotion:
            message = [NSString localizedStringWithFormat:NSLocalizedString(@"Tap on Settings and enable Motion Activity.", nil), appName];
            break;
        case kAPCSignUpPermissionsTypeMicrophone:
            message = [NSString localizedStringWithFormat:NSLocalizedString(@"Tap on Settings and enable Microphone", nil), appName];
            break;
        case kAPCSignUpPermissionsTypeCamera:
            message = [NSString localizedStringWithFormat:NSLocalizedString(@"Tap on Settings and enable Camera", nil), appName];
            break;
        case kAPCSignUpPermissionsTypePhotoLibrary:
            message = [NSString localizedStringWithFormat:NSLocalizedString(@"Tap on Settings and enable Photos", nil), appName];
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
