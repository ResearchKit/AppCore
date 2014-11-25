//
//  APCTask.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 11/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCScheduledTask;

@interface APCTask : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * taskClassName;
@property (nonatomic, retain) NSString * taskCompletionTimeString;
@property (nonatomic, retain) NSData * taskDescription;
@property (nonatomic, retain) NSString * taskHRef;
@property (nonatomic, retain) NSString * taskID;
@property (nonatomic, retain) NSString * taskTitle;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *scheduledTasks_unused;
@end

@interface APCTask (CoreDataGeneratedAccessors)

- (void)addScheduledTasks_unusedObject:(APCScheduledTask *)value;
- (void)removeScheduledTasks_unusedObject:(APCScheduledTask *)value;
- (void)addScheduledTasks_unused:(NSSet *)values;
- (void)removeScheduledTasks_unused:(NSSet *)values;

@end
