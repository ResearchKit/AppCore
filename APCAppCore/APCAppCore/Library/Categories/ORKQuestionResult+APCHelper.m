// 
//  ORKQuestionResult+APCHelper.m 
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
 
#import "ORKQuestionResult+APCHelper.h"

@implementation ORKQuestionResult (APCHelper)
- (id) consolidatedAnswer
{
    /**
     * Check if answer is nil (Skip) or NSNumber or NSString then process rules. Otherwise no processing of rules.
     *      Single choice: the selected RKAnswerOption's `value` property. SUPPORTED
     *      Multiple choice: array of values from selected RKAnswerOptions' `value` properties. NOT SUPPORTED
     *      Boolean: NSNumber SUPPORTED
     *      Text: NSString SUPPORTED
     *      Scale: NSNumber SUPPORTED
     *      Date: ORKDateAnswer with date components having (NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay). NOT SUPPORTED
     *      Time: ORKDateAnswer with date components having (NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond). NOT SUPPORTED
     *      DateAndTime: ORKDateAnswer with date components having (NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond). NOT SUPPORTED
     *      Time Interval: NSNumber, containing a time span in seconds. SUPPORTED
     */
    
    //ORKScaleQuestionResult : scaleAnswer
    //ORKBooleanQuestionResult : booleanAnswer
    //ORKTextQuestionResult : textAnswer
    //ORKNumericQuestionResult : numericAnswer
    //ORKTimeIntervalQuestionResult : intervalAnswer
    //ORKChoiceQuestionResult : choiceAnswers
    
    id retValue = nil;
    if ([self isKindOfClass:[ORKScaleQuestionResult class]]) {
        retValue = [(ORKScaleQuestionResult*) self scaleAnswer];
    }
    else if([self isKindOfClass:[ORKBooleanQuestionResult class]])
    {
        retValue = [(ORKBooleanQuestionResult*) self booleanAnswer];
    }
    else if([self isKindOfClass:[ORKTextQuestionResult class]])
    {
        retValue = [(ORKTextQuestionResult*) self textAnswer];
    }
    else if([self isKindOfClass:[ORKTimeIntervalQuestionResult class]])
    {
        retValue = [(ORKTimeIntervalQuestionResult*) self intervalAnswer];
    }
    else if([self isKindOfClass:[ORKNumericQuestionResult class]])
    {
        retValue = [(ORKNumericQuestionResult*) self numericAnswer];
    }
    else if([self isKindOfClass:[ORKChoiceQuestionResult class]])
    {
        retValue = [(ORKChoiceQuestionResult *) self choiceAnswers];
    }
    
    return retValue;
}

- (BOOL) validForApplyingRule
{
    BOOL retValue = NO;
    if ([self isKindOfClass:[ORKScaleQuestionResult class]]) {
        retValue = YES;
    }
    else if([self isKindOfClass:[ORKBooleanQuestionResult class]])
    {
        retValue = YES;
    }
    else if([self isKindOfClass:[ORKTextQuestionResult class]])
    {
        retValue = YES;
    }
    else if([self isKindOfClass:[ORKTextQuestionResult class]])
    {
        retValue = YES;
    }
    else if([self isKindOfClass:[ORKTimeIntervalQuestionResult class]])
    {
        retValue = YES;
    }
    else if([self isKindOfClass:[ORKChoiceQuestionResult class]])
    {
        retValue = YES;
    }
    else if ([self isKindOfClass:[ORKNumericQuestionResult class]])
    {
        retValue = YES;
    }
    
    return retValue;
}

@end
