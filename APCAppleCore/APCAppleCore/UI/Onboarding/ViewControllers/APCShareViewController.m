//
//  APCShareViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/30/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCShareViewController.h"
#import "APCShareTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

@interface APCShareViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *tableHeaderLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *okayButton;

@property (nonatomic, strong) NSArray *shareTitles;
@property (nonatomic, strong) NSArray *shareImages;

@end

@implementation APCShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shareTitles = @[@"Share on Twitter", @"Share on Facebook", @"Share via Email", @"Share via SMS"];
    self.shareImages = @[@"twitter_icon", @"facebook_icon", @"email_icon", @"sms_icon"];
    
    [self setupAppearance];
    
    self.okayButton.hidden = self.hidesOkayButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Setup

- (void)setupAppearance
{
    [self.messageLabel setTextColor:[UIColor appSecondaryColor1]];
    [self.messageLabel setFont:[UIFont appRegularFontWithSize:19.0f]];
    
    [self.tableHeaderLabel setFont:[UIFont appLightFontWithSize:14.0f]];
    [self.tableHeaderLabel setTextColor:[UIColor appSecondaryColor3]];
    
    [self.okayButton setBackgroundColor:[UIColor appPrimaryColor]];
    [self.okayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.okayButton.titleLabel setFont:[UIFont appMediumFontWithSize:19.0f]];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
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


#pragma mark - IBActions

- (IBAction)okayTapped:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
