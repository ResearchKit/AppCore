//
//  APCDataResult+AddOn.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/12/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDataResult+AddOn.h"
#import "APCAppleCore.h"
#import <ResearchKit/ResearchKit.h>

@implementation APCDataResult (AddOn)

+ (instancetype) storeRKSTResult:(RKSTResult*) rkResult inContext: (NSManagedObjectContext*) context
{
    __block APCDataResult * result;
    [context performBlockAndWait:^{
        result = [APCDataResult newObjectForContext:context];
        [self mapRKSTResult:rkResult toAPCResult:result];
        NSError * saveError;
        [result saveToPersistentStore:&saveError];
        [saveError handle];
    }];
    return result;
}

+(void) mapRKSTResult:(RKSTResult *)rkResult toAPCResult:(APCResult *)apcResult
{
    [super mapRKSTResult:rkResult toAPCResult:apcResult];
    
    NSParameterAssert([rkResult isKindOfClass:[RKSTDataResult class]]);
    RKSTDataResult * localRKSTResult = (RKSTDataResult*) rkResult;
    APCDataResult * localAPCResult = (APCDataResult*) apcResult;
    
    localAPCResult.fileName = localRKSTResult.filename;
    localAPCResult.data = localRKSTResult.data;
    
}

@end
