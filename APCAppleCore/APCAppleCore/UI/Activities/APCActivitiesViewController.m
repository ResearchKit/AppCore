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
static NSInteger kNumberOfSectionsInTableView = 1;

@interface APCActivitiesViewController () <RKTaskViewControllerDelegate>

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

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Activities", @"Activities");
    self.tableView.backgroundColor = [UIColor appSecondaryColor4];
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

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  kNumberOfSectionsInTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.scheduledTasksArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id task = self.scheduledTasksArray[indexPath.row];
    
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
        taskCompletionTimeString = groupedScheduledTask.taskCompletionTimeString;
        NSUInteger tasksCount = groupedScheduledTask.scheduledTasks.count;
        NSUInteger completedTasksCount = groupedScheduledTask.completedTasksCount;
        countLabel.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)completedTasksCount, (unsigned long)tasksCount];
        confirmView.completed = groupedScheduledTask.complete;
    }
    else if ([task isKindOfClass:[APCScheduledTask class]])
    {
        titleLabel.text = scheduledTask.task.taskTitle;
        confirmView.completed = scheduledTask.completed.boolValue;
        taskCompletionTimeString = scheduledTask.task.taskCompletionTimeString;
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
    
    if (section == 0) {
        headerLabel.text = NSLocalizedString(@"Today", @"Today");
    } else{
        headerLabel.text = NSLocalizedString(@"Past 5 Days", @"Past 5 Days");
    }
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id task = self.scheduledTasksArray[indexPath.row];
    
    if ([task isKindOfClass:[APCGroupedScheduledTask class]]) {
        
        APCGroupedScheduledTask *groupedScheduledTask = (APCGroupedScheduledTask *)task;
        
        NSString *taskClass = groupedScheduledTask.taskClassName;
        
        Class  class = [NSClassFromString(taskClass) class];
        
        if (class != [NSNull class]) {
            
            
            //            NSDate *currentDate = [NSDate date];
            NSInteger taskIndex = -1;
            
            for (int i =0; i<groupedScheduledTask.scheduledTasks.count; i++) {
                APCScheduledTask *scheduledTask = groupedScheduledTask.scheduledTasks[i];
                
                //                if ([currentDate compare:scheduledTask.dueOn] == NSOrderedAscending) {
                //                    taskIndex = i;
                //                    break;
                //                }else {
                //                    NSLog(@"The dueOn date for this task is older than the current time. Ignore this task.");
                //                }
                if (!scheduledTask.completed.boolValue) {
                    taskIndex = i;
                    break;
                }
            }
            
            if (taskIndex != -1) {
                APCSetupTaskViewController *controller = [class customTaskViewController:groupedScheduledTask.scheduledTasks[taskIndex]];
                [self presentViewController:controller animated:YES completion:nil];
            } else {
                //TODO: The user has tapped on an old task for the day (dueOn date is earlier than current time). May present alert.
            }
        }
        
    } else {
        APCScheduledTask *scheduledTask = (APCScheduledTask *)task;
        
        NSString *taskClass = scheduledTask.task.taskClassName;
        
        Class  class = [NSClassFromString(taskClass) class];
        
        if (class != [NSNull class]) {
            APCSetupTaskViewController *controller = [class customTaskViewController:scheduledTask];
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}

#pragma mark - Update methods

- (IBAction)updateActivities:(id)sender
{

    APCAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.scheduler updateScheduledTasks];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadData];
        [self.refreshControl endRefreshing];
    });

}

- (void)reloadData
{
    [self.scheduledTasksArray removeAllObjects];
    
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dueOn" ascending:YES];
    NSArray *unsortedScheduledTasks = [((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate  scheduledTasksForPredicate:nil sortDescriptors:@[dateSortDescriptor]];
    
    [self groupSimilarTasks:unsortedScheduledTasks];
    
    [self.tableView reloadData];
}

#pragma mark - Sort and Group Task

- (void)groupSimilarTasks:(NSArray *)unsortedScheduledTasks
{
    NSMutableArray *taskTypesArray = [[NSMutableArray alloc] init];
    
    /* Get the list of task Ids to group */
    
    for (APCScheduledTask *scheduledTask in unsortedScheduledTasks) {
        NSString *taskId = scheduledTask.task.uid;
        
        if (![taskTypesArray containsObject:taskId]) {
            [taskTypesArray addObject:taskId];
        }
    }
    
    /* group tasks by task Id */
    for (NSString *taskId in taskTypesArray) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"task.uid == %@", taskId];
        
        NSArray *filteredTasksArray = [unsortedScheduledTasks filteredArrayUsingPredicate:predicate];
        
        if (filteredTasksArray.count > 1) {
            APCScheduledTask *scheduledTask = filteredTasksArray.firstObject;
            APCGroupedScheduledTask *groupedTask = [[APCGroupedScheduledTask alloc] init];
            groupedTask.scheduledTasks = [NSMutableArray arrayWithArray:filteredTasksArray];
            groupedTask.taskType = scheduledTask.task.taskType;
            groupedTask.taskTitle = scheduledTask.task.taskTitle;
            groupedTask.taskClassName = scheduledTask.task.taskClassName;
            groupedTask.taskCompletionTimeString = scheduledTask.task.taskCompletionTimeString;
            
            [self.scheduledTasksArray addObject:groupedTask];
        } else{
            
            [self.scheduledTasksArray addObject:filteredTasksArray.firstObject];
        }
    }
}

@end
