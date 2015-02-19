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

- (IBAction) getStartedWasTapped: (id) __unused sender
{
    [self.gettingStartedButton setEnabled:NO];
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewController:didFinishWithNavigationDirection:)] == YES) {
            [self.delegate stepViewController:self didFinishWithNavigationDirection: ORKStepViewControllerNavigationDirectionForward];
        }
    }
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) __unused sender
{
    if ([segue.identifier isEqualToString:@"embeddedScroller"]) {
        self.introVC = segue.destinationViewController;
    }
}

- (void) cancelButtonTapped: (id) __unused sender
{
    if ([self.taskViewController.delegate respondsToSelector:@selector(taskViewController:didFinishWithResult:error:)]) {
        [self.taskViewController.delegate taskViewController:self.taskViewController didFinishWithResult:ORKTaskViewControllerResultDiscarded error:nil];
    }
}

@end
