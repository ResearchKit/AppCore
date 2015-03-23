// 
//  APCShareViewController.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCShareViewController.h"
#import "APCShareTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "UIImage+APCHelper.h"
#import "APCAppCore.h"

@interface APCShareViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *tableHeaderLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *okayButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomConstraint;

@property (nonatomic, strong) NSArray *shareTitles;
@property (nonatomic, strong) NSArray *shareImages;

@end

@implementation APCShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shareTitles = @[@"Share on Twitter", @"Share on Facebook", @"Share via Email", @"Share via SMS"];
    self.shareImages = @[@"twitter_icon", @"facebook_icon", @"email_icon", @"sms_icon"];
    
    [self setupAppearance];
    [self setupNavAppearance];
    
    self.okayButton.hidden = self.hidesOkayButton;
    if (self.okayButton.hidden) {
        self.tableBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }
    
    [self.logoImageView setImage:[UIImage imageNamed:@"logo_disease"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
  APCLogViewControllerAppeared();
}

#pragma mark - Setup

- (void)setupAppearance
{
    [self.messageLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.messageLabel setFont:[UIFont appRegularFontWithSize:19.0f]];
    
    [self.tableHeaderLabel setFont:[UIFont appLightFontWithSize:14.0f]];
    [self.tableHeaderLabel setTextColor:[UIColor appSecondaryColor3]];
    
    [self.okayButton setBackgroundImage:[UIImage imageWithColor:[UIColor appPrimaryColor]] forState:UIControlStateNormal];
    [self.okayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.okayButton.titleLabel setFont:[UIFont appMediumFontWithSize:19.0f]];
}

- (void)setupNavAppearance
{
    UIBarButtonItem  *backster = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(back) tintColor:[UIColor appPrimaryColor]];
    [self.navigationItem setLeftBarButtonItem:backster];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger) tableView: (UITableView *) __unused tableView
  numberOfRowsInSection: (NSInteger) __unused section
{
    return self.shareTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCShareTableViewCell *cell = (APCShareTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAPCShareTableViewCellIdentifier];
    cell.textLabel.text = self.shareTitles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:self.shareImages[indexPath.row]];
    return cell;
}

#pragma mark - Selectors / IBActions

- (IBAction) okayTapped: (id) __unused sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
