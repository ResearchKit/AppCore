//
//  APCSchedule+Bridge.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 11/21/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <APCAppleCore/APCAppleCore.h>

@interface APCSchedule (Bridge)
+ (void) updateSchedulesOnCompletion: (void (^)(NSError * error)) completionBlock;
@end
