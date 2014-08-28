//
//  APCTask.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface APCTask : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * taskType;
@property (nonatomic, retain) NSString * taskDescription;
@property (nonatomic) NSTimeInterval createdAt;
@property (nonatomic) NSTimeInterval updatedAt;
@property (nonatomic, retain) NSSet *schedules;
@end

@interface APCTask (CoreDataGeneratedAccessors)

- (void)addSchedulesObject:(NSManagedObject *)value;
- (void)removeSchedulesObject:(NSManagedObject *)value;
- (void)addSchedules:(NSSet *)values;
- (void)removeSchedules:(NSSet *)values;

@end
