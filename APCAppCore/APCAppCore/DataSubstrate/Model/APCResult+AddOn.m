// 
//  APCResult+AddOn.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCResult+AddOn.h"
#import "APCAppCore.h"
#import <ResearchKit/ResearchKit.h>

static NSDictionary * lookupDictionary;

@implementation APCResult (AddOn)

+ (NSManagedObjectID*) storeTaskResult:(RKSTTaskResult*) taskResult inContext: (NSManagedObjectContext*) context
{
    NSAssert([taskResult isKindOfClass:[RKSTTaskResult class]], @"Should be of type RKSTTaskResult");
    __block NSManagedObjectID * objectID;
    [context performBlockAndWait:^{
        APCResult * result = [APCResult newObjectForContext:context];
        [self mapRKSTResult:taskResult toAPCResult:result];
        NSError * saveError;
        [result saveToPersistentStore:&saveError];
        APCLogError2 (saveError);
        objectID = result.objectID;
    }];
    return objectID;
}

+ (void) mapRKSTResult:(RKSTTaskResult*) taskResult toAPCResult: (APCResult*) apcResult
{
    apcResult.taskRunID = taskResult.taskRunUUID.UUIDString;
    apcResult.taskID = taskResult.identifier;
    if (taskResult.metadata) {
        NSError * error;
        NSData * data = [NSJSONSerialization dataWithJSONObject:taskResult.metadata options:NSJSONWritingPrettyPrinted error:&error];
        APCLogError2 (error);
        apcResult.metaData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

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
