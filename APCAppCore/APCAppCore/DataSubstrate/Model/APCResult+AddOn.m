// 
//  APCResult+AddOn.m 
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
 
#import "APCResult+AddOn.h"
#import "APCAppCore.h"
#import <ResearchKit/ResearchKit.h>

static NSDictionary * lookupDictionary;

@implementation APCResult (AddOn)

+ (NSManagedObjectID*) storeTaskResult:(ORKTaskResult*) taskResult inContext: (NSManagedObjectContext*) context
{
    NSAssert([taskResult isKindOfClass:[ORKTaskResult class]], @"Should be of type ORKTaskResult");
    __block NSManagedObjectID * objectID;
    [context performBlockAndWait:^{
        APCResult * result = [APCResult newObjectForContext:context];
        [self mapORKResult:taskResult toAPCResult:result];
        NSError * saveError;
        [result saveToPersistentStore:&saveError];
        APCLogError2 (saveError);
        objectID = result.objectID;
    }];
    return objectID;
}

+ (void) mapORKResult:(ORKTaskResult*) taskResult toAPCResult: (APCResult*) apcResult
{
    apcResult.taskRunID = taskResult.taskRunUUID.UUIDString;
    apcResult.taskID = taskResult.identifier;
    apcResult.startDate = taskResult.startDate;
    apcResult.endDate = taskResult.endDate;
}

+ (APCResult *)findAPCResultFromTaskResult:(ORKTaskResult *)taskResult inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest * request = [APCResult request];
    request.predicate = [NSPredicate predicateWithFormat:@"taskRunID == %@", taskResult.taskRunUUID.UUIDString];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:NO]];
    request.fetchLimit = 1;
    NSError * error;
    NSArray * result = [context executeFetchRequest:request error:&error];
    APCLogError2(error);
    return result.count > 0 ? result.firstObject : nil;
}

+ (BOOL) updateResultSummary: (NSString*) summary forTaskResult:(ORKTaskResult *)taskResult inContext:(NSManagedObjectContext *)context
{
    BOOL retValue = NO;
    APCResult * result = [APCResult findAPCResultFromTaskResult:taskResult inContext:context];
    if (result) {
        result.resultSummary = summary;
        NSError * saveError;
        [result saveToPersistentStore:&saveError];
        APCLogError2(saveError);
        if (saveError == nil) {
            APCLogDebug(@"Saved results summary for task: %@  Result: %@", taskResult.identifier, summary);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:APCTaskResultsProcessedNotification object:result];
            });
            retValue = YES;
        }
    }
    else
    {
        APCLogError(@"APCResult for task result: %@ NOT FOUND", taskResult.identifier);
    }
    
    return retValue;
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
