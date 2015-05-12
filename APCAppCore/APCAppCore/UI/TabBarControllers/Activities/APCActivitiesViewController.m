// 
//  APCActivitiesViewController.m 
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
 
#import "APCActivitiesViewController.h"
#import "APCAppCore.h"
#import "APCActivitiesViewWithNoTask.h"
#import "APCCircularProgressView.h"
#import "UIColor+APCAppearance.h"

static CGFloat kTintedCellHeight = 65;

static CGFloat kTableViewSectionHeaderHeight = 77;

typedef NS_ENUM(NSUInteger, APCActivitiesSections)
{
    APCActivitiesSectionToday = 0,
    APCActivitiesSectionYesterday,
    APCActivitiesSectionsTotalNumberOfSections
};

@interface APCActivitiesViewController ()

@property (nonatomic) BOOL taskSelectionDisabled;

@property (strong, nonatomic) NSMutableArray *sectionsArray;
@property (strong, nonatomic) NSMutableArray *scheduledTasksArray;

@property (strong, nonatomic) APCActivitiesViewWithNoTask *noTasksView;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

// The below, tasksBySection and keepGoingTasks, are used only
// for filtering the tasks that should not appear in the 'Yesterday'
// section. Needless to say, we do need to refactor this bit of
// logic so that it is more flexible.
@property (strong, nonatomic) NSDictionary *tasksBySection;
@property (strong, nonatomic) NSMutableArray *keepGoingTasks;

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
    [self setupNotifications];
    
    self.navigationItem.title = NSLocalizedString(@"Activities", @"Activities");
    self.tableView.backgroundColor = [UIColor appSecondaryColor4];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"APCActivitiesSectionHeaderView" bundle:[NSBundle appleCoreBundle]] forHeaderFooterViewReuseIdentifier:kAPCActivitiesSectionHeaderViewIdentifier];
    
    self.dateFormatter = [NSDateFormatter new];
    
    self.keepGoingTasks = [NSMutableArray new];
    
    APCAppDelegate * appDelegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    self.tasksBySection = [appDelegate configureTasksForActivities];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [self setUpNavigationBarAppearance];

    [self reloadData];
    APCLogViewControllerAppeared();
}

-(void) setupNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:APCUpdateActivityNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateActivities:)
                                                 name:APCDayChangedNotification object:nil];
}

-(void)setUpNavigationBarAppearance{
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.translucent = NO;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    static  NSString  *medicationTrackerTaskId = @"a-APHMedicationTracker-20EF8ED2-E461-4C20-9024-F43FCAAAF4C3";
    
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
    
    APCActivitiesTintedTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier: kAPCActivitiesTintedTableViewCellIdentifier];
    
    if (taskCompletionTimeString) {
        cell.subTitleLabel.text = taskCompletionTimeString;
        cell.hidesSubTitle = NO;
    } else {
        cell.hidesSubTitle = YES;
    }

    if ([task isKindOfClass:[APCGroupedScheduledTask class]])
    {
        cell.titleLabel.text = groupedScheduledTask.taskTitle;
        NSUInteger tasksCount = groupedScheduledTask.scheduledTasks.count;
        NSUInteger completedTasksCount = groupedScheduledTask.completedTasksCount;
        
        if (tasksCount == completedTasksCount) {
            cell.countLabel.text = nil;
            cell.countLabel.hidden = YES;
        } else {
            NSUInteger remaining = tasksCount - completedTasksCount;
            cell.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)remaining];
            cell.countLabel.hidden = NO;
        }
        
        
        cell.confirmationView.completed = groupedScheduledTask.complete;
        
        APCScheduledTask *firstTask = groupedScheduledTask.scheduledTasks.firstObject;
        cell.tintColor = [UIColor colorForTaskId:firstTask.task.taskID];
    }
    else if ([task isKindOfClass:[APCScheduledTask class]])
    {        
        cell.titleLabel.text = scheduledTask.task.taskTitle;
        if ([scheduledTask.task.taskID isEqualToString:medicationTrackerTaskId] == NO) {
            cell.confirmationView.completed = scheduledTask.completed.boolValue;
        }
        cell.countLabel.text = nil;
        cell.countLabel.hidden = YES;
        cell.tintColor = [UIColor colorForTaskId:scheduledTask.task.taskID];
    }
    
    if (indexPath.section == APCActivitiesSectionYesterday) {
        [cell setupIncompleteAppearance];
    } else {
        [cell setupAppearance];
    }
    
    return  cell;
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)       tableView: (UITableView *) __unused tableView
    heightForRowAtIndexPath: (NSIndexPath *) __unused indexPath
{
    return  kTintedCellHeight;
}

- (CGFloat)        tableView: (UITableView *) __unused tableView
    heightForHeaderInSection: (NSInteger) __unused section
{
    CGFloat height = kTableViewSectionHeaderHeight;
    
    if (section == APCActivitiesSectionToday) {
        height -= 15;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    APCActivitiesSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kAPCActivitiesSectionHeaderViewIdentifier];
    
    
    switch (section) {
        case APCActivitiesSectionToday:
        {
            [self.dateFormatter setDateFormat:@"MMMM d"];
            headerView.titleLabel.text = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(@"Today", @""), [self.dateFormatter stringFromDate:[NSDate date]] ];
            headerView.subTitleLabel.text = NSLocalizedString(@"To start an activity, select from the list below.", @"");
        }
            break;
        case APCActivitiesSectionYesterday:
        {
            headerView.titleLabel.text = NSLocalizedString(@"Yesterday", @"");
            headerView.subTitleLabel.text = NSLocalizedString(@"Below are your incomplete tasks from yesterday. These are for reference only.", @"");
        }
            break;

            
        default: // Keep going
        {
            headerView.titleLabel.text = NSLocalizedString(@"Keep Going!", @"Keep going");
            headerView.subTitleLabel.text = NSLocalizedString(@"Try one of these extra activities, to enchance your experience in your study.",
                                                              @"Try one of these extra activities, to enchance your experience in your study.");
        }
            break;
    }
    

    return headerView;
}

- (BOOL)                tableView: (UITableView *) __unused tableView
    shouldHighlightRowAtIndexPath: (NSIndexPath *) indexPath
{
    return indexPath.section != 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section != APCActivitiesSectionYesterday) {
        if (!self.taskSelectionDisabled) {
            
            id task = ((NSArray*)self.scheduledTasksArray[indexPath.section])[indexPath.row];
            
            if ([task isKindOfClass:[APCGroupedScheduledTask class]]) {
                
                APCGroupedScheduledTask *groupedScheduledTask = (APCGroupedScheduledTask *)task;
                
                NSString *taskClass = groupedScheduledTask.taskClassName;
                
                Class  class = [NSClassFromString(taskClass) class];
                
                if (class != [NSNull class])
                {
                    NSInteger taskIndex = -1;
                    
                    for (NSUInteger i =0; i<groupedScheduledTask.scheduledTasks.count; i++) {
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
    
    NSNumber *remainingTasks = (completedScheduledTasks < allScheduledTasks) ? @(allScheduledTasks - completedScheduledTasks) : @(0);
    
    UITabBarItem *activitiesTab = appDelegate.tabster.tabBar.selectedItem;
    if (activitiesTab.tag == (NSInteger)kIndexOfActivitesTab) {
        if ([remainingTasks integerValue] != 0) {
            activitiesTab.badgeValue = [remainingTasks stringValue];
        } else {
            activitiesTab.badgeValue = nil;
        }
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
        
        NSArray *todaysTaskList = [self removeTaskWhenHardwareNotAvailble:scheduledTasksDict[@"today"]];
        
        NSArray * groupedArray = [self generateGroupsForTask:todaysTaskList];

        NSArray *sortedTasks = [self sortTasksInArray:groupedArray];
        
        [self.scheduledTasksArray addObject:sortedTasks];
    }
    
    if (((NSArray*)scheduledTasksDict[@"yesterday"]).count > 0) {
        NSArray *yesterdaysTaskList = [self removeTasksFromTaskList:scheduledTasksDict[@"yesterday"]];
        
        if (yesterdaysTaskList.count > 0) {
        [self.sectionsArray addObject:@"Yesterday - Incomplete Tasks"];
        
        NSArray * groupedArray = [self generateGroupsForTask:yesterdaysTaskList];
        
        NSArray *sortedTasks = [self sortTasksInArray:groupedArray];
        
        [self.scheduledTasksArray addObject:sortedTasks];
}
    }
}

- (NSArray *)sortTasksInArray:(NSArray *)unsortedTasks
{
    //NOTE: The task identifiers (taskID) start with a sort field. If you want to change the sort order change the identifiers within the file(s) currently named APHTasksAndSchedules.json and APHTasksAndSchedules_NoM7.json.
    NSSortDescriptor* descriptorForSorting = [[NSSortDescriptor alloc]initWithKey:@"task.taskID" ascending:YES];
    NSArray* sortDescriptors = @[descriptorForSorting];
    NSArray* sortedArray = [unsortedTasks sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedArray;
}

- (NSString*) formattedTodaySection
{
    [self.dateFormatter setDateFormat:@"MMMM d"];
    
    return [NSString stringWithFormat:@"Today, %@", [self.dateFormatter stringFromDate:[NSDate date]]];
}

- (NSArray*)generateGroupsForTask:(NSArray *)ungroupedScheduledTasks
{
    NSMutableArray *taskTypesArray = [[NSMutableArray alloc] init];
    
    /* Get the list of task Ids to group */
    for (APCScheduledTask *scheduledTask in ungroupedScheduledTasks) {
        NSString *taskId = scheduledTask.task.taskID;
        
        if (taskId) {
            if (![taskTypesArray containsObject:taskId]) {
                [taskTypesArray addObject:taskId];
            }
        }
    }
    
    NSMutableArray * returnArray = [NSMutableArray array];
    /* group tasks by task Id */
    for (NSString *taskId in taskTypesArray) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"task.taskID == %@", taskId];
        
        NSArray *filteredTasksArray = [ungroupedScheduledTasks filteredArrayUsingPredicate:predicate];
        
        //if there is more than 1 task for the taskID, create an APCGroupedScheduledTask
        if (filteredTasksArray.count > 1) {
            APCScheduledTask *scheduledTask = filteredTasksArray.firstObject;
            APCGroupedScheduledTask *groupedTask = [[APCGroupedScheduledTask alloc] init];

            groupedTask.scheduledTasks = [NSMutableArray arrayWithArray:filteredTasksArray];
            groupedTask.taskTitle = scheduledTask.task.taskTitle;
            groupedTask.taskClassName = scheduledTask.task.taskClassName;
            groupedTask.taskCompletionTimeString = scheduledTask.task.taskCompletionTimeString;
            
            [returnArray addObject:groupedTask];
        }
        else if(filteredTasksArray.count == 1)
        {
            [returnArray addObject:filteredTasksArray.firstObject];
        }
    }
    return returnArray;
}

/** @brief   Removes the tasks (provide via the self.tasksBySection property) from the provided task list.
  *
  * @param   taskList - Array of APCScheduledTask. This list will be filtered
  *
  * @return  A filtered array of APCScheduledTask; otherwise the original array is returned.
  *
  * @note    This needs to be refactored.
  */
- (NSArray *)removeTasksFromTaskList:(NSArray *)taskList
{
    NSArray *keepGoingTasks = self.tasksBySection[kActivitiesSectionKeepGoing];
    NSMutableArray *filteredList = [taskList mutableCopy];
    
    for (APCScheduledTask *scheduledTask in taskList) {
        if (keepGoingTasks) {
            if ([keepGoingTasks containsObject:scheduledTask.task.taskID]) {
                [filteredList removeObject:scheduledTask];
                [self.keepGoingTasks addObject:scheduledTask];
            }
        }
    }
    
    return filteredList;
}

/** @brief  When the hardware that is required by task that is not present on the device
 *          the task will be removed from the provided task list.
 *
 * @param   taskList - Array of APCScheduledTask. This list will be filtered
 *
 * @return  A filtered array of APCScheduledTask; otherwise the original array is returned.
 *
 * @note    This needs to be refactored.
 */
- (NSArray *)removeTaskWhenHardwareNotAvailble:(NSArray *)taskList
{
    NSMutableArray *filteredList = [taskList mutableCopy];
    
    if ([APCDeviceHardware isMotionActivityAvailable] == NO) {
        NSArray *hardwareDependentTasks = self.tasksBySection[kActivitiesRequiresMotionSensor];
        
        for (APCScheduledTask *scheduledTask in taskList) {
            if (hardwareDependentTasks) {
                if ([hardwareDependentTasks containsObject:scheduledTask.task.taskID]) {
                    [filteredList removeObject:scheduledTask];
                }
            }
        }
    }
    
    return filteredList;
}

@end
