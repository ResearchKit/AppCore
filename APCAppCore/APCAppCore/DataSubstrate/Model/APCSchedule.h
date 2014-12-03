//
//  APCSchedule.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 11/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCScheduledTask;

@interface APCSchedule : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * endsOn;
@property (nonatomic, retain) NSString * expires;
@property (nonatomic, retain) NSNumber * inActive;
@property (nonatomic, retain) NSString * reminderMessage;
@property (nonatomic, retain) NSNumber * reminderOffset;
@property (nonatomic, retain) NSNumber * remoteUpdatable;
@property (nonatomic, retain) NSString * scheduleString;
@property (nonatomic, retain) NSString * scheduleType;
@property (nonatomic, retain) NSNumber * shouldRemind;
@property (nonatomic, retain) NSDate * startsOn;
@property (nonatomic, retain) NSString * taskID;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *scheduledTasks;
@end

@interface APCSchedule (CoreDataGeneratedAccessors)

- (void)addScheduledTasksObject:(APCScheduledTask *)value;
- (void)removeScheduledTasksObject:(APCScheduledTask *)value;
- (void)addScheduledTasks:(NSSet *)values;
- (void)removeScheduledTasks:(NSSet *)values;

@end
