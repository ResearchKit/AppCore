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

static CGFloat kTableViewRowHeight = 70;
static CGFloat kTableViewSectionHeaderHeight = 30;
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
    APCActivitiesTableViewCell  *cell = (APCActivitiesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kTableCellReuseIdentifier];
    
    id task = self.scheduledTasksArray[indexPath.row];
    
    if ([task isKindOfClass:[APCGroupedScheduledTask class]]) {
        
        cell.type = kActivitiesTableViewCellTypeSubtitle;
        
        APCGroupedScheduledTask *groupedScheduledTask = (APCGroupedScheduledTask *)task;
        
        cell.titleLabel.text = groupedScheduledTask.taskTitle;
        
        NSUInteger tasksCount = groupedScheduledTask.scheduledTasks.count;
        NSUInteger completedTasksCount = groupedScheduledTask.completedTasksCount;
        
        cell.subTitleLabel.text = [NSString stringWithFormat:@"%lu/%lu %@", (unsigned long)completedTasksCount, (unsigned long)tasksCount, NSLocalizedString(@"Tasks Completed", nil)];
        
        cell.completed = groupedScheduledTask.complete;
        
    } else if ([task isKindOfClass:[APCScheduledTask class]]){
        
        cell.type = kActivitiesTableViewCellTypeDefault;
        
        APCScheduledTask *scheduledTask = (APCScheduledTask *)task;
        
        cell.titleLabel.text = scheduledTask.task.taskTitle;
        cell.completed = scheduledTask.completed.boolValue;
        
    } else{
        //Handle all cases in ifElse statements. May handle NSAssert here.
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
    
    switch (section) {
        case 0:
            headerView.textLabel.text = NSLocalizedString(@"Today", @"Today");
            break;
            
        default:{
            NSAssert(0, @"Invalid Section");
        }
            break;
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
            
            [self.scheduledTasksArray addObject:groupedTask];
        } else{
            
            [self.scheduledTasksArray addObject:filteredTasksArray.firstObject];
        }
    }
}

@end
