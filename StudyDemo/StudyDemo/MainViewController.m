//
//  MainViewController.m
//  StudyDemo
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "MainViewController.h"
#import <ResearchKit/ResearchKit.h>
#import "DynamicTask.h"
#import "CustomRecorder.h"
#import "AppDelegate.h"


@interface PDFViewController : UIViewController

@property (nonatomic, strong) UIWebView* pdfView;
@property (nonatomic, strong) NSData *pdfData;

@end

@implementation PDFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self pdfView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
}

- (UIWebView*)pdfView{
    if (_pdfView == nil) {
        _pdfView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _pdfView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self reloadContent];
        [self.view addSubview:_pdfView];
    }
    return _pdfView;
}

- (void)reloadContent
{
    [_pdfView loadData:self.pdfData MIMEType:@"application/pdf" textEncodingName:nil baseURL:nil];
}

- (IBAction)doneAction:(id)sender{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end

@interface MainViewController ()<RKTaskViewControllerDelegate>

@property (nonatomic, strong) RKTaskViewController* taskVC;
@property (nonatomic, strong) RKStudy* study;
@property (nonatomic, strong) NSData *signedPdfData;

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
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor orangeColor]];
    
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


- (IBAction)showTaskButtonTapped:(id)sender{
    
    NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKIntroductionStep* step = [[RKIntroductionStep alloc] initWithIdentifier:@"iid_001" name:@"intro step"];
        step.titleText = @"Demo Study";
        step.descriptionText = @"We're conducting research on the different question types ResearchKit has to offer. We'd love to hear from you about what question types you use the most and what question types you want to see built. This will help us make improvements to the existing tool and prioritize new features.";
        [steps addObject:step];
    }
    
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
        step.text = @"An active test\nPlease tap the orange button above when it appears.";
        step.countDown = 10.0;
        step.recorderConfigurations = @[[CustomRecorderConfiguration new]];
        [steps addObject:step];
    }
    
    {
        RKActiveStep* step = [[RKActiveStep alloc] initWithIdentifier:@"aid_001c" name:@"active step"];
        step.text = @"An active test collecting device motion data";
        step.recorderConfigurations = @[ [[RKDeviceMotionRecorderConfiguration alloc] initWithFrequency:100.0]];
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
    
    
     NSMutableArray* steps = [NSMutableArray new];
    
    {
        RKIntroductionStep* step = [[RKIntroductionStep alloc] initWithIdentifier:@"iid_001" name:@"intro step"];
        step.titleText = @"Demo Study";
        step.descriptionText = @"We're conducting research on the different question types ResearchKit has to offer. We'd love to hear from you about what question types you use the most and what question types you want to see built. This will help us make improvements to the existing tool and prioritize new features.";
        [steps addObject:step];
    }
    
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"printing" ofType:@"pdf"];
        RKConsentStep* step = [[RKConsentStep alloc] initWithIdentifier:@"cid_a" name:@"Conent step" consentFile:[NSData dataWithContentsOfFile:path]];
        [steps addObject:step];
    }
    
    RKTask* task = [[RKTask alloc] initWithName:@"Consent" identifier:@"ConsentTask" steps:steps];
    
    _taskVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    _taskVC.delegate = self;
    
    [self presentViewController:_taskVC animated:YES completion:^{
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
        RKMediaStep *step = [[RKMediaStep alloc] initWithIdentifier:@"itid_004" name:@"media"];
        step.request = @"Please take a picture of your right hand.";
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

-(void)sendResult:(RKResult*)result
{
    NSLog(@"To do: Upload %@", result);
}

#pragma mark - RKTaskViewControllerDelegate

- (BOOL)taskViewController:(RKTaskViewController *)taskViewController shouldShowMoreInfoOnStep:(RKStep *)step{
    return YES;
}

- (void)taskViewController:(RKTaskViewController *)taskViewController didReceiveLearnMoreEventFromStepViewController:(RKStepViewController *)stepViewController{
    NSLog(@"Want to learn more = %@", stepViewController);
}

- (void)taskViewController:(RKTaskViewController *)taskViewController didProduceResult:(RKResult*)result{
    
    NSLog(@"didProduceResult = %@", result);
    
    if ([result isKindOfClass:[RKSurveyResult class]]) {
        RKSurveyResult* sresult = (RKSurveyResult*)result;
        
        for (NSString* key in sresult.surveyResults) {
            RKQuestionResult* qr = sresult.surveyResults[key];
            NSLog(@"%@ = [%@] %@ ", key, qr.answer.class, qr.answer);
        }
    }
    
    if ([result isKindOfClass:[RKDataResult class]] && [result.stepIdentifier isEqualToString:@"cid_a"]) {
        self.signedPdfData = [(RKDataResult*)result data];
    }
    
    [self sendResult:result];
        
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
        
        // Set custom button on navi bar
        stepViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Custom button"
                                                                                               style:UIBarButtonItemStylePlain
                                                                                               target:nil
                                                                                              action:nil];
    }else if ([stepViewController.step.identifier isEqualToString:@"gait_001"]) {
        stepViewController.nextButton = nil;
    }else if ([stepViewController.step.identifier isEqualToString:@"gait_002"]) {
        stepViewController.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"I'm done" style:stepViewController.nextButton.style target:stepViewController.nextButton.target action:stepViewController.nextButton.action];
        stepViewController.backButton = nil;
    }else if ([stepViewController.step.identifier isEqualToString:@"gait_003"]) {
        stepViewController.backButton = nil;
    }else if ([stepViewController.step.identifier isEqualToString:@"qid_003"]) {
        RKQuestionStepViewController* qsvc = (RKQuestionStepViewController*)stepViewController;
        UILabel* footerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
        footerView.text = @"Custom footer view";
        footerView.textAlignment = NSTextAlignmentCenter;
        footerView.textColor = [UIColor lightGrayColor];
        footerView.layer.borderWidth = 1.0;
        footerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        qsvc.footerView = footerView;
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
        if (self.signedPdfData) {
            PDFViewController* pdfVC = [[PDFViewController alloc] init];
            pdfVC.pdfData = self.signedPdfData;
        
            UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:pdfVC];
            [self presentViewController:nav animated:YES completion:^{
                self.signedPdfData = nil;
            }];
        }
    }];
    
    
    
}



@end
