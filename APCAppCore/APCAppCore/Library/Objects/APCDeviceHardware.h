//
//  APCDeviceHardware.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCDeviceHardware : NSObject

+ (NSString *) platform;

+ (NSString *) platformString;

+ (BOOL)isMotionActivityAvailable;

@end
