// 
//  APCWithdrawSurveyViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCWithdrawSurveyViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCWithdrawDescriptionViewController.h"
#import "NSBundle+Helper.h"
#import "UIImage+APCHelper.h"
#import "APCAppCore.h"

@interface APCWithdrawSurveyViewController ()<APCWithdrawDescriptionViewControllerDelegate>

@property (nonatomic, strong) NSString *descriptionText;

@end

@implementation APCWithdrawSurveyViewController

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
    APCLogViewController();
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
    
    [self.submitButton.titleLabel setFont:[UIFont appMediumFontWithSize:19.0f]];
    [self.submitButton setBackgroundImage:[UIImage imageWithColor:[UIColor appPrimaryColor]] forState:UIControlStateNormal];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.items.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
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
    if (indexPath.row == (sectionItem.rows.count - 1)) {
        
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

- (void)withdrawViewControllerDidCancel:(APCWithdrawDescriptionViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)withdrawViewController:(APCWithdrawDescriptionViewController *)viewController didFinishWithDescription:(NSString *)text
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
    NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"];
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

- (IBAction)submit:(id)sender
{
    //TODO: Submit API Call
    [[NSNotificationCenter defaultCenter] postNotificationName:APCUserWithdrawStudyNotification object:self];
}

@end
