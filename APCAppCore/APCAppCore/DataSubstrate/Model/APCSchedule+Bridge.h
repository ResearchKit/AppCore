// 
//  APCSchedule+Bridge.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <APCAppCore/APCAppCore.h>

@interface APCSchedule (Bridge)
+ (void) updateSchedulesOnCompletion: (void (^)(NSError * error)) completionBlock;
@end
