// 
//  APCLearnMasterViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCLearnMasterViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "NSBundle+Helper.h"
#import "APCStudyDetailsViewController.h"
#import "APCLearnStudyDetailsViewController.h"

static CGFloat kSectionHeaderHeight = 40.f;

@interface APCLearnMasterViewController ()

@end

@implementation APCLearnMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.items = [NSMutableArray new];
    
    self.items = [self prepareContent];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    APCLogViewController();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)prepareContent
{
    return [self studyDetailsFromJSONFile:@"Learn"];
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

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewStudyDetailsItem *item = [self itemForIndexPath:indexPath];
    
    APCTableViewLearnItemType itemType = [self itemTypeForIndexPath:indexPath];
    
    switch (itemType) {
        case kAPCTableViewLearnItemTypeStudyDetails:
        {
            APCLearnStudyDetailsViewController *detailViewController = [[UIStoryboard storyboardWithName:@"APCLearn" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCLearnStudyDetailsViewController"];
            detailViewController.showConsentRow = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
            break;
        case kAPCTableViewLearnItemTypeOtherDetails:
        {
            APCStudyDetailsViewController *detailViewController = [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"StudyDetailsVC"];
            detailViewController.studyDetails = item;
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height;
    
    if (section == 0) {
        height = 0;
    } else {
        height = kSectionHeaderHeight;
    }
    
    return height;
}

#pragma mark - Public methods

- (NSArray *)studyDetailsFromJSONFile:(NSString *)jsonFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    NSMutableArray *learnItems = [NSMutableArray new];
    
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
                studyDetails.iconImage = [[UIImage imageNamed:rowItemDict[@"icon_image"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                studyDetails.tintColor = [UIColor tertiaryColorForString:rowItemDict[@"tint_color"]];
                
                rowItem.item = studyDetails;
                if ([studyDetails.detailText isEqualToString:@"study_details"]) {
                    rowItem.itemType = kAPCTableViewLearnItemTypeStudyDetails;
                } else {
                    rowItem.itemType = kAPCTableViewLearnItemTypeOtherDetails;
                }
                [rowItems addObject:rowItem];
            }
            
            section.rows = [NSArray arrayWithArray:rowItems];
            
            [learnItems addObject:section];
        }
    }
    
    return [NSArray arrayWithArray:learnItems];
}

- (APCTableViewStudyDetailsItem *)itemForIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSection *sectionItem = self.items[indexPath.section];
    APCTableViewRow *rowItem = sectionItem.rows[indexPath.row];
    
    APCTableViewStudyDetailsItem *studyDetailsItem = (APCTableViewStudyDetailsItem *)rowItem.item;
    
    return studyDetailsItem;
}

- (APCTableViewLearnItemType)itemTypeForIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSection *sectionItem = self.items[indexPath.section];
    APCTableViewRow *rowItem = sectionItem.rows[indexPath.row];
    
    APCTableViewLearnItemType learnItemType = rowItem.itemType;
    
    return learnItemType;
}

@end
