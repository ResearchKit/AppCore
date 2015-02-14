//
//  RKSTDefines.h
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

#define RK_NON_INTERNAL_BUILD 1
#if RK_NON_INTERNAL_BUILD
#define RK_CLASS_AVAILABLE_IOS(_iOSIntro)
#define RK_ENUM_AVAILABLE_IOS(_iOSIntro)
#define RK_AVAILABLE_IOS(_iOSIntro)
#else
#define RK_CLASS_AVAILABLE_IOS(_iOSIntro)    NS_CLASS_AVAILABLE_IOS(_iOSIntro)
#define RK_ENUM_AVAILABLE_IOS(_iOSIntro)     NS_ENUM_AVAILABLE_IOS(_iOSIntro)
#define RK_AVAILABLE_IOS(_iOSIntro)          NS_AVAILABLE_IOS(_iOSIntro)
#endif
