//
//  APCWithdrawSurveyViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCWithdrawSurveyViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

@interface APCWithdrawSurveyViewController ()

@end

@implementation APCWithdrawSurveyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    [self setupAppearance];
    
    self.items = [self prepareContent];
    
    [self.tableView reloadData];
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
    
    [self.withdrawButton.titleLabel setFont:[UIFont appMediumFontWithSize:19.0f]];
    [self.withdrawButton setBackgroundColor:[UIColor appPrimaryColor]];
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
    APCTableViewSwitchItem *optionItem = [self itemForIndexPath:indexPath];
    optionItem.on = !optionItem.on;
    
    [tableView reloadData];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (APCTableViewSwitchItem *)itemForIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSection *sectionItem = self.items[indexPath.section];
    APCTableViewRow *rowItem = sectionItem.rows[indexPath.row];
    
    APCTableViewSwitchItem *studyDetailsItem = (APCTableViewSwitchItem *)rowItem.item;
    
    return studyDetailsItem;
}

@end
