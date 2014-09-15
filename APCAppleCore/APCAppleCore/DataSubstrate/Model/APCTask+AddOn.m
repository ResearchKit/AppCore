//
//  APCTask+AddOn.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTask+AddOn.h"
#import "APCAppleCore.h"
#import <ResearchKit/ResearchKit.h>

static NSString * const kTaskIDKey = @"taskID";
static NSString * const kTaskTypeKey = @"taskType";
static NSString * const kTaskTitleKey = @"taskTitle";
static NSString * const kTaskClassNameKey = @"taskClassName";
static NSString * const kTaskFileNameKey = @"fileName";
static NSString * const kCustomizableSurveyTaskType =@"APHCustomizableSurvey";

@implementation APCTask (AddOn)

+ (void)createTasksFromJSON:(NSArray *)tasksArray inContext:(NSManagedObjectContext *)context
{
  [context performBlockAndWait:^{
      for (NSDictionary * taskDict in tasksArray) {
          APCTask * task = [APCTask newObjectForContext:context];
          task.uid = taskDict[kTaskIDKey];
          task.taskType = taskDict[kTaskTypeKey];
          task.taskTitle = taskDict[kTaskTitleKey];
          task.taskClassName = taskDict[kTaskClassNameKey];
          
          if ([task.taskType isEqualToString:kCustomizableSurveyTaskType]) {
              NSString *resource = [[NSBundle mainBundle] pathForResource:taskDict[kTaskFileNameKey] ofType:@"json"];
              NSError * error;
              NSString *taskDescription = [NSString stringWithContentsOfFile:resource encoding:NSUTF8StringEncoding error:&error];
              [error handle];
              task.taskDescription = taskDescription;
          }
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
        request.predicate = [NSPredicate predicateWithFormat:@"uid == %@",taskID];
        NSError * error;
        retTask = [[context executeFetchRequest:request error:&error]firstObject];
    }];
    return retTask;
}

- (RKTask*) generateRKTaskFromTaskDescription
{
    NSData* data = [self.taskDescription dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error=nil;
    id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    [error handle];
    RKTask *retTask = [[RKTask alloc] initWithDictionary:jsonData];
    return retTask;
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
