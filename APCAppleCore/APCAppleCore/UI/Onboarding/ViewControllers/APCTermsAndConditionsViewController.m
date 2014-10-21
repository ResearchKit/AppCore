//
//  APCTermsAndConditionsViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/21/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCTermsAndConditionsViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

@interface APCTermsAndConditionsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation APCTermsAndConditionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.textView.text = @"Lorem ipsum dolor sit amet, en sed consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore nisi a magna aliqua. Ut enim ad minim vem, quis nostrud aute y exercitation ullamco labs nisi ut aliqp ex ea commodo elit sed aconsequat.\n\nDuis aute irure dolor in dolor sit ento reprederit in voluptate velit esse cillum dolore eu fuat nulla tur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborm. Sed ut perspiciatis unde nis iste nus error sit voluptatemlaudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
    
    [self setupAppearance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

- (void)setupAppearance
{
    [self.textView setTextColor:[UIColor appSecondaryColor1]];
    [self.textView setFont:[UIFont appLightFontWithSize:17.0f]];
    [self.textView.layer setCornerRadius:5.0f];
    [self.textView setTextContainerInset:UIEdgeInsetsMake(13, 10, 10, 10)];
    
    self.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor]};
}

#pragma mark - IBActions

- (IBAction)agree:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(termsAndConditionsViewControllerDidAgree)]) {
        [self.delegate termsAndConditionsViewControllerDidAgree];
    }
}

- (IBAction)close:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(termsAndConditionsViewControllerDidCancel)]) {
        [self.delegate termsAndConditionsViewControllerDidCancel];
    }
}

@end
