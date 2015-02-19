// 
//  APCActivitiesViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCActivitiesViewController.h"
#import "APCAppCore.h"
#import "APCActivitiesViewWithNoTask.h"
#import "APCCircularProgressView.h"

static NSString *kTableCellReuseIdentifier = @"ActivitiesTableViewCell";
static NSString *kTableCellWithTimeReuseIdentifier = @"ActivitiesTableViewCellWithTime";

static CGFloat kTableViewRowHeight = 80;
static CGFloat kTableViewSectionHeaderHeight = 45;

@interface APCActivitiesViewController ()

@property (nonatomic) BOOL taskSelectionDisabled;

@property (strong, nonatomic) NSMutableArray *sectionsArray;
@property (strong, nonatomic) NSMutableArray *scheduledTasksArray;

@property (strong, nonatomic) APCActivitiesViewWithNoTask *noTasksView;

@end

@implementation APCActivitiesViewController

#pragma mark - Lazy Loading
- (NSMutableArray*) scheduledTasksArray
{
    if (!_scheduledTasksArray) {
        _scheduledTasksArray = [NSMutableArray array];
    }
    return _scheduledTasksArray;
}

- (NSMutableArray *)sectionsArray
{
    if (!_sectionsArray) {
        _sectionsArray = [NSMutableArray array];
    }
    return _sectionsArray;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Activities", @"Activities");
    self.tableView.backgroundColor = [UIColor appSecondaryColor4];
    
    [((APCAppDelegate *)[[UIApplication sharedApplication] delegate]) showPasscodeIfNecessary];
    
    self.taskProgress.lineWidth = 2;
    self.taskProgress.tintColor = [UIColor appPrimaryColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpNavigationBarAppearance];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:APCUpdateActivityNotification object:nil];
    APCLogViewControllerAppeared();
}

-(void)setUpNavigationBarAppearance{
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.translucent = NO;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *) __unused tableView
{
    return self.sectionsArray.count;
}

- (NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray*)self.scheduledTasksArray[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id task = ((NSArray*)self.scheduledTasksArray[indexPath.section])[indexPath.row];
    
    APCGroupedScheduledTask *groupedScheduledTask;
    APCScheduledTask *scheduledTask;
    NSString * taskCompletionTimeString;
    
    if ([task isKindOfClass:[APCGroupedScheduledTask class]])
    {
        groupedScheduledTask = (APCGroupedScheduledTask *)task;
        taskCompletionTimeString = groupedScheduledTask.taskCompletionTimeString;
    }
    else if ([task isKindOfClass:[APCScheduledTask class]])
    {
        scheduledTask = (APCScheduledTask *)task;
        taskCompletionTimeString = scheduledTask.task.taskCompletionTimeString;
    }
    
    UITableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier: taskCompletionTimeString.length ? kTableCellWithTimeReuseIdentifier : kTableCellReuseIdentifier];

    APCConfirmationView * confirmView = (APCConfirmationView*)[cell viewWithTag:100];
    UILabel * titleLabel = (UILabel*)[cell viewWithTag:200];
    APCBadgeLabel * countLabel = (APCBadgeLabel *)[cell viewWithTag:300];
    UILabel * completionTimeLabel = (UILabel*)[cell viewWithTag:400];
    
    //Styling
    titleLabel.font = [UIFont appRegularFontWithSize:17];
    countLabel.font = [UIFont appRegularFontWithSize:15];
    completionTimeLabel.font = [UIFont appLightFontWithSize:14];
    
    if (indexPath.section > 0) {
        titleLabel.textColor = [UIColor lightGrayColor];
        countLabel.textColor = [UIColor lightGrayColor];
        completionTimeLabel.textColor = [UIColor lightGrayColor];
    } else {
        titleLabel.textColor = [UIColor appSecondaryColor1];
        countLabel.textColor = [UIColor appPrimaryColor];
        completionTimeLabel.textColor = [UIColor appSecondaryColor3];
    }
    
    completionTimeLabel.text = taskCompletionTimeString;

    if ([task isKindOfClass:[APCGroupedScheduledTask class]])
    {
        titleLabel.text = groupedScheduledTask.taskTitle;
        NSUInteger tasksCount = groupedScheduledTask.scheduledTasks.count;
        NSUInteger completedTasksCount = groupedScheduledTask.completedTasksCount;
        
        if (tasksCount == completedTasksCount) {
            countLabel.text = nil;
        } else {
            NSUInteger remaining = tasksCount - completedTasksCount;
            countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)remaining];
        }
        
        confirmView.completed = groupedScheduledTask.complete;
    }
    else if ([task isKindOfClass:[APCScheduledTask class]])
    {
        titleLabel.text = scheduledTask.task.taskTitle;
        confirmView.completed = scheduledTask.completed.boolValue;
        countLabel.text = nil;
    }
    
    return  cell;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)       tableView: (UITableView *) __unused tableView
    heightForRowAtIndexPath: (NSIndexPath *) __unused indexPath
{
    return  kTableViewRowHeight;
}

- (CGFloat)        tableView: (UITableView *) __unused tableView
    heightForHeaderInSection: (NSInteger) __unused section
{
    return kTableViewSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), kTableViewSectionHeaderHeight)];
    headerView.contentView.backgroundColor = [UIColor whiteColor];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    headerLabel.font = [UIFont appLightFontWithSize:16.0f];
    headerLabel.textColor = [UIColor appSecondaryColor1];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:headerLabel];
    
    headerLabel.text = self.sectionsArray[section];

    return headerView;
}

- (BOOL)                tableView: (UITableView *) __unused tableView
    shouldHighlightRowAtIndexPath: (NSIndexPath *) indexPath
{
    return indexPath.section == 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (!self.taskSelectionDisabled) {
            
            id task = ((NSArray*)self.scheduledTasksArray[indexPath.section])[indexPath.row];
            
            if ([task isKindOfClass:[APCGroupedScheduledTask class]]) {
                
                APCGroupedScheduledTask *groupedScheduledTask = (APCGroupedScheduledTask *)task;
                
                NSString *taskClass = groupedScheduledTask.taskClassName;
                
                Class  class = [NSClassFromString(taskClass) class];
                
                if (class != [NSNull class])
                {
                    NSInteger taskIndex = -1;
                    
                    for (int i =0; i<groupedScheduledTask.scheduledTasks.count; i++) {
                        APCScheduledTask *scheduledTask = groupedScheduledTask.scheduledTasks[i];
                        if (!scheduledTask.completed.boolValue) {
                            taskIndex = i;
                            break;
                        }
                    }
                    APCScheduledTask * taskToPerform = (taskIndex != -1) ? groupedScheduledTask.scheduledTasks[taskIndex] : [groupedScheduledTask.scheduledTasks lastObject];
                    if (taskToPerform)
                    {
                        APCBaseTaskViewController *controller = [class customTaskViewController:taskToPerform];
                        if (controller) {
                            [self presentViewController:controller animated:YES completion:nil];
                        }
                        
                    }
                }
                
            } else {
                APCScheduledTask *scheduledTask = (APCScheduledTask *)task;
                
                NSString *taskClass = scheduledTask.task.taskClassName;
                
                Class  class = [NSClassFromString(taskClass) class];
                
                if (class != [NSNull class]) {
                    APCBaseTaskViewController *controller = [class customTaskViewController:scheduledTask];
                    if (controller) {
                        [self presentViewController:controller animated:YES completion:nil];
                    }
                    
                }
            }
        }
    }
}

#pragma mark - Update methods
- (IBAction)updateActivities:(id) __unused sender
{
    self.taskSelectionDisabled = YES;
    APCAppDelegate * appDelegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    __weak APCActivitiesViewController * weakSelf = self;
    [appDelegate.dataMonitor refreshFromBridgeOnCompletion:^(NSError *error) {
        if (error != nil) {
            UIAlertController * alert = [UIAlertController simpleAlertWithTitle:@"Error" message:error.message];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            [appDelegate.scheduler updateScheduledTasksIfNotUpdating:YES];
            [weakSelf reloadData];
        }
        [weakSelf.refreshControl endRefreshing];
        weakSelf.taskSelectionDisabled = NO;
    }];
}

- (void)reloadData
{
    // Update the badge
    APCAppDelegate *appDelegate = (APCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSUInteger allScheduledTasks = appDelegate.dataSubstrate.countOfAllScheduledTasksForToday;
    NSUInteger completedScheduledTasks = appDelegate.dataSubstrate.countOfCompletedScheduledTasksForToday;
    
    NSNumber *remainingTasks = @(allScheduledTasks - completedScheduledTasks);
    
    UITabBarItem *activitiesTab = appDelegate.tabster.tabBar.selectedItem;
    
    if ([remainingTasks integerValue] != 0) {
        activitiesTab.badgeValue = [remainingTasks stringValue];
    } else {
        activitiesTab.badgeValue = nil;
    }
    
    [self reloadTableArray];
    [self.tableView reloadData];
    
    //Display a custom view announcing that there are no activities if there are none.
    if (self.sectionsArray.count == 0) {
        [self addCustomNoTaskView];
    } else {
        if (self.noTasksView) {
            [self.noTasksView removeFromSuperview];
        }
    }
}

- (void) addCustomNoTaskView {
    
    UINib *nib = [UINib nibWithNibName:@"APCActivitiesViewWithNoTask" bundle:[NSBundle appleCoreBundle]];
    self.noTasksView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    [self.view addSubview:self.noTasksView];
    
    UIImage *image = [UIImage imageNamed:@"activitieshome_emptystate_asset"];
    
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.noTasksView.imgView setTintColor:[UIColor appPrimaryColor]];
    
    [self.noTasksView.imgView setImage:image];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSInteger month = [components month];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSString *monthName = [[df monthSymbols] objectAtIndex:(month-1)];
    
    self.noTasksView.todaysDate.text = [NSString stringWithFormat:@"Today, %@ %ld", monthName, (long)day];
    
    [self.noTasksView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.noTasksView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:0]];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.noTasksView
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1
                                                                constant:0]];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.noTasksView
                                                               attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1
                                                                constant:0]];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.noTasksView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1
                                                                constant:0.0]];
}

#pragma mark - Sort and Group Task

- (void) reloadTableArray
{
    [self.scheduledTasksArray removeAllObjects];
    [self.sectionsArray removeAllObjects];
    
    NSDictionary *scheduledTasksDict = [APCScheduledTask APCActivityVCScheduledTasksInContext:((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.mainContext];
    
    //create sections
    if (((NSArray*)scheduledTasksDict[@"today"]).count > 0) {
        [self.sectionsArray addObject:[self formattedTodaySection]];
        NSArray * groupedArray = [self groupSimilarTasks:((NSArray*)scheduledTasksDict[@"today"])];
        [self.scheduledTasksArray addObject:groupedArray];
    }
    
    if (((NSArray*)scheduledTasksDict[@"yesterday"]).count > 0) {
        [self.sectionsArray addObject:@"Yesterday - Incomplete Tasks"];
        NSArray * groupedArray = [self groupSimilarTasks:((NSArray*)scheduledTasksDict[@"yesterday"])];
        [self.scheduledTasksArray addObject:groupedArray];
    }
}

- (NSString*) formattedTodaySection
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSInteger month = [components month];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSString *monthName = [[df monthSymbols] objectAtIndex:(month-1)];
    
    return [NSString stringWithFormat:@"Today, %@ %ld", monthName, (long)day];
}

- (NSArray*)groupSimilarTasks:(NSArray *)ungroupedScheduledTasks
{
    NSMutableArray *taskTypesArray = [[NSMutableArray alloc] init];
    
    /* Get the list of task Ids to group */
    for (APCScheduledTask *scheduledTask in ungroupedScheduledTasks) {
        NSString *taskId = scheduledTask.task.taskID;
        
        if (![taskTypesArray containsObject:taskId]) {
            [taskTypesArray addObject:taskId];
        }
    }
    NSMutableArray * returnArray = [NSMutableArray array];
    /* group tasks by task Id */
    for (NSString *taskId in taskTypesArray) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"task.taskID == %@", taskId];
        
        NSArray *filteredTasksArray = [ungroupedScheduledTasks filteredArrayUsingPredicate:predicate];
        
        if (filteredTasksArray.count > 1) {
            APCScheduledTask *scheduledTask = filteredTasksArray.firstObject;
            APCGroupedScheduledTask *groupedTask = [[APCGroupedScheduledTask alloc] init];
            groupedTask.scheduledTasks = [NSMutableArray arrayWithArray:filteredTasksArray];
            groupedTask.taskTitle = scheduledTask.task.taskTitle;
            groupedTask.taskClassName = scheduledTask.task.taskClassName;
            groupedTask.taskCompletionTimeString = scheduledTask.task.taskCompletionTimeString;
            
            [returnArray addObject:groupedTask];
        }
        else
        {
            [returnArray addObject:filteredTasksArray.firstObject];
        }
    }
    return returnArray;
}

@end
