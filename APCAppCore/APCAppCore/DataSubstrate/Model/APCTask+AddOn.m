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

static NSArray *defaultSortDescriptorsInternal = nil;

static NSString * const kTaskIDKey = @"taskID";
static NSString * const kTaskTitleKey = @"taskTitle";
static NSString * const kTaskClassNameKey = @"taskClassName";
static NSString * const kTaskCompletionTimeStringKey = @"taskCompletionTimeString";
static NSString * const kTaskFileNameKey = @"taskFileName";

@implementation APCTask (AddOn)

/**
 Sets global, static values the first time anyone calls this category.

 By definition, this method is called once per category, in a thread-safe
 way, the first time the category is sent a message -- basically, the first
 time we refer to any method declared in that category.

 Documentation:  the key sentence is actually in the documentation for
 +initialize:  "initialize is invoked only once per class. If you want
 to perform independent initialization for the class and for categories
 of the class, you should implement +load methods."

 I learned that from:
 http://stackoverflow.com/q/13326435

 The official +load documentation:
 https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSObject_Class/index.html#//apple_ref/occ/clm/NSObject/load

 The official +initialize documentation, with that key sentence:
 https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSObject_Class/index.html#//apple_ref/occ/clm/NSObject/initialize
 */
+ (void) load
{
    defaultSortDescriptorsInternal = @[[NSSortDescriptor sortDescriptorWithKey: @"sortString" ascending: YES],
                                       [NSSortDescriptor sortDescriptorWithKey: @"taskTitle"  ascending: YES],
                                       [NSSortDescriptor sortDescriptorWithKey: @"updatedAt"  ascending: NO]];
}

+ (NSArray *) defaultSortDescriptors
{
    return defaultSortDescriptorsInternal;
}

+ (APCTask *) taskWithTaskID: (NSString *) taskID
                   inContext: (NSManagedObjectContext *) context
{
    __block APCTask *taskToReturn = nil;

    [context performBlockAndWait: ^{

        NSFetchRequest *request = [APCTask request];
        request.predicate = [NSPredicate predicateWithFormat: @"%K == %@",
                             NSStringFromSelector (@selector (taskID)),
                             taskID];

        NSError * errorRetrievingTasks = nil;
        NSArray *possibleTasks = [context executeFetchRequest: request
                                                        error: & errorRetrievingTasks];

        if (possibleTasks == nil)
        {
            APCLogError2 (errorRetrievingTasks);
        }

        else
        {
            taskToReturn = possibleTasks.firstObject;
        }
    }];

    return taskToReturn;
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
