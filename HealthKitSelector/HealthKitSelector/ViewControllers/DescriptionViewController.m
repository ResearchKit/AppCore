//
//  DescriptionViewController.m
//  HealthKitSelector
//
//  Created by Dzianis Asanovich on 10/21/14.
//  Copyright (c) 2014 Dzianis Asanovich. All rights reserved.
//

#import "DescriptionViewController.h"
#import "AddSampleViewController.h"
#import "WorkoutEventsViewController.h"
#import "HealthKitManager.h"

@interface DescriptionViewController ()
{
    NSMutableDictionary * allData;
    NSArray * keys;
}

@property (nonatomic, strong) IBOutlet UITableView * mainTableView;

@end

@implementation DescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    allData = [_sample.metadata mutableCopy];
    if (!allData)
        allData = [NSMutableDictionary dictionary];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd MMM yyyy HH:mm"];
    
    if ([_sample.startDate isEqualToDate: _sample.endDate])
    {
        allData[@"Date"] = [dateFormat stringFromDate: _sample.startDate];
    }
    else
    {
        allData[@"Start Date"] = [dateFormat stringFromDate: _sample.startDate];
        allData[@"End Date"] = [dateFormat stringFromDate: _sample.endDate];
    }
    allData[@"Source"] = _sample.source.name;
    
    [self addAllSampleData: _sample];
    
    keys = allData.allKeys;
    [self sortKeys];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return keys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
    NSString * key = [keys objectAtIndex: indexPath.row];
    if ([allData[key] isKindOfClass: [NSString class]])
    {
        cell = [tableView dequeueReusableCellWithIdentifier: @"paramCell"];
        
        UILabel * label = (UILabel *)[cell viewWithTag: 1];
        label.text = key;
        
        UILabel * descriptionLabel = (UILabel *)[cell viewWithTag: 2];
        descriptionLabel.text = allData[key];
    }
    else if ([allData[key] isKindOfClass: [HKSample class]])
    {
        HKSample * sample = allData[key];
        cell = [tableView dequeueReusableCellWithIdentifier: @"quantityCell"];
        
        UILabel * label = (UILabel *)[cell viewWithTag: 1];
        label.text = [HealthKitManager getIdentifierReadable: sample.sampleType.identifier];
    }
    else if ([allData[key] isKindOfClass: [NSArray class]] && [[allData[key] firstObject] isKindOfClass: [HKWorkoutEvent class]])
    {
        cell = [tableView dequeueReusableCellWithIdentifier: @"quantityCell"];
        
        UILabel * label = (UILabel *)[cell viewWithTag: 1];
        label.text = @"Workout Events";
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier: @"paramCell"];
        
        UILabel * label = (UILabel *)[cell viewWithTag: 1];
        label.text = key;
        
        UILabel * descriptionLabel = (UILabel *)[cell viewWithTag: 2];
        descriptionLabel.text = [allData[key] description];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * key = [keys objectAtIndex: indexPath.row];
    if ([allData[key] isKindOfClass: [HKSample class]])
    {
        return 57;
    }
    else
    {
        return 91;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated: YES];
    NSString * key = keys[indexPath.row];
    if ([allData[key] isKindOfClass: [HKSample class]])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        DescriptionViewController * descriptionVC = [storyboard instantiateViewControllerWithIdentifier:@"descriptionVC"];
        descriptionVC.sample = allData[key];
        descriptionVC.title = key;
        UINavigationController *navController = self.navigationController;
        [navController pushViewController: descriptionVC animated:YES];
    }
    else if ([allData[key] isKindOfClass: [NSArray class]])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        WorkoutEventsViewController * workoutEventsVC = [storyboard instantiateViewControllerWithIdentifier:@"workoutEvents"];
        workoutEventsVC.workoutEvents = allData[key];
        UINavigationController *navController = self.navigationController;
        [navController pushViewController: workoutEventsVC animated:YES];
    }
}

-(void) addAllSampleData: (HKSample*) newSample
{
    if ([newSample isKindOfClass: [HKQuantitySample class]])
    {
        HKQuantity * quantity = [(HKQuantitySample*)newSample quantity];

        NSString * description = [quantity description];
        NSString * unitString = [[description componentsSeparatedByString: @" "] lastObject];
        double value = [quantity doubleValueForUnit: [HKUnit unitFromString: unitString]];
        allData[[NSString stringWithFormat: @"value in %@", unitString]] = [NSString stringWithFormat: @"%.2f", value];
    }
    else if ([newSample isKindOfClass: [HKCorrelation class]])
    {
        NSSet * samplesSet = ((HKCorrelation*)_sample).objects;
        for (HKSample * sample in samplesSet)
        {
            if ([sample isKindOfClass: [HKQuantitySample class]])
            {
                HKQuantityType * quantity = [(HKQuantitySample*)sample quantityType];
                NSString * description = [quantity description];
                description = [HealthKitManager getIdentifierReadable: description];
                allData[description] = sample;
            }
        }
    }
    else if ([newSample isKindOfClass: [HKCategorySample class]])
    {
        HKCategorySample * categorySample = (HKCategorySample*)newSample;
        if (categorySample.value == HKCategoryValueSleepAnalysisAsleep)
            allData[@"Sleep Value"] = @"Asleep";
        else
            allData[@"Sleep Value"] = @"In bed";
    }
    else if ([newSample isKindOfClass: [HKWorkout class]])
    {
        HKWorkout * workout = (HKWorkout*)newSample;
        
        if (workout.workoutActivityType && (NSInteger)workout.workoutActivityType != NSIntegerMax)
        {
            NSArray * workoutTypes = [HealthKitManager getWorkouts];
            allData[@"Workout Type"] = workoutTypes[workout.workoutActivityType];
        }
        if (workout.totalEnergyBurned)
        {
            allData[@"Energy burned"] = workout.totalEnergyBurned.description;
        }
        if (workout.totalDistance)
        {
            allData[@"Total distance"] = workout.totalDistance.description;
        }
        if (workout.duration)
        {
            allData[@"Duration"] = [NSString stringWithFormat: @"%f", workout.duration];
        }
        if (workout.workoutEvents.count)
        {
            allData[@"Workout events"] = workout.workoutEvents;
        }
    }
}

-(void) sortKeys
{
    NSMutableArray * samplesKeys = [NSMutableArray array];
    NSMutableArray * stringsKeys = [NSMutableArray array];
    for (NSString * element in keys)
    {
        if ([allData[element] isKindOfClass: [HKSample class]])
            [samplesKeys addObject: element];
        else
            [stringsKeys addObject: element];
    }
    [samplesKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare: obj2];
    }];
    [stringsKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare: obj2];
    }];
    
    keys = [samplesKeys arrayByAddingObjectsFromArray: stringsKeys];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
