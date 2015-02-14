// 
//  APCShareViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
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
