// 
//  APCTask+AddOn.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCTask.h"

@protocol ORKTask;
@interface APCTask (AddOn)

//Synchronous Method Call
+ (void) createTasksFromJSON: (NSArray*) tasksArray inContext: (NSManagedObjectContext*) context;
+ (void) updateTasksFromJSON: (NSArray*) tasksArray inContext:(NSManagedObjectContext *)context;

+ (APCTask*) taskWithTaskID: (NSString*) taskID inContext: (NSManagedObjectContext*) context;

@property (nonatomic, strong) id<ORKTask> rkTask;


@end
