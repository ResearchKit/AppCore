// 
//  APCInstructionStepViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCInstructionStepViewController.h"
#import "APCIntroductionViewController.h"
#import "APCAppCore.h"

@interface APCInstructionStepViewController ()

@property (nonatomic, strong) APCIntroductionViewController * introVC;

@end

@implementation APCInstructionStepViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.gettingStartedButton setBackgroundImage:[UIImage imageWithColor:[UIColor appPrimaryColor]] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.accessoryContent != nil) {
        CGRect  frame = self.introVC.accessoryView.frame;
        frame.origin = CGPointMake(0.0, 0.0);
        self.accessoryContent.frame = frame;
        [self.introVC.accessoryView addSubview:self.accessoryContent];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.introVC setupWithInstructionalImages:self.imagesArray headlines:self.headingsArray andParagraphs:self.messagesArray];
    
    if (self.title) {
        self.navigationController.navigationBar.topItem.title = self.title;
        self.introVC.title = self.title;
    }
  APCLogViewControllerAppeared();
}

- (IBAction)getStartedWasTapped:(id)sender
{
    [self.gettingStartedButton setEnabled:NO];
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)] == YES) {
            [self.delegate stepViewController:self didFinishWithNavigationDirection: RKSTStepViewControllerNavigationDirectionForward];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embeddedScroller"]) {
        self.introVC = segue.destinationViewController;
    }
}

- (void)cancelButtonTapped:(id)sender
{
    if ([self.taskViewController.delegate respondsToSelector:@selector(taskViewControllerDidCancel:)]) {
        [self.taskViewController.delegate taskViewControllerDidCancel:self.taskViewController];
    }
}

@end
