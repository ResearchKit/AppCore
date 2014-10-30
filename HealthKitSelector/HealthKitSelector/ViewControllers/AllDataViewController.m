//
//  AllDataViewController.m
//  HealthKitSelector
//
//  Created by Dzianis Asanovich on 10/21/14.
//  Copyright (c) 2014 Dzianis Asanovich. All rights reserved.
//

#import "AllDataViewController.h"
#import "DescriptionViewController.h"
#import "AddSampleViewController.h"
#import "HealthKitManager.h"

@interface AllDataViewController ()
{
    NSArray * elements;
}

@property (nonatomic, strong) IBOutlet UITableView * mainTableView;

@end

@implementation AllDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target: self action: @selector(addNewElement:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self getAllSamples];
}

- (void)getAllSamples
{
    [[HealthKitManager sharedInstance] getSamplesForIdentifier: _identifier withCompletion:^(NSArray *array) {
        elements = array;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mainTableView reloadData];
        });
    }];
}

-(void) addNewElement: (id) sender
{
    if ([[HealthKitManager getObjectTypeForIdentifier: _identifier] isKindOfClass: [HKQuantityType class]])
    {
        [self performSegueWithIdentifier: @"addQuantitySample" sender:nil];
    }
    else if ([[HealthKitManager getObjectTypeForIdentifier: _identifier] isKindOfClass: [HKCorrelationType class]])
    {
        [self performSegueWithIdentifier: @"addCorrelationSample" sender:nil];
    }
    else if ([[HealthKitManager getObjectTypeForIdentifier: _identifier] isKindOfClass: [HKCategoryType class]])
    {
        [self performSegueWithIdentifier: @"addCategorySample" sender:nil];
    }
    else if ([[HealthKitManager getObjectTypeForIdentifier: _identifier] isKindOfClass: [HKWorkoutType class]])
    {
        [self performSegueWithIdentifier: @"addWorkoutSample" sender:nil];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return elements.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"nutritionCell"];
    UILabel * label = (UILabel *)[cell viewWithTag: 1];
    
    HKSample * sampleData = [elements objectAtIndex: indexPath.row];
    label.text = sampleData.source.name;
    
    UILabel * dateLabel = (UILabel *)[cell viewWithTag: 2];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd MMM yyyy HH:mm"];
    
    dateLabel.text = [dateFormat stringFromDate: sampleData.startDate];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSLog(@"Delete");
        HKSample * sampleData = [elements objectAtIndex: indexPath.row];
        [[HealthKitManager sharedInstance].healthStore deleteObject: sampleData withCompletion:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success)
                {
                    [[[UIAlertView alloc] initWithTitle: @"Done" message: @"Unit was deleted" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
                    [self getAllSamples];
                }
                else
                {
                    [[[UIAlertView alloc] initWithTitle: @"Error" message: error.localizedDescription delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
                }
            });
        }];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showDescriptionList"])
    {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [_mainTableView indexPathForCell:cell];
        [_mainTableView deselectRowAtIndexPath: indexPath animated: YES];
        DescriptionViewController * descriptionVC = (DescriptionViewController*)[segue destinationViewController];
        descriptionVC.sample = [elements objectAtIndex: indexPath.row];
        descriptionVC.title = descriptionVC.sample.source.name;
    }
    else if ([segue.identifier isEqualToString:@"addQuantitySample"] || [segue.identifier isEqualToString: @"addCorrelationSample"] || [segue.identifier isEqualToString: @"addCategorySample"] || [segue.identifier isEqualToString: @"addWorkoutSample"])
    {
        AddSampleViewController * addQuantityVC = (AddSampleViewController*)[segue destinationViewController];
        addQuantityVC.identifier = _identifier;
        addQuantityVC.title = self.title;
    }
}

@end
