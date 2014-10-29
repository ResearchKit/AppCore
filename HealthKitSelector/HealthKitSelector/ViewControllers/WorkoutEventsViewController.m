//
//  WorkoutEventsViewController.m
//  HealthKitSelector
//
//  Created by Dzianis Asanovich on 10/23/14.
//  Copyright (c) 2014 Dzianis Asanovich. All rights reserved.
//

#import "WorkoutEventsViewController.h"
#import "HealthKitManager.h"
#import "CustomIOS7AlertView.h"


@interface WorkoutEventsViewController ()

@end

@implementation WorkoutEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_returnSampleDelegate)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target: self action: @selector(addEvent:)];
    if (!_workoutEvents)
        _workoutEvents = [NSArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addEvent: (id) sender
{
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    UIView * view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 250)];
    UISegmentedControl * segmentButton = [[UISegmentedControl alloc] initWithFrame: CGRectMake(10, 20, 280, 30)];
    [segmentButton insertSegmentWithTitle: @"Pause" atIndex: 0 animated: NO];
    [segmentButton insertSegmentWithTitle: @"Resume" atIndex: 1 animated: NO];
    [segmentButton setSelectedSegmentIndex: 0];
    
    UIDatePicker * datePicker = [[UIDatePicker alloc] initWithFrame: CGRectMake(10, 40, 280, 200)];
    datePicker.clipsToBounds = YES;
    [view addSubview: segmentButton];
    [view addSubview: datePicker];
    [alertView setContainerView: view];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"OK", nil]];
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        if (buttonIndex == 1)
        {
            HKWorkoutEvent * event = [HKWorkoutEvent workoutEventWithType: segmentButton.selectedSegmentIndex + 1 date:datePicker.date];
            _workoutEvents = [_workoutEvents arrayByAddingObject: event];
            [_returnSampleDelegate newWorkoutEvents: [NSArray arrayWithArray: _workoutEvents]];
            [self.tableView reloadData];
        }
    }];
    [alertView show];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _workoutEvents.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"eventCell"];
    
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"dd/MM/yyyy HH:mm"];
    
    HKWorkoutEvent * event = [_workoutEvents objectAtIndex: indexPath.row];
    UILabel * label = (UILabel *)[cell viewWithTag: 1];
    if (event.type == HKWorkoutEventTypePause)
        label.text = @"Pause";
    else
        label.text = @"Resume";
    
    UILabel * descriptionLabel = (UILabel *)[cell viewWithTag: 2];
    descriptionLabel.text = [dateformate stringFromDate: event.date];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
}

@end
