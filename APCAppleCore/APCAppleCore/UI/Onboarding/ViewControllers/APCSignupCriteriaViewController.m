//
//  APCSignupCriteriaViewController.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppleCore.h"
#import "APCCriteriaCell.h"
#import "UIView+Helper.h"
#import "NSDate+Helper.h"
#import "APCTableViewItem.h"
#import "NSBundle+Helper.h"
#import "APCSegmentControl.h"
#import "APCStepProgressBar.h"
#import "APCSignupCriteriaViewController.h"
#import "APCSignUpPermissionsViewController.h"

#define SKIP_CONSENT 0

static NSString const *kAPCSignupCriteriaTableViewCellIdentifier    =   @"Criteria";

static CGFloat const kAPCSignupCriteriaTableViewCellHeight          =   98.0;


@interface APCSignupCriteriaViewController ()

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *criterias;

@end

@implementation APCSignupCriteriaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.criterias = [NSMutableArray array];
    
    {
        APCTableViewSegmentItem *item = [APCTableViewSegmentItem new];
        item.detailText = NSLocalizedString(@"I am a:", @"");
        item.segments = @[ NSLocalizedString(@"Patient", @""), NSLocalizedString(@"Caregiver", @"") ];
        item.selectedIndex = -1;
        [self.criterias addObject:item];
    }
    
    {
        APCTableViewSegmentItem *item = [APCTableViewSegmentItem new];
        item.detailText = NSLocalizedString(@"Do you have Parkinson's Disease?", @"");
        item.segments = @[ NSLocalizedString(@"Yes", @""), NSLocalizedString(@"No", @""), NSLocalizedString(@"I don't know", @"") ];
        item.selectedIndex = -1;
        [self.criterias addObject:item];
    }
    
    {
        APCTableViewDatePickerItem *item = [APCTableViewDatePickerItem new];
        item.detailText = NSLocalizedString(@"When were you diagnosed?", @"");
        item.caption = NSLocalizedString(@"Date", @"");
        item.placeholder = @"MMMM DD, YYYY";
        item.textAlignnment = NSTextAlignmentRight;
        item.date = [NSDate date];
        [self.criterias addObject:item];
    }
    
    {
        APCTableViewSegmentItem *item = [APCTableViewSegmentItem new];
        item.detailText = NSLocalizedString(@"What is the level of severity?", @"");
        item.segments = @[ NSLocalizedString(@"Mid", @""), NSLocalizedString(@"Moderate", @""), NSLocalizedString(@"Advanced", @"") ];
        item.selectedIndex = -1;
        [self.criterias addObject:item];
    }
    
    [self addNavigationItems];
    [self addTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (UIRectEdge)edgesForExtendedLayout
{
    return UIRectEdgeNone;
}

- (void) addNavigationItems {
    self.title = NSLocalizedString(@"Inclusion Criteria", @"");
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") style:UIBarButtonItemStylePlain target:self action:@selector(next)];
    nextBarButton.enabled = [self isContentValid];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}

- (void) addTableView {
    CGRect frame = self.view.bounds;
    frame.origin.y = self.topLayoutGuide.length;
    frame.size.height -= frame.origin.y;
    
    self.tableView = [UITableView new];
    self.tableView.frame = frame;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"APCCriteriaCell" bundle:[NSBundle appleCoreBundle]] forCellReuseIdentifier:(NSString *)kAPCSignupCriteriaTableViewCellIdentifier];
}


#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.criterias.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    APCTableViewItem *item = self.criterias[indexPath.row];
    
    APCCriteriaCell *cell = (APCCriteriaCell *)[tableView dequeueReusableCellWithIdentifier:(NSString *)kAPCSignupCriteriaTableViewCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.questionLabel.text = item.detailText;
    cell.captionLabel.text = item.caption;
    
    if ([item isKindOfClass:[APCTableViewSegmentItem class]]) {
        cell.segmentControl.hidden = NO;
        
        [cell setSegments:[(APCTableViewSegmentItem *)item segments] selectedIndex:[(APCTableViewSegmentItem *)item selectedIndex]];
        cell.segmentControl.segmentBorderColor = [UIColor clearColor];
    }
    else if ([item isKindOfClass:[APCTableViewDatePickerItem class]]) {
        cell.captionLabel.hidden = NO;
        cell.valueTextField.hidden = NO;
        
        NSDate *date = [(APCTableViewDatePickerItem *)item date];
        cell.valueTextField.text = [date toStringWithFormat:[(APCTableViewDatePickerItem *)item dateFormat]];
        cell.valueTextField.placeholder = [(APCTableViewDatePickerItem *)item placeholder];
        cell.valueTextField.textAlignment = [(APCTableViewDatePickerItem *)item textAlignnment];
        cell.valueTextField.inputView = cell.datePicker;
        cell.valueTextField.clearButtonMode = UITextFieldViewModeNever;
        cell.valueTextField.tintColor = [UIColor clearColor];
        
        cell.datePicker.datePickerMode = UIDatePickerModeDate;
        cell.datePicker.date = date;
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kAPCSignupCriteriaTableViewCellHeight;
}


#pragma mark - APCCriteriaCellDelegate

- (void)configurableCell:(APCConfigurableCell *)cell segmentIndexChanged:(NSUInteger)index {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewSegmentItem *criteria = self.criterias[indexPath.row];
    criteria.selectedIndex = cell.segmentControl.selectedSegmentIndex;
    
    self.navigationItem.rightBarButtonItem.enabled = [self isContentValid];
    
    [self.tableView endEditing:YES];
}

- (void) configurableCell:(APCConfigurableCell *)cell textValueChanged:(NSString *)text {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewTextFieldItem *criteria = self.criterias[indexPath.row];
    criteria.value = text;
    
    self.navigationItem.rightBarButtonItem.enabled = [self isContentValid];
    
    [self.tableView endEditing:YES];
}

- (void) configurableCell:(APCConfigurableCell *)cell dateValueChanged:(NSDate *)date {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewDatePickerItem *criteria = self.criterias[indexPath.row];
    criteria.date = cell.datePicker.date;
    
    cell.valueTextField.text = [cell.datePicker.date toStringWithFormat:nil];
    
    self.navigationItem.rightBarButtonItem.enabled = [self isContentValid];
    
    [self.tableView endEditing:YES];
}

- (void)showConsent
{
    RKConsentDocument* consent = [[RKConsentDocument alloc] init];
    consent.title = @"Demo Consent";
    consent.signaturePageTitle = @"Consent";
    consent.signaturePageContent = @"I agree  to participate in this research Study.";
    
    
    RKConsentSignature *participantSig = [RKConsentSignature signatureForPersonWithTitle:@"Participant" name:nil signatureImage:nil dateString:nil];
    [consent addSignature:participantSig];
    
    RKConsentSignature *investigatorSig = [RKConsentSignature signatureForPersonWithTitle:@"Investigator" name:@"Jake Clemson" signatureImage:[UIImage imageNamed:@"signature.png"] dateString:@"9/2/14"];
    [consent addSignature:investigatorSig];
    
    
    
    
    NSMutableArray* components = [NSMutableArray new];
    
    NSArray* scenes = @[@(RKConsentSectionTypeOverview),
                        @(RKConsentSectionTypeActivity),
                        @(RKConsentSectionTypeSensorData),
                        @(RKConsentSectionTypeDeIdentification),
                        @(RKConsentSectionTypeCombiningData),
                        @(RKConsentSectionTypeUtilizingData),
                        @(RKConsentSectionTypeImpactLifeTime),
                        @(RKConsentSectionTypePotentialRiskUncomfortableQuestion),
                        @(RKConsentSectionTypePotentialRiskSocial),
                        @(RKConsentSectionTypeAllowWithdraw)];
    for (NSNumber* type in scenes) {
        RKConsentSection* c = [[RKConsentSection alloc] initWithType:type.integerValue];
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    {
        RKConsentSection* c = [[RKConsentSection alloc] initWithType:RKConsentSectionTypeCustom];
        c.summary = @"Custom Scene summary";
        c.title = @"Custom Scene";
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        c.customImage = [UIImage imageNamed:@"image_example.png"];
        [components addObject:c];
    }
    
    {
        RKConsentSection* c = [[RKConsentSection alloc] initWithType:RKConsentSectionTypeOnlyInDocument];
        c.summary = @"OnlyInDocument Scene summary";
        c.title = @"OnlyInDocument Scene";
        c.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [components addObject:c];
    }
    
    consent.sections = [components copy];
    
    RKVisualConsentStep *step = [[RKVisualConsentStep alloc] initWithDocument:consent];
    RKConsentReviewStep *reviewStep = [[RKConsentReviewStep alloc] initWithSignature:participantSig inDocument:consent];
    RKTask *task = [[RKTask alloc] initWithName:@"consent" identifier:@"consent" steps:@[step,reviewStep]];
    RKTaskViewController *consentVC = [[RKTaskViewController alloc] initWithTask:task taskInstanceUUID:[NSUUID UUID]];
    
    consentVC.taskDelegate = self;
    [self presentViewController:consentVC animated:YES completion:nil];
    
}
#pragma mark - Private Methods

- (void) next
{
#if SKIP_CONSENT
    [((APCAppDelegate*)[UIApplication sharedApplication].delegate) dataSubstrate].currentUser.userConsented = YES;
    [self startSignUp];
#else
    [self showConsent];
#endif
    
}

- (BOOL) isContentValid
{
    BOOL isContentValid = NO;
    
    for (APCTableViewItem *item in self.criterias) {
        if ([item isKindOfClass:[APCTableViewSegmentItem class]]) {
            isContentValid = ([(APCTableViewSegmentItem *)item selectedIndex] != -1);
        }
        else if ([item isKindOfClass:[APCTableViewDatePickerItem class]]) {
            isContentValid = ([(APCTableViewDatePickerItem *)item date] != nil);
        }
        
        // Because we need not continue the loop, if any one of the field was not answered.
        if (!isContentValid) {
            break;
        }
    }
    
    return isContentValid;
}

#pragma mark - TaskViewController Delegate methods

- (void)taskViewControllerDidComplete: (RKTaskViewController *)taskViewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        [((APCAppDelegate*)[UIApplication sharedApplication].delegate) dataSubstrate].currentUser.userConsented = YES;
        [self startSignUp];
    }];
}

- (void)taskViewControllerDidCancel:(RKTaskViewController *)taskViewController
{
    [taskViewController suspend];
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public Method

- (void)startSignUp
{
    
}

@end
