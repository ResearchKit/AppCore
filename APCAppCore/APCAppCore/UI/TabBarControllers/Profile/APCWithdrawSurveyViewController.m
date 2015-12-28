// 
//  APCWithdrawSurveyViewController.m 
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
 
#import "APCWithdrawSurveyViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCWithdrawDescriptionViewController.h"
#import "NSBundle+Helper.h"
#import "UIImage+APCHelper.h"
#import "APCAppCore.h"
#import "APCUser+Bridge.h"

@interface APCWithdrawSurveyViewController ()<APCWithdrawDescriptionViewControllerDelegate>

@property (nonatomic, strong) NSString *descriptionText;

@end

@implementation APCWithdrawSurveyViewController

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    [self setupAppearance];
    
    self.items = [self prepareContent];
    self.descriptionText = @"";
    
    self.submitButton.enabled = NO;
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  APCLogViewControllerAppeared();
}

- (NSArray *)prepareContent
{
     return [self surveyFromJSONFile:@"WithdrawStudy"];
}

- (void)setupTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)setupAppearance
{
    [self.headerLabel setTextColor:[UIColor appSecondaryColor2]];
    [self.headerLabel setFont:[UIFont appLightFontWithSize:14.0f]];
    [self.selectAllLabel setTextColor:[UIColor appSecondaryColor2]];
    [self.selectAllLabel setFont:[UIFont appLightFontWithSize:14.0f]];
}

- (APCUser *) user {
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger) numberOfSectionsInTableView: (UITableView *) __unused tableView
{
    return self.items.count;
}
- (NSInteger) tableView: (UITableView *) __unused tableView
  numberOfRowsInSection: (NSInteger) section
{
    APCTableViewSection *sectionItem = self.items[section];
    
    return sectionItem.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSwitchItem *optionItem = [self itemForIndexPath:indexPath];
    
    APCCheckTableViewCell *cell = (APCCheckTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAPCCheckTableViewCellIdentifier];
    
    cell.textLabel.text = optionItem.caption;
    cell.confirmationView.completed = optionItem.on;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSection *sectionItem = self.items[indexPath.section];
    if ((NSUInteger)indexPath.row == (sectionItem.rows.count - 1)) {
        
        APCWithdrawDescriptionViewController *viewController = [[UIStoryboard storyboardWithName:@"APCProfile" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCWithdrawDescriptionViewController"];
        viewController.delegate = self;
        viewController.descriptionText = self.descriptionText;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self.navigationController presentViewController:navController animated:YES completion:nil];
        
    } else {
        APCTableViewSwitchItem *optionItem = [self itemForIndexPath:indexPath];
        optionItem.on = !optionItem.on;
        
        [tableView reloadData];
    }
    
    self.submitButton.enabled = [self isContentValid];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - APCWithdrawDescriptionViewControllerDelegate methods

- (void)withdrawViewControllerDidCancel:(APCWithdrawDescriptionViewController *) __unused viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) withdrawViewController: (APCWithdrawDescriptionViewController *) __unused viewController
       didFinishWithDescription: (NSString *) text
{
    self.descriptionText = text;
    
    [self dismissViewControllerAnimated:YES completion:^{
        APCTableViewSection *sectionItem = self.items[0];
        APCTableViewSwitchItem *optionItem = [self itemForIndexPath:[NSIndexPath indexPathForRow:(sectionItem.rows.count - 1) inSection:0]];
        optionItem.on = YES;
        [self.tableView reloadData];
        
        self.submitButton.enabled = [self isContentValid];
    }];
}

#pragma mark - Public methods

- (NSArray *)surveyFromJSONFile:(NSString *)jsonFileName
{
    NSString *filePath = [[APCAppDelegate sharedAppDelegate] pathForResource:jsonFileName ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    NSMutableArray *items = [NSMutableArray new];
    
    if (!parseError) {
        
        NSArray *options = jsonDictionary[@"options"];
        
        NSMutableArray *rowItems = [NSMutableArray new];
        
        for (NSDictionary *optionDict in options) {
            
            APCTableViewSwitchItem *option = [APCTableViewSwitchItem new];
            option.caption = optionDict[@"option"];
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = option;
            [rowItems addObject:row];
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        [items addObject:section];
    }
    
    return [NSArray arrayWithArray:items];
}

- (APCTableViewSwitchItem *)itemForIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSection *sectionItem = self.items[indexPath.section];
    APCTableViewRow *rowItem = sectionItem.rows[indexPath.row];
    
    APCTableViewSwitchItem *studyDetailsItem = (APCTableViewSwitchItem *)rowItem.item;
    
    return studyDetailsItem;
}

- (BOOL)isContentValid
{
    BOOL valid = NO;
    
    APCTableViewSection *sectionItem = self.items[0];
    
    for (APCTableViewRow *row in sectionItem.rows) {
        APCTableViewSwitchItem *option = (APCTableViewSwitchItem *)[row item];
        if (option.on) {
            valid = YES;
            break;
        }
    }
    
    return valid;
}

#pragma mark - IBActions

- (IBAction) submit: (id) __unused sender
{
    APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
    [self presentViewController:spinnerController animated:YES completion:nil];
    
    typeof(self) __weak weakSelf = self;
    self.user.sharedOptionSelection = APCUserConsentSharingScopeNone;
    NSString *reasonString = @"";
    APCTableViewSection *sectionItem = self.items[0];
    for (NSUInteger i = 0; i < sectionItem.rows.count; ++i) {
        if (i) {
            reasonString = [NSString stringWithFormat:@"%@\n", reasonString];
        }
        APCTableViewRow *rowItem = sectionItem.rows[i];
        APCTableViewSwitchItem *studyDetailsItem = (APCTableViewSwitchItem *)rowItem.item;
        NSString *answer = @"";
        if (i == sectionItem.rows.count - 1) {
            answer = self.descriptionText ?: @"";
        } else {
            answer = studyDetailsItem.on ? @"YES" : @"NO";
        }
        reasonString = [NSString stringWithFormat:@"%@%@\n%@\n", reasonString, studyDetailsItem.caption, answer];

    }
    
    [self.user withdrawStudyWithReason:reasonString onCompletion:^(NSError *error) {
        if (error) {
            APCLogError2 (error);
            [spinnerController dismissViewControllerAnimated:NO completion:^{
                UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedStringWithDefaultValue(@"Withdraw", @"APCAppCore", APCBundle(), @"Withdraw", @"") message:error.message];
                [weakSelf presentViewController:alert animated:YES completion:nil];
            }];
        }
        else {
            [spinnerController dismissViewControllerAnimated:NO completion:^{
                APCWithdrawCompleteViewController *viewController = [[UIStoryboard storyboardWithName:@"APCProfile" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCWithdrawCompleteViewController"];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
                [weakSelf.navigationController presentViewController:navController animated:YES completion:nil];
            }];
        }
    }];
}

- (IBAction)cancel:(id) __unused sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
