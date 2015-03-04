// 
//  APCSchedule+Bridge.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <APCAppCore/APCAppCore.h>

@interface APCSchedule (Bridge)
+ (void) updateSchedulesOnCompletion: (void (^)(NSError * error)) completionBlock;
@end
