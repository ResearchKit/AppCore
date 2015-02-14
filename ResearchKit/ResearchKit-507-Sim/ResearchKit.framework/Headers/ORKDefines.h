//
//  ORKDefines.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined(__cplusplus)
#define ORK_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define ORK_EXTERN extern __attribute__((visibility("default")))
#endif


#define ORK_CLASS_AVAILABLE __attribute__((visibility("default")))
#define ORK_ENUM_AVAILABLE
#define ORK_AVAILABLE_DECL

typedef NS_OPTIONS(NSInteger, ORKPermissionMask) {
    ORKPermissionNone                     = 0,
    ORKPermissionCoreMotionActivity       = (1 << 1),
    ORKPermissionCoreMotionAccelerometer  = (1 << 2),
    ORKPermissionAudioRecording           = (1 << 3),
    ORKPermissionCoreLocation             = (1 << 4),
} ORK_ENUM_AVAILABLE;


typedef NS_ENUM(NSInteger, ORKFileProtectionMode) {
    ORKFileProtectionNone = 0,
    ORKFileProtectionCompleteUntilFirstUserAuthentication,
    ORKFileProtectionCompleteUnlessOpen,
    ORKFileProtectionComplete
} ORK_ENUM_AVAILABLE;

