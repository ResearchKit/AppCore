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

@implementation APCResult (AddOn)

+ (instancetype) storeRKResult:(RKResult*) rkResult inContext: (NSManagedObjectContext*) context
{
    __block APCResult * result;
    [context performBlockAndWait:^{
        result = [APCResult newObjectForContext:context];
        [self mapRKResult:rkResult toAPCResult:result];
        NSError * saveError;
        [result saveToPersistentStore:&saveError];
        [saveError handle];
    }];
    return result;
}

+ (void) mapRKResult:(RKResult*) rkResult toAPCResult: (APCResult*) apcResult
{
    apcResult.uid = [NSUUID UUID].UUIDString;
    apcResult.rkTaskInstanceUUID = rkResult.taskInstanceUUID.UUIDString;
    apcResult.rkTimeStamp = rkResult.timestamp;
    apcResult.rkItemIdentifier = rkResult.itemIdentifier.stringValue;
    apcResult.rkContentType = rkResult.contentType;
    apcResult.rkDeviceHardware = rkResult.deviceHardware;
    NSError * error;
    NSData * data = [NSJSONSerialization dataWithJSONObject:rkResult.metadata options:NSJSONWritingPrettyPrinted error:&error];
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
