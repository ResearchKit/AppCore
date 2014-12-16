//
//  APCSmartSurveyTask.m
//  APCAppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCSmartSurveyTask.h"
#import <ResearchKit/ResearchKit.h>
#import <BridgeSDK/BridgeSDK.h>



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
@property (nonatomic, strong) RKSTOrderedTask * orderedTask;

@end

@implementation APCSmartSurveyTask

- (instancetype)initWithIdentifier: (NSString*) identifier survey:(SBBSurvey *)survey
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        NSMutableArray * stepsArray = [NSMutableArray array];
        [survey.questions enumerateObjectsUsingBlock:^(SBBSurveyQuestion* obj, NSUInteger idx, BOOL *stop) {
            [stepsArray addObject:[APCSmartSurveyTask rkStepFromSBBSurveyQuestion:obj]];
        }];
        self.orderedTask = [[RKSTOrderedTask alloc] initWithIdentifier:self.identifier steps:stepsArray];
    }
    return self;
}

- (RKSTStep *)stepAfterStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    return [self.orderedTask stepAfterStep:step withResult:result];
}

- (RKSTStep *)stepBeforeStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    return [self.orderedTask stepBeforeStep:step withResult:result];
}

- (RKSTTaskProgress)progressOfCurrentStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    if ([self.orderedTask respondsToSelector:@selector(progressOfCurrentStep:withResult:)]) {
        return [self.orderedTask progressOfCurrentStep:step withResult:result];
    }
    return RKSTTaskProgressMake(0, 0);
}


- (NSArray *)steps
{
    return self.orderedTask.steps;
}

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
    RKSTQuestionStep * retStep =[RKSTQuestionStep questionStepWithIdentifier:question.guid title:question.prompt answer:[self rkAnswerFormatFromSBBSurveyConstraints:question.constraints]];
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
        self.orderedTask = [aDecoder decodeObjectForKey:@"orderedTask"];
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.orderedTask forKey:@"orderedTask"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setOrderedTask:[self.orderedTask copyWithZone:zone]];
        [copy setIdentifier:[self.identifier copyWithZone:zone]];
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
