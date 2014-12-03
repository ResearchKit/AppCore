//
//  APCPermissionsManager.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 9/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
