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

+ (APCResult*) storeRKResult:(RKResult*) rkResult inContext: (NSManagedObjectContext*) context
{
    __block APCResult * result;
    [context performBlockAndWait:^{
        result = [APCResult newObjectForContext:context];
        result.uid = [NSUUID UUID].UUIDString;
        result.rkTaskInstanceUUID = rkResult.taskInstanceUUID.UUIDString;
        result.rkTimeStamp = rkResult.timestamp;
        result.rkItemIdentifier = rkResult.itemIdentifier.stringValue;
        result.rkContentType = rkResult.contentType;
        result.rkDeviceHardware = rkResult.deviceHardware;
        NSError * error;
        NSData * data = [NSJSONSerialization dataWithJSONObject:rkResult.metadata options:NSJSONWritingPrettyPrinted error:&error];
        result.rkMetadata = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSError * saveError;
        [result saveToPersistentStore:&saveError];
        [saveError handle];
    }];
    return result;
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
