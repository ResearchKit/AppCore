/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


 
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

@property (nonatomic, strong) ORKInstructionStep *introductionStep;
@property (nonatomic, strong) ORKQuestionStep *medicationStep;
@property (nonatomic, strong) ORKFormStep *medicationListStep;
@property (nonatomic, strong) ORKQuestionStep *healthDeviceStep;
@property (nonatomic, strong) ORKQuestionStep *otherAppsStep;

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


- (NSString *)name {
    return NSLocalizedString(@"Baseline Survey", @"Baseline Survey");
}

#pragma mark - Actions

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *)result
{
    ORKStep *nextStep = nil;
    
    NSString *stepIdentifier = step.identifier;
    
    if (step == nil) {
        nextStep = self.introductionStep;
    } else if ([stepIdentifier isEqualToString:self.introductionStep.identifier]) {
        nextStep = self.medicationStep;
    } else if ([stepIdentifier isEqualToString:self.medicationStep.identifier]) {
        ORKStepResult *stepResult = (ORKStepResult *)[result resultForIdentifier:stepIdentifier];
        ORKBooleanQuestionResult *questionResult = (ORKBooleanQuestionResult *)[stepResult firstResult];
        
        
        if (questionResult == nil || questionResult.booleanAnswer == nil || questionResult.booleanAnswer == (NSNumber *)[NSNull null]) {
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

- (ORKStep *)stepBeforeStep:(ORKStep *)step withResult:(ORKTaskResult *)result
{
    ORKStep *previousStep = nil;
    
    NSString *stepIdentifier = step.identifier;
    
    if (stepIdentifier == nil || stepIdentifier == self.introductionStep.identifier) {
        previousStep = nil;
    } else if ([stepIdentifier isEqualToString:self.medicationStep.identifier]) {
        previousStep = self.introductionStep;
    } else if ([stepIdentifier isEqualToString:self.medicationListStep.identifier]) {
        previousStep = self.medicationStep;
    } else if ([stepIdentifier isEqualToString:self.healthDeviceStep.identifier]) {
        ORKBooleanQuestionResult *questionResult = (ORKBooleanQuestionResult *)[(ORKStepResult *)[result stepResultForStepIdentifier:self.medicationStep.identifier] firstResult];
        
      

        
        if (questionResult == nil || questionResult.booleanAnswer == nil || questionResult.booleanAnswer == (NSNumber *)[NSNull null]) {
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

- (ORKStep *)stepWithIdentifier:(NSString *)identifier {
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

- (ORKTaskProgress)progressOfCurrentStep:(ORKStep *)step withResult:(ORKTaskResult *)result
{
    ORKTaskProgress taskProgress;

    if (!step) {
        taskProgress.current = 0;
    } else {
        taskProgress.current = [self.stepIdentifiers indexOfObject:step.identifier];
    }

    taskProgress.total = [self.stepIdentifiers count];
    
    return taskProgress;
}

#pragma mark - Step Accessors

- (ORKInstructionStep *)introductionStep
{
    if (!_introductionStep) {
        _introductionStep = [[ORKInstructionStep alloc] initWithIdentifier:kBaselineStepIntroduction];
        _introductionStep.title = NSLocalizedString(@"Baseline Survey", @"Baseline Survey");
    }
    
    return _introductionStep;
}

- (ORKQuestionStep *)medicationStep
{
    if (!_medicationStep) {
        _medicationStep = [[ORKQuestionStep alloc] initWithIdentifier:kBaselineStepMedication];
        _medicationStep.title = NSLocalizedString(@"Do you take any diabetes medications?",
                                                      @"Do you take any diabetes medications?");
        _medicationStep.answerFormat = [ORKBooleanAnswerFormat new];
        _medicationStep.optional = NO;
    }
    
    return _medicationStep;
}

- (ORKFormStep *)medicationListStep
{
    if (!_medicationListStep) {
        _medicationListStep = [[ORKFormStep alloc] initWithIdentifier:kBaselineStepMedicationList title:NSLocalizedString(@"Medication Details", @"Medication Details")
                                                              text:nil];
        _medicationListStep.optional = NO;
        NSMutableArray *items = [NSMutableArray array];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kMedicationListItemName
                                                                     text:NSLocalizedString(@"Name of medication", @"Name of medication")
                                                             answerFormat:[ORKTextAnswerFormat textAnswerFormat]];
            item.placeholder = @"For example: Aspirin";
            [items addObject:item];
        }
        
        {
            ORKNumericAnswerFormat *format = [[ORKNumericAnswerFormat alloc ]initWithStyle:ORKNumericAnswerStyleInteger unit:@"mg"];
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kMedicationListItemDose
                                                                     text:NSLocalizedString(@"Dose", @"Dose")
                                                             answerFormat:format];
            [items addObject:item];
        }
        {
            ORKTextChoiceAnswerFormat *format = [ORKTextChoiceAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                                         textChoices:@[
                                                                                                   @"Daily",
                                                                                                   @"Twice a day",
                                                                                                   @"Before meals",
                                                                                                   @"After meals"]];
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kMedicationListItemFrequency
                                                                     text:NSLocalizedString(@"Frequency", @"Frequency")
                                                             answerFormat:format];
            [items addObject:item];
        }
        {
            ORKTextChoiceAnswerFormat *format = [ORKTextChoiceAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                                         textChoices:@[
                                                                                                   @"Oral",
                                                                                                   @"Injection"]];
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:kMedicationListItemIntake
                                                                     text:@"Type of intake"
                                                             answerFormat:format];
            [items addObject:item];
        }
        
        _medicationListStep.formItems = items;
    }
    
    return _medicationListStep;
}

- (ORKQuestionStep *)healthDeviceStep
{
    if (!_healthDeviceStep) {
        _healthDeviceStep = [[ORKQuestionStep alloc] initWithIdentifier:kBaselineStepHealthDevice];
        _healthDeviceStep.title = NSLocalizedString(@"Do you use any health related devices?",
                                                    @"Do you use any health related devices?");
        _healthDeviceStep.answerFormat = [ORKBooleanAnswerFormat new];
    }
    
    return _healthDeviceStep;
}

- (ORKQuestionStep *)otherAppsStep
{
    if (!_otherAppsStep) {
        _otherAppsStep = [[ORKQuestionStep alloc] initWithIdentifier:kBaselineStepOtherApps];
        _otherAppsStep.title = NSLocalizedString(@"Do you use any diet tracking apps or devices?",
                                                 @"Do you use any diet tracking apps or devices?");
        _otherAppsStep.answerFormat = [ORKBooleanAnswerFormat new];
    }
    
    return _otherAppsStep;
}

@end

