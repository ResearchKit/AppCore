// 
//  APCTask+AddOn.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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
          
          if (taskDict[kTaskFileNameKey]) {
              NSString *resource = [[NSBundle mainBundle] pathForResource:taskDict[kTaskFileNameKey] ofType:@"json"];
              NSData *jsonData = [NSData dataWithContentsOfFile:resource];
              NSError * error;
              NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
              id manager = SBBComponent(SBBSurveyManager);
              SBBSurvey * survey = [[manager objectManager] objectFromBridgeJSON:dictionary];
              task.rkTask = [APCTask rkTaskFromSBBSurvey:survey];
          }
          NSError * error;
          [task saveToPersistentStore:&error];
          APCLogError2 (error);
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

- (id<RKSTTask>)rkTask
{
    RKSTOrderedTask * retTask = self.taskDescription ? [NSKeyedUnarchiver unarchiveObjectWithData:self.taskDescription] : nil;
    return retTask;
}

- (void)setRkTask:(id<RKSTTask>)rkTask
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
