//
//  APCLocalization.h
//  APCAppCore
//
//  Created by Erin Mounts on 11/18/15.
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined(__cplusplus)
#define APC_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define APC_EXTERN extern __attribute__((visibility("default")))
#endif

APC_EXTERN NSBundle *APCBundle();
APC_EXTERN NSBundle *APCDefaultLocaleBundle();

