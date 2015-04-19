// 
//  APCConsentTextChoiceQuestion.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCConsentTextChoiceQuestion.h"

@implementation APCConsentTextChoiceQuestion

- (instancetype)initWithIdentifier:(NSString*)identifier
                            prompt:(NSString*)prompt
                            suffix:(NSString*)suffix
                           answers:(NSArray*)answers
                    expectedAnswer:(NSUInteger)indexOfExpectedAnswer
{
    self = [super initWithIdentifier:identifier prompt:prompt suffix:suffix];
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
    ORKQuestionStep*            question = [ORKQuestionStep questionStepWithIdentifier:self.extendedIdentifier
                                                                                 title:self.prompt
                                                                                answer:format];
    question.optional = NO;
    
    return question;
}

@end
