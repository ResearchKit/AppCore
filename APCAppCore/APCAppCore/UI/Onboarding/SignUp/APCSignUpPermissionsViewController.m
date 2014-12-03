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

static CGFloat const kTableViewRowHeight                 = 165.0f;

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
    
    [self.stepProgressBar setCompletedSteps:(3 + [self onboarding].signUpTask.customStepIncluded) animation:YES];
    
    [self reloadData];
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
                item.detailText = NSLocalizedString(@"Lorem ipsum dolor sit amet, etos et ya consectetur adip isicing elit, sed.", @"");
                [items addObject:item];
            }
                break;
            case kSignUpPermissionsTypeCoremotion:
            {
                if ([CMMotionActivityManager isActivityAvailable]){
                    APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                    item.permissionType = kSignUpPermissionsTypeCoremotion;
                    item.caption = NSLocalizedString(@"Core Motion", @"");
                    item.detailText = NSLocalizedString(@"Lorem ipsum dolor sit amet, etos et ya consectetur adip isicing elit, sed.", @"");
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
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void) setupProgressBar {

    self.stepProgressBar = [[APCStepProgressBar alloc] initWithFrame:CGRectMake(0, -kAPCSignUpProgressBarHeight, self.view.width, kAPCSignUpProgressBarHeight) style:APCStepProgressBarStyleDefault];
    self.stepProgressBar.numberOfSteps = kNumberOfSteps + [self onboarding].signUpTask.customStepIncluded;
    [self.view addSubview:self.stepProgressBar];
    
    // Instead of reducing table view height, we can just adjust tableview scroll insets
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top += self.stepProgressBar.height;
    
    self.tableView.contentInset = inset;
    
    [self.stepProgressBar setCompletedSteps:(2 + [self onboarding].signUpTask.customStepIncluded) animation:NO];
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
                    UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Permissions Denied", @"") message:error.localizedDescription];
                    [self presentViewController:alert animated:YES completion:nil];
                });
            }            
        }];
    }
}


#pragma mark - Getter/Setter

- (void)setPermissionsGrantedCount:(NSInteger)permissionsGrantedCount
{
    _permissionsGrantedCount = permissionsGrantedCount;
}

#pragma mark - Selectors / Button Actions

- (void)finishSignUp
{
    [self.stepProgressBar setCompletedSteps:(4 + [self onboarding].signUpTask.customStepIncluded) animation:YES];
    
    // We are posting this notification after .5 seconds delay, because we need to display the progress bar completion animation
    [self performSelector:@selector(setUserSignedUp) withObject:nil afterDelay:0.5];
}

- (void) setUserSignedUp
{
    APCSpinnerViewController *spinnerController = [[APCSpinnerViewController alloc] init];
    [self presentViewController:spinnerController animated:YES completion:nil];
    
    typeof(self) __weak weakSelf = self;
    [self.user signUpOnCompletion:^(NSError *error) {
        if (error) {
            [spinnerController dismissViewControllerAnimated:NO completion:^{
                UIAlertController *alert = [UIAlertController simpleAlertWithTitle:NSLocalizedString(@"Sign Up", @"") message:error.localizedDescription];
                [self presentViewController:alert animated:YES completion:nil];
            }];
        }
        else
        {
            [spinnerController dismissViewControllerAnimated:NO completion:^{
                weakSelf.user.signedUp = YES;
            }];
        }
    }];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    [[self onboarding] popScene];
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
    
#if DEVELOPMENT
    self.navigationItem.rightBarButtonItem.enabled = YES;
#else
    self.navigationItem.rightBarButtonItem.enabled = [self isPermissionsGranted];
#endif
}


- (BOOL)isPermissionsGranted
{
    return (self.permissionsGrantedCount == self.permissions.count);
}

- (IBAction)next:(id)sender {
    [self finishSignUp];
}

@end
