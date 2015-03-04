// 
//  APCPermissionsManager.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <Foundation/Foundation.h>
#import "APCAppCore.h"
#import "APCConstants.h"

typedef void(^APCPermissionsBlock)(BOOL granted, NSError *error);

typedef NS_ENUM(NSUInteger, APCPermissionStatus) {
    kPermissionStatusNotDetermined,
    kPermissionStatusDenied,
    kPermissionStatusAuthorized,
};

@interface APCPermissionsManager : NSObject

+ (void)setHealthKitTypesToRead:(NSArray *)types;

+ (void)setHealthKitTypesToWrite:(NSArray *)types;

- (BOOL)isPermissionsGrantedForType:(APCSignUpPermissionsType)type;

- (void)requestForPermissionForType:(APCSignUpPermissionsType)type
                     withCompletion:(APCPermissionsBlock)completion;

@end
