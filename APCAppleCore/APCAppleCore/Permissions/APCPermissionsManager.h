//
//  APCPermissionsManager.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 9/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCAppleCore.h"

typedef void(^APCPermissionsBlock)(BOOL granted, NSError *error);

typedef NS_ENUM(NSUInteger, APCPermissionStatus) {
    kPermissionStatusNotDetermined,
    kPermissionStatusDenied,
    kPermissionStatusAuthorized,
};

@interface APCPermissionsManager : NSObject

- (BOOL)isPermissionsGrantedForType:(APCSignUpPermissionsType)type;

- (void)requestForPermissionForType:(APCSignUpPermissionsType)type
                     withCompletion:(APCPermissionsBlock)completion;

@end
