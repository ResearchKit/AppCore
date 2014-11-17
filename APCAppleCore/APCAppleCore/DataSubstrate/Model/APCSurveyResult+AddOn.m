//
//  APCSurveyResult+AddOn.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/12/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCSurveyResult+AddOn.h"
#import "APCAppleCore.h"
#import <ResearchKit/ResearchKit.h>

@implementation APCSurveyResult (AddOn)

+ (instancetype) storeRKResult:(RKResult*) rkResult inContext: (NSManagedObjectContext*) context
{
    __block APCSurveyResult * result;
    [context performBlockAndWait:^{
        result = [APCSurveyResult newObjectForContext:context];
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
    
    NSParameterAssert([rkResult isKindOfClass:[RKSurveyResult class]]);
    RKSurveyResult * localRKResult = (RKSurveyResult*) rkResult;
    APCSurveyResult * localAPCResult = (APCSurveyResult*) apcResult;
    
    for (id answer in localRKResult.surveyResults) {
        if ([answer isKindOfClass:[RKQuestionResult class]]) {
            APCQuestionResult* apcAnswer = [APCQuestionResult storeRKResult:answer inContext:apcResult.managedObjectContext];
            apcAnswer.survey = localAPCResult;
        }
        else if([answer isKindOfClass:[RKSurveyResult class]])
        {
            RKSurveyResult * localSurveyResult = (RKSurveyResult*) answer;
            for (RKQuestionResult * localAnswer in localSurveyResult.surveyResults) {
                APCQuestionResult* apcAnswer = [APCQuestionResult storeRKResult:localAnswer inContext:apcResult.managedObjectContext];
                apcAnswer.survey = localAPCResult;
            }
        }
        
    }
}

@end
