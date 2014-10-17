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

+ (instancetype) storeRKResult:(RKResult*) rkResult inContext: (NSManagedObjectContext*) context
{
    __block APCQuestionResult * result;
    [context performBlockAndWait:^{
        result = [APCQuestionResult newObjectForContext:context];
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
    
    NSParameterAssert([rkResult isKindOfClass:[RKQuestionResult class]]);
    RKQuestionResult * localRKResult = (RKQuestionResult*) rkResult;
    APCQuestionResult * localAPCResult = (APCQuestionResult*) apcResult;

    localAPCResult.questionTypeStore = [NSNumber numberWithInteger:localRKResult.questionType];
    if (localRKResult.answer) {
        switch (localRKResult.questionType) {
            case RKSurveyQuestionTypeDate:
            case RKSurveyQuestionTypeTime:
            case RKSurveyQuestionTypeDateAndTime:
            case RKSurveyQuestionTypeText:
            case RKSurveyQuestionTypeInteger:
            case RKSurveyQuestionTypeDecimal:
            case RKSurveyQuestionTypeSingleChoice:
            {
                //Expecting either a string or an int from a range of numbers
                if ([localRKResult.answer isKindOfClass:[NSString class]]) {
                    localAPCResult.stringAnswer = (NSString*)localRKResult.answer;
                } else if ([localRKResult.answer isKindOfClass:[NSNumber class]]) {
                    localAPCResult.integerAnswer = localRKResult.answer;
                } else {
                    NSAssert(localRKResult.answer, @"Its neither an integer nor a string");
                }
            }
                break;
            case RKSurveyQuestionTypeBoolean:
            {
                NSAssert([localRKResult.answer isKindOfClass:[NSNumber class]], @"Its not a NSNumber");
                localAPCResult.integerAnswer = (NSNumber*)localRKResult.answer;
            }
                break;
            case RKSurveyQuestionTypeTimeInterval:
            case RKSurveyQuestionTypeScale:
            {
                NSAssert([localRKResult.answer isKindOfClass:[NSNumber class]], @"Its not an NSNumber");
                localAPCResult.floatAnswer = (NSNumber*)localRKResult.answer;
            }
                break;
                
            case RKSurveyQuestionTypeMultipleChoice:
            {
                NSAssert([localRKResult.answer isKindOfClass:[NSArray class]], @"Its not NSArray");
                NSError * serializationError;
                NSData * data =  [NSJSONSerialization dataWithJSONObject:localRKResult.answer options:NSJSONWritingPrettyPrinted error:&serializationError];
                [serializationError handle];
                localAPCResult.stringAnswer = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
                break;
            case RKSurveyQuestionTypeCustom:
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
        case RKSurveyQuestionTypeCustom:
        default:
        {
            NSAssert(NO, @"Should not come here");
        }
            break;
    }
    return retObject;
}

@end
