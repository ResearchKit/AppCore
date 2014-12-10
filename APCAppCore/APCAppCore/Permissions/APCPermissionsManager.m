// 
//  APCPermissionsManager.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCPermissionsManager.h"

#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <HealthKit/HealthKit.h>

static NSArray *healthKitTypesToRead;
static NSArray *healthKitTypesToWrite;

static NSString * const APCPermissionsManagerErrorDomain = @"APCPermissionsManagerErrorDomain";

typedef NS_ENUM(NSUInteger, APCPermissionsErrorCode) {
    kPermissionsErrorAccessDenied = -100,
};

@interface APCPermissionsManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) HKHealthStore *healthStore;

@property (nonatomic) APCPermissionStatus coreMotionPermissionStatus;

@property (nonatomic, copy) APCPermissionsBlock completionBlock;

@end

@implementation APCPermissionsManager

+ (void)setHealthKitTypesToRead:(NSArray *)types
{
    healthKitTypesToRead = types;
}

+ (void)setHealthKitTypesToWrite:(NSArray *)types
{
    healthKitTypesToWrite = types;
}

- (instancetype)init
{
    if (self = [super init]) {
        _motionActivityManager = [[CMMotionActivityManager alloc] init];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidRegisterForRemoteNotifications) name:APCAppDidRegisterUserNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appFailedToRegisterForRemoteNotification) name:APCAppDidFailToRegisterForRemoteNotification object:nil];

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
    
    switch (type) {
        case kSignUpPermissionsTypeHealthKit:
        {
            HKCharacteristicType *dateOfBirth = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
            HKAuthorizationStatus status = [self.healthStore authorizationStatusForType:dateOfBirth];

            isGranted = (status == HKAuthorizationStatusSharingAuthorized);
        }
            break;
        case kSignUpPermissionsTypeLocation:
        {
#if TARGET_IPHONE_SIMULATOR
            isGranted = YES;
#else
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            isGranted = (status == kCLAuthorizationStatusAuthorizedAlways); //TODO: Revisit the type of permissions to restrict/allow.
#endif
        }
            break;
        case kSignUpPermissionsTypePushNotifications:
        {
#if TARGET_IPHONE_SIMULATOR
            isGranted = YES;
#else
            isGranted = [[UIApplication sharedApplication] currentUserNotificationSettings].types != 0;
#endif
        }
            break;
        case kSignUpPermissionsTypeCoremotion:
        {
#if TARGET_IPHONE_SIMULATOR
            isGranted = YES;
#else
            isGranted = self.coreMotionPermissionStatus == kPermissionStatusAuthorized;
#endif
        }
            break;
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
    
    switch (type) {
        case kSignUpPermissionsTypeHealthKit:
        {
            
            //Commenting out 
            
//            HKCharacteristicType *dateOfBirth = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
//            HKAuthorizationStatus status = [self.healthStore authorizationStatusForType:dateOfBirth];
//
//            if (status == HKAuthorizationStatusNotDetermined) {
            
                //------READ TYPES--------
                NSMutableArray *dataTypesToRead = [NSMutableArray new];
                for (id typeIdentifier in healthKitTypesToRead) {
                    if ([typeIdentifier isKindOfClass:[NSString class]]) {
                        [dataTypesToRead addObject:[HKQuantityType quantityTypeForIdentifier:typeIdentifier]];
                    }
                    else if ([typeIdentifier isKindOfClass:[NSDictionary class]])
                    {
                        [dataTypesToRead addObject:[self objectTypeFromDictionary:typeIdentifier]];
                    }

                }
                
                [dataTypesToRead addObjectsFromArray: @[
                                                       [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                                                       [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]
                                                       ]];
                
                //-------WRITE TYPES--------
                NSMutableArray *dataTypesToWrite = [NSMutableArray new];
                
                for (id typeIdentifier in healthKitTypesToWrite) {
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
                        completion(success, error);
                    }
                }];
                
//            } else {
//                if (self.completionBlock) {
//                    self.completionBlock(NO, [self permissionDeniedErrorForType:kSignUpPermissionsTypeHealthKit]);
//                    self.completionBlock = nil;
//                }
//            }
            
        }
            break;
        case kSignUpPermissionsTypeLocation:
        {
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            
            if (status == kCLAuthorizationStatusNotDetermined) {
                [self.locationManager requestAlwaysAuthorization];
            } else{
                if (self.completionBlock) {
                    self.completionBlock(NO, [self permissionDeniedErrorForType:kSignUpPermissionsTypeLocation]);
                    self.completionBlock = nil;
                }
            }
        }
            break;
        case kSignUpPermissionsTypePushNotifications:
        {
            if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == 0) {
                UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert
                                                                                                     |UIUserNotificationTypeBadge
                                                                                                     |UIUserNotificationTypeSound) categories:nil];
                [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            } else {
                
                if (self.completionBlock) {
                    self.completionBlock(NO, [self permissionDeniedErrorForType:kSignUpPermissionsTypePushNotifications]);
                    self.completionBlock = nil;
                }
            }
        }
            break;
        case kSignUpPermissionsTypeCoremotion:
        {
            __weak typeof(self) weakSelf = self;
            
            [self.motionActivityManager queryActivityStartingFromDate:[NSDate date] toDate:[NSDate date] toQueue:[NSOperationQueue new] withHandler:^(NSArray *activities, NSError *error) {
                if (!error) {
                    weakSelf.coreMotionPermissionStatus = kPermissionStatusAuthorized;
                    weakSelf.completionBlock(YES, nil);
                    weakSelf.completionBlock = nil;
                } else if (error != nil && error.code == CMErrorMotionActivityNotAuthorized) {
                    weakSelf.coreMotionPermissionStatus = kPermissionStatusDenied;
                    
                    if (weakSelf.completionBlock) {
                        weakSelf.completionBlock(NO, [self permissionDeniedErrorForType:kSignUpPermissionsTypeCoremotion]);
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

- (NSError *)permissionDeniedErrorForType:(APCSignUpPermissionsType)type
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *message;
    
    switch (type) {
        case kSignUpPermissionsTypeHealthKit:{
            message = [NSString localizedStringWithFormat:NSLocalizedString(@"Please go to Settings -> Privacy -> Health -> %@ to re-enable.", nil), appName];
        }
            break;
        case kSignUpPermissionsTypePushNotifications:{
            message = [NSString localizedStringWithFormat:NSLocalizedString(@"Please go to Settings -> Notification Center -> %@ to re-enable push notifications.", nil), appName];
        }
            break;
        case kSignUpPermissionsTypeLocation:{
            message = [NSString localizedStringWithFormat:NSLocalizedString(@"Please go to Settings -> Privacy -> Location -> %@ to re-enable Location services.", nil), appName];
        }
            break;
        case kSignUpPermissionsTypeCoremotion:{
            message = [NSString localizedStringWithFormat:NSLocalizedString(@"Please go to Settings -> %@ -> Privacy to re-enable.", nil), appName];
        }
            break;
            
        default:
            break;
    }
    
    NSError *error = [NSError errorWithDomain:APCPermissionsManagerErrorDomain code:kPermissionsErrorAccessDenied userInfo:@{NSLocalizedDescriptionKey:message}];
    
    return error;
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
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
                self.completionBlock(NO, [self permissionDeniedErrorForType:kSignUpPermissionsTypeLocation]);
                self.completionBlock = nil;
            }
            break;
        }
    }
    
    self.completionBlock = nil;
}

#pragma mark - Remote notifications methods

- (void)appDidRegisterForRemoteNotifications
{
    if (self.completionBlock) {
        self.completionBlock(YES, nil);
        self.completionBlock = nil;
    }
}

- (void)appFailedToRegisterForRemoteNotification
{
    if (self.completionBlock) {
        self.completionBlock(NO, [self permissionDeniedErrorForType:kSignUpPermissionsTypePushNotifications]);
        self.completionBlock = nil;
    }
}

#pragma mark - Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APCAppDidRegisterUserNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APCAppDidFailToRegisterForRemoteNotification object:self];
}

@end
