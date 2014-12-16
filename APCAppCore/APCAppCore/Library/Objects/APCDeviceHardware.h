//
//  APCDeviceHardware.h
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCDeviceHardware : NSObject

+ (NSString *) platform;

+ (NSString *) platformString;

+ (BOOL)isMotionActivityAvailable;

@end
