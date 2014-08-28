//
//  RKDefines.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined(__cplusplus)
#define RK_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define RK_EXTERN extern __attribute__((visibility("default")))
#endif

typedef NS_ENUM(NSInteger, RKFileProtectionMode) {
    RKFileProtectionNone = 0,
    RKFileProtectionCompleteUntilFirstUserAuthentication,
    RKFileProtectionCompleteUnlessOpen,
    RKFileProtectionComplete
};
