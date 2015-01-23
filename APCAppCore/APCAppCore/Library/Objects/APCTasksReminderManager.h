//
//  APCTasksReminderManager.h
//  APCAppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCTasksReminderManager : NSObject

+ (NSArray*) reminderTimesArray;

@property (nonatomic) BOOL reminderOn;
@property (nonatomic, strong) NSString * reminderTime; //Should be an element of reminderTimesArray

- (void) updateTasksReminder;

@end
