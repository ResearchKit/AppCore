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

+ (instancetype) storeRKResult:(RKResult*) rkResult inContext: (NSManagedObjectContext*) context
{
    __block APCFileResult * result;
    [context performBlockAndWait:^{
        result = [APCFileResult newObjectForContext:context];
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
    
    NSAssert([rkResult isKindOfClass:[RKFileResult class]], @"Not of type RKConsentResult");
    NSAssert([apcResult isKindOfClass:[APCFileResult class]], @"Not of type RKConsentResult");
    RKFileResult * localRKResult = (RKFileResult*) rkResult;
    APCFileResult * localAPCResult = (APCFileResult*) apcResult;

    NSData * data = [NSData dataWithContentsOfFile:localRKResult.fileUrl.path];
    localAPCResult.file = data;
    
}

@end
