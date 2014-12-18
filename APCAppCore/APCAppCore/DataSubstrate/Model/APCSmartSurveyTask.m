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
                self.rules[obj.identifier] = rulesArray;
            }

        }];
        NSAssert((self.staticStepIdentifiers.count == self.setOfIdentifiers.count), @"Duplicate Identifiers in Survey! Please rename them!");
        //For Debugging duplicates. Copy paste below commented line in lldb to look for duplicates
        //[self.staticStepIdentifiers sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
        
        self.dynamicStepIdentifiers = [self.staticStepIdentifiers mutableCopy];
    }
    return self;
}

- (NSString *) nextStepIdentifier: (BOOL) after currentIdentifier: (NSString*) currentIdentifier
{
    if (currentIdentifier == nil && after) {
        return self.staticStepIdentifiers[0];
    }
    NSInteger currentIndex = [self.staticStepIdentifiers indexOfObject: currentIdentifier];
    NSAssert(currentIndex != NSNotFound, @"Step Not Found. Should not get here.");
    NSInteger newIndex = NSNotFound;
    if (after) {
        if (currentIndex+1 < self.staticStepIdentifiers.count) {
            newIndex = currentIndex + 1;
        }
    }
    else
    {
        if ((currentIndex - 1) >= 0) {
            newIndex = currentIndex -1;
        }
    }
    return (newIndex != NSNotFound) ? self.staticStepIdentifiers[newIndex] : nil;
}

- (RKSTStep *)stepAfterStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    //STEP 1: Refill dynamic Array from current step forward
//    [self refillDynamicStepIdentifiersWithCurrentStepIdentifier:step.identifier];
    
    //STEP 2: Remove unnecessary steps
    NSString * nextStepIdentifier = [self nextStepIdentifier:YES currentIdentifier:step.identifier];
    return nextStepIdentifier? self.rkSteps[nextStepIdentifier] : nil;
}

- (RKSTStep *)stepBeforeStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    NSString * nextStepIdentifier = [self nextStepIdentifier:NO currentIdentifier:step.identifier];
    return nextStepIdentifier? self.rkSteps[nextStepIdentifier] : nil;
}

- (RKSTTaskProgress)progressOfCurrentStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    return RKSTTaskProgressMake([self.staticStepIdentifiers indexOfObject: step.identifier] + 1, self.staticStepIdentifiers.count);
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
