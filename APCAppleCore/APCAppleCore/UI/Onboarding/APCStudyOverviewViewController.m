//
//  APCStudyOverviewViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 9/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCStudyOverviewViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "UIImage+APCHelper.h"
#import "UIColor+TertiaryColors.h"
#import "APCStudyDetailsViewController.h"
#import "APCShareViewController.h"

static NSString * const kStudyOverviewCellIdentifier = @"kStudyOverviewCellIdentifier";

@interface APCStudyOverviewViewController ()

@end

@implementation APCStudyOverviewViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.items = [NSMutableArray new];
    
    [self setupTableView];
    [self setUpAppearance];
    [self prepareContent];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)prepareContent
{
    [self studyDetailsFromJSONFile:@"StudyOverview"];
    
    if (self.showShareRow){
        
        APCTableViewStudyDetailsItem *shareStudyItem = [APCTableViewStudyDetailsItem new];
        shareStudyItem.caption = NSLocalizedString(@"Share this Study", nil);
        shareStudyItem.iconImage = [UIImage imageNamed:@"share_icon"];
        shareStudyItem.tintColor = [UIColor appTertiaryGreenColor];

        APCTableViewRow *rowItem = [APCTableViewRow new];
        rowItem.item = shareStudyItem;
        rowItem.itemType = kAPCTableViewStudyItemTypeShare;
        APCTableViewSection *section = [self.items firstObject];
        NSMutableArray *rowItems = [NSMutableArray arrayWithArray:section.rows];
        [rowItems addObject:rowItem];
        section.rows = [NSArray arrayWithArray:rowItems];
    }
    
    if (self.showConsentRow) {
        
        APCTableViewStudyDetailsItem *reviewConsentItem = [APCTableViewStudyDetailsItem new];
        reviewConsentItem.caption = NSLocalizedString(@"Review Consent", nil);
        reviewConsentItem.iconImage = [UIImage imageNamed:@"consent_icon"];
        reviewConsentItem.tintColor = [UIColor appTertiaryPurpleColor];
        
        APCTableViewRow *rowItem = [APCTableViewRow new];
        rowItem.item = reviewConsentItem;
        
        APCTableViewSection *section = [self.items firstObject];
        NSMutableArray *rowItems = [NSMutableArray arrayWithArray:section.rows];
        [rowItems addObject:rowItem];
        section.rows = [NSArray arrayWithArray:rowItems];
    }
}

- (void)setupTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)setUpAppearance
{    
    [self.joinButton setBackgroundImage:[UIImage imageWithColor:[UIColor appPrimaryColor]] forState:UIControlStateNormal];
    [self.joinButton setTitleColor:[UIColor appSecondaryColor4] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[UIImage imageWithColor:[UIColor appSecondaryColor2]] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor appSecondaryColor4] forState:UIControlStateNormal];
    
    self.diseaseNameLabel.font = [UIFont appMediumFontWithSize:19];
    self.diseaseNameLabel.textColor = [UIColor appSecondaryColor1];
    self.diseaseNameLabel.adjustsFontSizeToFitWidth = YES;
    self.diseaseNameLabel.minimumScaleFactor = 0.5;
    
    self.dateRangeLabel.font = [UIFont appLightFontWithSize:16];
    self.dateRangeLabel.textColor = [UIColor appSecondaryColor3];
    
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

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewStudyDetailsItem *studyDetails = [self itemForIndexPath:indexPath];
    
    APCTableViewStudyItemType itemType = [self itemTypeForIndexPath:indexPath];
    
    switch (itemType) {
        case kAPCTableViewStudyItemTypeStudyDetails:
        {
            APCStudyDetailsViewController *detailsViewController = [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"StudyDetailsVC"];
            detailsViewController.studyDetails = studyDetails;
            [self.navigationController pushViewController:detailsViewController animated:YES];
        }
            break;
        case kAPCTableViewStudyItemTypeShare:
        {
            APCShareViewController *shareViewController = [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:nil] instantiateViewControllerWithIdentifier:@"ShareVC"];
            shareViewController.hidesOkayButton = YES;
            [self.navigationController pushViewController:shareViewController animated:YES];
        }
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Public methods

- (void)studyDetailsFromJSONFile:(NSString *)jsonFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    if (!parseError) {
        
        self.diseaseName = jsonDictionary[@"disease_name"];
        self.diseaseNameLabel.text = self.diseaseName;
        self.dateRangeLabel.text = [jsonDictionary[@"from_date"] stringByAppendingFormat:@" - %@", jsonDictionary[@"to_date"]];
        
        NSArray *questions = jsonDictionary[@"questions"];
        
        NSMutableArray *rowItems = [NSMutableArray new];
        
        for (NSDictionary *questionDict in questions) {
            
            APCTableViewStudyDetailsItem *studyDetails = [APCTableViewStudyDetailsItem new];
            studyDetails.caption = questionDict[@"title"];
            studyDetails.detailText = questionDict[@"details"];
            studyDetails.iconImage = [[UIImage imageNamed:questionDict[@"icon_image"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            studyDetails.tintColor = [UIColor tertiaryColorForString:questionDict[@"tint_color"]];
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = studyDetails;
            row.itemType = kAPCTableViewStudyItemTypeStudyDetails;
            [rowItems addObject:row];
        }
        
        APCTableViewSection *section = [APCTableViewSection new];
        section.rows = [NSArray arrayWithArray:rowItems];
        [self.items addObject:section];
    }
}

- (IBAction)signInTapped:(id)sender
{
    
}
- (IBAction)signUpTapped:(id)sender
{
    
}

- (APCTableViewStudyDetailsItem *)itemForIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSection *sectionItem = self.items[indexPath.section];
    APCTableViewRow *rowItem = sectionItem.rows[indexPath.row];
    
    APCTableViewStudyDetailsItem *studyDetailsItem = (APCTableViewStudyDetailsItem *)rowItem.item;
    
    return studyDetailsItem;
}

- (APCTableViewStudyItemType)itemTypeForIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSection *sectionItem = self.items[indexPath.section];
    APCTableViewRow *rowItem = sectionItem.rows[indexPath.row];
    
    APCTableViewStudyItemType studyItemType = rowItem.itemType;
    
    return studyItemType;
}

@end
