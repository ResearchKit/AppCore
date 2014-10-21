//
//  APCTask+Bridge.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTask+Bridge.h"
#import <ResearchKit/ResearchKit.h>
#import <BridgeSDK/BridgeSDK.h>

@implementation APCTask (Bridge)

+(void)getSurveyByRef:(NSString *)ref onCompletion:(void (^)(NSError *))completionBlock
{
#ifdef DEVELOPMENT
    if (completionBlock) {
        completionBlock(nil);
    }
#else
    [SBBComponent(SBBSurveyManager) getSurveyByRef:ref completion:^(id survey, NSError *error) {
        if (!error)
        {
            NSManagedObjectContext * context = [(APCAppDelegate*) [UIApplication sharedApplication].delegate dataSubstrate].persistentContext;
            SBBSurvey * sbbSurvey = (SBBSurvey*) survey;
            [context performBlockAndWait:^{
                NSFetchRequest * request = [APCTask request];
                request.predicate = [NSPredicate predicateWithFormat:@"uid == %@", sbbSurvey.identifier];
                APCTask * task = [[context executeFetchRequest:request error:NULL] firstObject];
                task.rkTask = [self rkTaskFromSBBSurvey:survey];
                [task saveToPersistentStore:NULL];
            }];
        }
        else
        {
            [error handle];
        }

    }];
#endif
}

/*********************************************************************************/
#pragma mark - SBB to RKTask Conversion
/*********************************************************************************/
+ (RKTask*) rkTaskFromSBBSurvey: (SBBSurvey*) survey
{
    NSMutableArray * stepsArray = [NSMutableArray array];
    [survey.questions enumerateObjectsUsingBlock:^(SBBSurveyQuestion* obj, NSUInteger idx, BOOL *stop) {
        [stepsArray addObject:[self rkStepFromSBBSurveyQuestion:obj]];
    }];
    RKTask * retTask = [[RKTask alloc] initWithName:survey.name identifier:survey.identifier steps:stepsArray];
    return retTask;
}

+ (RKQuestionStep*) rkStepFromSBBSurveyQuestion: (SBBSurveyQuestion*) question
{
    RKQuestionStep * retStep = [[RKQuestionStep alloc] initWithIdentifier:question.guid name:question.identifier];
    retStep.question = question.prompt;
    
    NSMutableArray * options = [NSMutableArray array];
    [[(SBBMultiValueConstraints*) question.constraints enumeration] enumerateObjectsUsingBlock:^(SBBSurveyQuestionOption* option, NSUInteger idx, BOOL *stop) {
        [options addObject:option.label];
    }];
    RKAnswerFormat * answerFormat = [RKChoiceAnswerFormat choiceAnswerWithOptions:options style:RKChoiceAnswerStyleSingleChoice];
    retStep.answerFormat = answerFormat;
    return retStep;
}
@end
