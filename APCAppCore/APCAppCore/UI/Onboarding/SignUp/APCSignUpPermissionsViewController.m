// 
//  APCSignUpPermissionsViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCAppCore.h"
#import "APCSignUpPermissionsViewController.h"
#import "APCTableViewItem.h"
#import "APCStepProgressBar.h"
#import "APCPermissionsCell.h"
#import "NSBundle+Helper.h"
#import "APCPermissionsManager.h"
#import "UIAlertController+Helper.h"
#import "UIView+Helper.h"
#import "APCAppDelegate.h"

#import <CoreMotion/CoreMotion.h>

static CGFloat const kTableViewRowHeight                 = 195.0f;

@interface APCSignUpPermissionsViewController () <UITableViewDelegate, UITableViewDataSource, APCPermissionCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic) NSInteger permissionsGrantedCount;

@property (nonatomic, strong) APCPermissionsManager *permissionsManager;

@end

#pragma mark - Init

@implementation APCSignUpPermissionsViewController

@synthesize stepProgressBar;

@synthesize user = _user;

- (instancetype)init
{
    if (self = [super init]) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _permissions = [NSMutableArray array];
    
    _permissionsGrantedCount = 0;
    
    _permissionsManager = [[APCPermissionsManager alloc] init];
}

#pragma mark - Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavAppearance];
    [self setupProgressBar];
    
    self.permissions = [self prepareData];
    [self reloadData];
}

- (void)viewWillLayoutSubviews
{
    self.stepProgressBar.frame = CGRectMake(0, -kAPCSignUpProgressBarHeight, self.view.width, kAPCSignUpProgressBarHeight);
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:([self onboarding].onboardingTask.currentStepNumber - 1) animation:YES];
    
    [self reloadData];
  APCLogViewControllerAppeared();

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Prepare Content

- (NSArray *)prepareData
{
    NSMutableArray *items = [NSMutableArray new];
    
    NSDictionary *initialOptions = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).initializationOptions;
    NSArray *servicesArray = initialOptions[kAppServicesListRequiredKey];
    
    for (NSNumber *type in servicesArray) {
        
        APCSignUpPermissionsType permissionType = type.integerValue;
        
        switch (permissionType) {
            case kSignUpPermissionsTypeHealthKit:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kSignUpPermissionsTypeHealthKit;
                item.caption = NSLocalizedString(@"Health Kit", @"");
                item.detailText = NSLocalizedString(@"Lorem ipsum dolor sit amet, etos et ya consectetur adip isicing elit, sed.", @"");
                [items addObject:item];
            }
                break;
            case kSignUpPermissionsTypeLocation:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kSignUpPermissionsTypeLocation;
                item.caption = NSLocalizedString(@"Location Services", @"");
                item.detailText = NSLocalizedString(@"Using your GPS enables the app to accurately determine distances travelled. Your actual location will never be shared.", @"");
                [items addObject:item];
            }
                break;
            case kSignUpPermissionsTypeCoremotion:
            {
                if ([CMMotionActivityManager isActivityAvailable]){
                    APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                    item.permissionType = kSignUpPermissionsTypeCoremotion;
                    item.caption = NSLocalizedString(@"Motion Activity", @"");
                    item.detailText = NSLocalizedString(@"Using the motion co-processor allows the app to determine your activity, helping the study better understand how activity level may influence disease.", @"");
                    [items addObject:item];
                }
            }
                break;
            case kSignUpPermissionsTypePushNotifications:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kSignUpPermissionsTypePushNotifications;
                item.caption = NSLocalizedString(@"Push Notifications", @"");
                item.detailText = NSLocalizedString(@"Lorem ipsum dolor sit amet, etos et ya consectetur adip isicing elit, sed.", @"");
                [items addObject:item];
            }
                break;
            case kSignUpPermissionsTypeMicrophone:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kSignUpPermissionsTypeMicrophone;
                item.caption = NSLocalizedString(@"Microphone", @"");
                item.detailText = NSLocalizedString(@"Access to microphone is required for your Voice Recording Activity.", @"");
                [items addObject:item];
            }
                break;
            default:
                break;
        }
    }
    
    return items;
}


#pragma mark - Setup

- (void)setupNavAppearance
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 44, 44);
    [backButton setImage:[[UIImage imageNamed:@"back_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    backButton.tintColor = [UIColor appPrimaryColor];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backBarButton];
}

- (void) setupProgressBar {

    self.stepProgressBar = [[APCStepProgressBar alloc] initWithFrame:CGRectMake(0, -kAPCSignUpProgressBarHeight, self.view.width, kAPCSignUpProgressBarHeight) style:APCStepProgressBarStyleDefault];
    self.stepProgressBar.numberOfSteps = [self onboarding].onboardingTask.numberOfSteps;
    [self.view addSubview:self.stepProgressBar];
    
    // Instead of reducing table view height, we can just adjust tableview scroll insets
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top += self.stepProgressBar.height;
    
    self.tableView.contentInset = inset;
    
    [self.stepProgressBar setCompletedSteps:([self onboarding].onboardingTask.currentStepNumber - 2) animation:NO];
}

- (APCUser *) user {
    if (!_user) {
        _user = ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
    }
    return _user;
}

- (APCOnboarding *)onboarding
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).onboarding;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.permissions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCPermissionsCell *cell = (APCPermissionsCell *)[tableView dequeueReusableCellWithIdentifier:kSignUpPermissionsCellIdentifier];
    
    APCTableViewPermissionsItem *item = self.permissions[indexPath.row];
    
    cell.titleLabel.text = item.caption;
    cell.detailsLabel.text = item.detailText;
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    [cell setPermissionsGranted:item.isPermissionGranted];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableViewRowHeight;
}

#pragma mark - APCPermissionCellDelegate method

- (void)permissionsCellTappedPermissionsButton:(APCPermissionsCell *)cell
{
    APCTableViewPermissionsItem *item = self.permissions[cell.indexPath.row];
    
    if (!item.isPermissionGranted) {
        
        __weak typeof(self) weakSelf = self;
        
        [self.permissionsManager requestForPermissionForType:item.permissionType withCompletion:^(BOOL granted, NSError *error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [weakSelf reloadData];
                });
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self presentSettingsAlert:error];
                });
            }            
        }];
    }
}

- (void)presentSettingsAlert:(NSError *)error
{
    UIAlertController *alertContorller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Permissions Denied", @"") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    [alertContorller addAction:dismiss];
    UIAlertAction *settings = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertContorller addAction:settings];
    
    [self.navigationController presentViewController:alertContorller animated:YES completion:nil];
}


#pragma mark - Getter/Setter

- (void)setPermissionsGrantedCount:(NSInteger)permissionsGrantedCount
{
    _permissionsGrantedCount = permissionsGrantedCount;
}

#pragma mark - Selectors / Button Actions

- (void)finishOnboarding
{
    [self.stepProgressBar setCompletedSteps:[self onboarding].onboardingTask.currentStepNumber animation:YES];
    
    if ([self onboarding].taskType == kAPCOnboardingTaskTypeSignIn) {
        // We are posting this notification after .4 seconds delay, because we need to display the progress bar completion animation
        [self performSelector:@selector(setUserSignedIn) withObject:nil afterDelay:0.4];
    } else{
        [self performSelector:@selector(setUserSignedUp) withObject:nil afterDelay:0.4];
    }
}

- (void) setUserSignedUp
{
    self.user.signedUp = YES;
}

- (void)setUserSignedIn
{
    self.user.signedIn = YES;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    [[self onboarding] popScene];
}

#pragma mark - UIApplication notification methods

- (void)appDidBecomeActive:(NSNotification *)notification
{
    [self reloadData];
}

#pragma mark - Permissions

- (void)updatePermissions
{
    self.permissionsGrantedCount = 0;
    
    for (APCTableViewPermissionsItem *item in self.permissions) {
        item.permissionGranted = [self.permissionsManager isPermissionsGrantedForType:item.permissionType];
        if (item.permissionGranted) {
            self.permissionsGrantedCount ++;
        }
    }
}

- (void)reloadData
{
    [self updatePermissions];

    [self.tableView reloadData];
}

- (IBAction)next:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self finishOnboarding];
}

@end
