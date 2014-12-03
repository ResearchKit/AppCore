//
//  APCSchedule+Bridge.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 11/21/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <APCAppCore/APCAppCore.h>

@interface APCSchedule (Bridge)
+ (void) updateSchedulesOnCompletion: (void (^)(NSError * error)) completionBlock;
@end
