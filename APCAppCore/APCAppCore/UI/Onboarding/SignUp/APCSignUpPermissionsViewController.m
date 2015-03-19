// 
//  APCSignUpPermissionsViewController.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCAppCore.h"
#import "APCSignUpPermissionsViewController.h"
#import "APCTableViewItem.h"
#import "APCPermissionsCell.h"
#import "NSBundle+Helper.h"
#import "APCPermissionsManager.h"
#import "UIAlertController+Helper.h"
#import "UIView+Helper.h"
#import "APCAppDelegate.h"

#import <CoreMotion/CoreMotion.h>

static CGFloat const kTableViewRowHeight                 = 200.0f;

@interface APCSignUpPermissionsViewController () <UITableViewDelegate, UITableViewDataSource, APCPermissionCellDelegate>

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
    
    _permissionsManager = [[APCPermissionsManager alloc] init];
}

#pragma mark - Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavAppearance];
    
    self.permissions = [self prepareData].mutableCopy;
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:([self onboarding].onboardingTask.currentStepNumber - 1) animation:YES];
    
    [self.tableView reloadData];
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
    NSDictionary *servicesDescrtiptions = initialOptions[kAppServicesDescriptionsKey];
    
    for (NSNumber *type in servicesArray) {
        
        APCSignUpPermissionsType permissionType = type.integerValue;
        
        switch (permissionType) {
            case kSignUpPermissionsTypeHealthKit:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kSignUpPermissionsTypeHealthKit;
                item.caption = NSLocalizedString(@"Health Kit", @"");
                item.detailText = servicesDescrtiptions[@(kSignUpPermissionsTypeHealthKit)];
                [items addObject:item];
            }
                break;
            case kSignUpPermissionsTypeLocation:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kSignUpPermissionsTypeLocation;
                item.caption = NSLocalizedString(@"Location Services", @"");
                item.detailText = servicesDescrtiptions[@(kSignUpPermissionsTypeLocation)];
                [items addObject:item];
            }
                break;
            case kSignUpPermissionsTypeCoremotion:
            {
                if ([CMMotionActivityManager isActivityAvailable]){
                    APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                    item.permissionType = kSignUpPermissionsTypeCoremotion;
                    item.caption = NSLocalizedString(@"Motion Activity", @"");
                    item.detailText = servicesDescrtiptions[@(kSignUpPermissionsTypeCoremotion)];
                    [items addObject:item];
                }
            }
                break;
            case kSignUpPermissionsTypeLocalNotifications:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kSignUpPermissionsTypeLocalNotifications;
                item.caption = NSLocalizedString(@"Notifications", @"");
                item.detailText = servicesDescrtiptions[@(kSignUpPermissionsTypeLocalNotifications)];
                [items addObject:item];
            }
                break;
            case kSignUpPermissionsTypeMicrophone:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kSignUpPermissionsTypeMicrophone;
                item.caption = NSLocalizedString(@"Microphone", @"");
                item.detailText = servicesDescrtiptions[@(kSignUpPermissionsTypeMicrophone)];
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
    UIBarButtonItem  *backster = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(back) tintColor:[UIColor appPrimaryColor]];
    [self.navigationItem setLeftBarButtonItem:backster];
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

- (NSInteger) tableView: (UITableView *) __unused tableView
  numberOfRowsInSection: (NSInteger) __unused section
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
    [cell.permissionButton setEnabled:item.permissionGranted];
    [cell setPermissionsGranted:item.permissionGranted];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)       tableView: (UITableView *) __unused tableView
    heightForRowAtIndexPath: (NSIndexPath *) __unused indexPath
{
    return kTableViewRowHeight;
}

#pragma mark - APCPermissionCellDelegate method

- (void)permissionsCellTappedPermissionsButton:(APCPermissionsCell *)cell
{
    __block APCTableViewPermissionsItem *item = self.permissions[cell.indexPath.row];
    
    if (!item.permissionGranted) {
        
        __weak typeof(self) weakSelf = self;
        
        [self.permissionsManager requestForPermissionForType:item.permissionType withCompletion:^(BOOL granted, NSError *error) {
            if (granted) {
                APCTableViewPermissionsItem *item = weakSelf.permissions[cell.indexPath.row];
                [item setPermissionGranted:granted];
                weakSelf.permissions[cell.indexPath.row] = item;
                [self.tableView reloadData];
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self presentSettingsAlert:error];
                });
            }            
        }];
    }
    [self.tableView reloadData];
}

- (void)presentSettingsAlert:(NSError *)error
{
    UIAlertController *alertContorller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Permissions Denied", @"") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *__unused action) {
        
    }];
    [alertContorller addAction:dismiss];
    UIAlertAction *settings = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * __unused action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertContorller addAction:settings];
    
    [self.navigationController presentViewController:alertContorller animated:YES completion:nil];
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
    
    [(APCAppDelegate *)[UIApplication sharedApplication].delegate afterOnBoardProcessIsFinished];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    [[self onboarding] popScene];
}

#pragma mark - UIApplication notification methods

- (void) appDidBecomeActive: (NSNotification *) __unused notification
{
    [self.tableView reloadData];
}

#pragma mark - Permissions

- (IBAction) next: (id) __unused sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.onboarding.taskType == kAPCOnboardingTaskTypeSignIn) {
        UIViewController *viewController = [[self onboarding] nextScene];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [self finishOnboarding];
    }
}

@end
