//
//  MainViewController.m
//  StudyDemo
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "MainViewController.h"
#import <ResearchKit/ResearchKit_Private.h>
#import <AVFoundation/AVFoundation.h>
#import "DynamicTask.h"
#import "CustomRecorder.h"
#import "AppDelegate.h"
#import "AppearanceControlViewController.h"

// #define DEMO


@interface MainViewController ()<RKSTTaskViewControllerDelegate>
{
    id<RKSTTaskResultSource> _lastRouteResult;
    RKSTConsentDocument *_currentDocument;
}

@property (nonatomic, strong) RKSTTaskViewController* taskVC;
@property (nonatomic, strong) RKSTStudy* study;
@property (nonatomic, strong) RKSTDataArchive *taskArchive;

@end

@implementation MainViewController


- (instancetype)initWithStudy:(RKSTStudy*)study
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
        self.restorationIdentifier = @"main";
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
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showTwoFingerTappingTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Two Finger Tapping" forState:UIControlStateNormal];
        buttons[@"tapping"] = button;
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
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showImageChoices:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Image Choices" forState:UIControlStateNormal];
        buttons[@"imageChoices"] = button;
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
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:buttons[@"imageChoices"]
                                                          attribute:NSLayoutAttributeBaseline
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:buttons[@"tapping"]
                                                          attribute:NSLayoutAttributeBaseline
                                                         multiplier:1 constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[join][leave(==join)]|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[task][dyntask(==task)]|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[interruptible][appearance(==interruptible)]|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageChoices][tapping(==imageChoices)]|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[consent][dates(==consent)][audio(==consent)][eq5d(==consent)][task(==consent)][interruptible(==consent)][join(==consent)][imageChoices(==consent)]-20-|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    
#else
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tapping]|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[consent]-30-[dates(==consent)]-30-[audio(==consent)]-30-[eq5d(==consent)]-[tapping]-100-|" options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
    
    
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
        RKSTInstructionStep* step = [[RKSTInstructionStep alloc] initWithIdentifier:@"iid_001"];
        step.title = @"Date Survey";
        [steps addObject:step];
    }
    {
        NSDateComponents *override = [NSDateComponents new];
        [override setYear:5774];
        RKSTDateAnswerFormat *dateAnswer = [RKSTDateAnswerFormat dateAnswerWithDefault:override defaultDate:nil minimum:nil maximum:nil calendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierHebrew]];
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_007"
                                                                 title:@"When is your birthday?"
                                                                   answer:dateAnswer];
        
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_008"
                                                                 title:@"What time do you get up?"
                                                                   answer:[RKSTDateAnswerFormat timeAnswer]];
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_009"
                                                                 title:@"When is your next meeting?"
                                                                   answer:[RKSTDateAnswerFormat dateTimeAnswer]];
        [steps addObject:step];
        
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_006"
                                                                 title:@"How long did it take to fall asleep last night?"
                                                                   answer:[RKSTTimeIntervalAnswerFormat timeIntervalAnswer]];
        [steps addObject:step];
    }
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:@"dates_001" steps:steps];
    
    self.taskVC = [[RKSTTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    [self beginTask:task];
}

- (IBAction)showSelectionSurvey:(id)sender{
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKSTInstructionStep* step = [[RKSTInstructionStep alloc] initWithIdentifier:@"iid_001"];
        step.title = @"Selection Survey";
        [steps addObject:step];
    }
    
    {
        RKSTNumericAnswerFormat* format = [RKSTNumericAnswerFormat integerAnswerWithUnit:@"years"];
        format.minimum = @(0);
        format.maximum = @(199);
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_001" title:@"How old are you?" answer:format];
        [steps addObject:step];
    }
    
    {
        RKSTBooleanAnswerFormat* format = [RKSTBooleanAnswerFormat new];
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_001b" title:@"Do you consent to a background check?" answer:format];
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_003"
                                                                 title:@"How many hours did you sleep last night?"
                                                                   answer:[RKSTChoiceAnswerFormat choiceAnswerWithTextOptions:@[@"Less than seven", @"Between seven and eight", @"More than eight"] style:RKChoiceAnswerStyleSingleChoice]];
        [steps addObject:step];
    }
    
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_004"
                                                                 title:@"Which symptoms do you have?"
                                                                   answer:[RKSTChoiceAnswerFormat choiceAnswerWithTextOptions:@[@[@"Cough",@"A cough and/or sore throat"], @[@"Fever", @"A 100F or higher fever or feeling feverish"], @[@"Headaches",@"Headaches and/or body aches"]]  style:RKChoiceAnswerStyleMultipleChoice]];
        
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_005"
                                                                 title:@"How did you feel last night?"
                                                                   answer:[RKSTTextAnswerFormat textAnswer]];
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_010"
                                                                 title:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                   answer:[RKSTScaleAnswerFormat scaleAnswerWithMaxValue:10 minValue:1]];
        [steps addObject:step];
    }
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"fqid_health_biologicalSex"
                                                                 title:@"What is your biological sex?"
                                                                   answer:[RKSTHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]]];
        [steps addObject:step];
    }
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"fqid_health_bloodType"
                                                                 title:@"What is your blood type?"
                                                                   answer:[RKSTHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType]]];
        [steps addObject:step];
    }
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"fqid_health_dob"
                                                                 title:@"What is your date of birth?"
                                                                   answer:[RKSTHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]]];
        [steps addObject:step];
    }
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"fqid_health_weight"
                                                                 title:@"How much do you weigh?"
                                                                   answer:[RKSTHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                                                              unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                                                             style:RKNumericAnswerStyleDecimal]];
        [steps addObject:step];
    }
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:@"tid_001" steps:steps];
    
    self.taskVC = [[RKSTTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    [self beginTask:task];
}


- (IBAction)showTask:(id)sender{
    
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKSTFormStep* step = [[RKSTFormStep alloc] initWithIdentifier:@"fid_001"
                                                            title:@"Mini Form"
                                                         subtitle:@"Mini Form groups multi-entry in one page"];
        NSMutableArray* items = [NSMutableArray new];
        
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_001"
                                                                 text:@"Have headache?"
                                                         answerFormat:[RKSTBooleanAnswerFormat new]];
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_002"
                                                                 text:@"Best Fruit?"
                                                         answerFormat:[RKSTChoiceAnswerFormat choiceAnswerWithTextOptions:@[@"Apple", @"Orange", @"Banana"]
                                                                       style:RKChoiceAnswerStyleSingleChoice]];
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_003" text:@"Message"
                                                         answerFormat:[RKSTTextAnswerFormat textAnswerWithMaximumLength:@(20)]];
            [items addObject:item];
        }
        {
            RKSTNumericAnswerFormat* af = [RKSTNumericAnswerFormat integerAnswerWithUnit:@"mm Hg"];
            af.maximum = @(200);
            af.minimum = @(0);
            
            RKSTFormItem* item1 = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_004a" text:@"BP Diastolic"
                                                          answerFormat:af];
            [items addObject:item1];
            
            RKSTFormItem* item2 = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_004b" text:@"BP Systolic"
                                                          answerFormat:af];
            [items addObject:item2];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_005" text:@"Birthdate"
                                                         answerFormat:[RKSTDateAnswerFormat dateAnswer]];
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_006" text:@"Today sunset time?"
                                                         answerFormat:[RKSTDateAnswerFormat timeAnswer]];
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_007" text:@"Next eclipse visible in Cupertino?"
                                                         answerFormat:[RKSTDateAnswerFormat dateTimeAnswer]];
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_008" text:@"Wake up interval"
                                                         answerFormat:[RKSTTimeIntervalAnswerFormat timeIntervalAnswer]];
            [items addObject:item];
        }
        
        {
            CGSize size = CGSizeMake(120, 120);
            RKSTImageAnswerOption* option1 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor greenColor] size:size border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor greenColor] size:size border:YES]
                                                                                 text:@"Green" value:@"green"];
            RKSTImageAnswerOption* option2 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor blueColor] size:size border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor blueColor] size:size border:YES]
                                                                                 text:nil value:@"blue"];
            RKSTImageAnswerOption* option3 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor cyanColor] size:size border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor cyanColor] size:size border:YES]
                                                                                 text:@"Cyan" value:@"cyanColor"];
            
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_009" text:@"Which color do you like?"
                                                         answerFormat:[RKSTChoiceAnswerFormat choiceAnswerWithImageOptions:@[option1, option2, option3]
                                                                                                              style:RKChoiceAnswerStyleMultipleChoice]];
            [items addObject:item];
        }
        
        [step setFormItems:items];
        
        [steps addObject:step];
    }
    
    {
        RKSTInstructionStep* step = [[RKSTInstructionStep alloc] initWithIdentifier:@"iid_001"];
        step.title = @"Demo Study";
        step.text = @"This 12-step walkthrough will explain the study and the impact it will have on your life.";
        step.detailText = @"You must complete the walkthough to participate in the study.";
        [steps addObject:step];
    }
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"aid_001d"];
        step.title = @"Audio";
        step.countDownInterval = 10.0;
        step.text = @"An active test recording audio";
        step.recorderConfigurations = @[[RKSTAudioRecorderConfiguration new]];
        step.shouldUseNextAsSkipButton = YES;
        [steps addObject:step];
    }
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"aid_001e"];
        step.title = @"Audio";
        step.countDownInterval = 10.0;
        step.text = @"An active test recording lossless audio";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[[RKSTAudioRecorderConfiguration alloc] initWithRecorderSettings:@{AVFormatIDKey : @(kAudioFormatAppleLossless),
                                                                                                         AVNumberOfChannelsKey : @(2),
                                                                                                         AVSampleRateKey: @(44100.0)
                                                                                                         }]];
        [steps addObject:step];
    }
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"aid_001a"];
        step.title = @"Touch";
        step.text = @"An active test, touch collection";
        step.shouldStartTimerAutomatically = NO;
        step.countDownInterval = 30.0;
        step.spokenInstruction = @"An active test, touch collection";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[RKSTTouchRecorderConfiguration configuration]];
        [steps addObject:step];
    }
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"aid_001b"];
        step.title = @"Button Tap";
        step.text = @"Please tap the orange button when it appears in the green area below.";
        step.countDownInterval = 10.0;
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[CustomRecorderConfiguration new]];
        [steps addObject:step];
    }
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"aid_001c"];
        step.title = @"Motion";
        step.text = @"An active test collecting device motion data";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[[RKSTDeviceMotionRecorderConfiguration alloc] initWithFrequency:100.0]];
        [steps addObject:step];
    }
    
    {
        RKSTNumericAnswerFormat* format = [RKSTNumericAnswerFormat integerAnswerWithUnit:@"years"];
        format.minimum = @(0);
        format.maximum = @(199);
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_001" title:@"How old are you?" answer:format];
        [steps addObject:step];
    }
    
    {
        RKSTBooleanAnswerFormat* format = [RKSTBooleanAnswerFormat new];
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_001b" title:@"Do you consent to a background check?" answer:format];
        [steps addObject:step];
    }
    
    
    {
        RKSTNumericAnswerFormat* format = [RKSTNumericAnswerFormat decimalAnswerWithUnit:nil];
        format.minimum = @(0);
        format.minimumFractionDigits = @(2);
        format.maximumFractionDigits = @(2);
        format.roundingIncrement = @(100);
        format.roundingMode = kCFNumberFormatterRoundFloor;
        
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_002" title:@"What is your annual salary?" answer:format];
        [steps addObject:step];
    }
    
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_003"
                                                                     title:@"How many hours did you sleep last night?"
                                                                   answer:[RKSTChoiceAnswerFormat choiceAnswerWithTextOptions:@[@"Less than seven", @"Between seven and eight", @"More than eight"] style:RKChoiceAnswerStyleSingleChoice]];
        [steps addObject:step];
    }
    
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_004"
                                                                     title:@"Which symptoms do you have?"
                                                                   answer:[RKSTChoiceAnswerFormat choiceAnswerWithTextOptions:@[@[@"Cough",@"A cough and/or sore throat"], @[@"Fever", @"A 100F or higher fever or feeling feverish"], @[@"Headaches",@"Headaches and/or body aches"]]  style:RKChoiceAnswerStyleMultipleChoice]];
        
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_005"
                                                                     title:@"How did you feel last night?"
                                                                   answer:[RKSTTextAnswerFormat textAnswerWithMaximumLength:@(20)]];
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_006"
                                                                     title:@"How long did it take to fall asleep last night?"
                                                                   answer:[RKSTTimeIntervalAnswerFormat timeIntervalAnswer]];
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_007"
                                                                     title:@"When is your birthday?"
                                                                   answer:[RKSTDateAnswerFormat dateAnswer]];
        
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_008"
                                                                     title:@"What time do you get up?"
                                                                   answer:[RKSTDateAnswerFormat timeAnswer]];
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_009"
                                                                     title:@"When is your next meeting?"
                                                                   answer:[RKSTDateAnswerFormat dateTimeAnswer]];
        [steps addObject:step];
        
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_010"
                                                                     title:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                   answer:[RKSTScaleAnswerFormat scaleAnswerWithMaxValue:10 minValue:1]];
        [steps addObject:step];
    }
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:@"tid_001" steps:steps];
    
    self.taskVC = [[RKSTTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    [self beginTask:task];
}



- (IBAction)showConsentSignature:(id)sender{
    
    RKSTConsentDocument *doc = [self buildConsentDocument];
    RKSTConsentSignature *participantSig = doc.signatures[0];
    [participantSig setSignatureDateFormatString:@"yyyy-MM-dd 'at' HH:mm"];
    _currentDocument = [doc copy];
    RKSTConsentReviewStep *reviewStep = [[RKSTConsentReviewStep alloc] initWithSignature:participantSig inDocument:doc];
    RKSTOrderedTask *task = [[RKSTOrderedTask alloc] initWithIdentifier:@"consent" steps:@[reviewStep]];
    [self beginTask:task];
}

- (IBAction)showConsent:(id)sender{
    
    RKSTConsentDocument* consent = [self buildConsentDocument];
    _currentDocument = [consent copy];
    
    RKSTVisualConsentStep *step = [[RKSTVisualConsentStep alloc] initWithDocument:consent];
    RKSTConsentReviewStep *reviewStep = [[RKSTConsentReviewStep alloc] initWithSignature:consent.signatures[0] inDocument:consent];
    RKSTOrderedTask *task = [[RKSTOrderedTask alloc] initWithIdentifier:@"consent" steps:@[step,reviewStep]];
    
    [self beginTask:task];
}

- (IBAction)showAudioTask:(id)sender{
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKSTInstructionStep* step = [[RKSTInstructionStep alloc] initWithIdentifier:@"iid_001"];
        step.title = @"Audio Task";
        [steps addObject:step];
    }
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"aid_001e"];
        step.title = @"Audio";
        step.countDownInterval = 10.0;
        step.text = @"An active test recording lossless audio";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[[RKSTAudioRecorderConfiguration alloc] initWithRecorderSettings:@{AVFormatIDKey : @(kAudioFormatAppleLossless),
                                                                                                         AVNumberOfChannelsKey : @(2),
                                                                                                         AVSampleRateKey: @(44100.0)
                                                                                                         }]];
        [steps addObject:step];
    }
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"aid_001"];
        step.title = @"Audio Task End";
        [steps addObject:step];
    }
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:@"tid_001" steps:steps];
    
    self.taskVC = [[RKSTTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    [self beginTask:task];

}

- (IBAction)showMiniForm:(id)sender{
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKSTInstructionStep* step = [[RKSTInstructionStep alloc] initWithIdentifier:@"iid_001"];
        step.title = @"Mini Form";
        [steps addObject:step];
    }
    
    {
        RKSTFormStep* step = [[RKSTFormStep alloc] initWithIdentifier:@"fid_001" title:@"Mini Form" subtitle:@"Mini Form groups multi-entry in one page"];
        NSMutableArray* items = [NSMutableArray new];
        
        {
            
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_health_biologicalSex" text:@"Gender" answerFormat:[RKSTHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]]];
            [items addObject:item];
        }
        {
            
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_health_bloodType" text:@"Blood Type" answerFormat:[RKSTHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType]]];
            [items addObject:item];
        }
        {
            
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_health_dob" text:@"Date of Birth" answerFormat:[RKSTHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]]];
            [items addObject:item];
        }
        {
            
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_health_weight"
                                                                 text:@"Weight"
                                                         answerFormat:
                                [RKSTHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                    unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                   style:RKNumericAnswerStyleDecimal]];
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_001" text:@"Have headache?" answerFormat:[RKSTBooleanAnswerFormat new]];
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_002" text:@"Which fruit do you like most? Please pick one from below."
                                                         answerFormat:[RKSTChoiceAnswerFormat choiceAnswerWithTextOptions:@[@"Apple", @"Orange", @"Banana"]
                                                                                                              style:RKChoiceAnswerStyleSingleChoice]];
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_003" text:@"Message"
                                                         answerFormat:[RKSTTextAnswerFormat textAnswer]];
            item.placeholder = @"Your message";
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_004a" text:@"BP Diastolic"
                                                         answerFormat:[RKSTNumericAnswerFormat integerAnswerWithUnit:@"mm Hg"]];
            item.placeholder = @"Enter value";
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_004b" text:@"BP Systolic"
                                                         answerFormat:[RKSTNumericAnswerFormat integerAnswerWithUnit:@"mm Hg"]];
            item.placeholder = @"Enter value";
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_005" text:@"Birthdate"
                                                         answerFormat:[RKSTDateAnswerFormat dateAnswer]];
            item.placeholder = @"Pick a date";
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_006" text:@"Today sunset time?"
                                                         answerFormat:[RKSTDateAnswerFormat timeAnswer]];
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_007" text:@"Next eclipse visible in Cupertino?"
                                                         answerFormat:[RKSTDateAnswerFormat dateTimeAnswer]];
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_008" text:@"Wake up interval"
                                                         answerFormat:[RKSTTimeIntervalAnswerFormat timeIntervalAnswer]];
            [items addObject:item];
        }
        

        {
            
            RKSTImageAnswerOption* option1 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor redColor] size:CGSizeMake(360, 360) border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor redColor] size:CGSizeMake(360, 360) border:YES]
                                                                                 text:@"Red" value:@"red"];
            RKSTImageAnswerOption* option2 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:CGSizeMake(360, 360) border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor orangeColor] size:CGSizeMake(360, 360) border:YES]
                                                                                 text:nil value:@"orange"];
            RKSTImageAnswerOption* option3 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:CGSizeMake(360, 360) border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor yellowColor] size:CGSizeMake(360, 360) border:YES]
                                                                                 text:@"Yellow" value:@"yellow"];
            
            RKSTFormItem* item3 = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_009_3" text:@"Which color do you like?"
                                                          answerFormat:[RKSTChoiceAnswerFormat choiceAnswerWithImageOptions:@[option1, option2, option3]
                                                                                                               style:RKChoiceAnswerStyleSingleChoice]];
            [items addObject:item3];
        }
    
        
        [step setFormItems:items];
        
        [steps addObject:step];
    }
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"aid_001"];
        step.title = @"Mini Form End";
        [steps addObject:step];
    }
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:@"tid_001" steps:steps];
    
    self.taskVC = [[RKSTTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    [self beginTask:task];
    
}

- (IBAction)showEQ5D:(id)sender{
    
    NSArray* qlist = @[@"MOBILITY",
                       @[@[@"No Problems", @"I have no problems in walking about."], @[@"Slight Problems",@"I have slight problems in walking about."], @[@"Moderate Problems", @"I have moderate problems in walking about."],  @[@"Severe Problems",@"I have severe problems in walking about."], @[@"Unable to complete",@"I am unable to walk about."]],
                       @"SELF-CARE",
                       @[@[@"No Problems",@"I have no problems washing or dressing myself"], @[@"Slight problems", @"I have slight problems washing or dressing myself"], @[@"Moderate problems", @"I have moderate problems washing or dressing myself"], @[@"Severe problems", @"I have severe problems washing or dressing myself"], @[@"Unable to complete", @"I am unable to wash or dress myself"]],
                       @"USUAL ACTIVITIES (e.g. work, study, housework, family or leisure activities)",
                       @[@[@"No Problems",@"I have no problems doing my usual activities"], @[@"Slight problems", @"I have slight problems doing my usual activities"], @[@"Moderate problems", @"I have moderate problems doing my usual activities"], @[@"Severe problems", @"I have severe problems doing my usual activities"], @[@"Unable to complete", @"I am unable to do my usual activities"]],
                       @"PAIN / DISCOMFORT",
                       @[@[@"No pain or discomfort", @"I have no pain or discomfort"], @[@"Slight pain or discomfort", @"I have slight pain or discomfort"], @[@"Moderate pain or discomfort", @"I have moderate pain or discomfort"], @[@"Severe pain or discomfort", @"I have severe pain or discomfort"], @[@"Extreme pain or discomfort", @"I have extreme pain or discomfort"]],
                       @"ANXIETY / DEPRESSION",
                       @[@[ @"Not anxious or depressed", @"I am not anxious or depressed"],@[@"Slightly anxious or depressed", @"I am slightly anxious or depressed"], @[@"Moderately anxious or depressed", @"I am moderately anxious or depressed"], @[@"Severely anxious or depressed", @"I am severely anxious or depressed"],@[@"Extremely anxious or depressed", @"I am extremely anxious or depressed"]]
                      ];
    
    NSMutableArray* steps = [[NSMutableArray alloc] init];
    
    int index = 0;
    for (NSString* object in qlist) {
        
        if ([object isKindOfClass:[NSString class]]) {
            index++;
            RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"question_%d", index]
                                                                     title:object
                                                                       answer:[RKSTChoiceAnswerFormat choiceAnswerWithTextOptions:qlist[[qlist indexOfObject:object]+1] style:RKChoiceAnswerStyleSingleChoice]];
            step.text = @"Please pick the ONE box that best describes your health TODAY";
            [steps addObject:step];
        }
    }
    
    index++;
    RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"question_%d", index]
                                                             title:@"We would like to know how good or bad your health is TODAY."
                                                               answer:[RKSTScaleAnswerFormat scaleAnswerWithMaxValue:100 minValue:0]];
    
    step.text = @"This scale is numbered from 0 to 100.\n - 100 means the best health you can imagine.\n - 0 means the worst health you can imagine. \n\nTap the scale to indicate how your health is TODAY.";
    
    [steps addObject:step];
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:@"tid_001" steps:steps];
    
    self.taskVC = [[RKSTTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    [self beginTask:task];
}

- (IBAction)showDynamicTask:(id)sender{
    
    
    DynamicTask* task = DynamicTask.alloc.init;
    
    [self beginTask:task];
    
}

- (IBAction)showGAIT:(id)sender{
    
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"gait_001"];
        step.title = @"20 Yards Walk";
        step.text = @"Please put the phone in a pocket or armband. Then wait for voice instruction.";
        step.countDownInterval = 8.0;
        step.shouldUseNextAsSkipButton = YES;
        [steps addObject:step];
    }
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"gait_002"];
        step.title = @"20 Yards Walk";
        step.text = @"Now please walk 20 yards, turn 180 degrees, and walk back.";
        step.shouldPlaySoundOnStart = YES;
        step.shouldVibrateOnStart = YES;
        step.spokenInstruction = step.text;
        step.countDownInterval = 60.0;
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[ [[RKSTAccelerometerRecorderConfiguration alloc] initWithFrequency:100.0]];
        [steps addObject:step];
    }
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"gait_003"];
        step.title = @"Thank you for completing this task.";
        step.spokenInstruction = step.text;
        [steps addObject:step];
    }
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:@"gait" steps:steps];
    [self beginTask:task];
    
    
}

- (IBAction)showInteruptTask:(id)sender{
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKSTNumericAnswerFormat *format = [RKSTNumericAnswerFormat integerAnswerWithUnit:@"years"];
        format.minimum = @(5);
        format.maximum = @(90);
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"itid_001" title:@"How old are you?" answer:format];
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"itid_002" title:@"How much did you pay for your car?" answer:[RKSTNumericAnswerFormat decimalAnswerWithUnit:@"USD"]];
        [steps addObject:step];
    }
    
    {
        RKSTMediaStep *step = [[RKSTMediaStep alloc] initWithIdentifier:@"itid_004"];
        step.request = @"Please take a picture of your right hand.";
        [steps addObject:step];
    }
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"itid_003"];
        step.title = @"Thank you for completing this task.";
        step.spokenInstruction = step.text;
        [steps addObject:step];
    }
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:@"screening" steps:steps];
    [self beginTask:task];
}

- (IBAction)controlAppearance:(id)sender{
    
    UINavigationController* navc = [[UINavigationController alloc] initWithRootViewController:[AppearanceControlViewController new]];
    [self presentViewController:navc animated:YES completion:nil];
}

- (IBAction)showImageChoices:(id)sender{
    
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKSTFormStep* step = [[RKSTFormStep alloc] initWithIdentifier:@"fid_001" title:@"Image Choices Form" subtitle:@"Mini Form groups multi-entry in one page"];
        NSMutableArray* items = [NSMutableArray new];
        

        
        for (NSNumber* dimension in @[@(360), @(60)])
        {
            CGSize size = CGSizeMake([dimension floatValue], [dimension floatValue]);
            
            RKSTImageAnswerOption* option1 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor redColor] size:size border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor redColor] size:size border:YES]
                                                                                 text:@"Red" value:@"red"];
            RKSTImageAnswerOption* option2 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:size border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor orangeColor] size:size border:YES]
                                                                                 text:nil value:@"orange"];
            RKSTImageAnswerOption* option3 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:size border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor yellowColor] size:size border:YES]
                                                                                 text:@"Yellow" value:@"yellow"];
            RKSTImageAnswerOption* option4 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor greenColor] size:size border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor greenColor] size:size border:YES]
                                                                                 text:@"Green" value:@"green"];
            RKSTImageAnswerOption* option5 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor blueColor] size:size border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor blueColor] size:size border:YES]
                                                                                 text:nil value:@"blue"];
            RKSTImageAnswerOption* option6 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor cyanColor] size:size border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor cyanColor] size:size border:YES]
                                                                                 text:@"Cyan" value:@"cyanColor"];
            
            
            RKSTFormItem* item1 = [[RKSTFormItem alloc] initWithIdentifier:[@"fqid_009_1" stringByAppendingFormat:@"%@",dimension] text:@"Which color do you like?"
                                                          answerFormat:[RKSTChoiceAnswerFormat choiceAnswerWithImageOptions:@[option1] style:RKChoiceAnswerStyleSingleChoice]];
            [items addObject:item1];
            
            RKSTFormItem* item2 = [[RKSTFormItem alloc] initWithIdentifier:[@"fqid_009_2" stringByAppendingFormat:@"%@",dimension] text:@"Which color do you like?"
                                                          answerFormat:[RKSTChoiceAnswerFormat choiceAnswerWithImageOptions:@[option1, option2] style:RKChoiceAnswerStyleSingleChoice]];
            [items addObject:item2];
            
            RKSTFormItem* item3 = [[RKSTFormItem alloc] initWithIdentifier:[@"fqid_009_3" stringByAppendingFormat:@"%@",dimension] text:@"Which color do you like?"
                                                          answerFormat:[RKSTChoiceAnswerFormat choiceAnswerWithImageOptions:@[option1, option2, option3] style:RKChoiceAnswerStyleSingleChoice]];
            [items addObject:item3];
            
            RKSTFormItem* item6 = [[RKSTFormItem alloc] initWithIdentifier:[@"fqid_009_6" stringByAppendingFormat:@"%@",dimension] text:@"Which color do you like?"
                                                          answerFormat:[RKSTChoiceAnswerFormat choiceAnswerWithImageOptions:@[option1, option2, option3, option4, option5, option6] style:RKChoiceAnswerStyleMultipleChoice]];
            [items addObject:item6];
        }
        
        
        [step setFormItems:items];
        
        [steps addObject:step];
    }
    
    for (NSNumber* dimension in @[@(360), @(60)]) {
        CGSize size = CGSizeMake([dimension floatValue], [dimension floatValue]);
        
        RKSTImageAnswerOption* option1 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor redColor] size:size border:NO]
                                                                    selectedImage:[self imageWithColor:[UIColor redColor] size:size border:YES]
                                                                             text:@"Red" value:@"red"];
        RKSTImageAnswerOption* option2 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:size border:NO]
                                                                    selectedImage:[self imageWithColor:[UIColor orangeColor] size:size border:YES]
                                                                             text:nil value:@"orange"];
        RKSTImageAnswerOption* option3 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:size border:NO]
                                                                    selectedImage:[self imageWithColor:[UIColor yellowColor] size:size border:YES]
                                                                             text:@"Yellow" value:@"yellow"];
        RKSTImageAnswerOption* option4 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor greenColor] size:size border:NO]
                                                                    selectedImage:[self imageWithColor:[UIColor greenColor] size:size border:YES]
                                                                             text:@"Green" value:@"green"];
        RKSTImageAnswerOption* option5 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor blueColor] size:size border:NO]
                                                                    selectedImage:[self imageWithColor:[UIColor blueColor] size:size border:YES]
                                                                             text:nil value:@"blue"];
        RKSTImageAnswerOption* option6 = [RKSTImageAnswerOption optionWithNormalImage:[self imageWithColor:[UIColor cyanColor] size:size border:NO]
                                                                    selectedImage:[self imageWithColor:[UIColor cyanColor] size:size border:YES]
                                                                             text:@"Cyan" value:@"cyanColor"];
        
        
        RKSTQuestionStep* step1 = [RKSTQuestionStep questionStepWithIdentifier:@"qid_000color1"
                                                                  title:@"Which color do you like?"
                                                                    answer:[RKSTChoiceAnswerFormat choiceAnswerWithImageOptions:@[option1] style:RKChoiceAnswerStyleSingleChoice]];
        [steps addObject:step1];
        
        RKSTQuestionStep* step2 = [RKSTQuestionStep questionStepWithIdentifier:@"qid_000color2"
                                                                  title:@"Which color do you like?"
                                                                    answer:[RKSTChoiceAnswerFormat choiceAnswerWithImageOptions:@[option1, option2] style:RKChoiceAnswerStyleSingleChoice]];
        [steps addObject:step2];
        
        RKSTQuestionStep* step3 = [RKSTQuestionStep questionStepWithIdentifier:@"qid_000color3"
                                                                  title:@"Which color do you like?"
                                                                    answer:[RKSTChoiceAnswerFormat choiceAnswerWithImageOptions:@[option1, option2, option3] style:RKChoiceAnswerStyleSingleChoice]];
        [steps addObject:step3];
        
        RKSTQuestionStep* step6 = [RKSTQuestionStep questionStepWithIdentifier:@"qid_000color6"
                                                                  title:@"Which color do you like?"
                                                                    answer:[RKSTChoiceAnswerFormat choiceAnswerWithImageOptions:@[option1, option2, option3, option4, option5, option6] style:RKChoiceAnswerStyleMultipleChoice]];
        [steps addObject:step6];
    }
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"aid_001"];
        step.title = @"Image Choices Form End";
        [steps addObject:step];
    }
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:@"tid_001" steps:steps];
    
    self.taskVC = [[RKSTTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    [self beginTask:task];
    
}

- (IBAction)showTwoFingerTappingTask:(id)sender{

    RKSTOrderedTask* task = [RKSTOrderedTask twoFingerTappingTaskWithIdentifier:@"tap" intendedUseDescription:@"" duration:10.0 options:(RKPredefinedTaskOption)0];
    self.taskVC = [[RKSTTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    [self beginTask:task];
}


#pragma mark - Helpers

- (RKSTConsentDocument*)buildConsentDocument{
    RKSTConsentDocument* consent = [[RKSTConsentDocument alloc] init];
    consent.title = @"Demo Consent";
    consent.signaturePageTitle = @"Consent";
    consent.signaturePageContent = @"I agree  to participate in this research Study.";
    
    RKSTConsentSignature *participantSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Participant" dateFormatString:nil identifier:@"participantSig"];
    [consent addSignature:participantSig];
    
    RKSTConsentSignature *investigatorSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Investigator" name:@"Jake Clemson" signatureImage:[UIImage imageNamed:@"signature.png"] dateString:@"9/2/14" identifier:@"investigatorSig"];
    [consent addSignature:investigatorSig];
    
    NSMutableArray* components = [NSMutableArray new];
    
    NSArray* scenes = @[@(RKSTConsentSectionTypeOverview),
                        @(RKSTConsentSectionTypeActivity),
                        @(RKSTConsentSectionTypeSensorData),
                        @(RKSTConsentSectionTypeDeIdentification),
                        @(RKSTConsentSectionTypeCombiningData),
                        @(RKSTConsentSectionTypeUtilizingData),
                        @(RKSTConsentSectionTypeImpactLifeTime),
                        @(RKSTConsentSectionTypePotentialRiskUncomfortableQuestion),
                        @(RKSTConsentSectionTypePotentialRiskSocial),
                        @(RKSTConsentSectionTypeAllowWithdraw)];
    for (NSNumber* type in scenes) {
        RKSTConsentSection* c = [[RKSTConsentSection alloc] initWithType:type.integerValue];
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    {
        RKSTConsentSection* c = [[RKSTConsentSection alloc] initWithType:RKSTConsentSectionTypeCustom];
        c.summary = @"Custom Scene summary";
        c.title = @"Custom Scene";
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        c.customImage = [UIImage imageNamed:@"image_example.png"];
        [components addObject:c];
    }
    
    {
        RKSTConsentSection* c = [[RKSTConsentSection alloc] initWithType:RKSTConsentSectionTypeOnlyInDocument];
        c.summary = @"OnlyInDocument Scene summary";
        c.title = @"OnlyInDocument Scene";
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    consent.sections = [components copy];
    return consent;
}

- (void)beginTask:(id<RKSTTask>)task
{
    if (self.taskArchive)
    {
        NSLog(@"Close old archive");
        [self.taskArchive resetContent];
    }
    
    self.taskVC = [[RKSTTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    self.taskVC.taskDelegate = self;
    
    if ([task isKindOfClass:[DynamicTask class]])
    {
        self.taskVC.defaultResultSource = _lastRouteResult;
    }
    _taskVC.restorationIdentifier = [task identifier];
    
    self.taskArchive = [[RKSTDataArchive alloc] initWithItemIdentifier:[task identifier] studyIdentifier:MainStudyIdentifier taskRunUUID:self.taskVC.taskRunUUID extraMetadata:nil fileProtection:RKFileProtectionCompleteUnlessOpen];
    NSLog(@"Start new archive");
    
    
    [self presentViewController:_taskVC animated:YES completion:nil];
}

- (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size border:(BOOL)border{
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    view.backgroundColor = color;
    
    if (border) {
        view.layer.borderColor = [[UIColor blackColor] CGColor];
        view.layer.borderWidth = 5.0;
    }

    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

#pragma mark - RKSTTaskViewControllerDelegate

- (BOOL)taskViewController:(RKSTTaskViewController *)taskViewController hasLearnMoreForStep:(RKSTStep *)step{
    static int counter = 0;
    counter ++;
    return ((counter % 2) > 0);
}

- (void)taskViewController:(RKSTTaskViewController *)taskViewController learnMoreForStep:(RKSTStepViewController *)stepViewController{
    NSLog(@"Want to learn more = %@", stepViewController);
}


- (BOOL)taskViewController:(RKSTTaskViewController *)taskViewController shouldPresentStep:(RKSTStep*)step {
    if ([ step.identifier isEqualToString:@"itid_002"]) {
        RKSTQuestionResult *qr = (RKSTQuestionResult *)[[[taskViewController result] stepResultForStepIdentifier:@"itid_001"] firstResult];
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
                
            }];
            return NO;
        }
    }
    return YES;
}

- (void)taskViewController:(RKSTTaskViewController *)taskViewController
stepViewControllerWillAppear:(RKSTStepViewController *)stepViewController{
    
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
        
        [(RKSTActiveStepViewController*)stepViewController setCustomView:customView];
        
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
        RKSTQuestionStepViewController* qsvc = (RKSTQuestionStepViewController*)stepViewController;
        UILabel* footerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
        footerView.text = @"Custom footer view";
        footerView.textAlignment = NSTextAlignmentCenter;
        footerView.textColor = [UIColor lightGrayColor];
        
        qsvc.footerView = footerView;
    }
}


- (void)taskViewController: (RKSTTaskViewController *)taskViewController didFailOnStep:(RKSTStep *)step withError:(NSError *)error {
    
    // Just log errors to the console
    NSLog(@"Error on step %@: %@", step, error);
    
}

- (void)taskViewControllerDidCancel:(RKSTTaskViewController *)taskViewController {
    
    _currentDocument = nil;
    [taskViewController suspend];
    
    NSLog(@"Close archive");
    [self.taskArchive resetContent];
    self.taskArchive = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewControllerDidComplete:(RKSTTaskViewController *)taskViewController {
    
    NSLog(@"%@", taskViewController.result);
    for (RKSTStepResult* sResult in taskViewController.result.results) {
        NSLog(@"--%@: %@", sResult, sResult.results);
    }
    
    if (_currentDocument)
    {
        RKSTStep* lastStep = [[(RKSTOrderedTask *)taskViewController.task steps] lastObject];
        RKSTConsentSignatureResult *signatureResult = (RKSTConsentSignatureResult *)[[[taskViewController result] stepResultForStepIdentifier:lastStep.identifier] firstResult];
        assert(signatureResult);
        
        [signatureResult applyToDocument:_currentDocument];
        
        [_currentDocument makePdfWithCompletionBlock:^(NSData *pdfData, NSError *error) {
            NSLog(@"Created PDF of size %lu (error = %@)", (unsigned long)[pdfData length], error);
        }];
        
        _currentDocument = nil;
        
    }
    else
    {
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
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:_taskVC forKey:@"taskVC"];
    [coder encodeObject:_lastRouteResult forKey:@"lastRouteResult"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    _taskVC = [coder decodeObjectOfClass:[UIViewController class] forKey:@"taskVC"];
    _lastRouteResult = [coder decodeObjectForKey:@"lastRouteResult"];
    if ([_taskVC.restorationIdentifier isEqualToString:@"DynamicTask01"])
    {
        _taskVC.task = [DynamicTask new];
        _taskVC.defaultResultSource = _lastRouteResult;
    }
    _taskVC.taskDelegate = self;
}



@end
