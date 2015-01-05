//
//  APCSmartSurveyTask.m
//  APCAppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
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

@interface APCSmartSurveyTask () <NSSecureCoding, NSCopying>

@property (nonatomic, strong) NSString * identifier;
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
        [survey.questions enumerateObjectsUsingBlock:^(SBBSurveyQuestion* obj, NSUInteger idx, BOOL *stop) {
            
            self.rkSteps[obj.identifier] = [APCSmartSurveyTask rkStepFromSBBSurveyQuestion:obj];
            
            [self.staticStepIdentifiers addObject:obj.identifier];
            [self.setOfIdentifiers addObject:obj.identifier];
            
            NSArray * rulesArray = [[obj constraints] rules];
            if (rulesArray) {
                self.rules[obj.identifier] = [self createArrayOfDictionaryForRules:rulesArray];
            }

        }];
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
    [rulesArray enumerateObjectsUsingBlock:^(SBBSurveyRule * rule, NSUInteger idx, BOOL *stop) {
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


- (RKSTStep *)stepAfterStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    [self refillDynamicStepIdentifiersWithCurrentStepIdentifier:step.identifier];
    
    //If Step has rules, process answer. Otherwise keep moving
    NSArray * rulesForThisStep = self.rules[step.identifier];
    NSString * skipToStep = nil;
    if (rulesForThisStep.count) {
        RKSTStepResult * stepResult = (RKSTStepResult*) [result resultForIdentifier:step.identifier];
        id firstResult = stepResult.results.firstObject;
        if (firstResult == nil || [firstResult isKindOfClass:[RKSTQuestionResult class]]) {
            skipToStep = [self processRules:rulesForThisStep forAnswer:[firstResult answer]];
        }
        //If there is new skipToStep then skip to that step
        if (skipToStep) {
            [self adjustDynamicStepIdentifersForSkipToStep:skipToStep from:step.identifier];
        }
    }
    
    NSString * nextStepIdentifier = [self nextStepIdentifier:YES currentIdentifier:step.identifier];
    return nextStepIdentifier? self.rkSteps[nextStepIdentifier] : nil;
}

- (RKSTStep *)stepBeforeStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    [self refillDynamicStepIdentifiersWithCurrentStepIdentifier:step.identifier];
    NSString * nextStepIdentifier = [self nextStepIdentifier:NO currentIdentifier:step.identifier];
    return nextStepIdentifier? self.rkSteps[nextStepIdentifier] : nil;
}

- (RKSTTaskProgress)progressOfCurrentStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    return RKSTTaskProgressMake([self.staticStepIdentifiers indexOfObject: step.identifier] + 1, self.staticStepIdentifiers.count);
}

/*********************************************************************************/
#pragma mark - Array Processing
/*********************************************************************************/
- (NSString *) nextStepIdentifier: (BOOL) after currentIdentifier: (NSString*) currentIdentifier
{
    if (currentIdentifier == nil && after) {
        return self.dynamicStepIdentifiers[0];
    }
    NSInteger currentIndex = [self.dynamicStepIdentifiers indexOfObject: currentIdentifier];
    NSAssert(currentIndex != NSNotFound, @"Step Not Found. Should not get here.");
    NSInteger newIndex = NSNotFound;
    if (after) {
        if (currentIndex+1 < self.dynamicStepIdentifiers.count) {
            newIndex = currentIndex + 1;
        }
    }
    else
    {
        if ((currentIndex - 1) >= 0) {
            newIndex = currentIndex -1;
        }
    }
    return (newIndex != NSNotFound) ? self.dynamicStepIdentifiers[newIndex] : nil;
}

- (void) adjustDynamicStepIdentifersForSkipToStep: (NSString*) skipToStep from: (NSString*) currentStep
{
    NSInteger currentIndex = [self.dynamicStepIdentifiers indexOfObject:currentStep];
    NSInteger skipToIndex = [self.dynamicStepIdentifiers indexOfObject:skipToStep];
    NSAssert(currentIndex != NSNotFound, @"Should not happen");
    NSAssert(skipToIndex != NSNotFound, @"Should not happen");
    
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
     *      Date: RKSTDateAnswer with date components having (NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay). NOT SUPPORTED
     *      Time: RKSTDateAnswer with date components having (NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond). NOT SUPPORTED
     *      DateAndTime: RKSTDateAnswer with date components having (NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond). NOT SUPPORTED
     *      Time Interval: NSNumber, containing a time span in seconds. SUPPORTED
     */
    __block NSString * skipToIdentifier = nil;
    if (answer == nil || [answer isKindOfClass:[NSNumber class]] || [answer isKindOfClass:[NSString class]]) {
        [rules enumerateObjectsUsingBlock:^(SBBSurveyRule * rule, NSUInteger idx, BOOL *stop) {
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
//        answerNumber = [answer isEqualToString:@"true"] ? @(YES) : answerNumber;
//        answerNumber = [answer isEqualToString:@"false"] ? @(NO) : answerNumber;
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
#pragma mark - Conversion of SBBSurvey to RKSTTask
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

+ (RKSTQuestionStep*) rkStepFromSBBSurveyQuestion: (SBBSurveyQuestion*) question
{
    RKSTQuestionStep * retStep =[RKSTQuestionStep questionStepWithIdentifier:question.identifier title:question.prompt answer:[self rkAnswerFormatFromSBBSurveyConstraints:question.constraints]];
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
    }
    else if ([constraints isKindOfClass:[SBBDateConstraints class]]) {
        retAnswer = [RKSTDateAnswerFormat dateAnswer];
    }
    else if ([constraints isKindOfClass:[SBBTimeConstraints class]]) {
        retAnswer = [RKSTDateAnswerFormat timeAnswer];
    }
    return retAnswer;
}

- (RKSTAnswerFormat*) rkChoiceAnswerFormat: (SBBSurveyConstraints*) constraints
{
    RKSTAnswerFormat * retAnswer;
    SBBMultiValueConstraints * localConstraints = (SBBMultiValueConstraints*)constraints;
    NSMutableArray * options = [NSMutableArray array];
    [localConstraints.enumeration enumerateObjectsUsingBlock:^(SBBSurveyQuestionOption* option, NSUInteger idx, BOOL *stop) {
        //TODO: Address this issue with Apple
        [options addObject: [RKSTTextAnswerOption optionWithText:[NSString stringWithFormat:@"Answer %lu", idx+1] detailText:option.label value:option.value]];
    }];
    if (localConstraints.allowOtherValue) {
        [options addObject:NSLocalizedString(@"Other", @"Spinner Option")];
    }
    retAnswer = [RKSTChoiceAnswerFormat choiceAnswerWithTextOptions:options style: localConstraints.allowMultipleValue ? RKChoiceAnswerStyleMultipleChoice : RKChoiceAnswerStyleSingleChoice];
    return retAnswer;
}

- (RKSTAnswerFormat *)rkNumericAnswerFormat:(SBBSurveyConstraints *)constraints
{
    RKSTAnswerFormat * retValue;
    if ([constraints isKindOfClass:[SBBIntegerConstraints class]]) {
        SBBIntegerConstraints * integerConstraint = (SBBIntegerConstraints*) constraints;
        if (integerConstraint.maxValue && integerConstraint.minValue) {
            retValue = [RKSTScaleAnswerFormat scaleAnswerWithMaxValue:integerConstraint.maxValueValue minValue:integerConstraint.minValueValue];
        }
        else
        {
            retValue = [RKSTNumericAnswerFormat integerAnswerWithUnit:nil];
        }
    }
    else if ([constraints isKindOfClass:[SBBDecimalConstraints class]]) {
        SBBDecimalConstraints * decimalConstraint = (SBBDecimalConstraints*) constraints;
        if (decimalConstraint.maxValue && decimalConstraint.minValue) {
            retValue = [RKSTScaleAnswerFormat scaleAnswerWithMaxValue:decimalConstraint.maxValueValue minValue:decimalConstraint.minValueValue];
        }
        else
        {
            retValue = [RKSTNumericAnswerFormat decimalAnswerWithUnit:nil];
        }
    }
    return retValue;
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
