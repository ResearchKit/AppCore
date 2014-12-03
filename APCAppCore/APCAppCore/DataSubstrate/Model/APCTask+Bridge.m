//
//  APCTask+Bridge.m
//  APCAppCore
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

- (RKSTAnswerFormat*) rkBooleanAnswerFormat: (SBBSurveyConstraints*) constraints;
- (RKSTAnswerFormat*) rkDateAnswerFormat: (SBBSurveyConstraints*) constraints;
- (RKSTAnswerFormat*) rkNumericAnswerFormat: (SBBSurveyConstraints*) constraints;
- (RKSTAnswerFormat*) rkTimeIntervalAnswerFormat: (SBBSurveyConstraints*) constraints;
- (RKSTAnswerFormat*) rkChoiceAnswerFormat: (SBBSurveyConstraints*) constraints;
- (RKSTAnswerFormat*) rkTextAnswerFormat: (SBBSurveyConstraints*) constraints;

@end



@implementation APCTask (Bridge)

/*********************************************************************************/
#pragma mark - Surveys
/*********************************************************************************/
+ (BOOL) serverDisabled
{
#if DEVELOPMENT
    return YES;
#else
    return ((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.parameters.bypassServer;
#endif
}

+ (void)refreshSurveys
{
    NSManagedObjectContext * context = ((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.persistentContext;
    NSFetchRequest * request = [APCTask request];
    request.predicate = [NSPredicate predicateWithFormat:@"taskDescription == nil && taskHRef != nil"];
    NSError * error;
    NSArray * unloadedSurveyTasks = [context executeFetchRequest:request error:&error];
    [error handle];
    [unloadedSurveyTasks enumerateObjectsUsingBlock:^(APCTask * task, NSUInteger idx, BOOL *stop) {
        [task loadSurveyOnCompletion:NULL];
    }];
}

- (void) loadSurveyOnCompletion: (void (^)(NSError * error)) completionBlock
{
    if ([APCTask serverDisabled] || self.taskDescription) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil);
            }
        });
    }
    else
    {
        [SBBComponent(SBBSurveyManager) getSurveyByRef:self.taskHRef completion:^(id survey, NSError *error) {
            if (!error)
            {
                SBBSurvey * sbbSurvey = (SBBSurvey*) survey;
                [self.managedObjectContext performBlockAndWait:^{
                    self.taskTitle = sbbSurvey.name;
                    self.rkTask = [APCTask rkTaskFromSBBSurvey:survey];
                    [self saveToPersistentStore:NULL];
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
    }
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
#pragma mark - SBB to RKSTOrderedTask Conversion
/*********************************************************************************/
+ (RKSTOrderedTask*) rkTaskFromSBBSurvey: (SBBSurvey*) survey
{
    NSMutableArray * stepsArray = [NSMutableArray array];
    [survey.questions enumerateObjectsUsingBlock:^(SBBSurveyQuestion* obj, NSUInteger idx, BOOL *stop) {
        [stepsArray addObject:[self rkStepFromSBBSurveyQuestion:obj]];
    }];
    RKSTOrderedTask * retTask = [[RKSTOrderedTask alloc] initWithIdentifier:survey.identifier steps:stepsArray];
    return retTask;
}

+ (RKSTQuestionStep*) rkStepFromSBBSurveyQuestion: (SBBSurveyQuestion*) question
{
    RKSTQuestionStep * retStep =[RKSTQuestionStep questionStepWithIdentifier:question.guid title:question.prompt answer:[self rkAnswerFormatFromSBBSurveyConstraints:question.constraints]];
    return retStep;
}

+ (RKSTAnswerFormat*) rkAnswerFormatFromSBBSurveyConstraints: (SBBSurveyConstraints*) constraints
{
    RKSTAnswerFormat * retAnswer;
    
    if (!_dummyObject) {
        _dummyObject = [[APCDummyObject alloc] init];
    }
    
    NSString * selectorName = [self lookUpAnswerFormatMethod:NSStringFromClass([constraints class])];
    SEL selector = NSSelectorFromString(selectorName);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    retAnswer = (RKSTAnswerFormat*) [_dummyObject performSelector:selector withObject:constraints];
#pragma clang diagnostic pop
    
    return retAnswer;
}

@end

@implementation APCDummyObject

/*********************************************************************************/
#pragma mark - Answer Format Methods
/*********************************************************************************/
-(RKSTAnswerFormat *)rkBooleanAnswerFormat:(SBBSurveyConstraints *)constraints
{
    RKSTAnswerFormat * retAnswer = [[RKSTBooleanAnswerFormat alloc] init];
    return retAnswer;
}

- (RKSTAnswerFormat *)rkDateAnswerFormat:(SBBSurveyConstraints *)constraints
{
    RKSTAnswerFormat * retAnswer;
    if ([constraints isKindOfClass:[SBBDateTimeConstraints class]]) {
        retAnswer = [RKSTDateAnswerFormat dateTimeAnswer];
//        SBBDateTimeConstraints * localConstraints = (SBBDateTimeConstraints*)constraints;
    }
    else if ([constraints isKindOfClass:[SBBDateConstraints class]]) {
        retAnswer = [RKSTDateAnswerFormat dateAnswer];
//        SBBDateConstraints * localConstraints = (SBBDateConstraints*)constraints;
    }
    else if ([constraints isKindOfClass:[SBBTimeConstraints class]]) {
        retAnswer = [RKSTDateAnswerFormat timeAnswer];
//        SBBTimeConstraints * localConstraints = (SBBTimeConstraints*)constraints;
    }
    return retAnswer;
}

- (RKSTAnswerFormat*) rkChoiceAnswerFormat: (SBBSurveyConstraints*) constraints
{
    RKSTAnswerFormat * retAnswer;
    SBBMultiValueConstraints * localConstraints = (SBBMultiValueConstraints*)constraints;
    NSMutableArray * options = [NSMutableArray array];
    [localConstraints.enumeration enumerateObjectsUsingBlock:^(SBBSurveyQuestionOption* option, NSUInteger idx, BOOL *stop) {
        //TODO: Fix this KLUDGE
        [options addObject:@[[NSString stringWithFormat:@"Answer %ld", idx+1], option.label]];
//        [options addObject:option.label];
    }];
    if (localConstraints.allowOtherValue) {
        [options addObject:NSLocalizedString(@"Other", @"Spinner Option")];
    }
    retAnswer = [RKSTChoiceAnswerFormat choiceAnswerWithTextOptions:options style: localConstraints.allowMultipleValue ? RKChoiceAnswerStyleMultipleChoice : RKChoiceAnswerStyleSingleChoice];
    return retAnswer;
}

- (RKSTAnswerFormat *)rkNumericAnswerFormat:(SBBSurveyConstraints *)constraints
{
    return [RKSTNumericAnswerFormat decimalAnswerWithUnit:nil];
}

- (RKSTAnswerFormat *)rkTextAnswerFormat:(SBBSurveyConstraints *)constraints
{
    return [RKSTTextAnswerFormat textAnswer];
}

- (RKSTAnswerFormat *)rkTimeIntervalAnswerFormat:(SBBSurveyConstraints *)constraints
{
    return [RKSTTimeIntervalAnswerFormat timeIntervalAnswer];
}


@end
