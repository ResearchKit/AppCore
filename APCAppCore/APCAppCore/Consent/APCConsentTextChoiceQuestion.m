//
//  APCConsentTextChoiceQuestion.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCConsentTextChoiceQuestion.h"

@implementation APCConsentTextChoiceQuestion

- (instancetype)initWithIdentifier:(NSString*)identifier
                            prompt:(NSString*)prompt
                           answers:(NSArray*)answers
                    expectedAnswer:(NSUInteger)indexOfExpectedAnswer
{
    self = [super initWithIdentifier:identifier prompt:prompt];
    if (self)
    {
        _answers               = answers;
        _indexOfExpectedAnswer = indexOfExpectedAnswer;
    }
    
    return self;
}

- (BOOL)evaluate:(ORKStepResult*)stepResult
{
    ORKChoiceQuestionResult*    questionResult   = stepResult.results.firstObject;
    BOOL                        evaulationResult = false;
    
    if ([questionResult isKindOfClass:[ORKChoiceQuestionResult class]])
    {
        if (questionResult != nil && questionResult.choiceAnswers != nil && questionResult.choiceAnswers.count > 0)
        {
            NSString*   answer = questionResult.choiceAnswers.firstObject;
            NSUInteger  index = [self.answers indexOfObject:answer];
            
            evaulationResult = index == self.indexOfExpectedAnswer;
        }
    }
    
    return evaulationResult;
}

- (ORKStep*)instantiateRkQuestion
{
    ORKTextChoiceAnswerFormat*  format   = [[ORKTextChoiceAnswerFormat alloc] initWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                                textChoices:self.answers];
    ORKQuestionStep*            question = [ORKQuestionStep questionStepWithIdentifier:self.identifier
                                                                                 title:self.prompt
                                                                                answer:format];
    question.optional = NO;
    
    return question;
}

@end
