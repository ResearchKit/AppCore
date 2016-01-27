//
//  MockUIApplication.h
//  APCAppCore
//
//  Created by Michael L DePhillips on 1/26/16.
//

#import <APCAppCore/APCAppCore.h>

@interface MockAPCTasksReminderManager : APCTasksReminderManager

@property (nonatomic, strong) NSDate* mockNow;
@property (nonatomic, strong) NSTimeZone* mockTimeZone;

- (void) setReminderKey:(NSString*)reminderKey toOn:(BOOL)on;
- (void) setAllReminders:(BOOL)on;

@property (nonatomic) NSMutableArray *scheduledLocalNotification;
@property (nonatomic) NSDictionary *tasksFullComplete;

@end