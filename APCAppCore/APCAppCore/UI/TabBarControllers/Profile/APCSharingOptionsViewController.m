//
//  APCSharingOptionsViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCAppCore.h"
#import "APCSharingOptionsViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCAppDelegate.h"
#import "APCUser+Bridge.h"
#import "APCSpinnerViewController.h"
#import "UIAlertController+Helper.h"

static NSString * const kSharingOptionsTableViewCellIdentifier = @"SharingOptionsTableViewCell";
static NSInteger kNumberOfRows = 2;

@interface APCSharingOptionsViewController()

@property (nonatomic, strong) NSString *instituteName;

@property (nonatomic, strong) APCUser *user;

@end

@implementation APCSharingOptionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupAppearance];
    [self prepareData];
    
    [self.tableView reloadData];
    
    self.title = NSLocalizedString(@"Sharing Options", @"Sharing Options");
}

- (void)prepareData
{
    [self setupDataFromJSON:@"APHConsentSection"];
    
    self.titleLabel.text = NSLocalizedString(@"Sharing Options", @"Sharing Options");
    
    NSString *messageText = [NSString stringWithFormat:@"%@ will receive your study data from your participation in this study.\n\nSharing your coded study data more broadly (without information such as your name) may benefit this and future research.", self.instituteName];
    self.messageLabel.text = NSLocalizedString(messageText, @"");
    
    
    NSMutableArray *options = [NSMutableArray new];
    
    {
        NSString *option = [NSString stringWithFormat:@"Share my data with %@ and qualified researchers worldwide", self.instituteName];
        [options addObject:option];
    }
    
    {
        NSString *option = [NSString stringWithFormat:@"Only share my data with %@", self.instituteName];
        [options addObject:option];
    }
    
    self.options = [NSArray arrayWithArray:options];
}

- (void)setupDataFromJSON:(NSString *)jsonFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    
    if (!parseError) {
        NSDictionary *infoDictionary = jsonDictionary[@"documentProperties"];
        self.instituteName = infoDictionary[@"investigatorLongDescription"];
    }
}

- (void)setupAppearance
{
    self.titleLabel.font = [UIFont appLightFontWithSize:34.f];
    self.titleLabel.textColor = [UIColor appSecondaryColor1];
    
    self.messageLabel.font = [UIFont appRegularFontWithSize:16.f];
    self.messageLabel.textColor = [UIColor appSecondaryColor1];
}

- (APCUser *) user {
    if (!_user) {
        _user = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
    }
    
    return _user;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section
{
    return kNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSharingOptionsTableViewCellIdentifier];
    
    cell.textLabel.text = self.options[indexPath.row];
    
    cell.textLabel.font = [UIFont appMediumFontWithSize:16.0f];
    cell.textLabel.textColor = [UIColor appSecondaryColor1];
    
    if (indexPath.row == 0 && self.user.sharedOptionSelection.integerValue == SBBConsentShareScopeAll) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 1 && self.user.sharedOptionSelection.integerValue == SBBConsentShareScopeStudy) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        self.user.sharedOptionSelection = [NSNumber numberWithInteger:SBBConsentShareScopeAll];
    } else if (indexPath.row == 1) {
        self.user.sharedOptionSelection = [NSNumber numberWithInteger:SBBConsentShareScopeStudy];
    }
    
    APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
    [self presentViewController:spinnerController animated:YES completion:nil];
    
    __weak typeof(self) weakSelf = self;
    
    [self.user changeDataSharingTypeOnCompletion:^(NSError *error) {
        
        [spinnerController dismissViewControllerAnimated:YES completion:^{
            if (error) {
                APCLogError2 (error);
                
                UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Sharing Options", @"") message:error.message];
                [weakSelf presentViewController:alert animated:YES completion:nil];
                
            } else {
                [tableView reloadData];
            }
        }];
        
    }];
}

- (IBAction)close:(id)__unused sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
