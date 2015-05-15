// 
//  APCSharingOptionsViewController.m 
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

@property (nonatomic, strong) NSString *instituteShortName;

@property (nonatomic, strong) NSString *instituteLongName;

@property (nonatomic, strong) APCUser *user;

@end

@implementation APCSharingOptionsViewController

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

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
    
    NSString *messageText = [NSString stringWithFormat:@"%@ will receive your study data from your participation in this study.\n\nSharing your coded study data more broadly (without information such as your name) may benefit this and future research.", self.instituteLongName];
    self.messageLabel.text = NSLocalizedString(messageText, @"");
    
    
    NSMutableArray *options = [NSMutableArray new];
    
    {
        NSString *option = [NSString stringWithFormat:@"Share my data with %@ and qualified researchers worldwide", self.instituteShortName];
        [options addObject:option];
    }
    
    {
        NSString *option = [NSString stringWithFormat:@"Only share my data with %@", self.instituteLongName];
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
        self.instituteLongName = infoDictionary[@"investigatorLongDescription"];
        self.instituteShortName = infoDictionary[@"investigatorShortDescription"];
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
    
    if (indexPath.row == 0 && self.user.sharingScope == APCUserConsentSharingScopeAll) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 1 && self.user.sharingScope == APCUserConsentSharingScopeStudy) {
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
        self.user.sharingScope = APCUserConsentSharingScopeAll;
    } else if (indexPath.row == 1) {
        self.user.sharingScope = APCUserConsentSharingScopeStudy;
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
