// 
//  APCStudyOverviewViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCStudyOverviewCollectionViewController.h"
#import "APCAppCore.h"
#import "APCStudyOverviewCollectionViewCell.h"

static NSString * const kStudyOverviewCellIdentifier = @"kStudyOverviewCellIdentifier";

@interface APCStudyOverviewCollectionViewController () <RKSTTaskViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *gradientCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *joinButtonLeadingConstraint;

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
    [self setupCollectionView];
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
    [self addTransparencyGradient];
}

- (void)addTransparencyGradient
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.gradientCollectionView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor, nil];
    gradientLayer.startPoint = CGPointMake(1.0f, 0.9f);
    gradientLayer.endPoint = CGPointMake(1.0f, 1.0f);
    self.gradientCollectionView.layer.mask = gradientLayer;
}

- (void)setUpAppearance
{
    self.diseaseNameLabel.font = [UIFont appMediumFontWithSize:19];
    self.diseaseNameLabel.textColor = [UIColor blackColor];
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

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    APCTableViewSection *sectionItem = self.items.firstObject;
    return sectionItem.rows.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    APCStudyOverviewCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"studyOverviewCell" forIndexPath:indexPath];
    
    APCTableViewStudyDetailsItem *studyDetails = [self itemForIndexPath: indexPath];

    NSString *filePath = [[NSBundle mainBundle] pathForResource: studyDetails.detailText ofType:@"html" inDirectory:@"HTMLContent"];
    NSURL *targetURL = [NSURL URLWithString:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [cell.webView loadRequest:request];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.collectionView.bounds.size;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.collectionView.frame.size.width;
    self.pageControl.currentPage = (self.collectionView.contentOffset.x + pageWidth / 2) / pageWidth;
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
