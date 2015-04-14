// 
//  APCTask+AddOn.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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

+ (void) updateTasksFromJSON: (NSArray*) tasksArray inContext:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        for (NSDictionary * taskDict in tasksArray) {
            APCTask * task = [APCTask taskWithTaskID:taskDict[kTaskIDKey] inContext:context];
            if (task == nil) {
                task = [APCTask newObjectForContext:context];
                task.taskID = taskDict[kTaskIDKey];
            }
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

- (id<ORKTask>)rkTask
{
    ORKOrderedTask * retTask = self.taskDescription ? [NSKeyedUnarchiver unarchiveObjectWithData:self.taskDescription] : nil;
    return retTask;
}

- (void)setRkTask:(id<ORKTask>)rkTask
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
