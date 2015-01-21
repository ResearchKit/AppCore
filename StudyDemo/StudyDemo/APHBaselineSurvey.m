// 
//  APHBaselineSurvey.m 
//  Diabetes 
// 
//  Copyright (c) 2014 Apple, Inc. All rights reserved. 
// 
 
#import "APHBaselineSurvey.h"

static NSString *kBaselineStepIntroduction   = @"baselineStepIntroduction";
static NSString *kBaselineStepMedication     = @"baselineStepMedication";
static NSString *kBaselineStepMedicationList = @"baselineStepMedicationList";
static NSString *kBaselineStepHealthDevice   = @"baselineStepHealthDevice";
static NSString *kBaselineStepOtherApps      = @"baselineStepOtherApps";

static NSString *kMedicationListItemName = @"baselineMedicationListItemName";
static NSString *kMedicationListItemDose = @"baselineMedicationListItemDose";
static NSString *kMedicationListItemFrequency = @"baselineMedicationListItemFrequency";
static NSString *kMedicationListItemIntake    = @"baselineMedicationListItemIntake";

@interface APHBaselineSurvey()

@property (nonatomic, strong) RKSTInstructionStep *introductionStep;
@property (nonatomic, strong) RKSTQuestionStep *medicationStep;
@property (nonatomic, strong) RKSTFormStep *medicationListStep;
@property (nonatomic, strong) RKSTQuestionStep *healthDeviceStep;
@property (nonatomic, strong) RKSTQuestionStep *otherAppsStep;

@property (nonatomic, strong) NSArray *stepIdentifiers;

@end

@implementation APHBaselineSurvey


#pragma mark - Initialization

- (instancetype)initWithIdentifier:(NSString *)identifier steps:(NSArray *)steps
{
    self = [super initWithIdentifier:identifier steps:nil];
    if (self) {
        _stepIdentifiers = @[
                             kBaselineStepIntroduction,
                             kBaselineStepMedication,
                             kBaselineStepMedicationList,
                             kBaselineStepHealthDevice,
                             kBaselineStepOtherApps];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _stepIdentifiers = @[
                             kBaselineStepIntroduction,
                             kBaselineStepMedication,
                             kBaselineStepMedicationList,
                             kBaselineStepHealthDevice,
                             kBaselineStepOtherApps];
    }
    return self;
}


- (NSString *)name{
    return NSLocalizedString(@"Baseline Survey", @"Baseline Survey");
}

#pragma mark - Actions

- (RKSTStep *)stepAfterStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    RKSTStep *nextStep = nil;
    
    NSString *stepIdentifier = step.identifier;
    
    if (step == nil) {
        nextStep = self.introductionStep;
    } else if ([stepIdentifier isEqualToString:self.introductionStep.identifier]) {
        nextStep = self.medicationStep;
    } else if ([stepIdentifier isEqualToString:self.medicationStep.identifier]) {
        RKSTStepResult *stepResult = (RKSTStepResult*)[result resultForIdentifier:stepIdentifier];
        RKSTBooleanQuestionResult *questionResult = (RKSTBooleanQuestionResult *)[stepResult firstResult];
        
        
        if (questionResult == nil || questionResult.booleanAnswer == nil || questionResult.booleanAnswer == (NSNumber*)[NSNull null]) {
            nextStep = nil;
        } else {
            if ([questionResult.booleanAnswer boolValue]) {
                nextStep = self.medicationListStep;
            } else {
                nextStep = self.healthDeviceStep;
            }
        }
        
    } else if ([stepIdentifier isEqualToString:self.medicationListStep.identifier]) {
        nextStep = self.healthDeviceStep;
    } else if ([stepIdentifier isEqualToString:self.healthDeviceStep.identifier]) {
        nextStep = self.otherAppsStep;
    }
    
    return nextStep;
}

- (RKSTStep *)stepBeforeStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    RKSTStep *previousStep = nil;
    
    NSString *stepIdentifier = step.identifier;
    
    if (stepIdentifier == nil || stepIdentifier == self.introductionStep.identifier) {
        previousStep = nil;
    } else if ([stepIdentifier isEqualToString:self.medicationStep.identifier]) {
        previousStep = self.introductionStep;
    } else if ([stepIdentifier isEqualToString:self.medicationListStep.identifier]) {
        previousStep = self.medicationStep;
    } else if ([stepIdentifier isEqualToString:self.healthDeviceStep.identifier]) {
        RKSTBooleanQuestionResult *questionResult = (RKSTBooleanQuestionResult *)[(RKSTStepResult *)[result stepResultForStepIdentifier:self.medicationStep.identifier] firstResult];
        
      

        
        if (questionResult == nil || questionResult.booleanAnswer == nil || questionResult.booleanAnswer == (NSNumber*)[NSNull null]) {
            previousStep = nil;
        } else {
            if ([questionResult.booleanAnswer boolValue]) {
                previousStep = self.medicationListStep;
            } else {
                previousStep = self.medicationStep;
            }
        }
        
    } else if ([stepIdentifier isEqualToString:self.otherAppsStep.identifier]) {
        previousStep = self.healthDeviceStep;
    }
    
    return previousStep;
}

- (RKSTStep *)stepWithIdentifier:(NSString *)identifier{
    if ([identifier isEqualToString:kBaselineStepIntroduction]) {
        return self.introductionStep;
    } else if([identifier isEqualToString:kBaselineStepMedication]) {
        return self.medicationStep;
    } else if([identifier isEqualToString:kBaselineStepMedicationList]) {
        return self.medicationListStep;
    } else if([identifier isEqualToString:kBaselineStepHealthDevice]) {
        return self.healthDeviceStep;
    } else if([identifier isEqualToString:kBaselineStepOtherApps]) {
        return self.otherAppsStep;
    }
    return nil;
}

#pragma mark - Progress

- (RKSTTaskProgress)progressOfCurrentStep:(RKSTStep *)step withResult:(RKSTTaskResult *)result
{
    RKSTTaskProgress taskProgress;

    if (!step) {
        taskProgress.current = 0;
    } else {
        taskProgress.current = [self.stepIdentifiers indexOfObject:step.identifier];
    }

    taskProgress.total = [self.stepIdentifiers count];
    
    return taskProgress;
}

#pragma mark - Step Accessors

- (RKSTInstructionStep *)introductionStep
{
    if (!_introductionStep) {
        _introductionStep = [[RKSTInstructionStep alloc] initWithIdentifier:kBaselineStepIntroduction];
        _introductionStep.title = NSLocalizedString(@"Baseline Survey", @"Baseline Survey");
    }
    
    return _introductionStep;
}

- (RKSTQuestionStep *)medicationStep
{
    if (!_medicationStep) {
        _medicationStep = [[RKSTQuestionStep alloc] initWithIdentifier:kBaselineStepMedication];
        _medicationStep.title = NSLocalizedString(@"Do you take any diabetes medications?",
                                                      @"Do you take any diabetes medications?");
        _medicationStep.answerFormat = [RKSTBooleanAnswerFormat new];
        _medicationStep.optional = NO;
    }
    
    return _medicationStep;
}

- (RKSTFormStep *)medicationListStep
{
    if (!_medicationListStep) {
        _medicationListStep = [[RKSTFormStep alloc] initWithIdentifier:kBaselineStepMedicationList title:NSLocalizedString(@"Medication Details", @"Medication Details")
                                                              text:nil];
        _medicationListStep.optional = NO;
        NSMutableArray *items = [NSMutableArray array];
        
        {
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kMedicationListItemName
                                                                     text:NSLocalizedString(@"Name of medication", @"Name of medication")
                                                             answerFormat:[RKSTTextAnswerFormat textAnswerFormat]];
            item.placeholder = @"For example: Aspirin";
            [items addObject:item];
        }
        
        {
            RKSTNumericAnswerFormat *format = [[RKSTNumericAnswerFormat alloc ]initWithStyle:RKNumericAnswerStyleInteger unit:@"mg"];
            
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kMedicationListItemDose
                                                                     text:NSLocalizedString(@"Dose", @"Dose")
                                                             answerFormat:format];
            [items addObject:item];
        }
        {
            RKSTTextChoiceAnswerFormat *format = [RKSTTextChoiceAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleSingleChoice
                                                                                         textChoices:@[
                                                                                                   @"Daily",
                                                                                                   @"Twice a day",
                                                                                                   @"Before meals",
                                                                                                   @"After meals"]];
            
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kMedicationListItemFrequency
                                                                     text:NSLocalizedString(@"Frequency", @"Frequency")
                                                             answerFormat:format];
            [items addObject:item];
        }
        {
            RKSTTextChoiceAnswerFormat *format = [RKSTTextChoiceAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleSingleChoice
                                                                                         textChoices:@[
                                                                                                   @"Oral",
                                                                                                   @"Injection"]];
            RKSTFormItem *item = [[RKSTFormItem alloc] initWithIdentifier:kMedicationListItemIntake
                                                                     text:@"Type of intake"
                                                             answerFormat:format];
            [items addObject:item];
        }
        
        _medicationListStep.formItems = items;
    }
    
    return _medicationListStep;
}

- (RKSTQuestionStep *)healthDeviceStep
{
    if (!_healthDeviceStep) {
        _healthDeviceStep = [[RKSTQuestionStep alloc] initWithIdentifier:kBaselineStepHealthDevice];
        _healthDeviceStep.title = NSLocalizedString(@"Do you use any health related devices?",
                                                    @"Do you use any health related devices?");
        _healthDeviceStep.answerFormat = [RKSTBooleanAnswerFormat new];
    }
    
    return _healthDeviceStep;
}

- (RKSTQuestionStep *)otherAppsStep
{
    if (!_otherAppsStep) {
        _otherAppsStep = [[RKSTQuestionStep alloc] initWithIdentifier:kBaselineStepOtherApps];
        _otherAppsStep.title = NSLocalizedString(@"Do you use any diet tracking apps or devices?",
                                                 @"Do you use any diet tracking apps or devices?");
        _otherAppsStep.answerFormat = [RKSTBooleanAnswerFormat new];
    }
    
    return _otherAppsStep;
}

@end

