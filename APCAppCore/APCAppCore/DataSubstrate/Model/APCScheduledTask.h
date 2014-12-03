//
//  APCScheduledTask.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 12/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCResult, APCSchedule, APCTask;

@interface APCScheduledTask : NSManagedObject

@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * endOn;
@property (nonatomic, retain) NSDate * startOn;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) APCSchedule *generatedSchedule;
@property (nonatomic, retain) NSSet *results;
@property (nonatomic, retain) APCTask *task;
@end

@interface APCScheduledTask (CoreDataGeneratedAccessors)

- (void)addResultsObject:(APCResult *)value;
- (void)removeResultsObject:(APCResult *)value;
- (void)addResults:(NSSet *)values;
- (void)removeResults:(NSSet *)values;

@end
