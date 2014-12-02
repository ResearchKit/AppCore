//
//  APCActivitiesViewController.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCActivitiesViewController.h"
#import "APCAppleCore.h"

static NSString *kTableCellReuseIdentifier = @"ActivitiesTableViewCell";
static NSString *kTableCellWithTimeReuseIdentifier = @"ActivitiesTableViewCellWithTime";

static CGFloat kTableViewRowHeight = 80;
static CGFloat kTableViewSectionHeaderHeight = 45;

@interface APCActivitiesViewController ()

@property (nonatomic) BOOL showTomorrow;
@property (nonatomic) BOOL taskSelectionDisabled;

@property (strong, nonatomic) NSMutableArray *sectionsArray;
@property (strong, nonatomic) NSMutableArray *scheduledTasksArray;

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
    
    
    UIBarButtonItem *toggleBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tomorrow" style:UIBarButtonItemStylePlain target:self action:@selector(toggle:)];
    self.navigationItem.leftBarButtonItem = toggleBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateActivities:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Misc
- (void)setShowTomorrow:(BOOL)showTomorrow
{
    _showTomorrow = showTomorrow;
    if (showTomorrow) {
        self.taskSelectionDisabled = YES;
    }
    else
    {
        self.taskSelectionDisabled = self.refreshControl.isRefreshing;
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  self.sectionsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self arrayWithSectionNumber:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id task = [self arrayWithSectionNumber:indexPath.section][indexPath.row];
    
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
    UILabel * countLabel = (UILabel*)[cell viewWithTag:300];
    UILabel * completionTimeLabel = (UILabel*)[cell viewWithTag:400];
    
    //Styling
    titleLabel.font = [UIFont appRegularFontWithSize:17];
    titleLabel.textColor = [UIColor appSecondaryColor1];
    countLabel.font = [UIFont appRegularFontWithSize:15];
    countLabel.textColor = [UIColor appSecondaryColor2];
    completionTimeLabel.font = [UIFont appLightFontWithSize:14];
    completionTimeLabel.textColor = [UIColor appSecondaryColor3];
    
    completionTimeLabel.text = taskCompletionTimeString;

    if ([task isKindOfClass:[APCGroupedScheduledTask class]])
    {
        titleLabel.text = groupedScheduledTask.taskTitle;
        NSUInteger tasksCount = groupedScheduledTask.scheduledTasks.count;
        NSUInteger completedTasksCount = groupedScheduledTask.completedTasksCount;
        countLabel.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)completedTasksCount, (unsigned long)tasksCount];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  kTableViewRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableViewSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), kTableViewSectionHeaderHeight)];
    headerView.contentView.backgroundColor = [UIColor appSecondaryColor4];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
    headerLabel.font = [UIFont appLightFontWithSize:16.0f];
    headerLabel.textColor = [UIColor appSecondaryColor3];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:headerLabel];
    
    headerLabel.text = self.sectionsArray[section];
    if (section != 0) {
        headerLabel.text = [headerLabel.text stringByAppendingString:@" - Incomplete Tasks"];
    }
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.taskSelectionDisabled) {
        id task = self.scheduledTasksArray[indexPath.row];
        
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

#pragma mark - Update methods
- (IBAction)updateActivities:(id)sender
{
    self.taskSelectionDisabled = YES;
    APCAppDelegate * appDelegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    __weak APCActivitiesViewController * weakSelf = self;
    [appDelegate.dataMonitor refreshFromBridgeOnCompletion:^(NSError *error) {
        [appDelegate.scheduler updateScheduledTasksIfNotUpdating:YES];
        [weakSelf reloadData];
        [weakSelf.refreshControl endRefreshing];
        weakSelf.taskSelectionDisabled = NO;
    }];
}

- (void)reloadData
{
    [self reloadTableArray];
    [self.tableView reloadData];
}

#pragma mark - Sort and Group Task

- (void) reloadTableArray
{
    [self.scheduledTasksArray removeAllObjects];
    [self.sectionsArray removeAllObjects];
    
    NSArray *scheduledTasks = [APCScheduledTask APCActivityVCScheduledTasks:self.showTomorrow inContext:((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.mainContext];
    
    //create sections
    for (APCScheduledTask *scheduledTask in scheduledTasks)
    {
        NSString *sectionName = scheduledTask.completeByDateString;
        if (![self.sectionsArray containsObject:sectionName]) {
            [self.sectionsArray addObject:sectionName];
        }
    }
    
    //Group scheduled tasks with same taskIDs within each section
    for (NSString * section in self.sectionsArray) {
        NSArray * unGroupedArray = [self arrayWithSectionName:section from:scheduledTasks];
        NSArray * groupedArray = [self groupSimilarTasks:unGroupedArray];
//        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startOn" ascending:YES];
//        NSArray * sortedArray = [groupedArray sortedArrayUsingDescriptors:@[dateSortDescriptor]];
//        [self.scheduledTasksArray addObjectsFromArray:sortedArray];
        [self.scheduledTasksArray addObjectsFromArray:groupedArray];
    }
}

- (NSArray*) arrayWithSectionName: (NSString*) sectionName from: (NSArray*) fromArray
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completeByDateString == %@", sectionName];
    return [fromArray filteredArrayUsingPredicate:predicate];
}

- (NSArray*) arrayWithSectionNumber: (NSUInteger) sectionNumber
{
    return [self arrayWithSectionName:self.sectionsArray[sectionNumber] from:self.scheduledTasksArray];
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

/*********************************************************************************/
#pragma mark - Misc
/*********************************************************************************/

- (IBAction)toggle:(UIBarButtonItem*)sender
{
    self.showTomorrow = !self.showTomorrow;
    sender.title = self.showTomorrow ? @"Today" : @"Tomorrow";
    sender.tintColor = self.showTomorrow ? [UIColor redColor] : nil;
    [self reloadTableArray];
    [self.tableView reloadData];
}

@end
