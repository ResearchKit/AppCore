//
//  MainViewController.m
//  StudyDemo
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "MainViewController.h"
#import <ResearchKit/ResearchKit.h>
#import "DynamicTask.h"
#import "PurpleRecorder.h"

@interface MainViewController ()<RKTaskViewControllerDelegate, RKResultCollector>

@property (nonatomic, strong) RKTaskViewController* taskVC;
@property (nonatomic, strong) RKConsentViewController* consentVC;
@property (nonatomic, strong) RKStudy* study;

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
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    CGRect buttonFrame = CGRectMake(0, 0, 240, 40);
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = buttonFrame;
        button.center = CGPointMake(self.view.center.x, 90);
        [button addTarget:self action:@selector(showTaskButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Show Task" forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = buttonFrame;
        button.center = CGPointMake(self.view.center.x, 150);
        [button addTarget:self action:@selector(showConsentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Show Consent" forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = buttonFrame;
        button.center = CGPointMake(self.view.center.x, 210);
        [button addTarget:self action:@selector(showDynamicButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Dynamic Task" forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = buttonFrame;
        button.center = CGPointMake(self.view.center.x, 270);
        [button addTarget:self action:@selector(showSample001ButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"EQ-5D-5L" forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = buttonFrame;
        button.center = CGPointMake(self.view.center.x, 330);
        [button addTarget:self action:@selector(showGAITButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"GAIT" forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = buttonFrame;
        button.center = CGPointMake(self.view.center.x, 390);
        [button addTarget:self action:@selector(showInteruptTaskButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Interruptible Task" forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = buttonFrame;
        button.center = CGPointMake(self.view.center.x-100, 450);
        [button addTarget:self action:@selector(joinStudy:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Join Study" forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    
    {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = buttonFrame;
        button.center = CGPointMake(self.view.center.x+100, 450);
        [button addTarget:self action:@selector(leaveStudy:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Leave Study" forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
}

#pragma mark - button handlers

-(void)joinStudy:(id)sender
{
    NSError *err = nil;
    if (![self.study updateParticipating:YES withJoinDate:[NSDate date] error:&err])
    {
        NSLog(@"Could not join %@: %@", self.study, err);
    }
}


-(void)leaveStudy:(id)sender
{
    NSError *err = nil;
    if (![self.study updateParticipating:NO withJoinDate:nil error:&err])
    {
        NSLog(@"Could not leave %@: %@", self.study, err);
    }
}


- (IBAction)showTaskButtonTapped:(id)sender{
    
    NSMutableArray* steps = [NSMutableArray new];
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"aid_001a" name:@"active step"];
        step.text = @"An active test, touch collection";
        step.countDown = 30.0;
        step.voicePrompt = @"An active test, touch collection";
        step.recorderConfigurations = @[[RKTouchRecorderConfiguration configuration]];
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"aid_001b" name:@"active step"];
        step.text = @"An active test B";
        step.voicePrompt = @"An active test";
        step.recorderConfigurations = @[[PurpleRecorderConfigration new]];
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"aid_001c" name:@"active step"];
        step.text = @"An active test C";
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_001" name:@"HowOld" question:@"How old are you?" answer:[RKNumericAnswerFormat integerAnswerWithUnit:@"years"]];
        [steps addObject:step];
    }
    
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_002" name:@"HowMuch" question:@"What is your annual salary?" answer:[RKNumericAnswerFormat decimalAnswerWithUnit:nil]];
        [steps addObject:step];
    }
    
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_003"
                                                                      name:@"Choices ONE"
                                                                  question:@"How many hours did you sleep last night?"
                                                                    answer:[RKChoiceAnswerFormat choiceAnswerWithOptions:@[@[@"s1",@"choice1"], @[@"s2",@"choice2"], @[@"s3",@"choice3"]] style:RKChoiceAnswerStyleSingleChoice]];
        [steps addObject:step];
    }
    
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_004"
                                                                  name:@"Choices Muti"
                                                              question:@"How many hours did you sleep last night?"
                                                                answer:[RKChoiceAnswerFormat choiceAnswerWithOptions:@[@[@"m1",@"choice1"], @[@"m2",@"choice2"], @[@"m3",@"choice3"]]  style:RKChoiceAnswerStyleMultipleChoice]];
        
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
                                                                  question:@"When did you arrive?"
                                                                    answer:[RKDateAnswerFormat dateAnswer]];
        
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_008"
                                                                      name:@"time"
                                                                  question:@"When did you arrive?"
                                                                    answer:[RKDateAnswerFormat timeAnswer]];
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"qid_009"
                                                                   name:@"date & time"
                                                               question:@"When did you arrive?"
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
    
    self.taskVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    
    self.taskVC.delegate = self;
    
    [self presentViewController:_taskVC animated:YES completion:^{
        NSLog(@"task Presented");
    }];
}

- (IBAction)showConsentButtonTapped:(id)sender{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"printing" ofType:@"pdf"];
    
    //RKConsentStep* step = [[RKConsentStep alloc] initWithIdentifier:@"sid_001" name:@"consnet" consentFile:[NSData dataWithContentsOfFile:path]];
    //RKTask* task = [[RKTask alloc] initWithName:@"Consent" identifier:@"tid_001" steps:@[step]];
    
    self.consentVC = [[RKConsentViewController alloc] initWithConsentPDF:[NSData dataWithContentsOfFile:path] taskInstanceUUID:[NSUUID UUID]];
    self.consentVC.delegate = self;
    [self presentViewController:_consentVC animated:YES completion:^{
        NSLog(@"consent Presented");
    }];
}

- (IBAction)showSample001ButtonTapped:(id)sender{
    
    NSArray* qlist = @[@"MOBILITY",
                       @[@[@"No problems", @"I have no problems in walking about"], @[@"Slight problems",@"I have slight problems in walking about"], @[@"Moderate problems", @"I have moderate problems in walking about"],  @[@"Severe problems",@"I have severe problems in walking about"], @[@"Unable to complete",@"I am unable to walk about"]],
                       @"SELF-CARE",
                       @[@[@"No problems",@"I have no problems washing or dressing myself"], @[@"Slight problems", @"I have slight problems washing or dressing myself"], @[@"Moderate problems", @"I have moderate problems washing or dressing myself"], @[@"Severe problems", @"I have severe problems washing or dressing myself"], @[@"Unable to complete", @"I am unable to wash or dress myself"] ],
                       @"USUAL ACTIVITIES (e.g. work, study, housework, family or leisure activities)",
                       @[@[@"No problems",@"I have no problems doing my usual activities"], @[@"Slight problems", @"I have slight problems doing my usual activities"], @[@"Moderate problems", @"I have moderate problems doing my usual activities"], @[@"Severe problems", @"I have severe problems doing my usual activities"], @[@"Unable to complete", @"I am unable to do my usual activities"]],
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
            step.prompt = @"Please tick the ONE box that best describes your health TODAY";
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
    
    self.taskVC.delegate = self;
    
    [self presentViewController:_taskVC animated:YES completion:^{
        
    }];
}

- (IBAction)showDynamicButtonTapped:(id)sender{
    
    
    DynamicTask* task = DynamicTask.alloc.init;
    
    self.taskVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    
    self.taskVC.delegate = self;
    
    [self presentViewController:_taskVC animated:YES completion:^{
        
    }];
}

- (IBAction)showGAITButtonTapped:(id)sender{
    
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"gait_001" name:@"active step"];
        step.text = @"Please put the phone in a pocket or armband. Then wait for voice instruction.";
        step.countDown = 8.0;
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"gait_002" name:@"active step"];
        step.text = @"Now please walk 20 yards, turn 180 degrees, and walk back.";
        step.buzz = YES;
        step.vibration = YES;
        step.voicePrompt = step.text;
        step.countDown = 60.0;
        step.recorderConfigurations = @[ [[RKAccelerometerRecorderConfiguration alloc] initWithFrequency:100.0]];
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"gait_003" name:@"active step"];
        step.text = @"Thank you for completing this task.";
        step.voicePrompt = step.text;
        [steps addObject:step];
    }
    
    RKTask* task = [[RKTask alloc] initWithName:@"GAIT" identifier:@"tid_001" steps:steps];
    self.taskVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    self.taskVC.delegate = self;
    
    [self presentViewController:_taskVC animated:YES completion:^{
        NSLog(@"task Presented");
    }];
    
    
}

- (IBAction)showInteruptTaskButtonTapped:(id)sender{
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"itid_001" name:@"HowOld" question:@"How old are you?" answer:[RKNumericAnswerFormat integerAnswerWithUnit:@"Years old"]];
        [steps addObject:step];
    }
    
    {
        RKQuestionStep* step = [RKQuestionStep questionStepWithIdentifier:@"itid_002" name:@"HowMuch" question:@"How much did you pay for your car?" answer:[RKNumericAnswerFormat decimalAnswerWithUnit:@"Dollars"]];
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"itid_003" name:@"active step"];
        step.text = @"Thank you for completing this task.";
        step.voicePrompt = step.text;
        [steps addObject:step];
    }
    
    RKTask* task = [[RKTask alloc] initWithName:@"Screening" identifier:@"tid_001" steps:steps];
    self.taskVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    self.taskVC.delegate = self;
    
    [self presentViewController:_taskVC animated:YES completion:^{
        NSLog(@"task Presented");
    }];
}

#pragma mark - Helpers

-(void)sendResult:(RKResult*)result uploader:(RKUploader*)uploader
{
    /*
    NSError *error = nil;
    NSData *data = [result serializationToJSONWithError:&error includingBase64RawData:NO];
    if (!data)
    {
        NSLog(@"Error producing data from %@: %@", result, error);
        return;
    }
    
    
    RKItemIdentifier *itemIdentifier = [[RKItemIdentifier alloc] initWithString:result.taskIdentifier];
    if (result.stepIdentifier)
    {
        itemIdentifier = [itemIdentifier itemIdentifierByAppendingComponent:result.stepIdentifier];
    }
    if (![uploader sendData:data itemIdentifier:itemIdentifier taskInstanceUUID:result.taskInstanceUUID mimeType:result.contentType error:&error])
    {
        NSLog(@"Error queueing data from %@ on %@: %@", result, uploader, error);
        return;
    }
     */
    NSError *error = nil;
    
    if (![uploader sendArchive:[result dataArchive] error:&error])
    {
        NSLog(@"Error queueing data from %@ on %@: %@", result, uploader, error);
        return;
    }
    
}

#pragma mark - RKTaskViewControllerDelegate

- (void)taskViewController:(RKTaskViewController *)taskViewController didProduceResult:(RKResult*)result{
    
    NSLog(@"didProduceResult = %@", result);
    
    if ([result isKindOfClass:[RKSurveyResult class]]) {
        RKSurveyResult* sresult = (RKSurveyResult*)result;
        
        for (NSString* key in sresult.surveyResults) {
            RKQuestionResult* qr = sresult.surveyResults[key];
            NSLog(@"%@ = [%@] %@ ", key, qr.answer.class, qr.answer);
        }
    }
    
    RKUploader *uploader = self.study.primaryUploader;
    if (uploader && result)
    {
        [self sendResult:result uploader:uploader];
    }
    
        
}

- (BOOL)taskViewController:(RKTaskViewController *)taskViewController shouldPresentStep:(RKStep*)step{
    if ([ step.identifier isEqualToString:@"itid_002"]) {
        RKQuestionResult* qr = taskViewController.surveyResults[@"itid_001"];
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
        customView.frame = [(RKActiveStepViewController*)stepViewController customViewContainer].bounds;
        customView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [[(RKActiveStepViewController*)stepViewController customViewContainer] addSubview:customView];
    }else if ([stepViewController.step.identifier isEqualToString:@"gait_001"]) {
        stepViewController.nextButton = nil;
    }else if ([stepViewController.step.identifier isEqualToString:@"gait_002"]) {
        stepViewController.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"I'm done" style:stepViewController.nextButton.style target:stepViewController.nextButton.target action:stepViewController.nextButton.action];
        stepViewController.backButton = nil;
    }else if ([stepViewController.step.identifier isEqualToString:@"gait_003"]) {
        stepViewController.backButton = nil;
    }

}


- (void)taskViewControllerDidFail: (RKTaskViewController *)taskViewController withError:(NSError*)error{
    
}

- (void)taskViewControllerDidCancel:(RKTaskViewController *)taskViewController{
    
    [taskViewController suspend];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)taskViewControllerDidComplete: (RKTaskViewController *)taskViewController{
    
    [taskViewController suspend];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

#pragma mark - RKResultCollector

-(void)didChangeResult:(RKResult *)result forStep:(RKStep *)step{
    
}


-(void)didProduceResult:(RKResult *)result forStep:(RKStep *)step{
    
}




@end
