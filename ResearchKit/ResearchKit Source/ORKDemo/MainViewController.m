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



#import "MainViewController.h"
#import <ResearchKit/ResearchKit_Private.h>
#import <AVFoundation/AVFoundation.h>
#import "DynamicTask.h"
#import "CustomRecorder.h"
#import "AppDelegate.h"
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
static NSString * const AudioTaskIdentifier = @"audio";
static NSString * const FitnessTaskIdentifier = @"fitness";
static NSString * const GaitTaskIdentifier = @"gait";
static NSString * const MemoryTaskIdentifier = @"memory";
static NSString * const DynamicTaskIdentifier = @"DynamicTask01";
static NSString * const TwoFingerTapTaskIdentifier = @"tap";
static NSString * const BCSEnrollmentTaskIdentifier = @"BCSEnrollment";
static NSString * const BaselineTaskIdentifier = @"Baseline";
static NSString * const CardioActivitySleepSurveyTaskIdentifier = @"CardioActivitySleepSurvey";
static NSString * const BreastCancerConsentIdentifier = @"BreastCancerConsentIdentifier";

@interface MainViewController () <ORKTaskViewControllerDelegate>
{
    id<ORKTaskResultSource> _lastRouteResult;
    ORKConsentDocument *_currentDocument;
    NSMutableDictionary *_savedViewControllers;
}

@property (nonatomic, strong) ORKTaskViewController *taskVC;

@end

@implementation MainViewController



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
    
    _savedViewControllers = [NSMutableDictionary new];
    
#ifndef VIDEO_DEMO
    // [[UIView appearance] setTintColor:[UIColor orangeColor]];
#endif
    NSMutableDictionary *buttons = [NSMutableDictionary dictionary];
    
    NSMutableArray *buttonKeys = [NSMutableArray array];

#ifndef VIDEO_DEMO
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showConsent:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Consent" forState:UIControlStateNormal];
        [buttonKeys addObject:@"consent"];
        buttons[buttonKeys.lastObject] = button;
        
    }

 
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showConsentSignature:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Consent Signature" forState:UIControlStateNormal];
        [buttonKeys addObject:@"consent_signature"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(pickDates:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Date Survey" forState:UIControlStateNormal];
        [buttonKeys addObject:@"dates"];
        buttons[buttonKeys.lastObject] = button;
    }
#endif
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showAudioTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Audio Task" forState:UIControlStateNormal];
        [buttonKeys addObject:@"audio"];
        buttons[buttonKeys.lastObject] = button;
    }
#ifndef VIDEO_DEMO
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showMiniForm:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Mini Form" forState:UIControlStateNormal];
        [buttonKeys addObject:@"form"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showSelectionSurvey:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Selection Survey" forState:UIControlStateNormal];
        [buttonKeys addObject:@"selection_survey"];
        buttons[buttonKeys.lastObject] = button;
    }
#endif
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showGAIT:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"GAIT" forState:UIControlStateNormal];
        [buttonKeys addObject:@"gait"];
        buttons[buttonKeys.lastObject] = button;
    }

    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
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
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showTwoFingerTappingTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Two Finger Tapping" forState:UIControlStateNormal];
        [buttonKeys addObject:@"tapping"];
        buttons[buttonKeys.lastObject] = button;
    }
    

#ifndef VIDEO_DEMO
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Show Task" forState:UIControlStateNormal];
        [buttonKeys addObject:@"task"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showMemoryTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Memory Game" forState:UIControlStateNormal];
        [buttonKeys addObject:@"memory"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showDynamicTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Dynamic Task" forState:UIControlStateNormal];
        [buttonKeys addObject:@"dyntask"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showInteruptTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Interruptible Task" forState:UIControlStateNormal];
        [buttonKeys addObject:@"interruptible"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showScales:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Scale" forState:UIControlStateNormal];
        [buttonKeys addObject:@"scale"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showImageChoices:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Image Choices" forState:UIControlStateNormal];
        [buttonKeys addObject:@"imageChoices"];
        buttons[buttonKeys.lastObject] = button;
    }
#endif
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showBCSEnrollmentTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"BCS Enrollment Survey" forState:UIControlStateNormal];
        [buttonKeys addObject:@"BCS"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showBaselineTask:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Baseline Survey" forState:UIControlStateNormal];
        [buttonKeys addObject:@"baseline"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(showCardioActivitySleepSurvey:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Cardio Activity Sleep" forState:UIControlStateNormal];
        [buttonKeys addObject:@"cardio"];
        buttons[buttonKeys.lastObject] = button;
    }
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
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
         NSString *hvfl = @"";
        if (buttons.count == 1) {
            hvfl= [NSString stringWithFormat:@"H:|[%@]|", buttonKeys.firstObject];
        } else {
            hvfl= [NSString stringWithFormat:@"H:|[%@][%@(==%@)]|", buttonKeys.firstObject, buttonKeys[1], buttonKeys.firstObject];
        }
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:hvfl options:(NSLayoutFormatOptions)0 metrics:nil views:buttons]];
        
        NSArray *allkeys = buttonKeys;
        BOOL left = YES;
        NSMutableString *leftVfl = [NSMutableString stringWithString:@"V:|-20-"];
        NSMutableString *rightVfl = [NSMutableString stringWithString:@"V:|-20-"];
        
        NSString *leftFirstKey = nil;
        NSString *rightFirstKey = nil;
        
        for (NSString *key in allkeys) {
        
            if (left == YES) {
            
                if (leftFirstKey) {
                    [leftVfl appendFormat:@"[%@(==%@)]", key, leftFirstKey];
                } else {
                    [leftVfl appendFormat:@"[%@]", key];
                }
                
                if (leftFirstKey == nil) {
                    leftFirstKey = key;
                }
            } else {
                
                if (rightFirstKey) {
                    [rightVfl appendFormat:@"[%@(==%@)]", key, rightFirstKey];
                } else {
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

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void)dealloc
{
}

#pragma mark - button handlers


- (ORKOrderedTask *)datePickingTask {
    NSMutableArray *steps = [NSMutableArray new];
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"iid_001"];
        step.title = @"Date Survey";
        step.detailText = @"date pickers";
        [steps addObject:step];
    }

    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_timeInterval_001"
                                                                    title:@"How long did it take to fall asleep last night?"
                                                                   answer:[ORKAnswerFormat timeIntervalAnswerFormat]];
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_timeInterval_default_002"
                                                                    title:@"How long did it take to fall asleep last night?"
                                                                   answer:[ORKAnswerFormat timeIntervalAnswerFormatWithDefaultInterval:300 step:5]];
        [steps addObject:step];
    }
    
    {
        ORKDateAnswerFormat *dateAnswer = [ORKDateAnswerFormat dateAnswerFormatWithDefaultDate:nil minimumDate:nil maximumDate:nil calendar: [NSCalendar calendarWithIdentifier:NSCalendarIdentifierHebrew]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_date_001"
                                                                 title:@"When is your birthday?"
                                                                   answer:dateAnswer];
        
        [steps addObject:step];
    }
    
    {
        NSDate *defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:10 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate *minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:8 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate *maxDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:12 toDate:[NSDate date] options:(NSCalendarOptions)0];
        ORKDateAnswerFormat *dateAnswer = [ORKDateAnswerFormat dateAnswerFormatWithDefaultDate:defaultDate
                                                                           minimumDate:minDate
                                                                           maximumDate:maxDate
                                                                              calendar: [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_date_default_002"
                                                                    title:@"What day are you available?"
                                                                   answer:dateAnswer];
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_timeOfDay_001"
                                                                 title:@"What time do you get up?"
                                                                   answer:[ORKTimeOfDayAnswerFormat timeOfDayAnswerFormat]];
        [steps addObject:step];
    }

    {
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.hour = 8;
        dateComponents.minute = 15;
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_timeOfDay_default_001"
                                                                    title:@"What time do you get up?"
                                                                   answer:[ORKTimeOfDayAnswerFormat timeOfDayAnswerFormatWithDefaultComponents:dateComponents]];
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_dateTime_001"
                                                                 title:@"When is your next meeting?"
                                                                   answer:[ORKDateAnswerFormat dateTimeAnswerFormat]];
        [steps addObject:step];
        
    }
    
    {
        NSDate *defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:10 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate *minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:8 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate *maxDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:12 toDate:[NSDate date] options:(NSCalendarOptions)0];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_dateTime_default_002"
                                                                    title:@"When is your next meeting?"
                                                                   answer:[ORKDateAnswerFormat dateTimeAnswerFormatWithDefaultDate:defaultDate minimumDate:minDate  maximumDate:maxDate calendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]]];
        [steps addObject:step];
        
    }
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:DatePickingTaskIdentifier steps:steps];
    return task;
}

- (id<ORKTask>)makeTaskWithIdentifier:(NSString *)identifier {
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
        id<ORKTask> task = [ORKOrderedTask audioTaskWithIdentifier:AudioTaskIdentifier
                                          intendedUseDescription:nil
                                               speechInstruction:nil
                                          shortSpeechInstruction:nil
                                                        duration:10
                                               recordingSettings:nil
                                                         options:(ORKPredefinedTaskOption)0];
        return task;
    } else if ([identifier isEqualToString:MiniFormTaskIdentifier]) {
        return [self makeMiniFormTask];
    } else if ([identifier isEqualToString:EQ5DTaskIdentifier]) {
        return [self makeEQ5DTask];
    } else if ([identifier isEqualToString:FitnessTaskIdentifier]) {
        return [ORKOrderedTask fitnessCheckTaskWithIdentifier:FitnessTaskIdentifier
                                      intendedUseDescription:nil
                                                walkDuration:360
                                                restDuration:180
                                                     options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:GaitTaskIdentifier]) {
        return [ORKOrderedTask shortWalkTaskWithIdentifier:GaitTaskIdentifier
                                   intendedUseDescription:nil
                                      numberOfStepsPerLeg:20
                                             restDuration:30
                                                  options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:MemoryTaskIdentifier]) {
        return [ORKOrderedTask spatialSpanMemoryTaskWithIdentifier:MemoryTaskIdentifier
                                           intendedUseDescription:nil
                                                      initialSpan:3
                                                      minimumSpan:2
                                                      maximumSpan:15
                                                        playSpeed:1
                                                         maxTests:5
                                           maxConsecutiveFailures:3
                                                customTargetImage:nil
                                           customTargetPluralName:nil
                                                  requireReversal:NO
                                                          options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:DynamicTaskIdentifier]) {
        return [DynamicTask new];
    } else if ([identifier isEqualToString:ScreeningTaskIdentifier]) {
        return [self makeScreeningTask];
    } else if ([identifier isEqualToString:ScalesTaskIdentifier]) {
        return [self makeScalesTask];
    } else if ([identifier isEqualToString:ImageChoicesTaskIdentifier]) {
        return [self makeImageChoicesTask];
    } else if ([identifier isEqualToString:TwoFingerTapTaskIdentifier]) {
        return [ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:TwoFingerTapTaskIdentifier
                                                  intendedUseDescription:nil
                                                                duration:20.0 options:(ORKPredefinedTaskOption)0];
    } else if ([identifier isEqualToString:BCSEnrollmentTaskIdentifier]) {
        return [self makeBCSEnrollmentTask];
    } else if ([identifier isEqualToString:BaselineTaskIdentifier]) {
        return [[APHBaselineSurvey alloc] initWithIdentifier:BaselineTaskIdentifier steps:nil];
    } else if ([identifier isEqualToString:CardioActivitySleepSurveyTaskIdentifier]) {
          return [self makeCardioActivitySleepSurveyTask];
    } else if ([identifier isEqualToString:BreastCancerConsentIdentifier]) {
        return [self makeBreastCancerConsent];
    }
    
    return nil;
}

- (void)beginTaskWithIdentifier:(NSString *)identifier {
    
    id<ORKTask> task = [self makeTaskWithIdentifier:identifier];
    
    if (_savedViewControllers[identifier])
    {
        NSData *data = _savedViewControllers[identifier];
        self.taskVC = [[ORKTaskViewController alloc] initWithTask:task restorationData:data];
    }
    else
    {
        self.taskVC = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    }
    
    [self beginTask];
}

- (IBAction)pickDates:(id)sender {
    [self beginTaskWithIdentifier:DatePickingTaskIdentifier];
}

- (ORKOrderedTask *)makeSelectionSurveyTask {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"iid_001"];
        step.title = @"Selection Survey";
        [steps addObject:step];
    }
    
    {
        ORKNumericAnswerFormat *format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"years"];
        format.minimum = @(0);
        format.maximum = @(199);
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_001" title:@"How old are you?" answer:format];
        [steps addObject:step];
    }
    
    {
        ORKBooleanAnswerFormat *format = [ORKBooleanAnswerFormat new];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_001b" title:@"Do you consent to a background check?" answer:format];
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_003"
                                                                 title:@"How many hours did you sleep last night?"
                                                                   answer:[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:@[@"Less than seven", @"Between seven and eight", @"More than eight"]]];
        [steps addObject:step];
    }
    
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_004"
                                                                 title:@"Which symptoms do you have?"
                                                                   answer:[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:@[@[@"Cough",@"A cough and/or sore throat"], @[@"Fever", @"A 100F or higher fever or feeling feverish"], @[@"Headaches",@"Headaches and/or body aches"]]  ]];
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_005"
                                                                 title:@"How did you feel last night?"
                                                                   answer:[ORKAnswerFormat textAnswerFormat]];
        [steps addObject:step];
    }
    
    {
        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormat];
        format.multipleLines = NO;
        format.autocapitalizationType = UITextAutocapitalizationTypeWords;
        format.autocorrectionType = UITextAutocorrectionTypeNo;
        format.spellCheckingType = UITextSpellCheckingTypeNo;
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_005a"
                                                                    title:@"What is your name?"
                                                                   answer:format];
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_010"
                                                                 title:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                   answer:[ORKAnswerFormat scaleAnswerFormatWithMaxValue:10 minValue:0 step:1 defaultValue:NSIntegerMax]];
        [steps addObject:step];
    }
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"fqid_health_biologicalSex"
                                                                 title:@"What is your biological sex?"
                                                                   answer:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]]];
        [steps addObject:step];
    }
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"fqid_health_bloodType"
                                                                 title:@"What is your blood type?"
                                                                   answer:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType]]];
        [steps addObject:step];
    }
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"fqid_health_dob"
                                                                 title:@"What is your date of birth?"
                                                                   answer:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]]];
        [steps addObject:step];
    }
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"fqid_health_weight"
                                                                 title:@"How much do you weigh?"
                                                                   answer:[ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                                                              unit:nil
                                                                                                                             style:ORKNumericAnswerStyleDecimal]];
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:SelectionSurveyTaskIdentifier steps:steps];
    
    return task;
}

- (IBAction)showSelectionSurvey:(id)sender {
    [self beginTaskWithIdentifier:SelectionSurveyTaskIdentifier];
}


- (IBAction)showTask:(id)sender {
    [self beginTaskWithIdentifier:LongTaskIdentifier];
}

- (ORKOrderedTask *)makeLongTask {
    NSMutableArray *steps = [NSMutableArray new];
    
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_081"
                                                                    title:@"Select a symptom"
                                                                   answer:[ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:@[@[@"Cough"],
                                                                                                                        @[@"Fever"],
                                                                                                                        @[@"Headaches"]]  ]];
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_000"
                                                                    title:@"(Misused)Which symptoms do you have?"
                                                                   answer:[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice
                                                                                                          textChoices:@[@[@"Cough, A cough and/or sore throat, A cough and/or sore throat",@"A cough and/or sore throat, A cough and/or sore throat, A cough and/or sore throat"],
                                                                                                                        @[@"Fever, A 100F or higher fever or feeling feverish"],
                                                                                                                        @[@"", @"Headaches, Headaches and/or body aches"]]  ]];
        
        [steps addObject:step];
    }
    
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"iid_001"];
        step.title = @"Demo Study";
        step.text = @"This 12-step walkthrough will explain the study and the impact it will have on your life.";
        step.detailText = @"You must complete the walkthough to participate in the study.";
        [steps addObject:step];
    }
    
    {
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001d"];
        step.title = @"Audio";
        step.stepDuration = 10.0;
        step.text = @"An active test recording audio";
        step.recorderConfigurations = @[[ORKAudioRecorderConfiguration new]];
        step.shouldUseNextAsSkipButton = YES;
        [steps addObject:step];
    }
    
    {
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001e"];
        step.title = @"Audio";
        step.stepDuration = 10.0;
        step.text = @"An active test recording lossless audio";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[[ORKAudioRecorderConfiguration alloc] initWithRecorderSettings:@{AVFormatIDKey : @(kAudioFormatAppleLossless),
                                                                                                         AVNumberOfChannelsKey : @(2),
                                                                                                         AVSampleRateKey: @(44100.0)
                                                                                                         }]];
        [steps addObject:step];
    }
    
    {
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001a"];
        step.title = @"Touch";
        step.text = @"An active test, touch collection";
        step.shouldStartTimerAutomatically = NO;
        step.stepDuration = 30.0;
        step.spokenInstruction = @"An active test, touch collection";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[ORKTouchRecorderConfiguration new]];
        [steps addObject:step];
    }
    
    {
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001b"];
        step.title = @"Button Tap";
        step.text = @"Please tap the orange button when it appears in the green area below.";
        step.stepDuration = 10.0;
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[CustomRecorderConfiguration new]];
        [steps addObject:step];
    }
    
    {
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001c"];
        step.title = @"Motion";
        step.text = @"An active test collecting device motion data";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[[ORKDeviceMotionRecorderConfiguration alloc] initWithFrequency:100.0]];
        [steps addObject:step];
    }
    
    {
        ORKNumericAnswerFormat *format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"years"];
        format.minimum = @(0);
        format.maximum = @(199);
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_001" title:@"How old are you?" answer:format];
        [steps addObject:step];
    }
    
    {
        ORKBooleanAnswerFormat *format = [ORKBooleanAnswerFormat new];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_001b" title:@"Do you consent to a background check?" answer:format];
        [steps addObject:step];
    }
    
    
    {
        ORKNumericAnswerFormat *format = [ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil];
        format.minimum = @(0);
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_002" title:@"What is your annual salary?" answer:format];
        [steps addObject:step];
    }
    
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_003"
                                                                     title:@"How many hours did you sleep last night?"
                                                                   answer:[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:@[@"Less than seven", @"Between seven and eight", @"More than eight"] ]];
        [steps addObject:step];
    }
    
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_004"
                                                                     title:@"Which symptoms do you have?"
                                                                   answer:[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:@[@[@"Cough",@"A cough and/or sore throat"], @[@"Fever", @"A 100F or higher fever or feeling feverish"], @[@"Headaches",@"Headaches and/or body aches"]]  ]];
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_005"
                                                                     title:@"How did you feel last night?"
                                                                   answer:[ORKTextAnswerFormat textAnswerFormatWithMaximumLength:20]];
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_006"
                                                                     title:@"How long did it take to fall asleep last night?"
                                                                   answer:[ORKTimeIntervalAnswerFormat timeIntervalAnswerFormat]];
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_007"
                                                                     title:@"When is your birthday?"
                                                                   answer:[ORKDateAnswerFormat dateAnswerFormat]];
        
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_008"
                                                                     title:@"What time do you get up?"
                                                                   answer:[ORKTimeOfDayAnswerFormat timeOfDayAnswerFormat]];
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_009"
                                                                     title:@"When is your next meeting?"
                                                                   answer:[ORKDateAnswerFormat dateTimeAnswerFormat]];
        [steps addObject:step];
        
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_010"
                                                                     title:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                   answer:[ORKScaleAnswerFormat scaleAnswerFormatWithMaxValue:10 minValue:0 step:1 defaultValue:NSIntegerMax]];
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:LongTaskIdentifier steps:steps];
    
    return task;
}



- (IBAction)showConsentSignature:(id)sender {
    [self beginTaskWithIdentifier:ConsentReviewTaskIdentifier];
}

- (ORKOrderedTask *)makeConsentSignatureTask {
    ORKConsentSharingStep *sharingStep =
    [[ORKConsentSharingStep alloc] initWithIdentifier:@"consent_sharing"
                           investigatorShortDescription:@"Stanford"
                       investigatorLongDescription:@"Stanford and its partners"
                        localizedLearnMoreHTMLContent:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."];
    
    ORKConsentDocument *doc = [self buildConsentDocument];
    ORKConsentSignature *participantSig = doc.signatures[0];
    [participantSig setSignatureDateFormatString:@"yyyy-MM-dd 'at' HH:mm"];
    _currentDocument = [doc copy];
    ORKConsentReviewStep *reviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:@"consent_review" signature:participantSig inDocument:doc];
    reviewStep.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    reviewStep.reasonForConsent = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:ConsentReviewTaskIdentifier steps:@[sharingStep,reviewStep]];
    return task;
}

- (IBAction)showConsent:(id)sender {
    [self beginTaskWithIdentifier:ConsentTaskIdentifier];
}

- (ORKOrderedTask *)makeConsentTask {
    ORKConsentDocument *consentDocument = [self buildConsentDocument];
    _currentDocument = [consentDocument copy];
    
    ORKVisualConsentStep *step = [[ORKVisualConsentStep alloc] initWithIdentifier:@"visual_consent" document:consentDocument];
    ORKConsentReviewStep *reviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:@"consent_review" signature:consentDocument.signatures[0] inDocument:consentDocument];
    reviewStep.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    reviewStep.reasonForConsent = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:ConsentTaskIdentifier steps:@[step,reviewStep]];
    
    return task;
}

- (IBAction)showAudioTask:(id)sender {
    [self beginTaskWithIdentifier:AudioTaskIdentifier];
}


- (IBAction)showMiniForm:(id)sender {
    [self beginTaskWithIdentifier:MiniFormTaskIdentifier];
}

- (id<ORKTask>)makeMiniFormTask {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"mini_form_001"];
        step.title = @"Mini Form";
        [steps addObject:step];
    }
    
    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_000" title:@"Mini Form" text:@"Mini Form groups multi-entry in one page"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight1"
                                                                 text:@"Weight"
                                                         answerFormat:
                                [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                             unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                            style:ORKNumericAnswerStyleDecimal]];
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight2"
                                                                 text:@"Weight"
                                                         answerFormat:
                                [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                             unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                            style:ORKNumericAnswerStyleDecimal]];
            item.placeholder = @"Add weight";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight3"
                                                                 text:@"Weight"
                                                         answerFormat:
                                [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                             unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                            style:ORKNumericAnswerStyleDecimal]];
            item.placeholder = @"Input your body weight here. Really long text.";
            [items addObject:item];
        }
        
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight4"
                                                                 text:@"Weight"
                                                         answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
            item.placeholder = @"Input your body weight here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
    }
    
    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_001" title:@"Mini Form" text:@"Mini Form groups multi-entry in one page"];
        NSMutableArray *items = [NSMutableArray new];
        
        {
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_biologicalSex" text:@"Gender" answerFormat:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]]];
            [items addObject:item];
        }
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Basic Information"];
            [items addObject:item];
        }
        {
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_bloodType" text:@"Blood Type" answerFormat:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType]]];
            item.placeholder = @"Choose a type";
            [items addObject:item];
        }
        {
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_dob" text:@"Date of Birth" answerFormat:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]]];
            item.placeholder = @"DOB";
            [items addObject:item];
        }
        {
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight"
                                                                 text:@"Weight"
                                                         answerFormat:
                                [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                    unit:nil
                                                                                   style:ORKNumericAnswerStyleDecimal]];
            item.placeholder = @"Add weight";
            [items addObject:item];
        }
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_001" text:@"Have headache?" answerFormat:[ORKBooleanAnswerFormat new]];
            [items addObject:item];
        }
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_002" text:@"Which fruit do you like most? Please pick one from below."
                                                         answerFormat:[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:@[@"Apple", @"Orange", @"Banana"]
                                                                                                              ]];
            [items addObject:item];
        }
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_003" text:@"Message"
                                                         answerFormat:[ORKAnswerFormat textAnswerFormat]];
            item.placeholder = @"Your message";
            [items addObject:item];
        }
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_004a" text:@"BP Diastolic"
                                                         answerFormat:[ORKAnswerFormat integerAnswerFormatWithUnit:@"mm Hg"]];
            item.placeholder = @"Enter value";
            [items addObject:item];
        }
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_004b" text:@"BP Systolic"
                                                         answerFormat:[ORKAnswerFormat integerAnswerFormatWithUnit:@"mm Hg"]];
            item.placeholder = @"Enter value";
            [items addObject:item];
        }
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_date_001" text:@"Birthdate"
                                                         answerFormat:[ORKAnswerFormat dateAnswerFormat]];
            item.placeholder = @"Pick a date";
            [items addObject:item];
        }
        
        {
            
            NSDate *defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitYear value:-30 toDate:[NSDate date] options:(NSCalendarOptions)0];
            NSDate *minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitYear value:-150 toDate:[NSDate date] options:(NSCalendarOptions)0];

            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_date_002" text:@"Birthdate"
                                                         answerFormat:[ORKAnswerFormat dateAnswerFormatWithDefaultDate:defaultDate
                                                                                                        minimumDate:minDate
                                                                                                        maximumDate:[NSDate date]
                                                                                                           calendar:nil]];
            item.placeholder = @"Pick a date (with default)";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_timeOfDay_001" text:@"Today sunset time?"
                                                         answerFormat:[ORKAnswerFormat timeOfDayAnswerFormat]];
            item.placeholder = @"No default time";
            [items addObject:item];
        }
        {
            NSDateComponents *defaultDC = [[NSDateComponents alloc] init];
            defaultDC.hour = 14;
            defaultDC.minute = 23;
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_timeOfDay_002" text:@"Today sunset time?"
                                                         answerFormat:[ORKAnswerFormat timeOfDayAnswerFormatWithDefaultComponents:defaultDC]];
            item.placeholder = @"Default time 14:23";
            [items addObject:item];
        }
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_dateTime_001" text:@"Next eclipse visible in Cupertino?"
                                                         answerFormat:[ORKAnswerFormat dateTimeAnswerFormat]];
            
            item.placeholder = @"No default date and range";
            [items addObject:item];
        }
        
        
        {
            
            NSDate *defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:3 toDate:[NSDate date] options:(NSCalendarOptions)0];
            NSDate *minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:0 toDate:[NSDate date] options:(NSCalendarOptions)0];
            NSDate *maxDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:10 toDate:[NSDate date] options:(NSCalendarOptions)0];
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_dateTime_002" text:@"Next eclipse visible in Cupertino?"
                                                         answerFormat:[ORKAnswerFormat dateTimeAnswerFormatWithDefaultDate:defaultDate
                                                                                                            minimumDate:minDate
                                                                                                            maximumDate:maxDate
                                                                                                               calendar:nil]];
            
            item.placeholder = @"Default date in 3 days and range(0, 10)";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_timeInterval_001" text:@"Wake up interval"
                                                         answerFormat:[ORKAnswerFormat timeIntervalAnswerFormat]];
            item.placeholder = @"No default Interval and step size";
            [items addObject:item];
        }
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_timeInterval_002" text:@"Wake up interval"
                                                         answerFormat:[ORKAnswerFormat timeIntervalAnswerFormatWithDefaultInterval:300 step:3]];
            
             item.placeholder = @"Default Interval 300 and step size 3";
            [items addObject:item];
        }
        

        {
            
            ORKImageChoice *option1 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor redColor] size:CGSizeMake(360, 360) border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor redColor] size:CGSizeMake(360, 360) border:YES]
                                                                                 text:@"Red" value:@"red"];
            ORKImageChoice *option2 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:CGSizeMake(360, 360) border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor orangeColor] size:CGSizeMake(360, 360) border:YES]
                                                                                 text:nil value:@"orange"];
            ORKImageChoice *option3 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:CGSizeMake(360, 360) border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor yellowColor] size:CGSizeMake(360, 360) border:YES]
                                                                                 text:@"Yellow" value:@"yellow"];
            
            ORKFormItem *item3 = [[ORKFormItem alloc] initWithIdentifier:@"fqid_009_3" text:@"Which color do you like?"
                                                          answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3]
                                                                                                               ]];
            [items addObject:item3];
        }
    
        
        [step setFormItems:items];
        
        [steps addObject:step];
    }
    
    {
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001"];
        step.title = @"Mini Form End";
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:MiniFormTaskIdentifier steps:steps];
    
    return task;
    
}


- (IBAction)showEQ5D:(id)sender {
    [self beginTaskWithIdentifier:EQ5DTaskIdentifier];
}

- (id<ORKTask>)makeEQ5DTask {
    NSArray *qlist = @[@"Mobility",
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
    
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    int index = 0;
    for (NSString *object in qlist) {
        
        if ([object isKindOfClass:[NSString class]]) {
            index++;
            ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"question_%d", index]
                                                                     title:object
                                                                       answer:[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:qlist[[qlist indexOfObject:object]+1] ]];
            
            
            
            step.text = @"Please pick the one answer that best describes your health today.";
            
            if (index == 3 ) {
                step.text = [NSString stringWithFormat:@"For example: work, study, housework, family or leisure activities.\n\n%@", step.text] ;
            }
            
            [steps addObject:step];
        }
    }
    
    index++;
    ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"question_%d", index]
                                                             title:@"We would like to know how good or bad your health is today."
                                                               answer:[ORKAnswerFormat scaleAnswerFormatWithMaxValue:100 minValue:0 step:10 defaultValue:-1]];
    
    step.text = @"This scale is numbered from 0 to 100.\n 100 means the best health you can imagine.\n 0 means the worst health you can imagine. \n\nTap the scale to indicate how your health is today.";
    
    [steps addObject:step];
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:EQ5DTaskIdentifier steps:steps];
    
    return task;
}

- (IBAction)showFitnessTask:(id)sender {
    [self beginTaskWithIdentifier:FitnessTaskIdentifier];
}

- (IBAction)showDynamicTask:(id)sender {
    
    [self beginTaskWithIdentifier:DynamicTaskIdentifier];
    
}

- (IBAction)showGAIT:(id)sender {
    [self beginTaskWithIdentifier:GaitTaskIdentifier];
}

- (IBAction)showMemoryTask:(id)sender {
    [self beginTaskWithIdentifier:MemoryTaskIdentifier];
}

- (IBAction)showInteruptTask:(id)sender {
    [self beginTaskWithIdentifier:ScreeningTaskIdentifier];
}

- (id<ORKTask>)makeScreeningTask {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKNumericAnswerFormat *format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"years"];
        format.minimum = @(5);
        format.maximum = @(90);
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"itid_001" title:@"How old are you?" answer:format];
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"itid_002" title:@"How much did you pay for your car?" answer:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:@"USD"]];
        [steps addObject:step];
    }
    
    {
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"itid_003"];
        step.title = @"Thank you for completing this task.";
        step.spokenInstruction = step.text;
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:ScreeningTaskIdentifier steps:steps];
    return task;
}

- (IBAction)showScales:(id)sender {
    [self beginTaskWithIdentifier:ScalesTaskIdentifier];
}

- (id<ORKTask>)makeScalesTask {

    NSMutableArray *steps = [NSMutableArray array];
    
    {
        
        ORKContinuousScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat continuousScaleAnswerFormatWithMaxValue:10 minValue:1 defaultValue:NSIntegerMax maximumFractionDigits:2];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_01"
                                                                    title:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                   answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaxValue:300 minValue:100 step:50 defaultValue:NSIntegerMax];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_02"
                                                                    title:@"How much money do you need?"
                                                                   answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaxValue:10 minValue:0 step:1 defaultValue:5];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_05"
                                                                    title:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                   answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaxValue:300 minValue:100 step:50 defaultValue:174];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_06"
                                                                    title:@"How much money do you need?"
                                                                   answer:scaleAnswerFormat];
        [steps addObject:step];
    }

    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:ScalesTaskIdentifier steps:steps];
    return task;
    
}

- (IBAction)showImageChoices:(id)sender {
    [self beginTaskWithIdentifier:ImageChoicesTaskIdentifier];
}

- (id<ORKTask>)makeImageChoicesTask {
    NSMutableArray *steps = [NSMutableArray new];
    
    for (NSValue *ratio in @[[NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)], [NSValue valueWithCGPoint:CGPointMake(2.0, 1.0)], [NSValue valueWithCGPoint:CGPointMake(1.0, 2.0)]])
    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_001" title:@"Image Choices Form" text:@"Mini Form groups multi-entry in one page"];
        
        NSMutableArray *items = [NSMutableArray new];
        
        for (NSNumber *dimension in @[@(360), @(60)])
        {
            CGSize size1 = CGSizeMake([dimension floatValue] * [ratio CGPointValue].x, [dimension floatValue] * [ratio CGPointValue].y);
            CGSize size2 = CGSizeMake([dimension floatValue] * [ratio CGPointValue].y, [dimension floatValue] * [ratio CGPointValue].x);
            
            ORKImageChoice *option1 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor redColor] size:size1 border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor redColor] size:size1 border:YES]
                                                                                 text:@"Red" value:@"red"];
            ORKImageChoice *option2 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:YES]
                                                                                 text:nil value:@"orange"];
            ORKImageChoice *option3 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:YES]
                                                                                 text:@"Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow" value:@"yellow"];
            ORKImageChoice *option4 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor greenColor] size:size2 border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor greenColor] size:size2 border:YES]
                                                                                 text:@"Green" value:@"green"];
            ORKImageChoice *option5 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor blueColor] size:size1 border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor blueColor] size:size1 border:YES]
                                                                                 text:nil value:@"blue"];
            ORKImageChoice *option6 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:NO]
                                                                        selectedImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:YES]
                                                                                 text:@"Cyan" value:@"cyanColor"];
            
            
            ORKFormItem *item1 = [[ORKFormItem alloc] initWithIdentifier:[@"fqid_009_1" stringByAppendingFormat:@"%@",dimension] text:@"Which color do you like?"
                                                          answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1] ]];
            [items addObject:item1];
            
            ORKFormItem *item2 = [[ORKFormItem alloc] initWithIdentifier:[@"fqid_009_2" stringByAppendingFormat:@"%@",dimension] text:@"Which color do you like?"
                                                          answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2] ]];
            [items addObject:item2];
            
            ORKFormItem *item3 = [[ORKFormItem alloc] initWithIdentifier:[@"fqid_009_3" stringByAppendingFormat:@"%@",dimension] text:@"Which color do you like?"
                                                          answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3] ]];
            [items addObject:item3];
            
            ORKFormItem *item6 = [[ORKFormItem alloc] initWithIdentifier:[@"fqid_009_6" stringByAppendingFormat:@"%@",dimension] text:@"Which color do you like?"
                                                          answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3, option4, option5, option6] ]];
            [items addObject:item6];
        }
        
        
        [step setFormItems:items];
        
        [steps addObject:step];
        
        
        for (NSNumber *dimension in @[@(360), @(60), @(20)]) {
            CGSize size1 = CGSizeMake([dimension floatValue] * [ratio CGPointValue].x, [dimension floatValue] * [ratio CGPointValue].y);
            CGSize size2 = CGSizeMake([dimension floatValue] * [ratio CGPointValue].y, [dimension floatValue] * [ratio CGPointValue].x);
            
            ORKImageChoice *option1 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor redColor] size:size1 border:NO]
                                                            selectedImage:[self imageWithColor:[UIColor redColor] size:size1 border:YES]
                                                                     text:@"Red\nRed\nRed\nRed" value:@"red"];
            ORKImageChoice *option2 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:NO]
                                                            selectedImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:YES]
                                                                     text:@"Orange" value:@"orange"];
            ORKImageChoice *option3 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:NO]
                                                            selectedImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:YES]
                                                                     text:@"Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow" value:@"yellow"];
            ORKImageChoice *option4 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor greenColor] size:size2 border:NO]
                                                            selectedImage:[self imageWithColor:[UIColor greenColor] size:size2 border:YES]
                                                                     text:@"Green" value:@"green"];
            ORKImageChoice *option5 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor blueColor] size:size1 border:NO]
                                                            selectedImage:[self imageWithColor:[UIColor blueColor] size:size1 border:YES]
                                                                     text:@"Blue" value:@"blue"];
            ORKImageChoice *option6 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:NO]
                                                            selectedImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:YES]
                                                                     text:@"Cyan" value:@"cyanColor"];
            
            
            ORKQuestionStep *step1 = [ORKQuestionStep questionStepWithIdentifier:@"qid_000color1"
                                                                         title:@"Which color do you like?"
                                                                        answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1] ]];
            [steps addObject:step1];
            
            ORKQuestionStep *step2 = [ORKQuestionStep questionStepWithIdentifier:@"qid_000color2"
                                                                         title:@"Which color do you like?"
                                                                        answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2] ]];
            [steps addObject:step2];
            
            ORKQuestionStep *step3 = [ORKQuestionStep questionStepWithIdentifier:@"qid_000color3"
                                                                         title:@"Which color do you like?"
                                                                        answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3] ]];
            [steps addObject:step3];
            
            ORKQuestionStep *step6 = [ORKQuestionStep questionStepWithIdentifier:@"qid_000color6"
                                                                         title:@"Which color do you like?"
                                                                        answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3, option4, option5, option6]]];
            [steps addObject:step6];
        }
    }
    
    {
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001"];
        step.title = @"Image Choices Form End";
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:ImageChoicesTaskIdentifier steps:steps];
    
    return task;
    
}

- (IBAction)showTwoFingerTappingTask:(id)sender {

    [self beginTaskWithIdentifier:TwoFingerTapTaskIdentifier];
}

- (IBAction)showBCSEnrollmentTask:(id)sender {
    [self beginTaskWithIdentifier:BCSEnrollmentTaskIdentifier];
}

- (ORKOrderedTask *)taskWithPath:(NSString *)path identifier:(NSString *)taskIdentifier {
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:nil];
    //NSLog(@"------%@ %@", root[@"questions"], NSStringFromClass([root[@"questions"] class]));
    
    
    NSMutableArray *steps = [NSMutableArray array];
    for (NSDictionary *q in root[@"questions"]) {
        
        //NSLog(@"%@", q);
        
        NSDictionary *constraints = q[@"constraints"];
        NSString *type = constraints[@"type"];
        NSString *identifier = q[@"identifier"];
        NSString *title = q[@"prompt"];
        NSString *text = q[@"text"];
        
        ORKAnswerFormat *af;
        if ([type isEqualToString:@"DateConstraints"] ) {
            af = [[ORKDateAnswerFormat alloc] initWithStyle:ORKDateAnswerStyleDate];
        } else if ([type isEqualToString:@"MultiValueConstraints"]){
            NSArray *choices = constraints[@"enumeration"];
            
            NSMutableArray *allChoices = [NSMutableArray array];
            NSUInteger index = 0;
            for (NSDictionary *c in choices) {
                index++;
                
                ORKTextChoice *choice = [[ORKTextChoice alloc] initWithText:c[@"label"]
                                                               detailText:c[@"text"] value:c[@"value"]];
                [allChoices addObject:choice];
            }
            
            
            
            af = [ORKAnswerFormat choiceAnswerFormatWithStyle:[constraints[@"allowMultiple"] boolValue]?ORKChoiceAnswerStyleMultipleChoice:ORKChoiceAnswerStyleSingleChoice
                                                 textChoices:allChoices];
            
            
        } else if ([type isEqualToString:@"IntegerConstraints"]){
    
            af = [[ORKNumericAnswerFormat alloc] initWithStyle:ORKNumericAnswerStyleInteger unit:nil minimum:q[@"minVaue"] maximum:q[@"maxVaue"]];
        }
        else {
            NSLog(@"%@", q);
            NSLog(@"123");
        }
        
        if (af == nil) {
            assert(0);
        }
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:identifier title:title answer:af];
        step.text = text;
        
        [steps addObject:step];
    }
    
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:taskIdentifier steps:steps];
    
    return task;
}

- (id<ORKTask>)makeBCSEnrollmentTask {
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"BCS Enrollment Survey" ofType:@"json"];
    
    return [self taskWithPath:path identifier:BCSEnrollmentTaskIdentifier];
}

- (IBAction)showBaselineTask:(id)sender {
    [self beginTaskWithIdentifier:BaselineTaskIdentifier];
}

- (IBAction)showCardioActivitySleepSurvey:(id)sender {
    [self beginTaskWithIdentifier:CardioActivitySleepSurveyTaskIdentifier];
}

- (id<ORKTask>)makeCardioActivitySleepSurveyTask {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cardio_activity_sleep_survey" ofType:@"json"];
    return [self taskWithPath:path identifier:CardioActivitySleepSurveyTaskIdentifier];
}

- (IBAction)showBreastCancerConsent:(id)sender {
    [self beginTaskWithIdentifier:BreastCancerConsentIdentifier];
}

- (id<ORKTask>)makeBreastCancerConsent {
    ORKConsentDocument *consent = [[ORKConsentDocument alloc] init];
    consent.title = @"Consent";
    consent.signaturePageTitle = @"Consent";
    consent.signaturePageContent = @"I agree  to participate in this research Study.";
    
    
   // UIImage *consentSignatureImage = [UIImage imageWithData:self.dataSubstrate.currentUser.consentSignatureImage];
    ORKConsentSignature *participantSig = [ORKConsentSignature signatureForPersonWithTitle:@"Participant"
                                                                        dateFormatString:nil
                                                                              identifier:@"participant"];
    [consent addSignature:participantSig];
    
    
    NSMutableArray *components = [NSMutableArray new];
    
    NSArray *scenes = @[@(ORKConsentSectionTypeOverview),
                        @(ORKConsentSectionTypeDataGathering),
                        @(ORKConsentSectionTypePrivacy),
                        @(ORKConsentSectionTypeDataUse),
                        @(ORKConsentSectionTypeTimeCommitment),
                        @(ORKConsentSectionTypeStudySurvey),
                        @(ORKConsentSectionTypeStudyTasks),
                        @(ORKConsentSectionTypeWithdrawing)];
    
    /*
    NSArray *scenes = @[
                        @(ORKConsentSectionTypeOverview),  //1
                        @(ORKConsentSectionTypeStudySurvey),  //2
                        @(ORKConsentSectionTypeDataGathering),    //3
                        @(ORKConsentSectionTypePrivacy),  //4
                        //@(ORKConsentSectionTypeCombiningData), //5
                        @(ORKConsentSectionTypeDataUse), //6
     
                        @(ORKConsentSectionTypeCustom),    //7.Potential Benefits
                        @(ORKConsentSectionTypeCustom),    //8.Risk To Privacy
                        @(ORKConsentSectionTypeCustom), //9. Issues to consider
                        @(ORKConsentSectionTypeCustom),    //10.Issues to consider
     
                        @(ORKConsentSectionTypeTimeCommitment), //11. Issues to Consider
                        @(ORKConsentSectionTypeWithdrawing)]; //12.
    */
    for (int i = 0; i<scenes.count; i ++) {
        
        
        ORKConsentSectionType sectionType = [scenes[i] integerValue];
        ORKConsentSection *section = [[ORKConsentSection alloc] initWithType:sectionType];
        
        switch (sectionType) {
            case ORKConsentSectionTypeOverview:
            {
                section.title = NSLocalizedString(@"Welcome", nil);
                section.summary = @"This simple walkthrough will explain the study, the impact it may have on your life and will allow you to provide your consent to participate.";
                section.content = @"SUMMARY\n\nYou are invited to participate in a research study to understand variations in symptoms during recovery from breast cancer treatment. This study is designed for women between 18 and 80 years old with a history of breast cancer treatment and women without any history of cancer. Your participation in this study is entirely voluntary.\n\nTo be in a research study you must give your informed consent. The purpose of this form is to help you decide if you want to participate in this study. Please read the information carefully. If you decide to take part in this research study, you will be given a copy of this signed and dated consent form. If you decide to participate, you are free to withdraw your consent, and to discontinue participation at any time.\n\nYou should not join the research study until all of your questions are answered.\n\nParticipating in a research study is not the same as receiving medical care. The decision to join or not join the research study will not affect your medical benefits.\n\nPURPOSE OF THE STUDY \nWomen recovering from breast cancer treatment can have very different and more or less severe symptoms day to day. These symptoms affect quality of life and make managing recovery difficult. We would like to understand the causes of these symptom variations.\n\nNew technologies allow people to record and track their health and symptoms in real time. This study will monitor your health and symptoms using questionnaires and sensors via a mobile phone application.\n\nIf you decide to join the study you will need to download the study application on your mobile device. Then, periodically we will ask you to answer questions and/or perform some tasks on your mobile phone. These questions may be about your health, exercise, diet, sleep and medicines, in addition to some more general health surveys. The tasks may include exercising or journaling about your week. Your study data will include your responses to surveys and tasks and some measurements from the phone itself about how you are moving and interacting with others.\n\nYour data, without your name, will be added to the data of other study participants and made available to groups of researchers worldwide for analysis and future research. You also will have a unique account that you can use to review your own data. We anticipate this study will be open for multiple years, during which time your data will remain available to you to review. We anticipate enrolling 20,000 subjects in this study.\n\nThe sponsor is Sage Bionetworks with some funding from the Robert Wood Johnson Foundation.\n";
            }
                break;
            case ORKConsentSectionTypeStudySurvey:
            case ORKConsentSectionTypeStudyTasks:
            {
                //section.title = @"What's involved: Activities";
                section.summary = @"This study will ask you to perform tasks and to respond to surveys.";
                section.content = @"Health Surveys: We will ask you to answer questions about yourself, your medical history, and your current health. You may choose to leave any questions that you do not wish to answer blank. We will ask you to rate your fatigue, cognition, sleep, mood and exercise performance on a scale of 1 to 5 daily. In addition to these daily questions we will ask you to answer brief weekly and monthly surveys about your symptoms in order to track any changes.\n\nTasks: Occasionally we will ask you to perform specific tasks while using your mobile phone and record sensor data directly from your phone. For example, you may be asked to type a short journal entry, which will then be shared and analyzed for typing speed and accuracy as well as word usage. Additionally, you may be asked to provide data from third-party fitness devices (like the Fitbit or Jawbone Up) with your permission.\nWe will send notices on your phone asking you to complete these tasks and surveys. You may choose to act at your convenience, (either then or later) and you may choose to participate in all or only in some parts of the study. These surveys and tasks should take you about 20 minutes each week. You have the right to refuse to answer particular questions and the right to participate in particular aspects of the study.";
            }
                break;
            case ORKConsentSectionTypeDataGathering:
            {
                section.summary = @"This study will gather sensor data from your phone.";
                section.content = @"New technologies allow people to record and track their health and symptoms in real time. This study is proposing to monitor individual’s health and symptoms using a mobile phone application. This study is unique in that it allows participants to step up as equal partners in both the surveillance and management of symptoms from breast cancer treatment as well as in the research process.\n\nWe will NOT access your personal contacts, other applications, text or email message content, or websites visited.";
            }
                break;
            case ORKConsentSectionTypePrivacy:
            {
                section.summary = @"Your data will be sent to a secure database where it will be seperated from your personal identity.";
                section.content = @"In order to preserve your privacy, we will use a random code instead of your name on all your study data. This unique code cannot be used to directly identify you. Any data that directly identifies you will be removed before the data is transferred for analysis, although researchers will have the ability to contact you if you have chosen to allow them to do so. We will never sell, rent or lease your contact information.";
            }
                break;
                /*
            case ORKConsentSectionTypeCombiningData:
            {
                section.summary = @"The de-identified data will be used for research and may be shared with other researchers.";
                section.content = @"We will combine your study data including survey responses and other measurements with those of other study participants. The combined data will be transferred to Synapse, a computational research platform, for analysis. The research team will analyze the combined data and report findings back to the community through Blog or scientific publications. The combined study data on Synapse will also be available to use for other research purposes and will be shared with registered users worldwide who agree to using the data in an ethical manner, to do no harm and not attempt to re-identify or re-contact you unless you have chosen to allow them to do so.";
            }
                break;
                */
            case ORKConsentSectionTypeDataUse:
            {
                section.summary = @"All of the data will be used and reused for new research.";
                section.content = @"The combined study data on Synapse will also be available to use for other research purposes and will be shared with registered users worldwide who agree to using the data in an ethical manner, to do no harm and not attempt to re-identify or re- contact you unless you have chosen to allow them to do so.\n\nUSE OF DATA FOR FUTURE RESEARCH\nSeveral databases are available to help researchers understand different diseases. These databases contain information and other data helpful to study diseases. This study will include your research data into one such database, Synapse, to be used in future research beyond this study. Your data may benefit future research.\n\nBefore your data is released to the Synapse database, your personal contact information such as your name, e-mail, etc, will be removed. Your unique code identifier will be used in place of your name when your data is released onto Synapse. The study data will be made available on Synapse to registered users who have agreed to using the data in an ethical manner, to do no harm and not attempt to re-identify or re-contact you unless you have chosen to allow them to do so. The Principal Investigator and Sponsor will have no oversight on the future use of the study data released through Synapse.\n\nAlthough you can withdraw from the study at any time, you cannot withdraw the de-identified data that have already been distributed through research databases.\n\nThe main risk of donating your de-identified data to a centralized database is the potential loss of privacy and confidentiality in case of public disclosure due to unintended data breaches, including hacking or other activities outside of the procedures authorized by the study. In such a case, your data may be misused or used for unauthorized purposes by someone sufficiently skilled in data analysis to try to re-identify you. This risk is low.";
            }
                break;
            case ORKConsentSectionTypeTimeCommitment:
            {
                //section.title = @"Issues to Consider";
                section.summary = @"This study will take about 20 minutes per week.";
                section.content = @"We do not expect any medical side effects from participating. Inconveniences associated with participation include spending approximately 20 minutes per week to respond to questions from the study application.\n\nPAYMENT\nYou will not be paid for being in this study.\n\nCOSTS\nThere is no cost to you to participate in this study other than to your mobile data plan if applicable.";
            }
                break;
            case ORKConsentSectionTypeCustom:
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
                } else if (i == 9){
                    section.title = @"Issues to Consider";
                    section.summary = @"Participating in this study may change how you feel. You may feel more tired, sad, energized, or happy.";
                    section.customImage = [UIImage imageNamed:@"consent_mood"];
                    section.content = @"Participation in this study may involve risks that are not known at this time.\n\nYou will be told about any new information that might change your decision to be in this study.\n\nSince no medical treatments are provided during this study there are no alternative therapies. The only alternative is to not participate.";
                }
                
            }
                break;
            case ORKConsentSectionTypeWithdrawing:
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
    
    ORKVisualConsentStep *step = [[ORKVisualConsentStep alloc] initWithIdentifier:@"visual" document:consent];
    ORKConsentReviewStep *reviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:@"reviewStep" signature:participantSig inDocument:consent];
    reviewStep.reasonForConsent = @"By agreeing you are consenting to take part in this research study.";
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:BreastCancerConsentIdentifier steps:@[step, reviewStep]];
    
    return task;
}


#pragma mark - Helpers

- (ORKConsentDocument *)buildConsentDocument {
    ORKConsentDocument *consent = [[ORKConsentDocument alloc] init];
    consent.htmlReviewContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cardio_fullconsent" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    consent.title = @"Demo Consent";
    consent.signaturePageTitle = @"Consent";
    consent.signaturePageContent = @"I agree  to participate in this research Study.";
    
    ORKConsentSignature *participantSig = [ORKConsentSignature signatureForPersonWithTitle:@"Participant" dateFormatString:nil identifier:@"participantSig"];
    [consent addSignature:participantSig];
    
    ORKConsentSignature *investigatorSig = [ORKConsentSignature signatureForPersonWithTitle:@"Investigator" dateFormatString:nil identifier:@"investigatorSig" givenName:@"Jake" familyName:@"Clemson" signatureImage:[UIImage imageNamed:@"signature.png"] dateString:@"9/2/14" ];
    [consent addSignature:investigatorSig];
    
    NSMutableArray *components = [NSMutableArray new];
    
    NSArray *scenes = @[@(ORKConsentSectionTypeOverview),
                        @(ORKConsentSectionTypeDataGathering),
                        @(ORKConsentSectionTypePrivacy),
                        @(ORKConsentSectionTypeDataUse),
                        @(ORKConsentSectionTypeTimeCommitment),
                        @(ORKConsentSectionTypeStudySurvey),
                        @(ORKConsentSectionTypeStudyTasks),
                        @(ORKConsentSectionTypeWithdrawing)];
    for (NSNumber *type in scenes) {
        ORKConsentSection *c = [[ORKConsentSection alloc] initWithType:type.integerValue];
        c.summary = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
        
        if (type.integerValue == ORKConsentSectionTypeOverview) {
            c.htmlContent = @"<ul><li>Lorem</li><li>ipsum</li><li>dolor</li></ul><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?</p>\
                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?</p> 研究";
        } else {
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
        ORKConsentSection *c = [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
        c.summary = @"Custom Scene summary";
        c.title = @"Custom Scene";
        c.customImage = [UIImage imageNamed:@"image_example.png"];
        c.customLearnMoreButtonTitle = @"Learn more about customizing ResearchKit";
        c.content = @"You can customize ResearchKit a lot!";
        [components addObject:c];
    }
    
    {
        ORKConsentSection *c = [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeOnlyInDocument];
        c.summary = @"OnlyInDocument Scene summary";
        c.title = @"OnlyInDocument Scene";
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    consent.sections = [components copy];
    return consent;
}

- (void)beginTask
{
    id<ORKTask> task = self.taskVC.task;
    self.taskVC.delegate = self;

    if (_taskVC.outputDirectory == nil) {
        NSURL *documents = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        NSURL *outputDir = [documents URLByAppendingPathComponent:[self.taskVC.taskRunUUID UUIDString]];
        [[NSFileManager defaultManager] createDirectoryAtURL:outputDir withIntermediateDirectories:YES attributes:nil error:nil];
        self.taskVC.outputDirectory = outputDir;
    }
    
    if ([task isKindOfClass:[DynamicTask class]])
    {
        self.taskVC.defaultResultSource = _lastRouteResult;
    }
    _taskVC.restorationIdentifier = [task identifier];
    
    [self presentViewController:_taskVC animated:YES completion:nil];
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size border:(BOOL)border {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
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

#pragma mark - ORKTaskViewControllerDelegate

- (BOOL)taskViewController:(ORKTaskViewController *)taskViewController hasLearnMoreForStep:(ORKStep *)step {
   
    NSString *task_identifier = taskViewController.task.identifier;

    return ([step isKindOfClass:[ORKInstructionStep class]]
            && NO == [@[AudioTaskIdentifier, FitnessTaskIdentifier, GaitTaskIdentifier, TwoFingerTapTaskIdentifier] containsObject:task_identifier]);
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController learnMoreForStep:(ORKStepViewController *)stepViewController {
    NSLog(@"Want to learn more = %@", stepViewController);
}


- (BOOL)taskViewController:(ORKTaskViewController *)taskViewController shouldPresentStep:(ORKStep *)step {
    if ([ step.identifier isEqualToString:@"itid_002"]) {
        ORKQuestionResult *qr = (ORKQuestionResult *)[[[taskViewController result] stepResultForStepIdentifier:@"itid_001"] firstResult];
        if (qr== nil || [(NSNumber *)qr.answer integerValue] < 18) {
            UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"Warning" message:@"You can't participate if you are under 18." preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction *ok = [UIAlertAction
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

- (void)taskViewController:(ORKTaskViewController *)taskViewController
stepViewControllerWillAppear:(ORKStepViewController *)stepViewController {
    
    if ([stepViewController.step.identifier isEqualToString:@"aid_001c"]) {
        UIView *customView = [UIView new];
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
        
        [(ORKActiveStepViewController *)stepViewController setCustomView:customView];
        
        // Set custom button on navi bar
        stepViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Custom button"
                                                                                               style:UIBarButtonItemStylePlain
                                                                                              target:nil
                                                                                              action:nil];
    } else if ([stepViewController.step.identifier hasPrefix:@"question_"]
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
    } else if ([stepViewController.step.identifier isEqualToString:@"gait_003"]) {
        stepViewController.backButtonItem = nil;
    }
    else if ([stepViewController.step.identifier isEqualToString: @"qid_001"])
    {
        stepViewController.backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"BACK" style:UIBarButtonItemStylePlain target:stepViewController.backButtonItem.target action:stepViewController.backButtonItem.action];
        stepViewController.cancelButtonItem.title = @"CANCEL";
    }
}


- (void)_dismissTaskViewController:(ORKTaskViewController *)taskViewController {
    
    _currentDocument = nil;
    [taskViewController suspend];
    
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

- (BOOL)taskViewControllerSupportsSaveAndRestore:(ORKTaskViewController *)taskViewController {
    
    return YES;
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithResult:(ORKTaskViewControllerResult)result error:(NSError *)error
{
    switch (result) {
        case ORKTaskViewControllerResultCompleted:
            [self _taskViewControllerDidComplete:taskViewController];
            break;
        case ORKTaskViewControllerResultFailed:
            NSLog(@"Error on step %@: %@", taskViewController.currentStepViewController.step, error);
            break;
        case ORKTaskViewControllerResultDiscarded:
            [self _dismissTaskViewController:taskViewController];
            break;
        case ORKTaskViewControllerResultSaved:
        {
            _savedViewControllers[[taskViewController.task identifier]] = [taskViewController restorationData];
            [self _dismissTaskViewController:taskViewController];
            return;
        }
            break;
            
        default:
            break;
    }
    
    [_savedViewControllers removeObjectForKey:[taskViewController.task identifier]];
}


- (void)_taskViewControllerDidComplete:(ORKTaskViewController *)taskViewController {
    
    NSLog(@"%@", taskViewController.result);
    for (ORKStepResult *sResult in taskViewController.result.results) {
        NSLog(@"--%@", sResult);
        for (ORKResult *result in sResult.results) {
            if ([result isKindOfClass:[ORKDateQuestionResult class]])
            {
                ORKDateQuestionResult *dqr = (ORKDateQuestionResult *)result;
                NSLog(@"    %@:   %@  %@  %@", result.identifier, dqr.answer, dqr.timeZone, dqr.calendar);
            }
            else if ([result isKindOfClass:[ORKQuestionResult class]])
            {
                ORKQuestionResult *qr = (ORKQuestionResult *)result;
                NSLog(@"    %@:   %@", result.identifier, qr.answer);
            }
            else if ([result isKindOfClass:[ORKTappingIntervalResult class]])
            {
                ORKTappingIntervalResult *tir = (ORKTappingIntervalResult *)result;
                NSLog(@"    %@:     %@\n    %@ %@", tir.identifier, tir.samples, NSStringFromCGRect(tir.buttonRect1), NSStringFromCGRect(tir.buttonRect2));
            }
            else if ([result isKindOfClass:[ORKFileResult class]]) {
                ORKFileResult *fileResult = (ORKFileResult *)result;
                NSLog(@"    File: %@", fileResult.fileURL);
            }
            else
            {
                NSLog(@"    %@:   userInfo: %@", result.identifier, result.userInfo);
            }
        }
    }
    
    if (_currentDocument)
    {
        ORKStep *lastStep = [[(ORKOrderedTask *)taskViewController.task steps] lastObject];
        ORKConsentSignatureResult *signatureResult = (ORKConsentSignatureResult *)[[[taskViewController result] stepResultForStepIdentifier:lastStep.identifier] firstResult];
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
    id<ORKTask> taskForTaskVC = [self makeTaskWithIdentifier:_taskVC.restorationIdentifier];
    
    _taskVC.task = taskForTaskVC;
    if ([_taskVC.restorationIdentifier isEqualToString:@"DynamicTask01"])
    {
        _taskVC.defaultResultSource = _lastRouteResult;
    }
    _taskVC.delegate = self;
}



@end
