//
//  APCTask.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCSchedule, APCScheduledTask;

@interface APCTask : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * taskDescription;
@property (nonatomic, retain) NSString * taskType;
@property (nonatomic, retain) NSString * taskTitle;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *schedules;
@property (nonatomic, retain) APCSchedule *schedule_unused;
@end

@interface APCTask (CoreDataGeneratedAccessors)

- (void)addSchedulesObject:(APCScheduledTask *)value;
- (void)removeSchedulesObject:(APCScheduledTask *)value;
- (void)addSchedules:(NSSet *)values;
- (void)removeSchedules:(NSSet *)values;

@end
