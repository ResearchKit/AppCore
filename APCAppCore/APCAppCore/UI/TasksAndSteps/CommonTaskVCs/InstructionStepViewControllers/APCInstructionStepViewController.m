//
//  APCInstructionStepViewController.m
//  APCAppCore
//
//  Created by Dhanush Balachandran on 11/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.introVC setupWithInstructionalImages:self.imagesArray headlines:self.headingsArray andParagraphs:self.messagesArray];
    if (self.accessoryContent != nil) {
        CGRect  frame = self.introVC.accessoryView.frame;
        frame.origin = CGPointMake(0.0, 0.0);
        self.accessoryContent.frame = frame;
        [self.introVC.accessoryView addSubview:self.accessoryContent];
    }
}

- (IBAction)getStartedWasTapped:(id)sender
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKSTStepViewControllerNavigationDirectionForward];
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
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidCancel:)] == YES) {
            [self.delegate stepViewControllerDidCancel:self];
        }
    }
}

@end
