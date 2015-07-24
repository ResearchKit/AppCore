// 
//  APCSignUpPermissionsViewController.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCSignUpPermissionsViewController.h"
#import "APCOnboardingManager.h"
#import "APCPermissionsManager.h"
#import "APCDataSubstrate.h"
#import "APCLog.h"
#import "APCTableViewItem.h"
#import "APCPermissionsCell.h"
#import "APCStepProgressBar.h"
#import "APCCustomBackButton.h"

#import "UIColor+APCAppearance.h"
#import "NSBundle+Helper.h"
#import "UIView+Helper.h"
#import "UIAlertController+Helper.h"

#import <CoreMotion/CoreMotion.h>

static CGFloat const kTableViewRowHeight                 = 200.0f;

@interface APCSignUpPermissionsViewController () <UITableViewDelegate, UITableViewDataSource, APCPermissionCellDelegate>

@property (nonatomic, strong) APCPermissionsManager *permissionsManager;

@end

#pragma mark - Init

@implementation APCSignUpPermissionsViewController

@synthesize stepProgressBar;


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
    self.permissions = [NSMutableArray array];
    self.permissionsManager = [self onboardingManager].permissionsManager;
}

#pragma mark - Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.permissions = [self prepareData].mutableCopy;
    [self setupNavAppearance];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Prepare Content

- (NSArray *)prepareData
{
    NSMutableArray *items = [NSMutableArray new];
    for (NSNumber *type in _permissionsManager.requiredServiceTypes) {
        
        APCSignUpPermissionsType permissionType = type.integerValue;
        
        switch (permissionType) {
            case kAPCSignUpPermissionsTypeHealthKit:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kAPCSignUpPermissionsTypeHealthKit;
                item.permissionGranted = [self.permissionsManager isPermissionsGrantedForType:item.permissionType];
                item.caption = NSLocalizedString(@"Health Kit", @"");
                item.detailText = [_permissionsManager permissionDescriptionForType:kAPCSignUpPermissionsTypeHealthKit];
                [items addObject:item];
            }
                break;
            case kAPCSignUpPermissionsTypeLocation:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kAPCSignUpPermissionsTypeLocation;
                item.permissionGranted = [self.permissionsManager isPermissionsGrantedForType:item.permissionType];
                item.caption = NSLocalizedString(@"Location Services", @"");
                item.detailText = [_permissionsManager permissionDescriptionForType:kAPCSignUpPermissionsTypeLocation];
                [items addObject:item];
            }
                break;
            case kAPCSignUpPermissionsTypeCoremotion:
            {
                if ([CMMotionActivityManager isActivityAvailable]){
                    APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                    item.permissionType = kAPCSignUpPermissionsTypeCoremotion;
                    item.permissionGranted = [self.permissionsManager isPermissionsGrantedForType:item.permissionType];
                    item.caption = NSLocalizedString(@"Motion Activity", @"");
                    item.detailText = [_permissionsManager permissionDescriptionForType:kAPCSignUpPermissionsTypeCoremotion];
                    [items addObject:item];
                }
            }
                break;
            case kAPCSignUpPermissionsTypeLocalNotifications:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kAPCSignUpPermissionsTypeLocalNotifications;
                item.permissionGranted = [self.permissionsManager isPermissionsGrantedForType:item.permissionType];
                item.caption = NSLocalizedString(@"Notifications", @"");
                item.detailText = [_permissionsManager permissionDescriptionForType:kAPCSignUpPermissionsTypeLocalNotifications];
                [items addObject:item];
            }
                break;
            case kAPCSignUpPermissionsTypeMicrophone:
            {
                APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
                item.permissionType = kAPCSignUpPermissionsTypeMicrophone;
                item.permissionGranted = [self.permissionsManager isPermissionsGrantedForType:item.permissionType];
                item.caption = NSLocalizedString(@"Microphone", @"");
                item.detailText = [_permissionsManager permissionDescriptionForType:kAPCSignUpPermissionsTypeMicrophone];
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

- (APCOnboardingManager *)onboardingManager {
    return [(id<APCOnboardingManagerProvider>)[UIApplication sharedApplication].delegate onboardingManager];
}

- (APCOnboarding *)onboarding {
    return [self onboardingManager].onboarding;
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
    
    // We are calling this method after .4 seconds delay, because we need to display the progress bar completion animation
    APCOnboardingManager *manager = [self onboardingManager];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [manager onboardingDidFinish];
    });
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    [[self onboarding] popScene];
}

#pragma mark - UIApplication notification methods

- (void) appDidBecomeActive: (NSNotification *) __unused notification
{
    self.permissions = [self prepareData].mutableCopy;
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
