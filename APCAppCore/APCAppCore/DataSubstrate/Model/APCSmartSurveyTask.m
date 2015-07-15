// 
//  APCSmartSurveyTask.m 
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
 
#import "APCSmartSurveyTask.h"
#import <ResearchKit/ResearchKit.h>
#import <BridgeSDK/BridgeSDK.h>
#import "APCAppCore.h"

NSString *const kRuleOperatorKey = @"operator";
NSString *const kRuleSkipToKey = @"skipTo";
NSString *const kRuleValueKey = @"value";

NSString *const kOperatorSkip               = @"de";
NSString *const kOperatorEqual              = @"eq";
NSString *const kOperatorNotEqual           = @"ne";
NSString *const kOperatorLessThan           = @"lt";
NSString *const kOperatorGreaterThan        = @"gt";
NSString *const kOperatorLessThanEqual      = @"le";
NSString *const kOperatorGreaterThanEqual   = @"ge";
NSString *const kOperatorOtherThan          = @"ot";

NSString *const kEndOfSurveyMarker          = @"END_OF_SURVEY";

NSString *const kConstraintsKey   = @"constraints";
NSString *const kUiHintKey   = @"uihint";
NSString *const kSliderValue   = @"slider";


@class APCDummyObject;
static APCDummyObject * _dummyObject;

@interface APCDummyObject : NSObject

- (ORKAnswerFormat*) rkBooleanAnswerFormat:(NSDictionary *)objectDictionary;
- (ORKAnswerFormat*) rkDateAnswerFormat:(NSDictionary *)objectDictionary;
- (ORKAnswerFormat*) rkNumericAnswerFormat:(NSDictionary *)objectDictionary;
- (ORKAnswerFormat*) rkTimeIntervalAnswerFormat:(NSDictionary *)objectDictionary;
- (ORKAnswerFormat*) rkChoiceAnswerFormat:(NSDictionary *)objectDictionary;
- (ORKAnswerFormat*) rkTextAnswerFormat:(NSDictionary *)objectDictionary;

@end

@interface APCSmartSurveyTask () <NSSecureCoding, NSCopying>

@property (nonatomic, copy) NSString * identifier;
@property (nonatomic, strong) NSMutableDictionary * rkSteps;
@property (nonatomic, strong) NSMutableDictionary * rules; //[stepID : [rules]]

@property (nonatomic, strong) NSMutableArray * staticStepIdentifiers;
@property (nonatomic, strong) NSMutableArray * dynamicStepIdentifiers;

@property (nonatomic, strong) NSMutableSet * setOfIdentifiers; //For checking identifier duplication

@property (nonatomic, strong) NSString * currentStep;

@end

@implementation APCSmartSurveyTask

- (instancetype)initWithIdentifier: (NSString*) identifier survey:(SBBSurvey *)survey
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.rules = [NSMutableDictionary dictionary];
        self.rkSteps = [NSMutableDictionary dictionary];
        self.staticStepIdentifiers = [NSMutableArray array];
        self.setOfIdentifiers = [NSMutableSet set];
        
        NSArray * elements = survey.elements;
        
        [elements enumerateObjectsUsingBlock:^(id object, NSUInteger __unused idx, BOOL * __unused stop) {
            if ([object isKindOfClass:[SBBSurveyQuestion class]]) {
                SBBSurveyQuestion * obj = (SBBSurveyQuestion*) object;
                self.rkSteps[obj.identifier] = [APCSmartSurveyTask rkStepFromSBBSurveyQuestion:obj];
                
                [self.staticStepIdentifiers addObject:obj.identifier];
                [self.setOfIdentifiers addObject:obj.identifier];
                
                NSArray * rulesArray = [[obj constraints] rules];
                if (rulesArray) {
                    self.rules[obj.identifier] = [self createArrayOfDictionaryForRules:rulesArray];
                }
            }
        }];
        
        NSAssert(self.staticStepIdentifiers.count > 0, @"Survey does not have any questions");
        NSAssert((self.staticStepIdentifiers.count == self.setOfIdentifiers.count), @"Duplicate Identifiers in Survey! Please rename them!");
        
        //For Debugging duplicates. Copy paste below commented line in lldb to look for duplicates
        //[self.staticStepIdentifiers sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
        
        self.dynamicStepIdentifiers = [self.staticStepIdentifiers mutableCopy];
    }
    return self;
}

- (NSArray*) createArrayOfDictionaryForRules: (NSArray*) rulesArray
{
    NSMutableArray * newRulesArray = [NSMutableArray array];
    [rulesArray enumerateObjectsUsingBlock:^(SBBSurveyRule * rule, NSUInteger __unused idx, BOOL * __unused stop) {
        NSMutableDictionary * ruleDict = [NSMutableDictionary dictionary];
        if (rule.operator) {
            ruleDict[kRuleOperatorKey] = rule.operator;
        }
        if (rule.value) {
            ruleDict[kRuleValueKey] = rule.value;
        }
        if (rule.skipTo) {
            ruleDict[kRuleSkipToKey] = rule.skipTo;
        }
        
        [newRulesArray addObject:ruleDict];
    }];
    return newRulesArray;
}


- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *)result
{
    [self refillDynamicStepIdentifiersWithCurrentStepIdentifier:step.identifier];
    
    //If Step has rules, process answer. Otherwise keep moving
    NSArray * rulesForThisStep = self.rules[step.identifier];
    NSString * skipToStep = nil;
    if (rulesForThisStep.count) {
        ORKStepResult * stepResult = (ORKStepResult*) [result resultForIdentifier:step.identifier];
        id firstResult = stepResult.results.firstObject;
        if (firstResult == nil || [firstResult isKindOfClass:[ORKQuestionResult class]]) {
            ORKQuestionResult * questionResult = (ORKQuestionResult*) firstResult;
            if ([questionResult validForApplyingRule]) {
                skipToStep = [self processRules:rulesForThisStep forAnswer:[questionResult consolidatedAnswer]];
            }
        }
        
        if ([skipToStep isEqualToString:kEndOfSurveyMarker]) {
            return nil;
        }
        
        //If there is new skipToStep then skip to that step
        if (skipToStep) {
            [self adjustDynamicStepIdentifersForSkipToStep:skipToStep from:step.identifier];
        }
    }
    
    NSString * nextStepIdentifier = [self nextStepIdentifier:YES currentIdentifier:step.identifier];
    return nextStepIdentifier? self.rkSteps[nextStepIdentifier] : nil;
}

- (ORKStep *)stepBeforeStep:(ORKStep *)step withResult:(ORKTaskResult *) __unused result
{
    [self refillDynamicStepIdentifiersWithCurrentStepIdentifier:step.identifier];
    NSString * nextStepIdentifier = [self nextStepIdentifier:NO currentIdentifier:step.identifier];
    return nextStepIdentifier? self.rkSteps[nextStepIdentifier] : nil;
}

- (ORKTaskProgress)progressOfCurrentStep:(ORKStep *)step withResult:(ORKTaskResult *) __unused result
{
    return ORKTaskProgressMake([self.staticStepIdentifiers indexOfObject: step.identifier], self.staticStepIdentifiers.count);
}

/*********************************************************************************/
#pragma mark - Array Processing
/*********************************************************************************/
- (NSString *) nextStepIdentifier: (BOOL) after currentIdentifier: (NSString*) currentIdentifier
{
    if (currentIdentifier == nil && after) {
        return (self.dynamicStepIdentifiers.count > 0) ? self.dynamicStepIdentifiers[0] : nil;
    }
    NSUInteger currentIndex = [self.dynamicStepIdentifiers indexOfObject: currentIdentifier];
    NSAssert(currentIndex != NSNotFound, @"Step Not Found. Should not get here.");
    NSInteger newIndex = NSNotFound;
    if (after) {
        if (currentIndex+1 < self.dynamicStepIdentifiers.count) {
            newIndex = currentIndex + 1;
        }
    }
    else
    {
        if (currentIndex >= 1) {
            newIndex = currentIndex -1;
        }
    }
    return (newIndex != NSNotFound) ? self.dynamicStepIdentifiers[newIndex] : nil;
}

- (void) adjustDynamicStepIdentifersForSkipToStep: (NSString*) skipToStep from: (NSString*) currentStep
{
    NSInteger currentIndex = [self.dynamicStepIdentifiers indexOfObject:currentStep];
    NSInteger skipToIndex = [self.dynamicStepIdentifiers indexOfObject:skipToStep];
    if (currentIndex == NSNotFound || skipToIndex == NSNotFound) {
        return;
    }
    
    if (skipToIndex > currentIndex) {
        while (![self.dynamicStepIdentifiers[currentIndex+1] isEqualToString:skipToStep]) {
            [self.dynamicStepIdentifiers removeObjectAtIndex:currentIndex+1];
        }
    }
}

- (void) refillDynamicStepIdentifiersWithCurrentStepIdentifier: (NSString*) stepIdentifier
{
    //Remove till end in dynamic
    NSUInteger currentIndexInDynamic = [self.dynamicStepIdentifiers indexOfObject:stepIdentifier];
    currentIndexInDynamic = currentIndexInDynamic == NSNotFound ? 0 : currentIndexInDynamic;
    NSRange rangeInDynamic = NSMakeRange(currentIndexInDynamic, self.dynamicStepIdentifiers.count - currentIndexInDynamic);
    [self.dynamicStepIdentifiers removeObjectsInRange:rangeInDynamic];
    
    //Add array from static
    NSUInteger currentIndexInStatic = [self.staticStepIdentifiers indexOfObject:stepIdentifier];
    currentIndexInStatic = currentIndexInStatic == NSNotFound ? 0 : currentIndexInStatic;
    NSRange rangeInStatic = NSMakeRange(currentIndexInStatic, self.staticStepIdentifiers.count - currentIndexInStatic);
    NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:rangeInStatic];
    NSArray * subArray = [self.staticStepIdentifiers objectsAtIndexes:indexSet];
    
    [self.dynamicStepIdentifiers addObjectsFromArray:subArray];
}



/*********************************************************************************/
#pragma mark - Rule Checking
/*********************************************************************************/

- (NSString *) processRules: (NSArray*) rules forAnswer: (id) answer
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
    __block NSString * skipToIdentifier = nil;
    if (answer == nil || [answer isKindOfClass:[NSNumber class]] || [answer isKindOfClass:[NSString class]]) {
        [rules enumerateObjectsUsingBlock:^(SBBSurveyRule * rule, NSUInteger __unused idx, BOOL *stop) {
            skipToIdentifier = [self checkRule:rule againstAnswer:answer];
            if (skipToIdentifier) {
                *stop = YES;
            }
        }];
    }
    if (skipToIdentifier) {
        APCLogDebug(@"SKIPPING TO: %@", skipToIdentifier);
    }
    return skipToIdentifier;
}

- (NSString *) checkRule: (SBBSurveyRule*) rule againstAnswer: (id) answer
{
    NSString * retValue = nil;
    NSString * operator     = [rule valueForKeyPath:kRuleOperatorKey];
    if (operator.length > 0) {
        operator = operator.lowercaseString;
    }
    id value                = [rule valueForKeyPath:kRuleValueKey];
    NSString * skipToValue  = [rule valueForKeyPath:kRuleSkipToKey];
    
    //Skip
    if ([operator isEqualToString:kOperatorSkip] && answer == nil) {
        retValue = skipToValue;
    }
    
    NSNumberFormatter * formatter = [NSNumberFormatter new];
    
    NSNumber * answerNumber;
    NSNumber * valueNumber;
    if ([answer isKindOfClass:[NSString class]]) {
        answerNumber =[formatter numberFromString:answer];
    }
    else if ([answer isKindOfClass:[NSNumber class]])
    {
        answerNumber = answer;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        valueNumber =[formatter numberFromString:value];
    }
    else if ([value isKindOfClass:[NSNumber class]])
    {
        valueNumber = value;
    }
    
    CGFloat answerDouble = answerNumber.doubleValue;
    CGFloat valueDouble = valueNumber.doubleValue;
    
    //Equal
    if ([operator isEqualToString:kOperatorEqual]) {
        if ([answer isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]] ) {
            if ([answer localizedCaseInsensitiveCompare:value] == NSOrderedSame) {
                retValue = skipToValue;
            }
        }
        else
        {
            if (answerNumber && valueNumber) {
                if (fabs(answerDouble - valueDouble) <= DBL_EPSILON) {
                    retValue = skipToValue;
                }
            }
        }
    }
    
    //Not Equal
    if ([operator isEqualToString:kOperatorNotEqual]) {
        if ([answer isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]] ) {
            if ([answer localizedCaseInsensitiveCompare:value] != NSOrderedSame) {
                retValue = skipToValue;
            }
        }
        else
        {
            if (answerNumber && valueNumber) {
                if (fabs(answerDouble - valueDouble) > DBL_EPSILON) {
                    retValue = skipToValue;
                }
            }
        }
    }
    
    //Other Than
    if ([operator isEqualToString:kOperatorOtherThan]) {
        if (answer == nil) {
            retValue = skipToValue;
        }
        else if ([answer isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]] ) {
            if ([answer localizedCaseInsensitiveCompare:value] != NSOrderedSame) {
                retValue = skipToValue;
            }
        }
        else
        {
            if (answerNumber && valueNumber) {
                if (fabs(answerDouble - valueDouble) > DBL_EPSILON) {
                    retValue = skipToValue;
                }
            }
        }
    }
    
    
    //Greater Than
    if ([operator isEqualToString:kOperatorGreaterThan]) {
        if (answerNumber && valueNumber) {
            if ((answerDouble - valueDouble) > DBL_EPSILON) {
                retValue = skipToValue;
            }
        }
    }
    
    //Lesser Than
    if ([operator isEqualToString:kOperatorLessThan]) {
        if (answerNumber && valueNumber) {
            if ((valueDouble - answerDouble) > DBL_EPSILON) {
                retValue = skipToValue;
            }
        }
    }
    
    //Greater Than or EqualTo
    if ([operator isEqualToString:kOperatorGreaterThanEqual]) {
        if (answerNumber && valueNumber) {
            if ((valueDouble - answerDouble) < DBL_EPSILON) {
                retValue = skipToValue;
            }
        }
    }
    
    //Less Than or EqualTo
    if ([operator isEqualToString:kOperatorGreaterThanEqual]) {
        if (answerNumber && valueNumber) {
            if ((answerDouble - valueDouble) < DBL_EPSILON) {
                retValue = skipToValue;
            }
        }
    }
    
    return retValue;
}


/*********************************************************************************/
#pragma mark - Conversion of SBBSurvey to ORKTask
/*********************************************************************************/

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

+ (ORKQuestionStep*) rkStepFromSBBSurveyQuestion: (SBBSurveyQuestion*) question
{
    ORKQuestionStep * retStep =[ORKQuestionStep questionStepWithIdentifier:question.identifier title:question.prompt answer:[self rkAnswerFormatFromSBBSurveyConstraints:question.constraints uiHint:question.uiHint]];

    if (question.promptDetail.length > 0) {
        retStep.text = question.promptDetail;
    }
    return retStep;
}

+ (ORKAnswerFormat*) rkAnswerFormatFromSBBSurveyConstraints: (SBBSurveyConstraints*) constraints uiHint: (NSString*) hint
{
    ORKAnswerFormat * retAnswer;
    
    if (!_dummyObject) {
        _dummyObject = [[APCDummyObject alloc] init];
    }
    
    NSString * selectorName = [self lookUpAnswerFormatMethod:NSStringFromClass([constraints class])];
    SEL selector = NSSelectorFromString(selectorName);
    
    NSMutableDictionary * objDict = [NSMutableDictionary dictionary];
    objDict[kConstraintsKey] = constraints;
    if (hint.length > 0) {
        objDict[kUiHintKey] = hint;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    retAnswer = (ORKAnswerFormat*) [_dummyObject performSelector:selector withObject:objDict];
#pragma clang diagnostic pop
    
    return retAnswer;
}

/*********************************************************************************/
#pragma mark - NSCoder, NSCopying Boiler Plate
/*********************************************************************************/

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.rules = [aDecoder decodeObjectForKey:@"rules"];
        self.rkSteps = [aDecoder decodeObjectForKey:@"rkSteps"];
        self.staticStepIdentifiers = [aDecoder decodeObjectForKey:@"staticStepIdentifiers"];
        self.dynamicStepIdentifiers = [self.staticStepIdentifiers mutableCopy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.rules forKey:@"rules"];
    [aCoder encodeObject:self.rkSteps forKey:@"rkSteps"];
    [aCoder encodeObject:self.staticStepIdentifiers forKey:@"staticStepIdentifiers"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    if (copy) {
        [copy setIdentifier:[self.identifier copyWithZone:zone]];
        [copy setRules:[self.rules copyWithZone:zone]];
        [copy setRkSteps:[self.rkSteps copyWithZone:zone]];
        [copy setStaticStepIdentifiers:[self.staticStepIdentifiers copyWithZone:zone]];
    }
    return copy;
}
@end

@implementation APCDummyObject

/*********************************************************************************/
#pragma mark - Answer Format Methods
/*********************************************************************************/
-(ORKAnswerFormat *)rkBooleanAnswerFormat:(NSDictionary *) __unused objectDictionary
{
    ORKAnswerFormat * retAnswer = [[ORKBooleanAnswerFormat alloc] init];
    return retAnswer;
}

- (ORKAnswerFormat *)rkDateAnswerFormat:(NSDictionary *)objectDictionary
{
    SBBSurveyConstraints * constraints = objectDictionary[kConstraintsKey];
    ORKAnswerFormat * retAnswer;
    if ([constraints isKindOfClass:[SBBDateTimeConstraints class]]) {
        retAnswer = [ORKDateAnswerFormat dateTimeAnswerFormat];
    }
    else if ([constraints isKindOfClass:[SBBDateConstraints class]]) {
        retAnswer = [ORKDateAnswerFormat dateAnswerFormat];
    }
    else if ([constraints isKindOfClass:[SBBTimeConstraints class]]) {
        retAnswer = [ORKTimeOfDayAnswerFormat timeOfDayAnswerFormat];
    }
    return retAnswer;
}

- (ORKAnswerFormat*) rkChoiceAnswerFormat:(NSDictionary *)objectDictionary
{
    SBBSurveyConstraints * constraints = objectDictionary[kConstraintsKey];
    ORKAnswerFormat * retAnswer;
    SBBMultiValueConstraints * localConstraints = (SBBMultiValueConstraints*)constraints;
    NSMutableArray * options = [NSMutableArray array];
    [localConstraints.enumeration enumerateObjectsUsingBlock:^(SBBSurveyQuestionOption* option, NSUInteger __unused idx, BOOL * __unused stop) {
        NSString * detailText = option.detail.length > 0 ? option.detail : nil;
        ORKTextChoice * choice = [ORKTextChoice choiceWithText:option.label detailText:detailText value:option.value];
        [options addObject: choice];
    }];
    if (localConstraints.allowOtherValue) {
        [options addObject:NSLocalizedString(@"Other", @"Spinner Option")];
    }
    retAnswer = [ORKAnswerFormat choiceAnswerFormatWithStyle:localConstraints.allowMultipleValue ? ORKChoiceAnswerStyleMultipleChoice : ORKChoiceAnswerStyleSingleChoice textChoices:options];
    return retAnswer;
}

- (ORKAnswerFormat *)rkNumericAnswerFormat:(NSDictionary *)objectDictionary
{
    SBBSurveyConstraints * constraints = objectDictionary[kConstraintsKey];
    NSString * uiHint = objectDictionary[kUiHintKey];
    ORKAnswerFormat * retValue;
    if ([constraints isKindOfClass:[SBBIntegerConstraints class]]) {
        SBBIntegerConstraints * integerConstraint = (SBBIntegerConstraints*) constraints;
        if (integerConstraint.maxValue && integerConstraint.minValue) {
            if ([uiHint isEqualToString:kSliderValue] && [self validConstraintsForSlider:integerConstraint]) {
                NSInteger stepValue = (integerConstraint.step != nil && [integerConstraint.step integerValue] > 0) ? [integerConstraint.step integerValue] : 1;
                NSInteger newStepValue = (NSInteger)((double)[integerConstraint.maxValue integerValue] - (double)[integerConstraint.minValue integerValue]) / 10.0;
                stepValue = MAX(newStepValue, stepValue);
                retValue = [ORKScaleAnswerFormat scaleAnswerFormatWithMaximumValue:[integerConstraint.maxValue integerValue] minimumValue:[integerConstraint.minValue integerValue] defaultValue:0 step:stepValue vertical:NO maximumValueDescription:nil minimumValueDescription:nil];
            }
            else {
                ORKNumericAnswerFormat * format = (integerConstraint.unit.length > 0) ? [ORKNumericAnswerFormat integerAnswerFormatWithUnit:integerConstraint.unit] : [ORKNumericAnswerFormat integerAnswerFormatWithUnit:nil];
                format.maximum = integerConstraint.maxValue;
                format.minimum = integerConstraint.minValue;
                retValue = format;
            }

        }
        else
        {
            retValue = (integerConstraint.unit.length > 0) ? [ORKNumericAnswerFormat integerAnswerFormatWithUnit:integerConstraint.unit] : [ORKNumericAnswerFormat integerAnswerFormatWithUnit:nil];
        }
    }
    else if ([constraints isKindOfClass:[SBBDecimalConstraints class]]) {
        SBBDecimalConstraints * decimalConstraint = (SBBDecimalConstraints*) constraints;
        if (decimalConstraint.maxValue && decimalConstraint.minValue) {
            ORKNumericAnswerFormat * format = (decimalConstraint.unit.length > 0) ? [ORKNumericAnswerFormat decimalAnswerFormatWithUnit:decimalConstraint.unit] : [ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil];
            format.maximum = decimalConstraint.maxValue;
            format.minimum = decimalConstraint.minValue;
            retValue = format;
        }
        else
        {
            retValue = (decimalConstraint.unit.length > 0) ? [ORKNumericAnswerFormat decimalAnswerFormatWithUnit:decimalConstraint.unit] : [ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil];
        }
    }
    return retValue;
}

- (BOOL) validConstraintsForSlider: (SBBIntegerConstraints*) integerConstraint
{
    BOOL retValue = YES;
    NSInteger maxValue = (NSInteger)[integerConstraint.maxValue doubleValue];
    NSInteger minValue = (NSInteger)[integerConstraint.minValue doubleValue];
    NSInteger range = maxValue - minValue;
    NSInteger stepValue = (integerConstraint.step != nil && [integerConstraint.step integerValue] > 0) ? [integerConstraint.step integerValue] : 1;
    NSInteger newStepValue = (NSInteger)round(((double)range / 10.0));
    stepValue = MAX(newStepValue, stepValue);
    double noOfSteps = (double) range / (double) stepValue;
    if ([self hasDecimals:noOfSteps]) {
        retValue = NO;
    }
    else if (noOfSteps > 10)
    {
        retValue = NO;
    }
    return retValue;
}

- (BOOL) hasDecimals: (double) f
{
     return (f-(NSInteger)f != 0);
}

BOOL CGFloatHasDecimals(float f) {
    return (f-(int)f != 0);
}

- (ORKAnswerFormat *)rkTextAnswerFormat:(NSDictionary *) __unused objectDictionary
{
    return [ORKTextAnswerFormat textAnswerFormat];
}

- (ORKAnswerFormat *)rkTimeIntervalAnswerFormat:(NSDictionary *) __unused objectDictionary
{
    return [ORKTimeIntervalAnswerFormat timeIntervalAnswerFormat];
}


@end
