//
//  APCSignUpPermissionsViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 9/19/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppleCore.h"
#import "APCSignUpPermissionsViewController.h"
#import "APCTableViewItem.h"
#import "APCStepProgressBar.h"
#import "UIView+Helper.h"
#import "APCPermissionsCell.h"
#import "NSBundle+Helper.h"
#import "APCPermissionsManager.h"
#import <CoreMotion/CoreMotion.h>


static NSString * const kSignUpPermissionsCellIdentifier = @"PermissonsCell";
static CGFloat const kTableViewRowHeight                 = 165.0f;
static NSString *const kSignedUpKey = @"SignedUp";

@interface APCSignUpPermissionsViewController () <UITableViewDelegate, UITableViewDataSource, APCPermissionCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *permissions;

@property (nonatomic) NSInteger permissionsGrantedCount;

@property (nonatomic, strong) APCPermissionsManager *permissionsManager;

@end

#pragma mark - Init

@implementation APCSignUpPermissionsViewController

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
    
    {
        APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
        item.permissionType = kSignUpPermissionsTypeHealthKit;
        item.caption = NSLocalizedString(@"Health Kit", @"");
        item.detailText = NSLocalizedString(@"Lorem ipsum dolor sit amet, etos et ya consectetur adip isicing elit, sed.", @"");
        [self.permissions addObject:item];
    }
    
    {
        APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
        item.permissionType = kSignUpPermissionsTypeLocation;
        item.caption = NSLocalizedString(@"Location Services", @"");
        item.detailText = NSLocalizedString(@"Lorem ipsum dolor sit amet, etos et ya consectetur adip isicing elit, sed.", @"");
        [self.permissions addObject:item];
    }
    
    {
        APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
        item.permissionType = kSignUpPermissionsTypePushNotifications;
        item.caption = NSLocalizedString(@"Push Notifications", @"");
        item.detailText = NSLocalizedString(@"Lorem ipsum dolor sit amet, etos et ya consectetur adip isicing elit, sed.", @"");
        [self.permissions addObject:item];
    }
    
    {
        if ([CMMotionActivityManager isActivityAvailable]){
            APCTableViewPermissionsItem *item = [APCTableViewPermissionsItem new];
            item.permissionType = kSignUpPermissionsTypeCoremotion;
            item.caption = NSLocalizedString(@"Core Motion", @"");
            item.detailText = NSLocalizedString(@"Lorem ipsum dolor sit amet, etos et ya consectetur adip isicing elit, sed.", @"");
            [self.permissions addObject:item];
        }        
    }
    
    _permissionsGrantedCount = 0;
    
    _permissionsManager = [[APCPermissionsManager alloc] init];
}

#pragma mark - Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addNavigationItems];
    [self setupProgressBar];
    [self addTableView];
    
    [self reloadData];
}

- (void)viewWillLayoutSubviews
{
    CGRect frame = self.view.bounds;
    frame.origin.y = self.stepProgressBar.bottom;
    frame.size.height -= frame.origin.y;
    self.tableView.frame = frame;
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:3 animation:YES];
    
    [self reloadData];
}

#pragma mark - Setup

- (void) addNavigationItems {
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"") style:UIBarButtonItemStylePlain target:self action:@selector(finishSignUp)];
    nextBarButton.enabled = [self isPermissionsGranted];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}

- (void) setupProgressBar {
    [self.stepProgressBar setCompletedSteps:2 animation:NO];
    [self setStepNumber:4 title:NSLocalizedString(@"Permissions", @"")];
}

- (void) addTableView {
    CGRect frame = self.view.bounds;
    frame.origin.y = self.stepProgressBar.bottom;
    frame.size.height -= frame.origin.y;
    
    self.tableView = [UITableView new];
    self.tableView.frame = frame;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"APCPermissionsCell" bundle:[NSBundle appleCoreBundle]] forCellReuseIdentifier:kSignUpPermissionsCellIdentifier];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.permissions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCPermissionsCell *cell = (APCPermissionsCell *)[tableView dequeueReusableCellWithIdentifier:kSignUpPermissionsCellIdentifier forIndexPath:indexPath];
    
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
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Permissions Denied", nil)
                                                                    message:error.localizedDescription
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                });
            }            
        }];
    }
}


#pragma mark - Getter/Setter

- (void)setPermissionsGrantedCount:(NSInteger)permissionsGrantedCount
{
    _permissionsGrantedCount = permissionsGrantedCount;
    
    self.navigationItem.rightBarButtonItem.enabled = [self isPermissionsGranted];
}

#pragma mark - Selectors / Button Actions

- (void)finishSignUp
{
    [self.stepProgressBar setCompletedSteps:5 animation:YES];
    
    // We are posting this notification after .5 seconds delay, because we need to display the progress bar completion animation
    [self performSelector:@selector(postLoginNotification) withObject:nil afterDelay:0.5];
}

- (void) postLoginNotification
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSignedUpKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)APCUserSignedUpNotification object:nil];
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
    
    self.navigationItem.leftBarButtonItem.enabled = [self isPermissionsGranted];
}


- (BOOL)isPermissionsGranted
{
    return (self.permissionsGrantedCount == self.permissions.count);
}

@end
