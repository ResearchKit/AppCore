// 
//  APCResult+AddOn.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
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
