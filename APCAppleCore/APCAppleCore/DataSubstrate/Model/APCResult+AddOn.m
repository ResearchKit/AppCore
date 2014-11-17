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

+ (Class) lookUpAPCResultClassForRKSTResult: (RKSTResult*) rkResult
{
    if (!lookupDictionary) {
        lookupDictionary = @{
                             @"RKSTResult"          :  @"APCResult",
                             @"RKConsentResult"   :  @"APCConsentResult",
                             @"RKSTDataResult"      :  @"APCDataResult",
                             @"RKSTFileResult"      :  @"APCFileResult",
                             @"RKSurveyResult"    :  @"APCSurveyResult"
                             };
    }
    
    NSString * rkResultClassName = NSStringFromClass([rkResult class]);
    NSString * apcResultClassname = lookupDictionary[rkResultClassName];
    Class localClass = apcResultClassname ? NSClassFromString(apcResultClassname) : nil;
    return localClass;
}

+ (instancetype) storeRKSTResult:(RKSTResult*) rkResult inContext: (NSManagedObjectContext*) context
{
    __block APCResult * result;
    if ([rkResult isMemberOfClass:[RKSTResult class]]) {
        [context performBlockAndWait:^{
            result = [APCResult newObjectForContext:context];
            [self mapRKSTResult:rkResult toAPCResult:result];
            NSError * saveError;
            [result saveToPersistentStore:&saveError];
            [saveError handle];
        }];
    }
    else
    {
        result = [[self lookUpAPCResultClassForRKSTResult:rkResult] storeRKSTResult:rkResult inContext:context];
    }
    return result;

}

+ (void) mapRKSTResult:(RKSTResult*) rkResult toAPCResult: (APCResult*) apcResult
{
    apcResult.uid = [NSUUID UUID].UUIDString;
    apcResult.rkTaskIdentifier = rkResult.identifier;
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
