//
//  APCLearnMasterViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/9/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCLearnMasterViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIColor+TertiaryColors.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

@interface APCLearnMasterViewController ()

@end

@implementation APCLearnMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.items = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    APCTableViewStudyDetailsItem *studyDetailsItem = [self itemForIndexPath:indexPath];
    
    APCTintedTableViewCell *cell = (APCTintedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kAPCTintedTableViewCellIdentifier];
    
    cell.textLabel.text = studyDetailsItem.caption;
    cell.imageView.image = studyDetailsItem.iconImage;
    cell.tintColor = studyDetailsItem.tintColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView;
    
    APCTableViewSection *sectionItem = self.items[section];
    
    if (sectionItem.sectionTitle.length > 0) {
        
        headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), tableView.sectionHeaderHeight)];
        headerView.contentView.backgroundColor = [UIColor appSecondaryColor4];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
        headerLabel.font = [UIFont appLightFontWithSize:16.0f];
        headerLabel.textColor = [UIColor appSecondaryColor3];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = sectionItem.sectionTitle;
        [headerView addSubview:headerLabel];
    }
    
    return headerView;
}

#pragma mark - Public methods

- (void)studyDetailsFromJSONFile:(NSString *)jsonFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    if (!parseError) {
        
        NSArray *items = jsonDictionary[@"items"];
        
        for (NSDictionary *sectionDict in items) {
            
            APCTableViewSection *section = [APCTableViewSection new];
            
            section.sectionTitle = sectionDict[@"section_title"];
            
            NSArray *rowItemsFromDict = sectionDict[@"row_items"];
            
            NSMutableArray *rowItems = [NSMutableArray new];
            
            for (NSDictionary *rowItemDict in rowItemsFromDict) {
                
                APCTableViewRow *rowItem = [APCTableViewRow new];
                
                APCTableViewStudyDetailsItem *studyDetails = [APCTableViewStudyDetailsItem new];
                studyDetails.caption = rowItemDict[@"title"];
                studyDetails.detailText = rowItemDict[@"details"];
                studyDetails.iconImage = [UIImage imageNamed:rowItemDict[@"icon_image"]];
                studyDetails.tintColor = [UIColor tertiaryColorForString:rowItemDict[@"tint_color"]];
                
                rowItem.item = studyDetails;
                [rowItems addObject:rowItem];
            }
            
            section.rows = [NSArray arrayWithArray:rowItems];
            
            [self.items addObject:section];
        }
    }
}

- (APCTableViewStudyDetailsItem *)itemForIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSection *sectionItem = self.items[indexPath.section];
    APCTableViewRow *rowItem = sectionItem.rows[indexPath.row];
    
    APCTableViewStudyDetailsItem *studyDetailsItem = (APCTableViewStudyDetailsItem *)rowItem.item;
    
    return studyDetailsItem;
}


@end
