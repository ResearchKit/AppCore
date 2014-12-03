//
//  APCTask+AddOn.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTask.h"

@class RKSTOrderedTask;
@interface APCTask (AddOn)

//Synchronous Method Call
+ (void) createTasksFromJSON: (NSArray*) tasksArray inContext: (NSManagedObjectContext*) context;

+ (APCTask*) taskWithTaskID: (NSString*) taskID inContext: (NSManagedObjectContext*) context;

@property (nonatomic, strong) RKSTOrderedTask * rkTask;


@end
