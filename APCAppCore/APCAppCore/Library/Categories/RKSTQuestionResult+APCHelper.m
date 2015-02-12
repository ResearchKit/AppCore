//
//  RKSTQuestionResult+APCHelper.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "RKSTQuestionResult+APCHelper.h"

@implementation RKSTQuestionResult (APCHelper)
- (id) consolidatedAnswer
{
    /**
     * Check if answer is nil (Skip) or NSNumber or NSString then process rules. Otherwise no processing of rules.
     *      Single choice: the selected RKAnswerOption's `value` property. SUPPORTED
     *      Multiple choice: array of values from selected RKAnswerOptions' `value` properties. NOT SUPPORTED
     *      Boolean: NSNumber SUPPORTED
     *      Text: NSString SUPPORTED
     *      Scale: NSNumber SUPPORTED
     *      Date: RKSTDateAnswer with date components having (NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay). NOT SUPPORTED
     *      Time: RKSTDateAnswer with date components having (NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond). NOT SUPPORTED
     *      DateAndTime: RKSTDateAnswer with date components having (NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond). NOT SUPPORTED
     *      Time Interval: NSNumber, containing a time span in seconds. SUPPORTED
     */
    
    //RKSTScaleQuestionResult : scaleAnswer
    //RKSTBooleanQuestionResult : booleanAnswer
    //RKSTTextQuestionResult : textAnswer
    //RKSTNumericQuestionResult : numericAnswer
    //RKSTTimeIntervalQuestionResult : intervalAnswer
    
    id retValue = nil;
    if ([self isKindOfClass:[RKSTScaleQuestionResult class]]) {
        retValue = [(RKSTScaleQuestionResult*) self scaleAnswer];
    }
    else if([self isKindOfClass:[RKSTBooleanQuestionResult class]])
    {
        retValue = [(RKSTBooleanQuestionResult*) self booleanAnswer];
    }
    else if([self isKindOfClass:[RKSTTextQuestionResult class]])
    {
        retValue = [(RKSTTextQuestionResult*) self textAnswer];
    }
    else if([self isKindOfClass:[RKSTTimeIntervalQuestionResult class]])
    {
        retValue = [(RKSTTimeIntervalQuestionResult*) self intervalAnswer];
    }
    else if([self isKindOfClass:[RKSTChoiceQuestionResult class]])
    {
        RKSTChoiceQuestionResult * choiceResult = (RKSTChoiceQuestionResult*) self;
        retValue = choiceResult.choiceAnswers.firstObject;
    }
    
    return retValue;
}

- (BOOL) validForApplyingRule
{
    BOOL retValue = NO;
    if ([self isKindOfClass:[RKSTScaleQuestionResult class]]) {
        retValue = YES;
    }
    else if([self isKindOfClass:[RKSTBooleanQuestionResult class]])
    {
        retValue = YES;
    }
    else if([self isKindOfClass:[RKSTTextQuestionResult class]])
    {
        retValue = YES;
    }
    else if([self isKindOfClass:[RKSTTextQuestionResult class]])
    {
        retValue = YES;
    }
    else if([self isKindOfClass:[RKSTTimeIntervalQuestionResult class]])
    {
        retValue = YES;
    }
    else if([self isKindOfClass:[RKSTChoiceQuestionResult class]])
    {
        RKSTChoiceQuestionResult * choiceResult = (RKSTChoiceQuestionResult*) self;
        retValue = (choiceResult.choiceAnswers.count > 1) ? NO : YES;
    }
    
    return retValue;
}
@end
