//
//  ORKQuestionResult+APCHelper.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
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
    else if([self isKindOfClass:[ORKChoiceQuestionResult class]])
    {
        ORKChoiceQuestionResult * choiceResult = (ORKChoiceQuestionResult*) self;
        retValue = choiceResult.choiceAnswers.firstObject;
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
        ORKChoiceQuestionResult * choiceResult = (ORKChoiceQuestionResult*) self;
        retValue = (choiceResult.choiceAnswers.count > 1) ? NO : YES;
    }
    
    return retValue;
}
@end
