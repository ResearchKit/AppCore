//
//  APCResult+AddOn.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCResult+AddOn.h"
#import "APCAppleCore.h"
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
        [saveError handle];
        objectID = result.objectID;
    }];
    return objectID;
}

+ (void) mapRKSTResult:(RKSTTaskResult*) taskResult toAPCResult: (APCResult*) apcResult
{
    apcResult.taskRunID = taskResult.taskRunUUID.UUIDString;
    apcResult.rkTaskIdentifier = taskResult.identifier;
    NSError * error;
    NSData * data = [NSJSONSerialization dataWithJSONObject:taskResult.metadata options:NSJSONWritingPrettyPrinted error:&error];
    [error handle];
    apcResult.rkMetadata = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
