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
#import "APHBaselineSurvey.h"

//#define VIDEO_DEMO

static NSString * const DatePickingTaskIdentifier = @"dates_001";
static NSString * const SelectionSurveyTaskIdentifier = @"tid_001";
static NSString * const LongTaskIdentifier = @"tid_002";
static NSString * const ConsentReviewTaskIdentifier = @"consent-review";
static NSString * const ConsentTaskIdentifier = @"consent";
static NSString * const MiniFormTaskIdentifier = @"miniform";
static NSString * const EQ5DTaskIdentifier = @"eq5d";
static NSString * const ScreeningTaskIdentifier = @"screening";
static NSString * const ScalesTaskIdentifier = @"scales";
static NSString * const ImageChoicesTaskIdentifier = @"images";
static NSString * const AudioTaskIdentifier = @"audio001";
static NSString * const FitnessTaskIdentifier = @"fitness";
static NSString * const GaitTaskIdentifier = @"gait";
static NSString * const DynamicTaskIdentifier = @"DynamicTask01";
static NSString * const TwoFingerTapTaskIdentifier = @"tap";
static NSString * const BCSEnrollmentTaskIdentifier = @"BCSEnrollment";
static NSString * const BaselineTaskIdentifier = @"Baseline";
static NSString * const CardioActivitySleepSurveyTaskIdentifier = @"CardioActivitySleepSurvey";
static NSString * const BreastCancerConsentIdentifier = @"BreastCancerConsentIdentifier";

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
#ifndef VIDEO_DEMO
    [[UIView appearance] setTintColor:[UIColor orangeColor]];
#endif
    NSMutableDictionary *buttons = [NSMutableDictionary dictionary];
    
    NSMutableArray *buttonKeys = [NSMutableArray array];

#ifndef VIDEO_DEMO
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showConsent:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Consent" forState:UIControlStateNormal];
        [buttonKeys addObject:@"consent"];
        buttons[buttonKeys.lastObject] = button;
        
    }

 
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showConsentSignature:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Consent Signature" forState:UIControlStateNormal];
        [buttonKeys addObject:@"consent_signature"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(pickDates:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Date Survey" forState:UIControlStateNormal];
        [buttonKeys addObject:@"dates"];
        buttons[buttonKeys.lastObject] = button;
    }
#endif
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showAudioTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Audio Task" forState:UIControlStateNormal];
        [buttonKeys addObject:@"audio"];
        buttons[buttonKeys.lastObject] = button;
    }
#ifndef VIDEO_DEMO
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showMiniForm:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Mini Form" forState:UIControlStateNormal];
        [buttonKeys addObject:@"form"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showSelectionSurvey:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Selection Survey" forState:UIControlStateNormal];
        [buttonKeys addObject:@"selection_survey"];
        buttons[buttonKeys.lastObject] = button;
    }
#endif
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showGAIT:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"GAIT" forState:UIControlStateNormal];
        [buttonKeys addObject:@"gait"];
        buttons[buttonKeys.lastObject] = button;
    }

    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showEQ5D:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"EQ-5D-5L" forState:UIControlStateNormal];
        [buttonKeys addObject:@"eq5d"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showFitnessTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Fitness" forState:UIControlStateNormal];
        [buttonKeys addObject:@"fitness"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showTwoFingerTappingTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Two Finger Tapping" forState:UIControlStateNormal];
        [buttonKeys addObject:@"tapping"];
        buttons[buttonKeys.lastObject] = button;
    }
    

#ifndef VIDEO_DEMO
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Show Task" forState:UIControlStateNormal];
        [buttonKeys addObject:@"task"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showDynamicTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Dynamic Task" forState:UIControlStateNormal];
        [buttonKeys addObject:@"dyntask"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showInteruptTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Interruptible Task" forState:UIControlStateNormal];
        [buttonKeys addObject:@"interruptible"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(joinStudy:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Join Study" forState:UIControlStateNormal];
        [buttonKeys addObject:@"join"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(leaveStudy:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Leave Study" forState:UIControlStateNormal];
        [buttonKeys addObject:@"leave"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showScales:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Scale" forState:UIControlStateNormal];
        [buttonKeys addObject:@"scale"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showImageChoices:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Image Choices" forState:UIControlStateNormal];
        [buttonKeys addObject:@"imageChoices"];
        buttons[buttonKeys.lastObject] = button;
    }
#endif
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showBCSEnrollmentTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"BCS Enrollment Survey" forState:UIControlStateNormal];
        [buttonKeys addObject:@"BCS"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showBaselineTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Baseline Survey" forState:UIControlStateNormal];
        [buttonKeys addObject:@"baseline"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showCardioActivitySleepSurvey:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Cardio Activity Sleep" forState:UIControlStateNormal];
        [buttonKeys addObject:@"cardio"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showBreastCancerConsent:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Breast Cancer Consent" forState:UIControlStateNormal];
        [buttonKeys addObject:@"bcConsent"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    
    [buttons enumerateKeysAndObjectsUsingBlock:^(id key, UIView *obj, BOOL *stop) {
        [obj setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:obj];
    }];
    
   
    if (buttons.count > 0) {
         NSString* hvfl = @"";
        if (buttons.count == 1) {
            hvfl= [NSString stringWithFormat:@"H:|[%@]|", buttonKeys.firstObject];
        }else{
            hvfl= [NSString stringWithFormat:@"H:|[%@][%@(==%@)]|", buttonKeys.firstObject, buttonKeys[1], buttonKeys.firstObject];
        }
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:hvfl options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
        
        NSArray* allkeys = buttonKeys;
        BOOL left = YES;
        NSMutableString* leftVfl = [NSMutableString stringWithString:@"V:|-20-"];
        NSMutableString* rightVfl = [NSMutableString stringWithString:@"V:|-20-"];
        
        NSString* leftFirstKey = nil;
        NSString* rightFirstKey = nil;
        
        for (NSString* key in allkeys) {
        
            if (left == YES) {
            
                if (leftFirstKey) {
                    [leftVfl appendFormat:@"[%@(==%@)]", key, leftFirstKey];
                }else{
                    [leftVfl appendFormat:@"[%@]", key];
                }
                
                if (leftFirstKey == nil) {
                    leftFirstKey = key;
                }
            }else{
                
                if (rightFirstKey) {
                    [rightVfl appendFormat:@"[%@(==%@)]", key, rightFirstKey];
                }else{
                    [rightVfl appendFormat:@"[%@]", key];
                }
                
                if (rightFirstKey == nil) {
                    rightFirstKey = key;
                }
            }
            
            left = !left;
        }
        
        [leftVfl appendString:@"-20-|"];
        [rightVfl appendString:@"-20-|"];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:leftVfl options:NSLayoutFormatAlignAllCenterX metrics:nil views:buttons]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:rightVfl options:NSLayoutFormatAlignAllCenterX metrics:nil views:buttons]];
        
    }
    

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

- (RKSTOrderedTask *)datePickingTask {
    NSMutableArray* steps = [NSMutableArray new];
    {
        RKSTInstructionStep* step = [[RKSTInstructionStep alloc] initWithIdentifier:@"iid_001"];
        step.title = @"Date Survey";
        [steps addObject:step];
    }

    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_timeInterval_001"
                                                                    title:@"How long did it take to fall asleep last night?"
                                                                   answer:[RKSTAnswerFormat timeIntervalAnswerFormat]];
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_timeInterval_default_002"
                                                                    title:@"How long did it take to fall asleep last night?"
                                                                   answer:[RKSTAnswerFormat timeIntervalAnswerFormatWithDefaultInterval:300 step:5]];
        [steps addObject:step];
    }
    
    {
        RKSTDateAnswerFormat *dateAnswer = [RKSTDateAnswerFormat dateAnswerFormatWithDefaultDate:nil minimumDate:nil maximumDate:nil calendar: [NSCalendar calendarWithIdentifier:NSCalendarIdentifierHebrew]];
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_date_001"
                                                                 title:@"When is your birthday?"
                                                                   answer:dateAnswer];
        
        [steps addObject:step];
    }
    
    {
        NSDate* defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:10 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate* minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:8 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate* maxDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:12 toDate:[NSDate date] options:(NSCalendarOptions)0];
        RKSTDateAnswerFormat *dateAnswer = [RKSTDateAnswerFormat dateAnswerFormatWithDefaultDate:defaultDate
                                                                           minimumDate:minDate
                                                                           maximumDate:maxDate
                                                                              calendar: [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_date_default_002"
                                                                    title:@"Which day are you avaiable? "
                                                                   answer:dateAnswer];
        
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_timeOfDay_001"
                                                                 title:@"What time do you get up?"
                                                                   answer:[RKSTTimeOfDayAnswerFormat timeOfDayAnswerFormat]];
        [steps addObject:step];
    }

    {
        
        NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
        dateComponents.hour = 8;
        dateComponents.minute = 15;
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_timeOfDay_default_001"
                                                                    title:@"What time do you get up?"
                                                                   answer:[RKSTTimeOfDayAnswerFormat timeOfDayAnswerFormatWithDefaultComponents:dateComponents]];
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_dateTime_001"
                                                                 title:@"When is your next meeting?"
                                                                   answer:[RKSTDateAnswerFormat dateTimeAnswerFormat]];
        [steps addObject:step];
        
    }
    
    {
        NSDate* defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:10 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate* minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:8 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate* maxDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:12 toDate:[NSDate date] options:(NSCalendarOptions)0];
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_dateTime_default_002"
                                                                    title:@"When is your next meeting?"
                                                                   answer:[RKSTDateAnswerFormat dateTimeAnswerFormatWithDefaultDate:defaultDate minimumDate:minDate  maximumDate:maxDate calendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]]];
        [steps addObject:step];
        
    }
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:DatePickingTaskIdentifier steps:steps];
    return task;
}

- (id<RKSTTask>)makeTaskWithIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:DatePickingTaskIdentifier]) {
        return [self datePickingTask];
    } else if ([identifier isEqualToString:SelectionSurveyTaskIdentifier]) {
        return [self makeSelectionSurveyTask];
    } else if ([identifier isEqualToString:LongTaskIdentifier]) {
        return [self makeLongTask];
    } else if ([identifier isEqualToString:ConsentReviewTaskIdentifier]) {
        return [self makeConsentSignatureTask];
    } else if ([identifier isEqualToString:ConsentTaskIdentifier]) {
        return [self makeConsentTask];
    } else if ([identifier isEqualToString:AudioTaskIdentifier]) {
        id<RKSTTask> task = [RKSTOrderedTask audioTaskWithIdentifier:AudioTaskIdentifier
                                          intendedUseDescription:nil
                                               speechInstruction:nil
                                          shortSpeechInstruction:nil
                                                        duration:10
                                               recordingSettings:nil
                                                         options:(RKPredefinedTaskOption)0];
        return task;
    } else if ([identifier isEqualToString:MiniFormTaskIdentifier]) {
        return [self makeMiniFormTask];
    } else if ([identifier isEqualToString:EQ5DTaskIdentifier]) {
        return [self makeEQ5DTask];
    } else if ([identifier isEqualToString:FitnessTaskIdentifier]) {
        return [RKSTOrderedTask fitnessCheckTaskWithIdentifier:FitnessTaskIdentifier
                                      intendedUseDescription:nil
                                                walkDuration:360
                                                restDuration:180
                                                     options:RKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:GaitTaskIdentifier]) {
        return [RKSTOrderedTask shortWalkTaskWithIdentifier:GaitTaskIdentifier
                                   intendedUseDescription:nil
                                      numberOfStepsPerLeg:20
                                             restDuration:30
                                                  options:RKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:DynamicTaskIdentifier]) {
        return [DynamicTask new];
    } else if ([identifier isEqualToString:ScreeningTaskIdentifier]) {
        return [self makeScreeningTask];
    } else if ([identifier isEqualToString:ScalesTaskIdentifier]) {
        return [self makeScalesTask];
    } else if ([identifier isEqualToString:ImageChoicesTaskIdentifier]) {
        return [self makeImageChoicesTask];
    } else if ([identifier isEqualToString:TwoFingerTapTaskIdentifier]) {
        return [RKSTOrderedTask twoFingerTappingIntervalTaskWithIdentifier:TwoFingerTapTaskIdentifier
                                                  intendedUseDescription:nil
                                                                duration:20.0 options:(RKPredefinedTaskOption)0];
    } else if ([identifier isEqualToString:BCSEnrollmentTaskIdentifier]) {
        return [self makeBCSEnrollmentTask];
    }else if ([identifier isEqualToString:BaselineTaskIdentifier]) {
        return [[APHBaselineSurvey alloc] initWithIdentifier:BaselineTaskIdentifier steps:nil];
    }else if ([identifier isEqualToString:CardioActivitySleepSurveyTaskIdentifier]) {
          return [self makeCardioActivitySleepSurveyTask];
    }else if ([identifier isEqualToString:BreastCancerConsentIdentifier]) {
        return [self makeBreastCancerConsent];
    }
    
    return nil;
}

- (void)beginTaskWithIdentifier:(NSString *)identifier {
    id<RKSTTask> task = [self makeTaskWithIdentifier:identifier];
    [self beginTask:task];
}

- (IBAction)pickDates:(id)sender {
    [self beginTaskWithIdentifier:DatePickingTaskIdentifier];
}

- (RKSTOrderedTask *)makeSelectionSurveyTask {
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKSTInstructionStep* step = [[RKSTInstructionStep alloc] initWithIdentifier:@"iid_001"];
        step.title = @"Selection Survey";
        [steps addObject:step];
    }
    
    {
        RKSTNumericAnswerFormat* format = [RKSTNumericAnswerFormat integerAnswerFormatWithUnit:@"years"];
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
                                                                   answer:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleSingleChoice textChoices:@[@"Less than seven", @"Between seven and eight", @"More than eight"]]];
        [steps addObject:step];
    }
    
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_004"
                                                                 title:@"Which symptoms do you have?"
                                                                   answer:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleMultipleChoice textChoices:@[@[@"Cough",@"A cough and/or sore throat"], @[@"Fever", @"A 100F or higher fever or feeling feverish"], @[@"Headaches",@"Headaches and/or body aches"]]  ]];
        
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_005"
                                                                 title:@"How did you feel last night?"
                                                                   answer:[RKSTAnswerFormat textAnswerFormat]];
        [steps addObject:step];
    }
    
    {
        RKSTTextAnswerFormat *format = [RKSTAnswerFormat textAnswerFormat];
        format.multipleLines = NO;
        format.autocapitalizationType = UITextAutocapitalizationTypeWords;
        format.autocorrectionType = UITextAutocorrectionTypeNo;
        format.spellCheckingType = UITextSpellCheckingTypeNo;
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_005a"
                                                                    title:@"What is your name?"
                                                                   answer:format];
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_010"
                                                                 title:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                   answer:[RKSTAnswerFormat scaleAnswerFormatWithMaxValue:10 minValue:0 step:1 defaultValue:NSIntegerMax]];
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
                                                                                                                              unit:nil
                                                                                                                             style:RKNumericAnswerStyleDecimal]];
        [steps addObject:step];
    }
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:SelectionSurveyTaskIdentifier steps:steps];
    
    return task;
}

- (IBAction)showSelectionSurvey:(id)sender {
    [self beginTaskWithIdentifier:SelectionSurveyTaskIdentifier];
}


- (IBAction)showTask:(id)sender{
    [self beginTaskWithIdentifier:LongTaskIdentifier];
}

- (RKSTOrderedTask *)makeLongTask {
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_000"
                                                                    title:@"(Misused)Which symptoms do you have?"
                                                                   answer:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleMultipleChoice
                                                                                                          textChoices:@[@[@"Cough, A cough and/or sore throat, A cough and/or sore throat",@"A cough and/or sore throat, A cough and/or sore throat, A cough and/or sore throat"],
                                                                                                                        @[@"Fever, A 100F or higher fever or feeling feverish"],
                                                                                                                        @[@"", @"Headaches, Headaches and/or body aches"]]  ]];
        
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
        step.stepDuration = 10.0;
        step.text = @"An active test recording audio";
        step.recorderConfigurations = @[[RKSTAudioRecorderConfiguration new]];
        step.shouldUseNextAsSkipButton = YES;
        [steps addObject:step];
    }
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"aid_001e"];
        step.title = @"Audio";
        step.stepDuration = 10.0;
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
        step.stepDuration = 30.0;
        step.spokenInstruction = @"An active test, touch collection";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[RKSTTouchRecorderConfiguration configuration]];
        [steps addObject:step];
    }
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"aid_001b"];
        step.title = @"Button Tap";
        step.text = @"Please tap the orange button when it appears in the green area below.";
        step.stepDuration = 10.0;
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
        RKSTNumericAnswerFormat* format = [RKSTNumericAnswerFormat integerAnswerFormatWithUnit:@"years"];
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
        RKSTNumericAnswerFormat* format = [RKSTNumericAnswerFormat decimalAnswerFormatWithUnit:nil];
        format.minimum = @(0);
        
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_002" title:@"What is your annual salary?" answer:format];
        [steps addObject:step];
    }
    
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_003"
                                                                     title:@"How many hours did you sleep last night?"
                                                                   answer:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleSingleChoice textChoices:@[@"Less than seven", @"Between seven and eight", @"More than eight"] ]];
        [steps addObject:step];
    }
    
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_004"
                                                                     title:@"Which symptoms do you have?"
                                                                   answer:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleMultipleChoice textChoices:@[@[@"Cough",@"A cough and/or sore throat"], @[@"Fever", @"A 100F or higher fever or feeling feverish"], @[@"Headaches",@"Headaches and/or body aches"]]  ]];
        
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_005"
                                                                     title:@"How did you feel last night?"
                                                                   answer:[RKSTTextAnswerFormat textAnswerFormatWithMaximumLength:20]];
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_006"
                                                                     title:@"How long did it take to fall asleep last night?"
                                                                   answer:[RKSTTimeIntervalAnswerFormat timeIntervalAnswerFormat]];
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_007"
                                                                     title:@"When is your birthday?"
                                                                   answer:[RKSTDateAnswerFormat dateAnswerFormat]];
        
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_008"
                                                                     title:@"What time do you get up?"
                                                                   answer:[RKSTTimeOfDayAnswerFormat timeOfDayAnswerFormat]];
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_009"
                                                                     title:@"When is your next meeting?"
                                                                   answer:[RKSTDateAnswerFormat dateTimeAnswerFormat]];
        [steps addObject:step];
        
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"qid_010"
                                                                     title:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                   answer:[RKSTScaleAnswerFormat scaleAnswerFormatWithMaxValue:10 minValue:0 step:1 defaultValue:NSIntegerMax]];
        [steps addObject:step];
    }
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:LongTaskIdentifier steps:steps];
    
    return task;
}



- (IBAction)showConsentSignature:(id)sender {
    [self beginTaskWithIdentifier:ConsentReviewTaskIdentifier];
}

- (RKSTOrderedTask *)makeConsentSignatureTask {
    RKSTConsentDocument *doc = [self buildConsentDocument];
    RKSTConsentSignature *participantSig = doc.signatures[0];
    [participantSig setSignatureDateFormatString:@"yyyy-MM-dd 'at' HH:mm"];
    _currentDocument = [doc copy];
    RKSTConsentReviewStep *reviewStep = [[RKSTConsentReviewStep alloc] initWithIdentifier:@"consent_review" signature:participantSig inDocument:doc];
    reviewStep.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    reviewStep.reasonForConsent = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    RKSTOrderedTask *task = [[RKSTOrderedTask alloc] initWithIdentifier:ConsentReviewTaskIdentifier steps:@[reviewStep]];
    return task;
}

- (IBAction)showConsent:(id)sender{
    [self beginTaskWithIdentifier:ConsentTaskIdentifier];
}

- (RKSTOrderedTask *)makeConsentTask {
    RKSTConsentDocument* consentDocument = [self buildConsentDocument];
    _currentDocument = [consentDocument copy];
    
    RKSTVisualConsentStep *step = [[RKSTVisualConsentStep alloc] initWithIdentifier:@"visual_consent" document:consentDocument];
    RKSTConsentReviewStep *reviewStep = [[RKSTConsentReviewStep alloc] initWithIdentifier:@"consent_review" signature:consentDocument.signatures[0] inDocument:consentDocument];
    reviewStep.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    reviewStep.reasonForConsent = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    RKSTOrderedTask *task = [[RKSTOrderedTask alloc] initWithIdentifier:ConsentTaskIdentifier steps:@[step,reviewStep]];
    
    return task;
}

- (IBAction)showAudioTask:(id)sender{
    [self beginTaskWithIdentifier:AudioTaskIdentifier];
}


- (IBAction)showMiniForm:(id)sender{
    [self beginTaskWithIdentifier:MiniFormTaskIdentifier];
}

- (id<RKSTTask>)makeMiniFormTask {
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKSTInstructionStep* step = [[RKSTInstructionStep alloc] initWithIdentifier:@"mini_form_001"];
        step.title = @"Mini Form";
        [steps addObject:step];
    }
    
    {
        RKSTFormStep* step = [[RKSTFormStep alloc] initWithIdentifier:@"fid_000" title:@"Mini Form" text:@"Mini Form groups multi-entry in one page"];
        NSMutableArray* items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_health_weight1"
                                                                 text:@"Weight"
                                                         answerFormat:
                                [RKSTHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                             unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                            style:RKNumericAnswerStyleDecimal]];
            [items addObject:item];
        }
        
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_health_weight2"
                                                                 text:@"Weight"
                                                         answerFormat:
                                [RKSTHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                             unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                            style:RKNumericAnswerStyleDecimal]];
            item.placeholder = @"Add weight";
            [items addObject:item];
        }
        
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_health_weight3"
                                                                 text:@"Weight"
                                                         answerFormat:
                                [RKSTHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                             unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                            style:RKNumericAnswerStyleDecimal]];
            item.placeholder = @"Input your body weight here. Really long text.";
            [items addObject:item];
        }
        
        
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_health_weight3"
                                                                 text:@"Weight"
                                                         answerFormat:[RKSTNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
            item.placeholder = @"Input your body weight here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
    }
    
    {
        RKSTFormStep* step = [[RKSTFormStep alloc] initWithIdentifier:@"fid_001" title:@"Mini Form" text:@"Mini Form groups multi-entry in one page"];
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
            item.placeholder = @"DOB";
            [items addObject:item];
        }
        {
            
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_health_weight"
                                                                 text:@"Weight"
                                                         answerFormat:
                                [RKSTHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                    unit:nil
                                                                                   style:RKNumericAnswerStyleDecimal]];
            item.placeholder = @"Add weight";
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_001" text:@"Have headache?" answerFormat:[RKSTBooleanAnswerFormat new]];
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_002" text:@"Which fruit do you like most? Please pick one from below."
                                                         answerFormat:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleSingleChoice textChoices:@[@"Apple", @"Orange", @"Banana"]
                                                                                                              ]];
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_003" text:@"Message"
                                                         answerFormat:[RKSTAnswerFormat textAnswerFormat]];
            item.placeholder = @"Your message";
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_004a" text:@"BP Diastolic"
                                                         answerFormat:[RKSTAnswerFormat integerAnswerFormatWithUnit:@"mm Hg"]];
            item.placeholder = @"Enter value";
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_004b" text:@"BP Systolic"
                                                         answerFormat:[RKSTAnswerFormat integerAnswerFormatWithUnit:@"mm Hg"]];
            item.placeholder = @"Enter value";
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_date_001" text:@"Birthdate"
                                                         answerFormat:[RKSTAnswerFormat dateAnswerFormat]];
            item.placeholder = @"Pick a date";
            [items addObject:item];
        }
        
        {
            
            NSDate* defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitYear value:-30 toDate:[NSDate date] options:(NSCalendarOptions)0];
            NSDate* minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitYear value:-150 toDate:[NSDate date] options:(NSCalendarOptions)0];

            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_date_002" text:@"Birthdate"
                                                         answerFormat:[RKSTAnswerFormat dateAnswerFormatWithDefaultDate:defaultDate
                                                                                                        minimumDate:minDate
                                                                                                        maximumDate:[NSDate date]
                                                                                                           calendar:nil]];
            item.placeholder = @"Pick a date (with default)";
            [items addObject:item];
        }
        
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_timeOfDay_001" text:@"Today sunset time?"
                                                         answerFormat:[RKSTAnswerFormat timeOfDayAnswerFormat]];
            item.placeholder = @"No default time";
            [items addObject:item];
        }
        {
            NSDateComponents* defaultDC = [[NSDateComponents alloc] init];
            defaultDC.hour = 14;
            defaultDC.minute = 23;
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_timeOfDay_002" text:@"Today sunset time?"
                                                         answerFormat:[RKSTAnswerFormat timeOfDayAnswerFormatWithDefaultComponents:defaultDC]];
            item.placeholder = @"Default time 14:23";
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_dateTime_001" text:@"Next eclipse visible in Cupertino?"
                                                         answerFormat:[RKSTAnswerFormat dateTimeAnswerFormat]];
            
            item.placeholder = @"No default date and range";
            [items addObject:item];
        }
        
        
        {
            
            NSDate* defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:3 toDate:[NSDate date] options:(NSCalendarOptions)0];
            NSDate* minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:0 toDate:[NSDate date] options:(NSCalendarOptions)0];
            NSDate* maxDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:10 toDate:[NSDate date] options:(NSCalendarOptions)0];
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_dateTime_002" text:@"Next eclipse visible in Cupertino?"
                                                         answerFormat:[RKSTAnswerFormat dateTimeAnswerFormatWithDefaultDate:defaultDate
                                                                                                            minimumDate:minDate
                                                                                                            maximumDate:maxDate
                                                                                                               calendar:nil]];
            
            item.placeholder = @"Default date in 3 days and range(0, 10)";
            [items addObject:item];
        }
        
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_timeInterval_001" text:@"Wake up interval"
                                                         answerFormat:[RKSTAnswerFormat timeIntervalAnswerFormat]];
            item.placeholder = @"No default Interval and step size";
            [items addObject:item];
        }
        {
            RKSTFormItem* item = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_timeInterval_002" text:@"Wake up interval"
                                                         answerFormat:[RKSTAnswerFormat timeIntervalAnswerFormatWithDefaultInterval:300 step:3]];
            
             item.placeholder = @"Default Interval 300 and step size 3";
            [items addObject:item];
        }
        

        {
            
            RKSTImageChoice* option1 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor redColor] size:CGSizeMake(360, 360) border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor redColor] size:CGSizeMake(360, 360) border:YES]
                                                                                 text:@"Red" value:@"red"];
            RKSTImageChoice* option2 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:CGSizeMake(360, 360) border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor orangeColor] size:CGSizeMake(360, 360) border:YES]
                                                                                 text:nil value:@"orange"];
            RKSTImageChoice* option3 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:CGSizeMake(360, 360) border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor yellowColor] size:CGSizeMake(360, 360) border:YES]
                                                                                 text:@"Yellow" value:@"yellow"];
            
            RKSTFormItem* item3 = [[RKSTFormItem alloc] initWithIdentifier:@"fqid_009_3" text:@"Which color do you like?"
                                                          answerFormat:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleSingleChoice imageChoices:@[option1, option2, option3]
                                                                                                               ]];
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
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:MiniFormTaskIdentifier steps:steps];
    
    return task;
    
}


- (IBAction)showEQ5D:(id)sender{
    [self beginTaskWithIdentifier:EQ5DTaskIdentifier];
}

- (id<RKSTTask>)makeEQ5DTask {
    NSArray* qlist = @[@"Mobility",
                       @[@[@"No Problems", @"I have no problems in walking about."], @[@"Slight Problems",@"I have slight problems in walking about."], @[@"Moderate Problems", @"I have moderate problems in walking about."],  @[@"Severe Problems",@"I have severe problems in walking about."], @[@"Unable to complete",@"I am unable to walk about."]],
                       @"Self-Care",
                       @[@[@"No Problems",@"I have no problems washing or dressing myself"], @[@"Slight problems", @"I have slight problems washing or dressing myself"], @[@"Moderate problems", @"I have moderate problems washing or dressing myself"], @[@"Severe problems", @"I have severe problems washing or dressing myself"], @[@"Unable to complete", @"I am unable to wash or dress myself"]],
                       @"Usual Activities",
                       @[@[@"No Problems",@"I have no problems doing my usual activities"], @[@"Slight problems", @"I have slight problems doing my usual activities"], @[@"Moderate problems", @"I have moderate problems doing my usual activities"], @[@"Severe problems", @"I have severe problems doing my usual activities"], @[@"Unable to complete", @"I am unable to do my usual activities"]],
                       @"Pain / Discomfort",
                       @[@[@"No pain or discomfort", @"I have no pain or discomfort"], @[@"Slight pain or discomfort", @"I have slight pain or discomfort"], @[@"Moderate pain or discomfort", @"I have moderate pain or discomfort"], @[@"Severe pain or discomfort", @"I have severe pain or discomfort"], @[@"Extreme pain or discomfort", @"I have extreme pain or discomfort"]],
                       @"Anxiety / Depression",
                       @[@[ @"Not anxious or depressed", @"I am not anxious or depressed"],@[@"Slightly anxious or depressed", @"I am slightly anxious or depressed"], @[@"Moderately anxious or depressed", @"I am moderately anxious or depressed"], @[@"Severely anxious or depressed", @"I am severely anxious or depressed"],@[@"Extremely anxious or depressed", @"I am extremely anxious or depressed"]]
                      ];
    
    NSMutableArray* steps = [[NSMutableArray alloc] init];
    
    int index = 0;
    for (NSString* object in qlist) {
        
        if ([object isKindOfClass:[NSString class]]) {
            index++;
            RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"question_%d", index]
                                                                     title:object
                                                                       answer:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleSingleChoice textChoices:qlist[[qlist indexOfObject:object]+1] ]];
            
            
            
            step.text = @"Please pick the one answer that best describes your health today.";
            
            if (index == 3 ) {
                step.text = [NSString stringWithFormat:@"For example: work, study, housework, family or leisure activities.\n\n%@", step.text] ;
            }
            
            [steps addObject:step];
        }
    }
    
    index++;
    RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"question_%d", index]
                                                             title:@"We would like to know how good or bad your health is today."
                                                               answer:[RKSTAnswerFormat scaleAnswerFormatWithMaxValue:100 minValue:0 step:10 defaultValue:-1]];
    
    step.text = @"This scale is numbered from 0 to 100.\n 100 means the best health you can imagine.\n 0 means the worst health you can imagine. \n\nTap the scale to indicate how your health is today.";
    
    [steps addObject:step];
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:EQ5DTaskIdentifier steps:steps];
    
    return task;
}

- (IBAction)showFitnessTask:(id)sender {
    [self beginTaskWithIdentifier:FitnessTaskIdentifier];
}

- (IBAction)showDynamicTask:(id)sender{
    
    [self beginTaskWithIdentifier:DynamicTaskIdentifier];
    
}

- (IBAction)showGAIT:(id)sender{
    [self beginTaskWithIdentifier:GaitTaskIdentifier];
}

- (IBAction)showInteruptTask:(id)sender{
    [self beginTaskWithIdentifier:ScreeningTaskIdentifier];
}

- (id<RKSTTask>)makeScreeningTask {
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKSTNumericAnswerFormat *format = [RKSTNumericAnswerFormat integerAnswerFormatWithUnit:@"years"];
        format.minimum = @(5);
        format.maximum = @(90);
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"itid_001" title:@"How old are you?" answer:format];
        [steps addObject:step];
    }
    
    {
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"itid_002" title:@"How much did you pay for your car?" answer:[RKSTNumericAnswerFormat decimalAnswerFormatWithUnit:@"USD"]];
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
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:ScreeningTaskIdentifier steps:steps];
    return task;
}

- (IBAction)controlAppearance:(id)sender{
    
    UINavigationController* navc = [[UINavigationController alloc] initWithRootViewController:[AppearanceControlViewController new]];
    [self presentViewController:navc animated:YES completion:nil];
}

- (IBAction)showScales:(id)sender{
    [self beginTaskWithIdentifier:ScalesTaskIdentifier];
}

- (id<RKSTTask>)makeScalesTask {

    NSMutableArray* steps = [NSMutableArray array];
    
    {
        
        RKSTScaleAnswerFormat* scaleAnswerFormat =  [RKSTAnswerFormat scaleAnswerFormatWithMaxValue:10 minValue:0 step:1 defaultValue:NSIntegerMax];
        
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"scale_01"
                                                                    title:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                   answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        
        RKSTScaleAnswerFormat* scaleAnswerFormat =  [RKSTAnswerFormat scaleAnswerFormatWithMaxValue:300 minValue:100 step:50 defaultValue:NSIntegerMax];
        
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"scale_02"
                                                                    title:@"How much money do you need?"
                                                                   answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        
        RKSTScaleAnswerFormat* scaleAnswerFormat =  [RKSTAnswerFormat scaleAnswerFormatWithMaxValue:10 minValue:0 step:1 defaultValue:5];
        
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"scale_05"
                                                                    title:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                   answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        
        RKSTScaleAnswerFormat* scaleAnswerFormat =  [RKSTAnswerFormat scaleAnswerFormatWithMaxValue:300 minValue:100 step:50 defaultValue:174];
        
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:@"scale_06"
                                                                    title:@"How much money do you need?"
                                                                   answer:scaleAnswerFormat];
        [steps addObject:step];
    }

    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:ScalesTaskIdentifier steps:steps];
    return task;
    
}

- (IBAction)showImageChoices:(id)sender{
    [self beginTaskWithIdentifier:ImageChoicesTaskIdentifier];
}

- (id<RKSTTask>)makeImageChoicesTask {
    NSMutableArray* steps = [NSMutableArray new];
    
    for (NSValue* ratio in @[[NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)], [NSValue valueWithCGPoint:CGPointMake(2.0, 1.0)], [NSValue valueWithCGPoint:CGPointMake(1.0, 2.0)]])
    {
        RKSTFormStep* step = [[RKSTFormStep alloc] initWithIdentifier:@"fid_001" title:@"Image Choices Form" text:@"Mini Form groups multi-entry in one page"];
        
        NSMutableArray* items = [NSMutableArray new];
        
        for (NSNumber* dimension in @[@(360), @(60)])
        {
            CGSize size1 = CGSizeMake([dimension floatValue] * [ratio CGPointValue].x, [dimension floatValue] * [ratio CGPointValue].y);
            CGSize size2 = CGSizeMake([dimension floatValue] * [ratio CGPointValue].y, [dimension floatValue] * [ratio CGPointValue].x);
            
            RKSTImageChoice* option1 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor redColor] size:size1 border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor redColor] size:size1 border:YES]
                                                                                 text:@"Red" value:@"red"];
            RKSTImageChoice* option2 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:YES]
                                                                                 text:nil value:@"orange"];
            RKSTImageChoice* option3 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:YES]
                                                                                 text:@"Yellow Yellow Yellow" value:@"yellow"];
            RKSTImageChoice* option4 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor greenColor] size:size2 border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor greenColor] size:size2 border:YES]
                                                                                 text:@"Green" value:@"green"];
            RKSTImageChoice* option5 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor blueColor] size:size1 border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor blueColor] size:size1 border:YES]
                                                                                 text:nil value:@"blue"];
            RKSTImageChoice* option6 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:YES]
                                                                                 text:@"Cyan" value:@"cyanColor"];
            
            
            RKSTFormItem* item1 = [[RKSTFormItem alloc] initWithIdentifier:[@"fqid_009_1" stringByAppendingFormat:@"%@",dimension] text:@"Which color do you like?"
                                                          answerFormat:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleSingleChoice imageChoices:@[option1] ]];
            [items addObject:item1];
            
            RKSTFormItem* item2 = [[RKSTFormItem alloc] initWithIdentifier:[@"fqid_009_2" stringByAppendingFormat:@"%@",dimension] text:@"Which color do you like?"
                                                          answerFormat:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleSingleChoice imageChoices:@[option1, option2] ]];
            [items addObject:item2];
            
            RKSTFormItem* item3 = [[RKSTFormItem alloc] initWithIdentifier:[@"fqid_009_3" stringByAppendingFormat:@"%@",dimension] text:@"Which color do you like?"
                                                          answerFormat:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleSingleChoice imageChoices:@[option1, option2, option3] ]];
            [items addObject:item3];
            
            RKSTFormItem* item6 = [[RKSTFormItem alloc] initWithIdentifier:[@"fqid_009_6" stringByAppendingFormat:@"%@",dimension] text:@"Which color do you like?"
                                                          answerFormat:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleMultipleChoice imageChoices:@[option1, option2, option3, option4, option5, option6] ]];
            [items addObject:item6];
        }
        
        
        [step setFormItems:items];
        
        [steps addObject:step];
        
        
        for (NSNumber* dimension in @[@(360), @(60), @(20)]) {
            CGSize size1 = CGSizeMake([dimension floatValue] * [ratio CGPointValue].x, [dimension floatValue] * [ratio CGPointValue].y);
            CGSize size2 = CGSizeMake([dimension floatValue] * [ratio CGPointValue].y, [dimension floatValue] * [ratio CGPointValue].x);
            
            RKSTImageChoice* option1 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor redColor] size:size1 border:NO]
                                                            selectedImage:[self imageWithColor:[UIColor redColor] size:size1 border:YES]
                                                                     text:@"Red\nRed\nRed\nRed" value:@"red"];
            RKSTImageChoice* option2 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:NO]
                                                            selectedImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:YES]
                                                                     text:@"Orange" value:@"orange"];
            RKSTImageChoice* option3 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:NO]
                                                            selectedImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:YES]
                                                                     text:@"Yellow" value:@"yellow"];
            RKSTImageChoice* option4 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor greenColor] size:size2 border:NO]
                                                            selectedImage:[self imageWithColor:[UIColor greenColor] size:size2 border:YES]
                                                                     text:@"Green" value:@"green"];
            RKSTImageChoice* option5 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor blueColor] size:size1 border:NO]
                                                            selectedImage:[self imageWithColor:[UIColor blueColor] size:size1 border:YES]
                                                                     text:@"Blue" value:@"blue"];
            RKSTImageChoice* option6 = [RKSTImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:NO]
                                                            selectedImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:YES]
                                                                     text:@"Cyan" value:@"cyanColor"];
            
            
            RKSTQuestionStep* step1 = [RKSTQuestionStep questionStepWithIdentifier:@"qid_000color1"
                                                                         title:@"Which color do you like?"
                                                                        answer:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleSingleChoice imageChoices:@[option1] ]];
            [steps addObject:step1];
            
            RKSTQuestionStep* step2 = [RKSTQuestionStep questionStepWithIdentifier:@"qid_000color2"
                                                                         title:@"Which color do you like?"
                                                                        answer:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleSingleChoice imageChoices:@[option1, option2] ]];
            [steps addObject:step2];
            
            RKSTQuestionStep* step3 = [RKSTQuestionStep questionStepWithIdentifier:@"qid_000color3"
                                                                         title:@"Which color do you like?"
                                                                        answer:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleSingleChoice imageChoices:@[option1, option2, option3] ]];
            [steps addObject:step3];
            
            RKSTQuestionStep* step6 = [RKSTQuestionStep questionStepWithIdentifier:@"qid_000color6"
                                                                         title:@"Which color do you like?"
                                                                        answer:[RKSTAnswerFormat choiceAnswerFormatWithStyle:RKChoiceAnswerStyleMultipleChoice imageChoices:@[option1, option2, option3, option4, option5, option6]]];
            [steps addObject:step6];
        }
    }
    
    {
        RKSTActiveStep* step = [[RKSTActiveStep alloc] initWithIdentifier:@"aid_001"];
        step.title = @"Image Choices Form End";
        [steps addObject:step];
    }
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:ImageChoicesTaskIdentifier steps:steps];
    
    return task;
    
}

- (IBAction)showTwoFingerTappingTask:(id)sender{

    [self beginTaskWithIdentifier:TwoFingerTapTaskIdentifier];
}

- (IBAction)showBCSEnrollmentTask:(id)sender{
    [self beginTaskWithIdentifier:BCSEnrollmentTaskIdentifier];
}

- (RKSTOrderedTask*)taskWithPath:(NSString*)path identifier:(NSString*)taskIdentifier{
    NSData* data = [NSData dataWithContentsOfFile:path];
    
    NSDictionary* root = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:nil];
    //NSLog(@"------%@ %@", root[@"questions"], NSStringFromClass([root[@"questions"] class]));
    
    
    NSMutableArray* steps = [NSMutableArray array];
    for (NSDictionary* q in root[@"questions"]) {
        
        //NSLog(@"%@", q);
        
        NSDictionary* constraints = q[@"constraints"];
        NSString* type = constraints[@"type"];
        NSString* identifier = q[@"identifier"];
        NSString* title = q[@"prompt"];
        NSString* text = q[@"text"];
        
        RKSTAnswerFormat* af;
        if ([type isEqualToString:@"DateConstraints"] ) {
            af = [[RKSTDateAnswerFormat alloc] initWithStyle:RKDateAnswerStyleDate];
        }else if ([type isEqualToString:@"MultiValueConstraints"]){
            NSArray* choices = constraints[@"enumeration"];
            
            NSMutableArray* allChoices = [NSMutableArray array];
            NSUInteger index = 0;
            for (NSDictionary* c in choices) {
                index++;
                
                RKSTTextChoice* choice = [[RKSTTextChoice alloc] initWithText:c[@"label"]
                                                               detailText:c[@"text"] value:c[@"value"]];
                [allChoices addObject:choice];
            }
            
            
            
            af = [RKSTAnswerFormat choiceAnswerFormatWithStyle:[constraints[@"allowMultiple"] boolValue]?RKChoiceAnswerStyleMultipleChoice:RKChoiceAnswerStyleSingleChoice
                                                 textChoices:allChoices];
            
            
        }else if ([type isEqualToString:@"IntegerConstraints"]){
    
            af = [[RKSTNumericAnswerFormat alloc] initWithStyle:RKNumericAnswerStyleInteger unit:nil minimum:q[@"minVaue"] maximum:q[@"maxVaue"]];
        }
        else{
            NSLog(@"%@", q);
            NSLog(@"123");
        }
        
        if (af == nil) {
            assert(0);
        }
        
        RKSTQuestionStep* step = [RKSTQuestionStep questionStepWithIdentifier:identifier title:title answer:af];
        step.text = text;
        
        [steps addObject:step];
    }
    
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:taskIdentifier steps:steps];
    
    return task;
}

- (id<RKSTTask>)makeBCSEnrollmentTask{
    
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"BCS Enrollment Survey" ofType:@"json"];
    
    return [self taskWithPath:path identifier:BCSEnrollmentTaskIdentifier];
}

- (IBAction)showBaselineTask:(id)sender{
    [self beginTaskWithIdentifier:BaselineTaskIdentifier];
}

- (IBAction)showCardioActivitySleepSurvey:(id)sender{
    [self beginTaskWithIdentifier:CardioActivitySleepSurveyTaskIdentifier];
}

- (id<RKSTTask>)makeCardioActivitySleepSurveyTask{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"cardio_activity_sleep_survey" ofType:@"json"];
    return [self taskWithPath:path identifier:CardioActivitySleepSurveyTaskIdentifier];
}

- (IBAction)showBreastCancerConsent:(id)sender {
    [self beginTaskWithIdentifier:BreastCancerConsentIdentifier];
}

- (id<RKSTTask>)makeBreastCancerConsent{
    RKSTConsentDocument* consent = [[RKSTConsentDocument alloc] init];
    consent.title = @"Consent";
    consent.signaturePageTitle = @"Consent";
    consent.signaturePageContent = @"I agree  to participate in this research Study.";
    
    
   // UIImage *consentSignatureImage = [UIImage imageWithData:self.dataSubstrate.currentUser.consentSignatureImage];
    RKSTConsentSignature *participantSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Participant"
                                                                        dateFormatString:nil
                                                                              identifier:@"participant"];
    [consent addSignature:participantSig];
    
    
    NSMutableArray* components = [NSMutableArray new];
    
    NSArray* scenes = @[@(RKSTConsentSectionTypeOverview),
                        @(RKSTConsentSectionTypeDataGathering),
                        @(RKSTConsentSectionTypePrivacy),
                        @(RKSTConsentSectionTypeDataUse),
                        @(RKSTConsentSectionTypeTimeCommitment),
                        @(RKSTConsentSectionTypeStudySurvey),
                        @(RKSTConsentSectionTypeStudyTasks),
                        @(RKSTConsentSectionTypeWithdrawing)];
    
    /*
    NSArray* scenes = @[
                        @(RKSTConsentSectionTypeOverview),  //1
                        @(RKSTConsentSectionTypeStudySurvey),  //2
                        @(RKSTConsentSectionTypeDataGathering),    //3
                        @(RKSTConsentSectionTypePrivacy),  //4
                        //@(RKSTConsentSectionTypeCombiningData), //5
                        @(RKSTConsentSectionTypeDataUse), //6
     
                        @(RKSTConsentSectionTypeCustom),    //7.Potential Benefits
                        @(RKSTConsentSectionTypeCustom),    //8.Risk To Privacy
                        @(RKSTConsentSectionTypeCustom), //9. Issues to consider
                        @(RKSTConsentSectionTypeCustom),    //10.Issues to consider
     
                        @(RKSTConsentSectionTypeTimeCommitment), //11. Issues to Consider
                        @(RKSTConsentSectionTypeWithdrawing)]; //12.
    */
    for (int i = 0; i<scenes.count; i ++) {
        
        
        RKSTConsentSectionType sectionType = [scenes[i] integerValue];
        RKSTConsentSection *section = [[RKSTConsentSection alloc] initWithType:sectionType];
        
        switch (sectionType) {
            case RKSTConsentSectionTypeOverview:
            {
                section.title = NSLocalizedString(@"Welcome", nil);
                section.summary = @"This simple walkthrough will explain the study, the impact it may have on your life and will allow you to provide your consent to participate.";
                section.content = @"SUMMARY\n\nYou are invited to participate in a research study to understand variations in symptoms during recovery from breast cancer treatment. This study is designed for women between 18 and 80 years old with a history of breast cancer treatment and women without any history of cancer. Your participation in this study is entirely voluntary.\n\nTo be in a research study you must give your informed consent. The purpose of this form is to help you decide if you want to participate in this study. Please read the information carefully. If you decide to take part in this research study, you will be given a copy of this signed and dated consent form. If you decide to participate, you are free to withdraw your consent, and to discontinue participation at any time.\n\nYou should not join the research study until all of your questions are answered.\n\nParticipating in a research study is not the same as receiving medical care. The decision to join or not join the research study will not affect your medical benefits.\n\nPURPOSE OF THE STUDY \nWomen recovering from breast cancer treatment can have very different and more or less severe symptoms day to day. These symptoms affect quality of life and make managing recovery difficult. We would like to understand the causes of these symptom variations.\n\nNew technologies allow people to record and track their health and symptoms in real time. This study will monitor your health and symptoms using questionnaires and sensors via a mobile phone application.\n\nIf you decide to join the study you will need to download the study application on your mobile device. Then, periodically we will ask you to answer questions and/or perform some tasks on your mobile phone. These questions may be about your health, exercise, diet, sleep and medicines, in addition to some more general health surveys. The tasks may include exercising or journaling about your week. Your study data will include your responses to surveys and tasks and some measurements from the phone itself about how you are moving and interacting with others.\n\nYour data, without your name, will be added to the data of other study participants and made available to groups of researchers worldwide for analysis and future research. You also will have a unique account that you can use to review your own data. We anticipate this study will be open for multiple years, during which time your data will remain available to you to review. We anticipate enrolling 20,000 subjects in this study.\n\nThe sponsor is Sage Bionetworks with some funding from the Robert Wood Johnson Foundation.\n";
            }
                break;
            case RKSTConsentSectionTypeStudySurvey:
            case RKSTConsentSectionTypeStudyTasks:
            {
                //section.title = @"What's involved: Activities";
                section.summary = @"This study will ask you to perform tasks and to respond to surveys.";
                section.content = @"Health Surveys: We will ask you to answer questions about yourself, your medical history, and your current health. You may choose to leave any questions that you do not wish to answer blank. We will ask you to rate your fatigue, cognition, sleep, mood and exercise performance on a scale of 1 to 5 daily. In addition to these daily questions we will ask you to answer brief weekly and monthly surveys about your symptoms in order to track any changes.\n\nTasks: Occasionally we will ask you to perform specific tasks while using your mobile phone and record sensor data directly from your phone. For example, you may be asked to type a short journal entry, which will then be shared and analyzed for typing speed and accuracy as well as word usage. Additionally, you may be asked to provide data from third-party fitness devices (like the Fitbit or Jawbone Up) with your permission.\nWe will send notices on your phone asking you to complete these tasks and surveys. You may choose to act at your convenience, (either then or later) and you may choose to participate in all or only in some parts of the study. These surveys and tasks should take you about 20 minutes each week. You have the right to refuse to answer particular questions and the right to participate in particular aspects of the study.";
            }
                break;
            case RKSTConsentSectionTypeDataGathering:
            {
                section.summary = @"This study will gather sensor data from your phone.";
                section.content = @"New technologies allow people to record and track their health and symptoms in real time. This study is proposing to monitor individual’s health and symptoms using a mobile phone application. This study is unique in that it allows participants to step up as equal partners in both the surveillance and management of symptoms from breast cancer treatment as well as in the research process.\n\nWe will NOT access your personal contacts, other applications, text or email message content, or websites visited.";
            }
                break;
            case RKSTConsentSectionTypePrivacy:
            {
                section.summary = @"Your data will be sent to a secure database where it will be seperated from your personal identity.";
                section.content = @"In order to preserve your privacy, we will use a random code instead of your name on all your study data. This unique code cannot be used to directly identify you. Any data that directly identifies you will be removed before the data is transferred for analysis, although researchers will have the ability to contact you if you have chosen to allow them to do so. We will never sell, rent or lease your contact information.";
            }
                break;
                /*
            case RKSTConsentSectionTypeCombiningData:
            {
                section.summary = @"The de-identified data will be used for research and may be shared with other researchers.";
                section.content = @"We will combine your study data including survey responses and other measurements with those of other study participants. The combined data will be transferred to Synapse, a computational research platform, for analysis. The research team will analyze the combined data and report findings back to the community through Blog or scientific publications. The combined study data on Synapse will also be available to use for other research purposes and will be shared with registered users worldwide who agree to using the data in an ethical manner, to do no harm and not attempt to re-identify or re-contact you unless you have chosen to allow them to do so.";
            }
                break;
                */
            case RKSTConsentSectionTypeDataUse:
            {
                section.summary = @"All of the data will be used and reused for new research.";
                section.content = @"The combined study data on Synapse will also be available to use for other research purposes and will be shared with registered users worldwide who agree to using the data in an ethical manner, to do no harm and not attempt to re-identify or re- contact you unless you have chosen to allow them to do so.\n\nUSE OF DATA FOR FUTURE RESEARCH\nSeveral databases are available to help researchers understand different diseases. These databases contain information and other data helpful to study diseases. This study will include your research data into one such database, Synapse, to be used in future research beyond this study. Your data may benefit future research.\n\nBefore your data is released to the Synapse database, your personal contact information such as your name, e-mail, etc, will be removed. Your unique code identifier will be used in place of your name when your data is released onto Synapse. The study data will be made available on Synapse to registered users who have agreed to using the data in an ethical manner, to do no harm and not attempt to re-identify or re-contact you unless you have chosen to allow them to do so. The Principal Investigator and Sponsor will have no oversight on the future use of the study data released through Synapse.\n\nAlthough you can withdraw from the study at any time, you cannot withdraw the de-identified data that have already been distributed through research databases.\n\nThe main risk of donating your de-identified data to a centralized database is the potential loss of privacy and confidentiality in case of public disclosure due to unintended data breaches, including hacking or other activities outside of the procedures authorized by the study. In such a case, your data may be misused or used for unauthorized purposes by someone sufficiently skilled in data analysis to try to re-identify you. This risk is low.";
            }
                break;
            case RKSTConsentSectionTypeTimeCommitment:
            {
                //section.title = @"Issues to Consider";
                section.summary = @"This study will take about 20 minutes per week.";
                section.content = @"We do not expect any medical side effects from participating. Inconveniences associated with participation include spending approximately 20 minutes per week to respond to questions from the study application.\n\nPAYMENT\nYou will not be paid for being in this study.\n\nCOSTS\nThere is no cost to you to participate in this study other than to your mobile data plan if applicable.";
            }
                break;
            case RKSTConsentSectionTypeCustom:
            {
                if (i == 6) {
                    section.title = @"Potential Benefits";
                    section.summary = @"You will be able to visualize your data and potentially learn more about trends in your health.";
                    section.customImage = [UIImage imageNamed:@"consent_visualize"];
                    section.content = @"The goal of this study is to create knowledge that can benefit us as a society. The benefits are primarily the creation of insights to help current and future patients and their families to better detect, understand and manage their health. We will return the insights learned from analysis of the study data through the study website, but these insights may not be of direct benefit to you. We cannot, and thus we do not, guarantee or promise that you will personally receive any direct benefits from this study. However you will be able to track your health and export your data at will to share with your medical doctor and anyone you choose.";
                    
                } else if (i == 7){
                    section.title = @"Risk to Privacy";
                    section.summary = @"We will make every effort to protect your information, but total anonymity cannot be guaranteed.";
                    section.customImage = [UIImage imageNamed:@"consent_privacy"];
                    section.content = @"You may have concerns about data security, privacy and confidentiality. We take great care to protect your information, however there is a slight risk of loss of privacy. This is a low risk because we separate your personal information (information that can directly identify you, such as your name or phone number) from the research data to respect your privacy. However, even with removal of this information, it is sometimes possible to re-identify an individual given enough cross-reference information about him or her. This risk, while very low, should still be contemplated prior to enrolling.\n\nCONFIDENTIALITY\nWe are committed to protect your privacy. Your identity will be kept as confidential as possible. Except as required by law, you will not be identified by name or by any other direct personal identifier. We will use a random code number instead of your name on all your data collected, analyzed, aggregated and released to researchers. Information about the code will be kept in a secure system. This study anticipates that your data will be added to a combined study dataset placed in a “repository” - an online database – like Sage Bionetworks Synapse where other researchers can access it. No name or contact information will be included in this combined study dataset. Researchers will have access to all the study data but will be unable to easily map any particular data to the identities of the participants. However, there is always a risk that the database can be breached by hackers, or that experts in re- identification may attempt to reverse our processes. Total confidentiality cannot be guaranteed.";
                } else if (i == 8){
                    section.title = @"Issues to Consider";
                    section.summary = @"Some questions may make you uncomfortable. Simply do not respond.";
                    section.customImage = [UIImage imageNamed:@"consent_uncomfortablequestions"];
                    section.content = @"This is not a treatment study and we do not expect any medical side effects from participating.\nSome survey questions may make you feel uncomfortable. Know that the information you provide is entirely up to you and you are free to skip questions that you do not want to answer.\n\nOther people may glimpse the study notifications and/or reminders on your phone and realize you are enrolled in this study. This can make some people feel self- conscious. You can avoid this discomfort by putting a passcode on your phone to block unauthorized users from accessing your phone content.\n\nYou may have concerns about data security, privacy and confidentiality. We take great care to protect your information, however there is a slight risk of loss of privacy. This is a low risk because we separate your personal information (information that can directly identify you, such as your name or phone number) from the research data to respect your privacy. However, even with removal of this information, it is sometimes possible to re-identify an individual given enough cross-reference information about him or her. This risk, while very low, should still be contemplated prior to enrolling.\n\nData collected in this study will count against your existing mobile data plan. You may configure the application to only use WiFi connections to limit the impact this data collection has on your data plan.";
                }else if (i == 9){
                    section.title = @"Issues to Consider";
                    section.summary = @"Participating in this study may change how you feel. You may feel more tired, sad, energized, or happy.";
                    section.customImage = [UIImage imageNamed:@"consent_mood"];
                    section.content = @"Participation in this study may involve risks that are not known at this time.\n\nYou will be told about any new information that might change your decision to be in this study.\n\nSince no medical treatments are provided during this study there are no alternative therapies. The only alternative is to not participate.";
                }
                
            }
                break;
            case RKSTConsentSectionTypeWithdrawing:
            {
                section.summary = @"You may withdraw your consent and discontinue participation at any time.";
                section.content = @"Your authorization for the use and/or disclosure of your health information will expire December 31, 2060.\n\nVOLUNTARY PARTICIPATION AND WITHDRAWAL\nYour participation in this study is voluntary. You do not have to sign this consent form. But if you do not, you will not be able to participate in this research study. You may decide not to participate or you may leave the study at any time. Your decision will not result in any penalty or loss of benefits to which you are entitled.\n● You are not obligated to participate in this study.\n● Your questions should be answered clearly and to your satisfaction, before you choose to participate in the study.\n● You have a right to download or transfer a copy of all of your study data.\n● By agreeing to participate you do not waive any of your legal rights.\n\nIf you choose to withdraw from the research study, we will stop collecting your study data. At the end of the study period we will stop collecting your data, even if the application remains on your phone and you keep using it. If you were interested in joining another study afterward, we would ask you to complete another consent, like this one, explaining the risks and benefits of the new study.\n\nThe Study Principal Investigator or the sponsor may also withdraw you from the study without your consent at any time for any reason, including if it is in your best interest, you do not consent to continue in the study after being told of changes in the research that may affect you, or if the study is cancelled.";
            }
                break;
            default:
                break;
        }
        
        [components addObject:section];
    }
    
    consent.sections = [components copy];
    
    RKSTVisualConsentStep *step = [[RKSTVisualConsentStep alloc] initWithIdentifier:@"visual" document:consent];
    RKSTConsentReviewStep *reviewStep = [[RKSTConsentReviewStep alloc] initWithIdentifier:@"reviewStep" signature:participantSig inDocument:consent];
    reviewStep.reasonForConsent = @"By agreeing you are consenting to take part in this research study.";
    
    RKSTOrderedTask *task = [[RKSTOrderedTask alloc] initWithIdentifier:BreastCancerConsentIdentifier steps:@[step, reviewStep]];
    
    return task;
}


#pragma mark - Helpers

- (RKSTConsentDocument*)buildConsentDocument{
    RKSTConsentDocument* consent = [[RKSTConsentDocument alloc] init];
    consent.title = @"Demo Consent";
    consent.signaturePageTitle = @"Consent";
    consent.signaturePageContent = @"I agree  to participate in this research Study.";
    
    RKSTConsentSignature *participantSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Participant" dateFormatString:nil identifier:@"participantSig"];
    [consent addSignature:participantSig];
    
    RKSTConsentSignature *investigatorSig = [RKSTConsentSignature signatureForPersonWithTitle:@"Investigator" dateFormatString:nil identifier:@"investigatorSig" firstName:@"Jake" lastName:@"Clemson" signatureImage:[UIImage imageNamed:@"signature.png"] dateString:@"9/2/14" ];
    [consent addSignature:investigatorSig];
    
    NSMutableArray* components = [NSMutableArray new];
    
    NSArray* scenes = @[@(RKSTConsentSectionTypeOverview),
                        @(RKSTConsentSectionTypeDataGathering),
                        @(RKSTConsentSectionTypePrivacy),
                        @(RKSTConsentSectionTypeDataUse),
                        @(RKSTConsentSectionTypeTimeCommitment),
                        @(RKSTConsentSectionTypeStudySurvey),
                        @(RKSTConsentSectionTypeStudyTasks),
                        @(RKSTConsentSectionTypeWithdrawing)];
    for (NSNumber* type in scenes) {
        RKSTConsentSection* c = [[RKSTConsentSection alloc] initWithType:type.integerValue];
        c.summary = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
        
        if (type.integerValue == RKSTConsentSectionTypeOverview) {
            c.htmlContent = @"<ul><li>Lorem</li><li>ipsum</li><li>dolor</li></ul><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?</p>\
                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?</p> 研究";
        }else{
            c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?\
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?\
                An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo? Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?\
                An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo? Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?\
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?\
                An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        }
        
        [components addObject:c];
    }
    
    {
        RKSTConsentSection* c = [[RKSTConsentSection alloc] initWithType:RKSTConsentSectionTypeCustom];
        c.summary = @"Custom Scene summary";
        c.title = @"Custom Scene";
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
    self.taskVC.delegate = self;
    NSURL *documents = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
    NSURL *outputDir = [documents URLByAppendingPathComponent:[self.taskVC.taskRunUUID UUIDString]];
    [[NSFileManager defaultManager] createDirectoryAtURL:outputDir withIntermediateDirectories:YES attributes:nil error:nil];
    self.taskVC.outputDirectory = outputDir;
    
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
    //static int counter = 0;
    //counter ++;
    //return ((counter % 2) > 0);
    
    return ([step isKindOfClass:[RKSTInstructionStep class]]);
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
    }else if ([stepViewController.step.identifier hasPrefix:@"question_"]
              && ![stepViewController.step.identifier hasSuffix:@"6"])
    {
        stepViewController.continueButtonTitle = @"Next Question";
    }
    else if ([stepViewController.step.identifier isEqualToString:@"mini_form_001"])
    {
        stepViewController.continueButtonTitle = @"Try Mini Form";
        stepViewController.learnMoreButtonTitle = @"Learn more about this survey";
    }
    else if ([stepViewController.step.identifier isEqualToString:@"gait_002"]) {
        stepViewController.backButtonItem = nil;
    }else if ([stepViewController.step.identifier isEqualToString:@"gait_003"]) {
        stepViewController.backButtonItem = nil;
    }
    else if ([stepViewController.step.identifier isEqualToString: @"qid_001"])
    {
        stepViewController.backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"BACK" style:UIBarButtonItemStylePlain target:stepViewController.backButtonItem.target action:stepViewController.backButtonItem.action];
        stepViewController.cancelButtonItem.title = @"CANCEL";
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
    
    NSURL *dir = taskViewController.outputDirectory;
    [self dismissViewControllerAnimated:YES completion:^{
        if (dir)
        {
            NSError *err = nil;
            if (! [[NSFileManager defaultManager] removeItemAtURL:dir error:&err]) {
                NSLog(@"Error removing %@: %@", dir, err);
            }
        }
    }];
}

- (void)taskViewControllerDidComplete:(RKSTTaskViewController *)taskViewController {
    
    NSLog(@"%@", taskViewController.result);
    for (RKSTStepResult* sResult in taskViewController.result.results) {
        NSLog(@"--%@", sResult);
        for (RKSTResult* result in sResult.results) {
            if ([result isKindOfClass:[RKSTDateQuestionResult class]])
            {
                RKSTDateQuestionResult* dqr = (RKSTDateQuestionResult *)result;
                NSLog(@"    %@:   %@  %@  %@", result.identifier, dqr.answer, dqr.timeZone, dqr.calendar);
            }
            else if ([result isKindOfClass:[RKSTQuestionResult class]])
            {
                RKSTQuestionResult* qr = (RKSTQuestionResult *)result;
                NSLog(@"    %@:   %@", result.identifier, qr.answer);
            }
            else if ([result isKindOfClass:[RKSTTappingIntervalResult class]])
            {
                RKSTTappingIntervalResult* tir = (RKSTTappingIntervalResult *)result;
                NSLog(@"    %@:     %@\n    %@ %@", tir.identifier, tir.samples, NSStringFromCGRect(tir.buttonRect1), NSStringFromCGRect(tir.buttonRect2));
            }
            else if ([result isKindOfClass:[RKSTFileResult class]]) {
                RKSTFileResult *fileResult = (RKSTFileResult *)result;
                NSError *error = nil;
                if (! [self.taskArchive addFileWithURL:fileResult.fileURL contentType:fileResult.contentType metadata:fileResult.userInfo error:&error]) {
                    NSLog(@"Error archiving %@: %@", fileResult.fileURL, error);
                } else {
                    NSLog(@"Archived %@", fileResult.fileURL);
                }
            }
            else
            {
                NSLog(@"    %@:   userInfo: %@", result.identifier, result.userInfo);
            }
        }
    }
    
    if (_currentDocument)
    {
        RKSTStep* lastStep = [[(RKSTOrderedTask *)taskViewController.task steps] lastObject];
        RKSTConsentSignatureResult *signatureResult = (RKSTConsentSignatureResult *)[[[taskViewController result] stepResultForStepIdentifier:lastStep.identifier] firstResult];
        //assert(signatureResult);
        
        [signatureResult applyToDocument:_currentDocument];
        
        [_currentDocument makePDFWithCompletionHandler:^(NSData *pdfData, NSError *error) {
            NSLog(@"Created PDF of size %lu (error = %@)", (unsigned long)[pdfData length], error);
            
            if (! error) {
                NSURL *documents = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
                NSURL *outputUrl = [documents URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", [taskViewController.taskRunUUID UUIDString]]];
                
                [pdfData writeToURL:outputUrl atomically:YES];
                NSLog(@"Wrote PDF to %@", [outputUrl path]);
            }
            
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
#if 0
            if (archiveFileURL)
            {
                [[NSFileManager defaultManager] removeItemAtURL:archiveFileURL error:nil];
            }
#endif
        }
    }
    
    NSURL *dir = taskViewController.outputDirectory;
    [self dismissViewControllerAnimated:YES completion:^{
        if (dir)
        {
            NSError *err = nil;
            if (! [[NSFileManager defaultManager] removeItemAtURL:dir error:&err]) {
                NSLog(@"Error removing %@: %@", dir, err);
            }
        }
    }];
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
    
    // Need to give the task VC back a copy of its task, so it can restore itself.
    
    // Could save and restore the task's identifier separately, but the VC's
    // restoration identifier defaults to the task's identifier.
    id<RKSTTask> taskForTaskVC = [self makeTaskWithIdentifier:_taskVC.restorationIdentifier];
    
    _taskVC.task = taskForTaskVC;
    if ([_taskVC.restorationIdentifier isEqualToString:@"DynamicTask01"])
    {
        _taskVC.defaultResultSource = _lastRouteResult;
    }
    _taskVC.delegate = self;
}



@end
