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
#import "APCAppCore.h"

static CGFloat kSectionHeaderHeight = 40.f;
static NSString *kreturnControlOfTaskDelegate = @"returnControlOfTaskDelegate";

@interface APCLearnMasterViewController () <ORKTaskViewControllerDelegate>

@property (strong, nonatomic) ORKTaskViewController *consentVC;
@property (weak, nonatomic) IBOutlet UIImageView *diseaseBanner;
@property (weak, nonatomic) IBOutlet UILabel *diseaseName;

@end

@implementation APCLearnMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnControlOfTaskDelegate:) name:kreturnControlOfTaskDelegate object:nil];
    
    self.items = [NSMutableArray new];
    
    self.diseaseBanner.image = [UIImage imageNamed:@"logo_disease_researchInstitute"];
    self.diseaseName.text = [APCUtilities appName];
    
    self.items = [self prepareContent];
    
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUpNavigationBarAppearance];
}

-(void)setUpNavigationBarAppearance{
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  APCLogViewControllerAppeared();
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kreturnControlOfTaskDelegate object:nil];
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

- (NSInteger) numberOfSectionsInTableView: (UITableView *) __unused tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *) __unused tableView
  numberOfRowsInSection: (NSInteger) section
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
    cell.imageView.tintColor = [UIColor appPrimaryColor];
    
    return cell;
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
        case kAPCTableViewLearnItemTypeReviewConsent:
        {
            [self showConsent];
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

- (CGFloat)        tableView: (UITableView *) __unused tableView
    heightForHeaderInSection: (NSInteger) section
{
    CGFloat height;
    
    if (section == 0) {
        height = 0;
    } else {
        height = kSectionHeaderHeight;
    }
    
    return height;
}

#pragma mark - Consent

- (void)showConsent
{
    self.consentVC = [((APCAppDelegate *)[UIApplication sharedApplication].delegate) consentViewController];
    
    self.consentVC.delegate = self;
    [self presentViewController:self.consentVC animated:YES completion:nil];
    
}

#pragma mark - TaskViewController Delegate methods
//If the TaskViewController has claimed the task delegate, we will be returned control here
-(void) returnControlOfTaskDelegate: (id) __unused sender
{
    self.consentVC.delegate = self;
}

- (void)taskViewControllerDidComplete: (ORKTaskViewController *) __unused taskViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewControllerDidCancel:(ORKTaskViewController *)taskViewController
{
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFailOnStep:(ORKStep *) __unused step withError:(NSError *) __unused error
{
    //TODO: Figure out what to do if it fails
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
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
                
                rowItem.item = studyDetails;
                
                if ([studyDetails.detailText isEqualToString:@"study_details"]) {
                    rowItem.itemType = kAPCTableViewLearnItemTypeStudyDetails;
                }else {
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
