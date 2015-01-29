// 
//  APCStudyOverviewViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCStudyOverviewViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "UIImage+APCHelper.h"
#import "APCStudyDetailsViewController.h"
#import "APCShareViewController.h"
#import "APCAppDelegate.h"
#import "APCOnboarding.h"
#import "NSBundle+Helper.h"
#import "APCSignInViewController.h"
#import "APCUser.h"
#import "UIAlertController+Helper.h"
#import "APCDeviceHardware+APCHelper.h"
#import "APCAppCore.h"

static NSString * const kStudyOverviewCellIdentifier = @"kStudyOverviewCellIdentifier";

@interface APCStudyOverviewViewController () <RKSTTaskViewControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *joinButtonLeadingConstraint;

@end

@implementation APCStudyOverviewViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.items = [NSMutableArray new];
    
    [self setupTableView];
    [self setUpAppearance];
    self.items = [self prepareContent];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goBackToSignUpJoin:)
                                                 name:APCConsentCompletedWithDisagreeNotification
                                               object:nil];
  APCLogViewControllerAppeared();
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APCConsentCompletedWithDisagreeNotification object:nil];
}

- (void)goBackToSignUpJoin:(NSNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSArray *)prepareContent
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:[self studyDetailsFromJSONFile:@"StudyOverview"]];
    
    if (self.showShareRow){
        
        APCTableViewStudyDetailsItem *shareStudyItem = [APCTableViewStudyDetailsItem new];
        shareStudyItem.caption = NSLocalizedString(@"Share this Study", nil);
        shareStudyItem.iconImage = [UIImage imageNamed:@"share_icon"];
        shareStudyItem.tintColor = [UIColor appTertiaryGreenColor];

        APCTableViewRow *rowItem = [APCTableViewRow new];
        rowItem.item = shareStudyItem;
        rowItem.itemType = kAPCTableViewStudyItemTypeShare;
        
        APCTableViewSection *section = [items firstObject];
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
        rowItem.itemType = kAPCTableViewStudyItemTypeReviewConsent;
        
        APCTableViewSection *section = [items firstObject];
        NSMutableArray *rowItems = [NSMutableArray arrayWithArray:section.rows];
        [rowItems addObject:rowItem];
        section.rows = [NSArray arrayWithArray:rowItems];
    }
    
    return [NSArray arrayWithArray:items];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([self user].consented) {
        self.joinButtonLeadingConstraint.constant = CGRectGetWidth(self.view.frame)/2;
        [self.view layoutIfNeeded];
    }
}
- (void)setupTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.researchInstituteImageView setImage:[UIImage imageNamed:@"logo_disease_researchInstitute"]];
}

- (void)setUpAppearance
{
    self.diseaseNameLabel.font = [UIFont appMediumFontWithSize:19];
    self.diseaseNameLabel.textColor = [UIColor appSecondaryColor1];
    self.diseaseNameLabel.adjustsFontSizeToFitWidth = YES;
    self.diseaseNameLabel.minimumScaleFactor = 0.5;
    
    self.dateRangeLabel.font = [UIFont appLightFontWithSize:16];
    self.dateRangeLabel.textColor = [UIColor appSecondaryColor3];
    
}

- (APCOnboarding *)onboarding
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).onboarding;
}

- (APCUser *)user
{
    return ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
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
            APCStudyDetailsViewController *detailsViewController = [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"StudyDetailsVC"];
            detailsViewController.studyDetails = studyDetails;
            [self.navigationController pushViewController:detailsViewController animated:YES];
        }
            break;
        case kAPCTableViewStudyItemTypeShare:
        {
            APCShareViewController *shareViewController = [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"ShareVC"];
            shareViewController.hidesOkayButton = YES;
            [self.navigationController pushViewController:shareViewController animated:YES];
        }
            break;
            
        case kAPCTableViewStudyItemTypeReviewConsent:
        {
            [self showConsent];
        }
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Consent

- (void)showConsent
{
    RKSTTaskViewController *consentVC = [((APCAppDelegate *)[UIApplication sharedApplication].delegate) consentViewController];
    
    consentVC.delegate = self;
    [self presentViewController:consentVC animated:YES completion:nil];
    
}

#pragma mark - TaskViewController Delegate methods

- (void)taskViewControllerDidComplete: (RKSTTaskViewController *)taskViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewControllerDidCancel:(RKSTTaskViewController *)taskViewController
{
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewController:(RKSTTaskViewController *)taskViewController didFailOnStep:(RKSTStep *)step withError:(NSError *)error
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
    
    NSMutableArray *items = [NSMutableArray new];
    
    if (!parseError) {
        
        self.diseaseName = jsonDictionary[@"disease_name"];
        self.diseaseNameLabel.text = self.diseaseName;
        
        NSString *fromDate = jsonDictionary[@"from_date"];
        if (fromDate.length > 0) {
            self.dateRangeLabel.text = [fromDate stringByAppendingFormat:@" - %@", jsonDictionary[@"to_date"]];
        } else {
            self.dateRangeLabel.hidden = YES;
        }
        
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
        [items addObject:section];
    }
    
    return [NSArray arrayWithArray:items];
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

- (void)signInTapped:(id)sender
{
    [((APCAppDelegate *)[UIApplication sharedApplication].delegate) instantiateOnboardingForType:kAPCOnboardingTaskTypeSignIn];
    
    UIViewController *viewController = [[self onboarding] nextScene];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (void)signUpTapped:(id)sender
{
    [((APCAppDelegate *)[UIApplication sharedApplication].delegate) instantiateOnboardingForType:kAPCOnboardingTaskTypeSignUp];
    
    UIViewController *viewController = [[self onboarding] nextScene];
    [self.navigationController pushViewController:viewController animated:YES];
    
}


@end
