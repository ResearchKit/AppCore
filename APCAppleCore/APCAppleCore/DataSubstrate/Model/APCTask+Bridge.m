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
#import <Foundation/Foundation.h>

@class APCDummyObject;
static APCDummyObject * _dummyObject;

@interface APCDummyObject : NSObject

- (RKAnswerFormat*) rkBooleanAnswerFormat: (SBBSurveyConstraints*) constraints;
- (RKAnswerFormat*) rkDateAnswerFormat: (SBBSurveyConstraints*) constraints;
- (RKAnswerFormat*) rkNumericAnswerFormat: (SBBSurveyConstraints*) constraints;
- (RKAnswerFormat*) rkTimeIntervalAnswerFormat: (SBBSurveyConstraints*) constraints;
- (RKAnswerFormat*) rkChoiceAnswerFormat: (SBBSurveyConstraints*) constraints;
- (RKAnswerFormat*) rkTextAnswerFormat: (SBBSurveyConstraints*) constraints;

@end



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
                [context processPendingChanges];
            }];
        }
        else
        {
            [error handle];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(error);
            }
        });
    }];
#endif
}

+ (NSString *) lookUpAnswerFormatMethod: (NSString*) SBBClassName
{
    NSDictionary * answerFormatClass = @{
                                         @"SBBBooleanConstraints"   :   @"rkBooleanAnswerFormat:",
                                         @"SBBDateConstraints"      :   @"rkDateAnswerFormat:",
                                         @"SBBDateTimeConstraints"  :   @"rkDateAnswerFormat:",
                                         @"SBBDecimalConstraints"   :   @"rkNumericAnswerFormat:",
                                         @"SBBDurationConstraints"  :   @"rkTimeIntervalAnswerFormat:",
                                         @"SBBIntegerConstraints"   :   @"rkNumericAnswerFormat:",
                                         @"SBBMultiValueConstraints":   @"rkChoiceAnswerFormat:",
                                         @"SBBTimeConstraints"      :   @"rkDateAnswerFormat:",
                                         @"SBBStringConstraints"    :   @"rkTextAnswerFormat:"
                                         };
    NSAssert(answerFormatClass[SBBClassName], @"SBBClass Not Defined");
    return answerFormatClass[SBBClassName];
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
    retStep.answerFormat = [self rkAnswerFormatFromSBBSurveyConstraints:question.constraints];
    return retStep;
}

+ (RKAnswerFormat*) rkAnswerFormatFromSBBSurveyConstraints: (SBBSurveyConstraints*) constraints
{
    RKAnswerFormat * retAnswer;
    
    if (!_dummyObject) {
        _dummyObject = [[APCDummyObject alloc] init];
    }
    
    NSString * selectorName = [self lookUpAnswerFormatMethod:NSStringFromClass([constraints class])];
    SEL selector = NSSelectorFromString(selectorName);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    retAnswer = (RKAnswerFormat*) [_dummyObject performSelector:selector withObject:constraints];
#pragma clang diagnostic pop

    
    return retAnswer;
}

@end

@implementation APCDummyObject

/*********************************************************************************/
#pragma mark - Answer Format Methods
/*********************************************************************************/
-(RKAnswerFormat *)rkBooleanAnswerFormat:(SBBSurveyConstraints *)constraints
{
    RKAnswerFormat * retAnswer = [[RKBooleanAnswerFormat alloc] init];
    return retAnswer;
}

- (RKAnswerFormat *)rkDateAnswerFormat:(SBBSurveyConstraints *)constraints
{
    RKAnswerFormat * retAnswer;
    if ([constraints isKindOfClass:[SBBDateTimeConstraints class]]) {
        retAnswer = [RKDateAnswerFormat dateTimeAnswer];
//        SBBDateTimeConstraints * localConstraints = (SBBDateTimeConstraints*)constraints;
    }
    else if ([constraints isKindOfClass:[SBBDateConstraints class]]) {
//        SBBDateConstraints * localConstraints = (SBBDateConstraints*)constraints;
    }
    else if ([constraints isKindOfClass:[SBBTimeConstraints class]]) {
//        SBBTimeConstraints * localConstraints = (SBBTimeConstraints*)constraints;
    }
    return retAnswer;
}

- (RKAnswerFormat*) rkChoiceAnswerFormat: (SBBSurveyConstraints*) constraints
{
    RKAnswerFormat * retAnswer;
    SBBMultiValueConstraints * localConstraints = (SBBMultiValueConstraints*)constraints;
    NSMutableArray * options = [NSMutableArray array];
    [localConstraints.enumeration enumerateObjectsUsingBlock:^(SBBSurveyQuestionOption* option, NSUInteger idx, BOOL *stop) {
        [options addObject:option.label];
    }];
    if (localConstraints.allowOtherValue) {
        [options addObject:NSLocalizedString(@"Other", @"Spinner Option")];
    }
    retAnswer = [RKChoiceAnswerFormat choiceAnswerWithOptions:options style: localConstraints.allowMultipleValue ? RKChoiceAnswerStyleMultipleChoice : RKChoiceAnswerStyleSingleChoice];
    return retAnswer;
}

- (RKAnswerFormat *)rkNumericAnswerFormat:(SBBSurveyConstraints *)constraints
{
    return [RKNumericAnswerFormat decimalAnswerWithUnit:nil];
}

- (RKAnswerFormat *)rkTextAnswerFormat:(SBBSurveyConstraints *)constraints
{
    return [RKTextAnswerFormat textAnswer];
}

- (RKAnswerFormat *)rkTimeIntervalAnswerFormat:(SBBSurveyConstraints *)constraints
{
    return [RKTimeIntervalAnswerFormat timeIntervalAnswer];
}


@end