//
//  APCTask+AddOn.m
//  APCAppCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTask+AddOn.h"
#import "APCAppCore.h"
#import <ResearchKit/ResearchKit.h>

static NSString * const kTaskIDKey = @"taskID";
static NSString * const kTaskTitleKey = @"taskTitle";
static NSString * const kTaskClassNameKey = @"taskClassName";
static NSString * const kTaskCompletionTimeStringKey = @"taskCompletionTimeString";
static NSString * const kTaskFileNameKey = @"taskFileName";

@implementation APCTask (AddOn)

+ (void)createTasksFromJSON:(NSArray *)tasksArray inContext:(NSManagedObjectContext *)context
{
  [context performBlockAndWait:^{
      for (NSDictionary * taskDict in tasksArray) {
          APCTask * task = [APCTask newObjectForContext:context];
          task.taskID = taskDict[kTaskIDKey];
          task.taskTitle = taskDict[kTaskTitleKey];
          task.taskClassName = taskDict[kTaskClassNameKey];
          task.taskCompletionTimeString = taskDict[kTaskCompletionTimeStringKey];
          
          //TODO: For Dhanush, Add loading Survey JSON
          NSError * error;
          [task saveToPersistentStore:&error];
          [error handle];
      }
  }];
}

+ (APCTask*) taskWithTaskID: (NSString*) taskID inContext:(NSManagedObjectContext *)context
{
    __block APCTask * retTask;
    [context performBlockAndWait:^{
        NSFetchRequest * request = [APCTask request];
        request.predicate = [NSPredicate predicateWithFormat:@"taskID == %@",taskID];
        NSError * error;
        retTask = [[context executeFetchRequest:request error:&error]firstObject];
    }];
    return retTask;
}

- (RKSTOrderedTask *)rkTask
{
    RKSTOrderedTask * retTask = self.taskDescription ? [NSKeyedUnarchiver unarchiveObjectWithData:self.taskDescription] : nil;
    return retTask;
}

- (void)setRkTask:(RKSTOrderedTask *)rkTask
{
    self.taskDescription = [NSKeyedArchiver archivedDataWithRootObject:rkTask];
}

/*********************************************************************************/
#pragma mark - Life Cycle Methods
/*********************************************************************************/
- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self setPrimitiveValue:[NSDate date] forKey:@"createdAt"];
}

- (void)willSave
{
    [self setPrimitiveValue:[NSDate date] forKey:@"updatedAt"];
}

@end
