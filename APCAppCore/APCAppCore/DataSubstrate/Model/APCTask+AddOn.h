// 
//  APCTask+AddOn.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCTask.h"

@protocol ORKTask;
@interface APCTask (AddOn)

//Synchronous Method Call
+ (void) createTasksFromJSON: (NSArray*) tasksArray inContext: (NSManagedObjectContext*) context;

+ (APCTask*) taskWithTaskID: (NSString*) taskID inContext: (NSManagedObjectContext*) context;

@property (nonatomic, strong) id<ORKTask> rkTask;


@end
