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

+ (instancetype) storeRKResult:(RKResult*) rkResult inContext: (NSManagedObjectContext*) context
{
    __block APCDataResult * result;
    [context performBlockAndWait:^{
        result = [APCDataResult newObjectForContext:context];
        [self mapRKResult:rkResult toAPCResult:result];
        NSError * saveError;
        [result saveToPersistentStore:&saveError];
        [saveError handle];
    }];
    return result;
}

+(void) mapRKResult:(RKResult *)rkResult toAPCResult:(APCResult *)apcResult
{
    [super mapRKResult:rkResult toAPCResult:apcResult];
    
    NSParameterAssert([rkResult isKindOfClass:[RKDataResult class]]);
    RKDataResult * localRKResult = (RKDataResult*) rkResult;
    APCDataResult * localAPCResult = (APCDataResult*) apcResult;
    
    localAPCResult.fileName = localRKResult.filename;
    localAPCResult.data = localRKResult.data;
    
}

@end
