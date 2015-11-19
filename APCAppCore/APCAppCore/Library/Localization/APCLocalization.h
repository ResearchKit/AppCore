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

#define APCDefaultLocalizedValue(key) \
[APCDefaultLocaleBundle() localizedStringForKey:key value:@"" table:@"APCAppCore"]

#define APCLocalizedString(key, comment) \
[APCBundle() localizedStringForKey:(key) value:APCDefaultLocalizedValue(key) table:@"APCAppCore"]

#define APCLocalizedStringFromNumber(number) \
[NSNumberFormatter localizedStringFromNumber:number numberStyle:NSNumberFormatterNoStyle]

