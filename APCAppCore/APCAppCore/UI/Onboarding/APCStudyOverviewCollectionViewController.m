// 
//  APCStudyOverviewViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCStudyOverviewCollectionViewController.h"
#import "APCAppCore.h"
#import "APCWebViewController.h"

@interface APCStudyOverviewCollectionViewController () <ORKTaskViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *gradientCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *joinButtonLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIButton *btnAlreadyParticipated;

@end

@implementation APCStudyOverviewCollectionViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.items = [NSMutableArray new];
    
    [self setUpAppearance];
    self.items = [self prepareContent];
    [self setUpPageView];
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupCollectionView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APCConsentCompletedWithDisagreeNotification object:nil];
}

- (void) goBackToSignUpJoin: (NSNotification *) __unused notification
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

- (void)setUpPageView
{
    APCTableViewSection *sectionItem = self.items.firstObject;
    self.pageControl.numberOfPages = sectionItem.rows.count;
}

- (void)setupCollectionView
{
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.researchInstituteImageView setImage:[UIImage imageNamed:@"logo_disease_researchInstitute"]];
}

- (void)setUpAppearance
{
    self.diseaseNameLabel.font = [UIFont appMediumFontWithSize:19];
    self.diseaseNameLabel.textColor = [UIColor blackColor];
    self.diseaseNameLabel.adjustsFontSizeToFitWidth = YES;
    self.diseaseNameLabel.minimumScaleFactor = 0.5;
    
    self.dateRangeLabel.font = [UIFont appLightFontWithSize:16];
    self.dateRangeLabel.textColor = [UIColor appSecondaryColor3];
    
    self.btnAlreadyParticipated.tintColor = [UIColor appPrimaryColor];
    
}

- (APCOnboarding *)onboarding
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).onboarding;
}

- (APCUser *)user
{
    return ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) __unused collectionView
{
    return 1;
}

-(NSInteger) collectionView: (UICollectionView *) __unused collectionView
	 numberOfItemsInSection: (NSInteger) __unused section
{
    APCTableViewSection *sectionItem = self.items.firstObject;
    return sectionItem.rows.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell;
    
    APCTableViewStudyDetailsItem *studyDetails = [self itemForIndexPath:indexPath];

    if (studyDetails.videoName.length > 0) {
        
        APCStudyVideoCollectionViewCell *videoCell = (APCStudyVideoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kAPCStudyVideoCollectionViewCellIdentifier forIndexPath:indexPath];
        videoCell.delegate = self;
        videoCell.titleLabel.text = studyDetails.caption;
        
        cell = videoCell;
        
    } else {
        APCStudyOverviewCollectionViewCell *webViewCell = (APCStudyOverviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kAPCStudyOverviewCollectionViewCellIdentifier forIndexPath:indexPath];
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource: studyDetails.detailText ofType:@"html" inDirectory:@"HTMLContent"];
        NSURL *targetURL = [NSURL URLWithString:filePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [webViewCell.webView loadRequest:request];
        
        cell = webViewCell;
    }
    
    
    return cell;
}

- (CGSize) collectionView: (UICollectionView *) __unused collectionView
				   layout: (UICollectionViewLayout*) __unused collectionViewLayout
   sizeForItemAtIndexPath: (NSIndexPath *) __unused indexPath
{
    return self.collectionView.bounds.size;
}

#pragma mark - UIScrollViewDelegate methods

- (void) scrollViewDidEndDecelerating: (UIScrollView *) __unused scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    self.pageControl.currentPage = (self.collectionView.contentOffset.x + pageWidth / 2) / pageWidth;
}

#pragma mark - Consent

- (void)showConsent
{
    ORKTaskViewController *consentVC = [((APCAppDelegate *)[UIApplication sharedApplication].delegate) consentViewController];
    
    consentVC.delegate = self;
    [self presentViewController:consentVC animated:YES completion:nil];
    
}

#pragma mark - TaskViewController Delegate methods

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithResult:(ORKTaskViewControllerResult)result error:(NSError *)error
{
    if (result == ORKTaskViewControllerResultCompleted)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [taskViewController dismissViewControllerAnimated:YES completion:nil];
    }
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
            studyDetails.videoName = questionDict[@"video_name"];
            
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

- (void) signInTapped: (id) __unused sender
{
    [((APCAppDelegate *)[UIApplication sharedApplication].delegate) instantiateOnboardingForType:kAPCOnboardingTaskTypeSignIn];
    
    UIViewController *viewController = [[self onboarding] nextScene];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (void) signUpTapped: (id) __unused sender
{
    [((APCAppDelegate *)[UIApplication sharedApplication].delegate) instantiateOnboardingForType:kAPCOnboardingTaskTypeSignUp];
    
    UIViewController *viewController = [[self onboarding] nextScene];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (IBAction)pageClicked:(UIPageControl *)sender {
    NSInteger page = sender.currentPage;
    CGRect frame = self.collectionView.frame;
    CGFloat offset = frame.size.width * page;
    [self.collectionView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

#pragma mark - APCStudyVideoCollectionViewCellDelegate methods

- (void)studyVideoCollectionViewCellWatchVideo:(APCStudyVideoCollectionViewCell *)cell
{
    APCTableViewStudyDetailsItem *studyDetails = (APCTableViewStudyDetailsItem *)[self itemForIndexPath:[self.collectionView indexPathForCell:cell]];
    
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:studyDetails.videoName ofType:@"mp4"]];
    APCIntroVideoViewController *introVideoViewController = [[APCIntroVideoViewController alloc] initWithContentURL:fileURL];
    [self.navigationController presentViewController:introVideoViewController animated:YES completion:nil];

}

- (void)studyVideoCollectionViewCellReadConsent:(APCStudyVideoCollectionViewCell *)cell
{
    APCWebViewController *webViewController = [[UIStoryboard storyboardWithName:@"APCOnboarding" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCWebViewController"];
    webViewController.fileName = @"consent";
    webViewController.fileType = @"pdf";
    webViewController.title = NSLocalizedString(@"Consent", @"Consent");
    
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:webViewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];

}

- (void)studyVideoCollectionViewCellEmailConsent:(APCStudyVideoCollectionViewCell *)cell
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailComposeVC = [[MFMailComposeViewController alloc] init];
        mailComposeVC.mailComposeDelegate = self;
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"consent" ofType:@"pdf"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        [mailComposeVC addAttachmentData:fileData mimeType:@"application/pdf" fileName:@"Consent"];
        
        [self presentViewController:mailComposeVC animated:YES completion:NULL];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate method

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            APCLogError2(error);
            break;
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
