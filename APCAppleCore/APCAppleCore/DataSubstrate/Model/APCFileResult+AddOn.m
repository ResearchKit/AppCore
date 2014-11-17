//
//  APCFileResult+AddOn.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/12/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCFileResult+AddOn.h"
#import "APCAppleCore.h"
#import <ResearchKit/ResearchKit.h>

@implementation APCFileResult (AddOn)

+ (instancetype) storeRKSTResult:(RKSTResult*) rkResult inContext: (NSManagedObjectContext*) context
{
    __block APCFileResult * result;
    [context performBlockAndWait:^{
        result = [APCFileResult newObjectForContext:context];
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
    
    NSParameterAssert([rkResult isKindOfClass:[RKSTFileResult class]]);
    RKSTFileResult * localRKSTResult = (RKSTFileResult*) rkResult;
    APCFileResult * localAPCResult = (APCFileResult*) apcResult;

    NSData * data = [NSData dataWithContentsOfFile:localRKSTResult.fileUrl.path];
    localAPCResult.file = data;
    
}

@end
