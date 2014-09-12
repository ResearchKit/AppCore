//
//  APCConsentResult+AddOn.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/12/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCConsentResult+AddOn.h"
#import "APCAppleCore.h"
#import <ResearchKit/ResearchKit.h>

@implementation APCConsentResult (AddOn)

+ (instancetype) storeRKResult:(RKResult*) rkResult inContext: (NSManagedObjectContext*) context
{
    __block APCConsentResult * result;
    [context performBlockAndWait:^{
        result = [APCConsentResult newObjectForContext:context];
        [self mapRKResult:rkResult toAPCResult:result];
        NSError * saveError;
        [result saveToPersistentStore:&saveError];
        [saveError handle];
    }];
    return result;
}

+(void) mapRKResult:(RKResult *)rkResult toAPCResult:(APCResult *)apcResult
{
    NSAssert([rkResult isKindOfClass:[RKConsentResult class]], @"Not of type RKConsentResult");
    NSAssert([apcResult isKindOfClass:[APCConsentResult class]], @"Not of type RKConsentResult");
    
    RKConsentResult * localRKResult = (RKConsentResult*) rkResult;
    APCConsentResult * localAPCResult = (APCConsentResult*) apcResult;
    [super mapRKResult:rkResult toAPCResult:apcResult];
    
    localAPCResult.signatureName = localRKResult.signatureName;
    localAPCResult.signatureDate = localRKResult.signatureDate;
    
}

@end
