//
//  APCQuestionResult+AddOn.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/12/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCQuestionResult+AddOn.h"
#import "APCAppleCore.h"
#import <ResearchKit/ResearchKit.h>

@implementation APCQuestionResult (AddOn)

+ (instancetype) storeRKSTResult:(RKSTResult*) rkResult inContext: (NSManagedObjectContext*) context
{
    __block APCQuestionResult * result;
    [context performBlockAndWait:^{
        result = [APCQuestionResult newObjectForContext:context];
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
    
    NSParameterAssert([rkResult isKindOfClass:[RKSTQuestionResult class]]);
    RKSTQuestionResult * localRKSTResult = (RKSTQuestionResult*) rkResult;
    APCQuestionResult * localAPCResult = (APCQuestionResult*) apcResult;

    localAPCResult.questionTypeStore = [NSNumber numberWithInteger:localRKSTResult.questionType];
    if (localRKSTResult.answer) {
        switch (localRKSTResult.questionType) {
            case RKSurveyQuestionTypeDate:
            case RKSurveyQuestionTypeTime:
            case RKSurveyQuestionTypeDateAndTime:
            case RKSurveyQuestionTypeText:
            case RKSurveyQuestionTypeInteger:
            case RKSurveyQuestionTypeDecimal:
            case RKSurveyQuestionTypeSingleChoice:
            {
                //Expecting either a string or an int
                if ([localRKSTResult.answer isKindOfClass:[NSString class]]) {
                    localAPCResult.stringAnswer = (NSString*)localRKSTResult.answer;
                } else if ([localRKSTResult.answer isKindOfClass:[NSNumber class]]) {
                    localAPCResult.integerAnswer = localRKSTResult.answer;
                } else {
                    NSAssert(localRKSTResult.answer, @"Its neither an integer nor a string");
                }
            }
                break;
            case RKSurveyQuestionTypeBoolean:
            {
                NSAssert([localRKSTResult.answer isKindOfClass:[NSNumber class]], @"Its not a NSNumber");
                localAPCResult.integerAnswer = (NSNumber*)localRKSTResult.answer;
            }
                break;
            case RKSurveyQuestionTypeTimeInterval:
            case RKSurveyQuestionTypeScale:
            {
                NSAssert([localRKSTResult.answer isKindOfClass:[NSNumber class]], @"Its not an NSNumber");
                localAPCResult.floatAnswer = (NSNumber*)localRKSTResult.answer;
            }
                break;
                
            case RKSurveyQuestionTypeMultipleChoice:
            {
                NSAssert([localRKSTResult.answer isKindOfClass:[NSArray class]], @"Its not NSArray");
                NSError * serializationError;
                NSData * data =  [NSJSONSerialization dataWithJSONObject:localRKSTResult.answer options:NSJSONWritingPrettyPrinted error:&serializationError];
                [serializationError handle];
                localAPCResult.stringAnswer = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
                break;
            default:
            {
                NSAssert(NO, @"Should not come here");
            }
                break;
        }
    }

}

- (RKSurveyQuestionType)questionType
{
    return (RKSurveyQuestionType)[self.questionTypeStore integerValue];
}

- (NSObject*) answer
{
    NSObject * retObject;
    switch (self.questionType) {
        case RKSurveyQuestionTypeDate:
        case RKSurveyQuestionTypeTime:
        case RKSurveyQuestionTypeDateAndTime:
        case RKSurveyQuestionTypeText:
        case RKSurveyQuestionTypeInteger:
        case RKSurveyQuestionTypeDecimal:
        {
            retObject = self.stringAnswer;
        }
            break;
        case RKSurveyQuestionTypeSingleChoice:
        case RKSurveyQuestionTypeBoolean:
        {
            retObject = self.integerAnswer;
        }
            break;
        case RKSurveyQuestionTypeTimeInterval:
        case RKSurveyQuestionTypeScale:
        {
            retObject = self.floatAnswer;
        }
            break;
            
        case RKSurveyQuestionTypeMultipleChoice:
        {
            NSError * serializationError;
            retObject =  [NSJSONSerialization JSONObjectWithData:[self.stringAnswer dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&serializationError];
            [serializationError handle];
        }
        default:
        {
            NSAssert(NO, @"Should not come here");
        }
            break;
    }
    return retObject;
}

@end
