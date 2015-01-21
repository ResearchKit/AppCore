//
//  RKDefines_Private.h
//  Itasca
//
//  Created by John Earl on 12/12/14.
//  Copyright © 2014 Apple. All rights reserved.
//

#import <ResearchKit/RKDefines.h>


typedef NS_OPTIONS(NSInteger, RKPermissionMask) {
    RKPermissionNone                     = 0,
    RKPermissionCoreMotionActivity       = (1 << 1),
    RKPermissionAudioRecording           = (1 << 3),
    RKPermissionCoreLocation             = (1 << 4),
} RK_ENUM_AVAILABLE_IOS(8_3);

RK_EXTERN NSBundle *_RKBundle() RK_AVAILABLE_IOS(8_3);

#define RKLocalizedString(key, comment) \
[_RKBundle() localizedStringForKey:(key) value:@"" table:nil]

