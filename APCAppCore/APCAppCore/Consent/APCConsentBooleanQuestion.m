//
//  APCConsentBooleanQuestion.m
//  APCAppCore
//
//  Created by Edward Cessna on 2/22/15.
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
    
    return question;
}

@end
