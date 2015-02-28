//
//  APCConsentBooleanQuestion.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCConsentBooleanQuestion.h"

@implementation APCConsentBooleanQuestion

- (instancetype)initWithIdentifier:(NSString*)identifier prompt:(NSString*)prompt expectedAnswer:(BOOL)expectedAnswer
{
    self = [super initWithIdentifier:identifier prompt:prompt];
    if (self)
    {
        _expectedAnswer = expectedAnswer;
    }
    
    return self;
}

- (BOOL)evaluate:(ORKStepResult*)stepResult
{
    ORKBooleanQuestionResult*   questionResult   = stepResult.results.firstObject;
    BOOL                        evaulationResult = false;
    
    if ([questionResult isKindOfClass:[ORKBooleanQuestionResult class]])
    {
        evaulationResult = [questionResult booleanAnswer].boolValue == self.expectedAnswer;
    }
    
    return evaulationResult;
}

- (ORKStep*)instantiateRkQuestion
{
    ORKBooleanAnswerFormat* format   = [ORKBooleanAnswerFormat booleanAnswerFormat];
    ORKQuestionStep*        question = [ORKQuestionStep questionStepWithIdentifier:self.identifier
                                                                             title:self.prompt
                                                                            answer:format];
    question.optional = NO;
    
    return question;
}

@end
