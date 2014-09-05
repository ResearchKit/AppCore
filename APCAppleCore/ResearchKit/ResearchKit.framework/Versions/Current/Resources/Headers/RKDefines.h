//
//  RKDefines.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//



#if defined(__cplusplus)
#define RK_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define RK_EXTERN extern __attribute__((visibility("default")))
#endif
