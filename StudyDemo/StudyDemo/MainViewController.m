//
//  MainViewController.m
//  StudyDemo
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "MainViewController.h"
#import <ResearchKit/ResearchKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DynamicTask.h"
#import "CustomRecorder.h"
#import "AppDelegate.h"
#import "AppearanceControlViewController.h"

// #define DEMO


@interface MainViewController ()<RKTaskViewControllerDelegate>
{
    id<RKTaskDefaultResultProvider> _lastRouteResult;
}

@property (nonatomic, strong) RKTaskViewController* taskVC;
@property (nonatomic, strong) RKStudy* study;
@property (nonatomic, strong) RKDataArchive *taskArchive;

@end

@implementation MainViewController


- (instancetype)initWithStudy:(RKStudy*)study
{
    self = [self initWithNibName:nil bundle:nil];
    if (self)
    {
        self.study = study;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIView appearance] setTintColor:[UIColor orangeColor]];
    
    NSMutableDictionary *buttons = [NSMutableDictionary dictionary];
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showConsent:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Consent" forState:UIControlStateNormal];
        buttons[@"consent"] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showConsentSignature:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Consent Signature" forState:UIControlStateNormal];
        buttons[@"consent_signature"] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(pickDates:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Date Survey" forState:UIControlStateNormal];
        buttons[@"dates"] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showAudioTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Audio Task" forState:UIControlStateNormal];
        buttons[@"audio"] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showMiniForm:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Mini Form" forState:UIControlStateNormal];
        buttons[@"form"] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showSelectionSurvey:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Selection Survey" forState:UIControlStateNormal];
        buttons[@"selection_survey"] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showGAIT:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"GAIT" forState:UIControlStateNormal];
        buttons[@"gait"] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showEQ5D:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"EQ-5D-5L" forState:UIControlStateNormal];
        buttons[@"eq5d"] = button;
    }
    
    
#ifndef DEMO
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Show Task" forState:UIControlStateNormal];
        buttons[@"task"] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showDynamicTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Dynamic Task" forState:UIControlStateNormal];
        buttons[@"dyntask"] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showInteruptTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Interruptible Task" forState:UIControlStateNormal];
        buttons[@"interruptible"] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(joinStudy:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Join Study" forState:UIControlStateNormal];
        buttons[@"join"] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(leaveStudy:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Leave Study" forState:UIControlStateNormal];
        buttons[@"leave"] = button;
    }
    
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(controlAppearance:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Appearance" forState:UIControlStateNormal];
        buttons[@"appearance"] = button;
    }
    
#endif
    
    [buttons enumerateKeysAndObjectsUsingBlock:^(id key, UIView *obj, BOOL *stop) {
        [obj setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:obj];
    }];
    
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:buttons[@"consent"]
                                                          attribute:NSLayoutAttributeBaseline
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:buttons[@"consent_signature"]
                                                          attribute:NSLayoutAttributeBaseline
                                                         multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:buttons[@"dates"]
                                                          attribute:NSLayoutAttributeBaseline
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:buttons[@"selection_survey"]
                                                          attribute:NSLayoutAttributeBaseline
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:buttons[@"audio"]
                                                          attribute:NSLayoutAttributeBaseline
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:buttons[@"form"]
                                                          attribute:NSLayoutAttributeBaseline
                                                         multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:buttons[@"eq5d"]
                                                          attribute:NSLayoutAttributeBaseline
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:buttons[@"gait"]
                                                          attribute:NSLayoutAttributeBaseline
                                                         multiplier:1 constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[consent][consent_signature(==consent)]|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dates][selection_survey(==dates)]|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[eq5d][gait(==eq5d)]|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[audio][form(==audio)]|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    
#ifndef DEMO
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:buttons[@"join"]
                                                          attribute:NSLayoutAttributeBaseline
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:buttons[@"leave"]
                                                          attribute:NSLayoutAttributeBaseline
                                                         multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:buttons[@"task"]
                                                          attribute:NSLayoutAttributeBaseline
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:buttons[@"dyntask"]
                                                          attribute:NSLayoutAttributeBaseline
                                                         multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:buttons[@"interruptible"]
                                                          attribute:NSLayoutAttributeBaseline
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:buttons[@"appearance"]
                                                          attribute:NSLayoutAttributeBaseline
                                                         multiplier:1 constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[join][leave(==join)]|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[task][dyntask(==task)]|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[interruptible][appearance(==interruptible)]|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[consent][dates(==consent)][audio(==consent)][eq5d(==consent)][task(==consent)][interruptible(==consent)][join(==consent)]-20-|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    
#else
    
    //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[eq5d]|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[consent]-30-[dates(==consent)]-30-[audio(==consent)]-30-[eq5d(==consent)]-100-|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    
    
#endif
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
}

- (void)dealloc
{
    [self.taskArchive resetContent];
}

#pragma mark - button handlers

-(void)joinStudy:(id)sender
{
    NSError *err = nil;
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setJustJoined:YES];
    if (![self.study updateParticipating:YES withJoinDate:[NSDate date] error:&err])
    {
        NSLog(@"Could not join %@: %@", self.study, err);
    }
}


-(void)leaveStudy:(id)sender
{
    NSError *err = nil;
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setJustJoined:NO];
    if (![self.study updateParticipating:NO withJoinDate:nil error:&err])
    {
        NSLog(@"Could not leave %@: %@", self.study, err);
    }
}

- (IBAction)pickDates:(id)sender {
    NSMutableArray* steps = [NSMutableArray new];
    {
        RKIntroductionStep* step = [[RKIntroductionStep alloc] initWithIdentifier:@"iid_001" name:@"intro step"];
        step.caption = @"Date Survey";
        [steps addObject:step];
    }
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_007"
                                                                     name:@"date"
                                                                 question:@"When is your birthday?"
                                                                   answer:[RKDateAnswerFormat dateAnswer]];
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_008"
                                                                     name:@"time"
                                                                 question:@"What time do you get up?"
                                                                   answer:[RKDateAnswerFormat timeAnswer]];
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_009"
                                                                     name:@"date & time"
                                                                 question:@"When is your next meeting?"
                                                                   answer:[RKDateAnswerFormat dateTimeAnswer]];
        [steps addObject:step];
        
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_006"
                                                                     name:@"Time Interval"
                                                                 question:@"How long did it take to fall asleep last night?"
                                                                   answer:[RKTimeIntervalAnswerFormat timeIntervalAnswer]];
        [steps addObject:step];
    }
    
    RKTask* task = [[RKTask alloc] initWithName:@"Dates" identifier:@"dates_001" steps:steps];
    
    self.taskVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    [self beginTask:task];
}

- (IBAction)showSelectionSurvey:(id)sender{
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKIntroductionStep* step = [[RKIntroductionStep alloc] initWithIdentifier:@"iid_001" name:@"intro step"];
        step.caption = @"Selection Survey";
        [steps addObject:step];
    }
    
    {
        RKNumericAnswerFormat* format = [RKNumericAnswerFormat integerAnswerWithUnit:@"years"];
        format.minimum = @(0);
        format.maximum = @(199);
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_001" name:@"HowOld" question:@"How old are you?" answer:format];
        [steps addObject:step];
    }
    
    {
        RKBooleanAnswerFormat* format = [RKBooleanAnswerFormat new];
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_001b" name:@"Boolean" question:@"Do you consent to a background check?" answer:format];
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_003"
                                                                     name:@"Choices ONE"
                                                                 question:@"How many hours did you sleep last night?"
                                                                   answer:[RKChoiceAnswerFormat choiceAnswerWithOptions:@[@"Less than seven", @"Between seven and eight", @"More than eight"] style:RKChoiceAnswerStyleSingleChoice]];
        [steps addObject:step];
    }
    
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_004"
                                                                     name:@"Choices Muti"
                                                                 question:@"Which symptoms do you have?"
                                                                   answer:[RKChoiceAnswerFormat choiceAnswerWithOptions:@[@[@"Cough",@"A cough and/or sore throat"], @[@"Fever", @"A 100F or higher fever or feeling feverish"], @[@"Headaches",@"Headaches and/or body aches"]]  style:RKChoiceAnswerStyleMultipleChoice]];
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_005"
                                                                     name:@"Text"
                                                                 question:@"How did you feel last night?"
                                                                   answer:[RKTextAnswerFormat textAnswer]];
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_010"
                                                                     name:@"scale "
                                                                 question:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                   answer:[RKScaleAnswerFormat scaleAnswerWithMaxValue:10 minValue:1]];
        [steps addObject:step];
    }
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"fqid_health_biologicalSex"
                                                                     name:@"Biological Sex"
                                                                 question:@"What is your biological sex?"
                                                                   answer:[RKHealthAnswerFormat healthAnswerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]]];
        [steps addObject:step];
    }
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"fqid_health_bloodType"
                                                                     name:@"Blood Type"
                                                                 question:@"What is your blood type?"
                                                                   answer:[RKHealthAnswerFormat healthAnswerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType]]];
        [steps addObject:step];
    }
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"fqid_health_dob"
                                                                     name:@"DOB"
                                                                 question:@"What is your date of birth?"
                                                                   answer:[RKHealthAnswerFormat healthAnswerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]]];
        [steps addObject:step];
    }
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"fqid_health_weight"
                                                                     name:@"Weight"
                                                                 question:@"How much do you weigh?"
                                                                   answer:[RKHealthAnswerFormat healthAnswerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                                                              unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                                                             style:RKNumericAnswerStyleDecimal]];
        [steps addObject:step];
    }
    
    RKTask* task = [[RKTask alloc] initWithName:@"Demo" identifier:@"tid_001" steps:steps];
    
    self.taskVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    [self beginTask:task];
}


- (IBAction)showTask:(id)sender{
    
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKFormStep* step = [[RKFormStep alloc] initWithIdentifier:@"fid_001" name:@"form step" title:@"Mini Form" subtitle:@"Mini Form groups multi-entry in one page"];
        NSMutableArray* items = [NSMutableArray new];
        
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_001" text:@"Have headache?" answerFormat:[RKBooleanAnswerFormat new]];
            [items addObject:item];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_002" text:@"Best Fruit?"
                                                         answerFormat:[RKChoiceAnswerFormat choiceAnswerWithOptions:@[@"Apple", @"Orange", @"Banana"]
                                                                                                              style:RKChoiceAnswerStyleSingleChoice]];
            [items addObject:item];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_003" text:@"Message"
                                                         answerFormat:[RKTextAnswerFormat textAnswer]];
            [items addObject:item];
        }
        {
            RKNumericAnswerFormat* af = [RKNumericAnswerFormat integerAnswerWithUnit:@"mm Hg"];
            af.maximum = @(200);
            af.minimum = @(0);
            
            RKFormItem* item1 = [[RKFormItem alloc] initWithIdentifier:@"fqid_004a" text:@"BP Diastolic"
                                                         answerFormat:af];
            [items addObject:item1];
        
            RKFormItem* item2 = [[RKFormItem alloc] initWithIdentifier:@"fqid_004b" text:@"BP Systolic"
                                                         answerFormat:af];
            [items addObject:item2];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_005" text:@"Birthdate"
                                                         answerFormat:[RKDateAnswerFormat dateAnswer]];
            [items addObject:item];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_006" text:@"Today sunset time?"
                                                         answerFormat:[RKDateAnswerFormat timeAnswer]];
            [items addObject:item];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_007" text:@"Next eclipse visible in Cupertino?"
                                                         answerFormat:[RKDateAnswerFormat dateTimeAnswer]];
            [items addObject:item];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_008" text:@"Wake up interval"
                                                         answerFormat:[RKTimeIntervalAnswerFormat timeIntervalAnswer]];
            [items addObject:item];
        }
        
        [step setFormItems:items];
        
        [steps addObject:step];
    }
    
    {
        RKIntroductionStep* step = [[RKIntroductionStep alloc] initWithIdentifier:@"iid_001" name:@"intro step"];
        step.caption = @"Demo Study";
        step.instruction = @"This 12-step walkthrough will explain the study and the impact it will have on your life.";
        step.explanation = @"You must complete the walkthough to participate in the study.";
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"aid_001d" name:@"active step"];
        step.caption = @"Audio";
        step.countDown = 10.0;
        step.text = @"An active test recording audio";
        step.recorderConfigurations = @[[RKAudioRecorderConfiguration new]];
        step.useNextForSkip = YES;
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"aid_001e" name:@"active step"];
        step.caption = @"Audio";
        step.countDown = 10.0;
        step.text = @"An active test recording lossless audio";
        step.useNextForSkip = YES;
        step.recorderConfigurations = @[[[RKAudioRecorderConfiguration alloc] initWithRecorderSettings:@{AVFormatIDKey : @(kAudioFormatAppleLossless),
                                                                                                         AVNumberOfChannelsKey : @(2),
                                                                                                         AVSampleRateKey: @(44100.0)
                                                                                                         }]];
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"aid_001a" name:@"active step"];
        step.caption = @"Touch";
        step.text = @"An active test, touch collection";
        step.clickButtonToStartTimer = YES;
        step.countDown = 30.0;
        step.voicePrompt = @"An active test, touch collection";
        step.useNextForSkip = YES;
        step.recorderConfigurations = @[[RKTouchRecorderConfiguration configuration]];
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"aid_001b" name:@"active step"];
        step.caption = @"Button Tap";
        step.text = @"Please tap the orange button when it appears in the green area below.";
        step.countDown = 10.0;
        step.useNextForSkip = YES;
        step.recorderConfigurations = @[[CustomRecorderConfiguration new]];
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"aid_001c" name:@"active step"];
        step.caption = @"Motion";
        step.text = @"An active test collecting device motion data";
        step.useNextForSkip = YES;
        step.recorderConfigurations = @[[[RKDeviceMotionRecorderConfiguration alloc] initWithFrequency:100.0]];
        [steps addObject:step];
    }
    
    {
        RKNumericAnswerFormat* format = [RKNumericAnswerFormat integerAnswerWithUnit:@"years"];
        format.minimum = @(0);
        format.maximum = @(199);
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_001" name:@"HowOld" question:@"How old are you?" answer:format];
        [steps addObject:step];
    }
    
    {
        RKBooleanAnswerFormat* format = [RKBooleanAnswerFormat new];
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_001b" name:@"Boolean" question:@"Do you consent to a background check?" answer:format];
        [steps addObject:step];
    }
    
    
    {
        RKNumericAnswerFormat* format = [RKNumericAnswerFormat decimalAnswerWithUnit:nil];
        format.minimum = @(0);
        format.minimumFractionDigits = @(2);
        format.maximumFractionDigits = @(2);
        format.roundingIncrement = @(100);
        format.roundingMode = kCFNumberFormatterRoundFloor;
        
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_002" name:@"HowMuch" question:@"What is your annual salary?" answer:format];
        [steps addObject:step];
    }
    
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_003"
                                                                     name:@"Choices ONE"
                                                                 question:@"How many hours did you sleep last night?"
                                                                   answer:[RKChoiceAnswerFormat choiceAnswerWithOptions:@[@"Less than seven", @"Between seven and eight", @"More than eight"] style:RKChoiceAnswerStyleSingleChoice]];
        [steps addObject:step];
    }
    
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_004"
                                                                     name:@"Choices Muti"
                                                                 question:@"Which symptoms do you have?"
                                                                   answer:[RKChoiceAnswerFormat choiceAnswerWithOptions:@[@[@"Cough",@"A cough and/or sore throat"], @[@"Fever", @"A 100F or higher fever or feeling feverish"], @[@"Headaches",@"Headaches and/or body aches"]]  style:RKChoiceAnswerStyleMultipleChoice]];
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_005"
                                                                     name:@"Text"
                                                                 question:@"How did you feel last night?"
                                                                   answer:[RKTextAnswerFormat textAnswer]];
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_006"
                                                                     name:@"Time Interval"
                                                                 question:@"How long did it take to fall asleep last night?"
                                                                   answer:[RKTimeIntervalAnswerFormat timeIntervalAnswer]];
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_007"
                                                                     name:@"date"
                                                                 question:@"When is your birthday?"
                                                                   answer:[RKDateAnswerFormat dateAnswer]];
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_008"
                                                                     name:@"time"
                                                                 question:@"What time do you get up?"
                                                                   answer:[RKDateAnswerFormat timeAnswer]];
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_009"
                                                                     name:@"date & time"
                                                                 question:@"When is your next meeting?"
                                                                   answer:[RKDateAnswerFormat dateTimeAnswer]];
        [steps addObject:step];
        
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_010"
                                                                     name:@"scale "
                                                                 question:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                   answer:[RKScaleAnswerFormat scaleAnswerWithMaxValue:10 minValue:1]];
        [steps addObject:step];
    }
    
    RKTask* task = [[RKTask alloc] initWithName:@"Demo" identifier:@"tid_001" steps:steps];
    NSString * path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"sleepSurvey.task"];
    NSKeyedArchiver * archiver = [NSKeyedArchiver alloc] initForWritingWithMutableData:<#(NSMutableData *)#>
    [NSKeyedArchiver archiveRootObject:task toFile:path];
    self.taskVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    [self beginTask:task];
}

- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : nil;
    return basePath;
}

- (IBAction)showConsentSignature:(id)sender{
    
    RKConsentSignature *participantSig = [RKConsentSignature signatureForPersonWithTitle:@"Participant" name:nil signatureImage:nil dateString:nil];
    RKConsentReviewStep *reviewStep = [[RKConsentReviewStep alloc] initWithSignature:participantSig inDocument:[self buildConsentDocument]];
    RKTask *task = [[RKTask alloc] initWithName:@"consent" identifier:@"consent" steps:@[reviewStep]];
    RKTaskViewController *consentVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    
    consentVC.taskDelegate = self;
    [self presentViewController:consentVC animated:YES completion:nil];
}

- (IBAction)showConsent:(id)sender{
    
    RKConsentSignature *participantSig = [RKConsentSignature signatureForPersonWithTitle:@"Participant" name:nil signatureImage:nil dateString:nil];
    RKConsentDocument* consent = [self buildConsentDocument];
    
    RKVisualConsentStep *step = [[RKVisualConsentStep alloc] initWithDocument:consent];
    RKConsentReviewStep *reviewStep = [[RKConsentReviewStep alloc] initWithSignature:participantSig inDocument:consent];
    RKTask *task = [[RKTask alloc] initWithName:@"consent" identifier:@"consent" steps:@[step,reviewStep]];
    RKTaskViewController *consentVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    
    consentVC.taskDelegate = self;
    [self presentViewController:consentVC animated:YES completion:nil];
}

- (IBAction)showAudioTask:(id)sender{
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKIntroductionStep* step = [[RKIntroductionStep alloc] initWithIdentifier:@"iid_001" name:@"intro step"];
        step.caption = @"Audio Task";
        [steps addObject:step];
    }
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"aid_001e" name:@"active step"];
        step.caption = @"Audio";
        step.countDown = 10.0;
        step.text = @"An active test recording lossless audio";
        step.useNextForSkip = YES;
        step.recorderConfigurations = @[[[RKAudioRecorderConfiguration alloc] initWithRecorderSettings:@{AVFormatIDKey : @(kAudioFormatAppleLossless),
                                                                                                         AVNumberOfChannelsKey : @(2),
                                                                                                         AVSampleRateKey: @(44100.0)
                                                                                                         }]];
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"aid_001" name:@"Mini Form"];
        step.caption = @"Audio Task End";
        [steps addObject:step];
    }
    
    RKTask* task = [[RKTask alloc] initWithName:@"Demo" identifier:@"tid_001" steps:steps];
    
    self.taskVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    [self beginTask:task];

}

- (IBAction)showMiniForm:(id)sender{
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKIntroductionStep* step = [[RKIntroductionStep alloc] initWithIdentifier:@"iid_001" name:@"Mini Form"];
        step.caption = @"Mini Form";
        [steps addObject:step];
    }
    
    {
        RKFormStep* step = [[RKFormStep alloc] initWithIdentifier:@"fid_001" name:@"form step" title:@"Mini Form" subtitle:@"Mini Form groups multi-entry in one page"];
        NSMutableArray* items = [NSMutableArray new];
        
        {
            
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_health_biologicalSex" text:@"Gender" answerFormat:[RKHealthAnswerFormat healthAnswerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]]];
            [items addObject:item];
        }
        {
            
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_health_bloodType" text:@"Blood Type" answerFormat:[RKHealthAnswerFormat healthAnswerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType]]];
            [items addObject:item];
        }
        {
            
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_health_dob" text:@"Date of Birth" answerFormat:[RKHealthAnswerFormat healthAnswerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]]];
            [items addObject:item];
        }
        {
            
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_health_weight"
                                                                 text:@"Weight"
                                                         answerFormat:
                                [RKHealthAnswerFormat healthAnswerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                    unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                   style:RKNumericAnswerStyleDecimal]];
            [items addObject:item];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_001" text:@"Have headache?" answerFormat:[RKBooleanAnswerFormat new]];
            [items addObject:item];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_002" text:@"Best Fruit?"
                                                         answerFormat:[RKChoiceAnswerFormat choiceAnswerWithOptions:@[@"Apple", @"Orange", @"Banana"]
                                                                                                              style:RKChoiceAnswerStyleSingleChoice]];
            [items addObject:item];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_003" text:@"Message"
                                                         answerFormat:[RKTextAnswerFormat textAnswer]];
            item.placeholder = @"Your message";
            [items addObject:item];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_004a" text:@"BP Diastolic"
                                                         answerFormat:[RKNumericAnswerFormat integerAnswerWithUnit:@"mm Hg"]];
            item.placeholder = @"Enter value";
            [items addObject:item];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_004b" text:@"BP Systolic"
                                                         answerFormat:[RKNumericAnswerFormat integerAnswerWithUnit:@"mm Hg"]];
            item.placeholder = @"Enter value";
            [items addObject:item];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_005" text:@"Birthdate"
                                                         answerFormat:[RKDateAnswerFormat dateAnswer]];
            item.placeholder = @"Pick a date";
            [items addObject:item];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_006" text:@"Today sunset time?"
                                                         answerFormat:[RKDateAnswerFormat timeAnswer]];
            [items addObject:item];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_007" text:@"Next eclipse visible in Cupertino?"
                                                         answerFormat:[RKDateAnswerFormat dateTimeAnswer]];
            [items addObject:item];
        }
        {
            RKFormItem* item = [[RKFormItem alloc] initWithIdentifier:@"fqid_008" text:@"Wake up interval"
                                                         answerFormat:[RKTimeIntervalAnswerFormat timeIntervalAnswer]];
            [items addObject:item];
        }
        
        [step setFormItems:items];
        
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"aid_001" name:@"Mini Form"];
        step.caption = @"Mini Form End";
        [steps addObject:step];
    }
    
    RKTask* task = [[RKTask alloc] initWithName:@"Demo" identifier:@"tid_001" steps:steps];
    
    self.taskVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    [self beginTask:task];
    
}

- (IBAction)showEQ5D:(id)sender{
    
    NSArray* qlist = @[@"MOBILITY",
                       @[@[@"No Problems", @"I have no problems in walking about."], @[@"Slight Problems",@"I have slight problems in walking about."], @[@"Moderate Problems", @"I have moderate problems in walking about."],  @[@"Severe Problems",@"I have severe problems in walking about."], @[@"Unable to complete",@"I am unable to walk about."]],
                       @"SELF-CARE",
                       @[@[@"No Problems",@"I have no problems washing or dressing myself"], @[@"Slight problems", @"I have slight problems washing or dressing myself"], @[@"Moderate problems", @"I have moderate problems washing or dressing myself"], @[@"Severe problems", @"I have severe problems washing or dressing myself"], @[@"Unable to complete", @"I am unable to wash or dress myself"] ],
                       @"USUAL ACTIVITIES (e.g. work, study, housework, family or leisure activities)",
                       @[@[@"No Problems",@"I have no problems doing my usual activities"], @[@"Slight problems", @"I have slight problems doing my usual activities"], @[@"Moderate problems", @"I have moderate problems doing my usual activities"], @[@"Severe problems", @"I have severe problems doing my usual activities"], @[@"Unable to complete", @"I am unable to do my usual activities"]],
                       @"PAIN / DISCOMFORT",
                       @[@[@"No pain or discomfort", @"I have no pain or discomfort"], @[@"Slight pain or discomfort", @"I have slight pain or discomfort"], @[@"Moderate pain or discomfort", @"I have moderate pain or discomfort"], @[@"Severe pain or discomfort", @"I have severe pain or discomfort"], @[@"Extreme pain or discomfort", @"I have extreme pain or discomfort"]],
                       @"ANXIETY / DEPRESSION",
                       @[@[ @"Not anxious or depressed", @"I am not anxious or depressed"],@[@"Slightly anxious or depressed", @"I am slightly anxious or depressed"], @[@"Moderately anxious or depressed", @"I am moderately anxious or depressed" ], @[@"Severely anxious or depressed", @"I am severely anxious or depressed"],@[@"Extremely anxious or depressed", @"I am extremely anxious or depressed"]]
                       ];
    
    NSMutableArray* steps = [[NSMutableArray alloc] init];
    
    int index = 0;
    for (NSString* object in qlist) {
        
        if ([object isKindOfClass:[NSString class]]) {
            index++;
            RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"question_%d", index]
                                                                         name:@""
                                                                     question:object
                                                                       answer:[RKChoiceAnswerFormat choiceAnswerWithOptions:qlist[[qlist indexOfObject:object]+1] style:RKChoiceAnswerStyleSingleChoice]];
            step.prompt = @"Please pick the ONE box that best describes your health TODAY";
            [steps addObject:step];
        }
    }
    
    index++;
    RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"question_%d", index]
                                                                 name:@""
                                                             question:@"We would like to know how good or bad your health is TODAY."
                                                               answer:[RKScaleAnswerFormat scaleAnswerWithMaxValue:100 minValue:0]];
    
    step.prompt = @"This scale is numbered from 0 to 100.\n - 100 means the best health you can imagine.\n - 0 means the worst health you can imagine. \n\nTap the scale to indicate how your health is TODAY.";
    
    [steps addObject:step];
    RKTask* task = [[RKTask alloc] initWithName:@"Health Questionnaire" identifier:@"tid_001" steps:steps];
    
    self.taskVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    [self beginTask:task];
}

- (IBAction)showDynamicTask:(id)sender{
    
    
    DynamicTask* task = DynamicTask.alloc.init;
    
    [self beginTask:task];
    
}

- (IBAction)showGAIT:(id)sender{
    
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"gait_001" name:@"active step"];
        step.caption = @"20 Yards Walk";
        step.text = @"Please put the phone in a pocket or armband. Then wait for voice instruction.";
        step.countDown = 8.0;
        step.useNextForSkip = YES;
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"gait_002" name:@"active step"];
        step.caption = @"20 Yards Walk";
        step.text = @"Now please walk 20 yards, turn 180 degrees, and walk back.";
        step.buzz = YES;
        step.vibration = YES;
        step.voicePrompt = step.text;
        step.countDown = 60.0;
        step.useNextForSkip = YES;
        step.recorderConfigurations = @[ [[RKAccelerometerRecorderConfiguration alloc] initWithFrequency:100.0]];
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"gait_003" name:@"active step"];
        step.caption = @"Thank you for completing this task.";
        step.voicePrompt = step.text;
        [steps addObject:step];
    }
    
    RKTask* task = [[RKTask alloc] initWithName:@"GAIT" identifier:@"tid_001" steps:steps];
    [self beginTask:task];
    
    
}

- (IBAction)showInteruptTask:(id)sender{
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"itid_001" name:@"HowOld" question:@"How old are you?" answer:[RKNumericAnswerFormat integerAnswerWithUnit:@"years"]];
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"itid_002" name:@"HowMuch" question:@"How much did you pay for your car?" answer:[RKNumericAnswerFormat decimalAnswerWithUnit:@"USD"]];
        [steps addObject:step];
    }
    
    {
        RKMediaStep *step = [[RKMediaStep alloc] initWithIdentifier:@"itid_004" name:@"media"];
        step.request = @"Please take a picture of your right hand.";
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"itid_003" name:@"active step"];
        step.caption = @"Thank you for completing this task.";
        step.voicePrompt = step.text;
        [steps addObject:step];
    }
    
    RKTask* task = [[RKTask alloc] initWithName:@"Screening" identifier:@"tid_001" steps:steps];
    [self beginTask:task];
}

- (IBAction)controlAppearance:(id)sender{
    
    UINavigationController* navc = [[UINavigationController alloc] initWithRootViewController:[AppearanceControlViewController new]];
    [self presentViewController:navc animated:YES completion:nil];
}

#pragma mark - Helpers

- (RKConsentDocument*)buildConsentDocument{
    RKConsentDocument* consent = [[RKConsentDocument alloc] init];
    consent.title = @"Demo Consent";
    consent.signaturePageTitle = @"Consent";
    consent.signaturePageContent = @"I agree  to participate in this research Study.";
    
    RKConsentSignature *participantSig = [RKConsentSignature signatureForPersonWithTitle:@"Participant" name:nil signatureImage:nil dateString:nil];
    [consent addSignature:participantSig];
    
    RKConsentSignature *investigatorSig = [RKConsentSignature signatureForPersonWithTitle:@"Investigator" name:@"Jake Clemson" signatureImage:[UIImage imageNamed:@"signature.png"] dateString:@"9/2/14"];
    [consent addSignature:investigatorSig];
    
    NSMutableArray* components = [NSMutableArray new];
    
    NSArray* scenes = @[@(RKConsentSectionTypeOverview),
                        @(RKConsentSectionTypeActivity),
                        @(RKConsentSectionTypeSensorData),
                        @(RKConsentSectionTypeDeIdentification),
                        @(RKConsentSectionTypeCombiningData),
                        @(RKConsentSectionTypeUtilizingData),
                        @(RKConsentSectionTypeImpactLifeTime),
                        @(RKConsentSectionTypePotentialRiskUncomfortableQuestion),
                        @(RKConsentSectionTypePotentialRiskSocial),
                        @(RKConsentSectionTypeAllowWithdraw)];
    for (NSNumber* type in scenes) {
        RKConsentSection* c = [[RKConsentSection alloc] initWithType:type.integerValue];
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    {
        RKConsentSection* c = [[RKConsentSection alloc] initWithType:RKConsentSectionTypeCustom];
        c.summary = @"Custom Scene summary";
        c.title = @"Custom Scene";
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        c.customImage = [UIImage imageNamed:@"image_example.png"];
        [components addObject:c];
    }
    
    {
        RKConsentSection* c = [[RKConsentSection alloc] initWithType:RKConsentSectionTypeOnlyInDocument];
        c.summary = @"OnlyInDocument Scene summary";
        c.title = @"OnlyInDocument Scene";
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    consent.sections = [components copy];
    return consent;
}

- (void)beginTask:(id<RKLogicalTask>)task
{
    if (self.taskArchive)
    {
        NSLog(@"Close old archive");
        [self.taskArchive resetContent];
    }
    
    self.taskVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    self.taskVC.taskDelegate = self;
    
    if ([task isKindOfClass:[DynamicTask class]])
    {
        self.taskVC.defaultResultProvider = _lastRouteResult;
    }
    
    self.taskArchive = [[RKDataArchive alloc] initWithItemIdentifier:[RKItemIdentifier itemIdentifierForTask:task] studyIdentifier:MainStudyIdentifier taskInstanceUUID:self.taskVC.taskInstanceUUID extraMetadata:nil fileProtection:RKFileProtectionCompleteUnlessOpen];
    NSLog(@"Start new archive");
    
    [self presentViewController:_taskVC animated:YES completion:nil];
}

-(void)sendResult:(RKResult*)result
{
    // In a real application, consider adding to the archive on a concurrent queue.
    NSError *err = nil;
    if (![result addToArchive:self.taskArchive error:&err])
    {
        // Error adding the result to the archive; archive may be invalid. Tell
        // the user there's been a problem and stop the task.
        NSLog(@"Error adding %@ to archive: %@", result, err);
    }
}

#pragma mark - RKTaskViewControllerDelegate

- (BOOL)taskViewController:(RKTaskViewController *)taskViewController shouldShowMoreInfoOnStep:(RKStep *)step{
    static int counter = 0;
    counter ++;
    return ((counter % 2) > 0);
}

- (void)taskViewController:(RKTaskViewController *)taskViewController didReceiveLearnMoreEventFromStepViewController:(RKStepViewController *)stepViewController{
    NSLog(@"Want to learn more = %@", stepViewController);
}

- (void)taskViewController:(RKTaskViewController *)taskViewController didProduceResult:(RKResult*)result{
    
    NSLog(@"didProduceResult = %@", result);
    if ([taskViewController.task isKindOfClass:[DynamicTask class]] && [result isKindOfClass:[RKSurveyResult class]])
    {
        _lastRouteResult = (RKSurveyResult *)result;
    }
    
    if ([result isKindOfClass:[RKSurveyResult class]]) {
        RKSurveyResult* sresult = (RKSurveyResult*)result;
        
        for (RKResult* r in sresult.surveyResults) {
            if ([r isKindOfClass:[RKQuestionResult class]])
            {
                RKQuestionResult *qr = (RKQuestionResult *)r;
                NSLog(@"%@ = [%@] %@ ", [[qr itemIdentifier] stringValue], [qr.answer class], qr.answer);
            }
            else if ([r isKindOfClass:[RKSurveyResult class]])
            {
                NSLog(@"%@ = [%@] ", [[r itemIdentifier] stringValue], r.class);
            }
        }
    }
    
    
    [self sendResult:result];
    
}

- (RKQuestionResult *)_questionResultForStepIdentifier:(NSString *)identifier fromSurveyResults:(NSArray *)surveyResults
{
    for (RKQuestionResult *result in surveyResults)
    {
        if (![result isKindOfClass:[RKQuestionResult class]])
        {
            continue;
        }
        if ([[[[result itemIdentifier] components] lastObject] isEqualToString:identifier])
        {
            return result;
        }
    }
    return nil;
}

- (BOOL)taskViewController:(RKTaskViewController *)taskViewController shouldPresentStep:(RKStep*)step{
    if ([ step.identifier isEqualToString:@"itid_002"]) {
        RKQuestionResult* qr = [self _questionResultForStepIdentifier:@"itid_001" fromSurveyResults:taskViewController.surveyResults];
        if (qr== nil || [(NSNumber*)qr.answer integerValue] < 18) {
            UIAlertController* alerVC = [UIAlertController alertControllerWithTitle:@"Warning" message:@"You can't participate if you are under 18." preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alerVC dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            
            
            [alerVC addAction:ok];
            
            [taskViewController presentViewController:alerVC animated:NO completion:^{
                
            } ];
            return NO;
        }
    }
    return YES;
}

- (void)taskViewController:(RKTaskViewController *)taskViewController
willPresentStepViewController:(RKStepViewController *)stepViewController{
    
    if ([stepViewController.step.identifier isEqualToString:@"aid_001c"]) {
        UIView* customView = [UIView new];
        customView.backgroundColor = [UIColor cyanColor];
        
        // Have the custom view request the space it needs.
        // A little tricky because we need to let it size to fit if there's not enough space.
        [customView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[c(>=160)]" options:0 metrics:nil views:@{@"c":customView}];
        for (NSLayoutConstraint *constraint in verticalConstraints)
        {
            constraint.priority = UILayoutPriorityFittingSizeLevel;
        }
        [customView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(>=280)]" options:0 metrics:nil views:@{@"c":customView}]];
        [customView addConstraints:verticalConstraints];
        
        [(RKActiveStepViewController*)stepViewController setCustomView:customView];
        
        // Set custom button on navi bar
        stepViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Custom button"
                                                                                               style:UIBarButtonItemStylePlain
                                                                                              target:nil
                                                                                              action:nil];
    }else if ([stepViewController.step.identifier isEqualToString:@"gait_001"]) {
        stepViewController.continueButton = nil;
    }else if ([stepViewController.step.identifier isEqualToString:@"gait_002"]) {
        stepViewController.continueButton = [[UIBarButtonItem alloc] initWithTitle:@"I'm done" style:stepViewController.continueButton.style target:stepViewController.continueButton.target action:stepViewController.continueButton.action];
        stepViewController.backButton = nil;
    }else if ([stepViewController.step.identifier isEqualToString:@"gait_003"]) {
        stepViewController.backButton = nil;
    }else if ([stepViewController.step.identifier isEqualToString:@"qid_003"]) {
        RKQuestionStepViewController* qsvc = (RKQuestionStepViewController*)stepViewController;
        UILabel* footerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
        footerView.text = @"Custom footer view";
        footerView.textAlignment = NSTextAlignmentCenter;
        footerView.textColor = [UIColor lightGrayColor];
        
        qsvc.footerView = footerView;
    }
}


- (void)taskViewControllerDidFail: (RKTaskViewController *)taskViewController withError:(NSError*)error{
    
    NSLog(@"Close archive");
    [self.taskArchive resetContent];
    self.taskArchive = nil;
    
}

- (void)taskViewControllerDidCancel:(RKTaskViewController *)taskViewController{
    
    [taskViewController suspend];
    
    NSLog(@"Close archive");
    [self.taskArchive resetContent];
    self.taskArchive = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewControllerDidComplete: (RKTaskViewController *)taskViewController{
    
    [taskViewController suspend];
    
    
    NSLog(@"Save archive to URL");
    NSError *err = nil;
    NSURL *archiveFileURL = [self.taskArchive archiveURLWithError:&err];
    if (archiveFileURL)
    {
        NSURL *documents = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        NSURL *outputUrl = [documents URLByAppendingPathComponent:[archiveFileURL lastPathComponent]];
        
        // This is where you would queue the archive for upload. In this demo, we move it
        // to the documents directory, where you could copy it off using iTunes, for instance.
        [[NSFileManager defaultManager] moveItemAtURL:archiveFileURL toURL:outputUrl error:nil];
        
        NSLog(@"outputUrl= %@", outputUrl);
        
        // When done, clean up:
        self.taskArchive = nil;
        if (archiveFileURL)
        {
            [[NSFileManager defaultManager] removeItemAtURL:archiveFileURL error:nil];
        }
    }
    
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#if 0
#pragma mark - RKConsentViewControllerDelegate

- (void)consentViewControllerDidCancel:(RKConsentViewController *)consentViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)consentViewControllerDidComplete: (RKConsentViewController *)consentViewController{
    
    
    [consentViewController.consent makePdfWithCompletionBlock:^(NSData *data, NSError *error) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString* path = [NSString stringWithFormat:@"%@/signedConsent.pdf", documentsDirectory];
        BOOL write = [data writeToFile:path atomically:NO];
        
        NSLog(@"%d, open %@", write ,path);
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#endif




@end
