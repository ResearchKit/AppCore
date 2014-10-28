//
//  ViewController.m
//  HealthKitSelector
//
//  Created by Dzianis Asanovich on 10/21/14.
//  Copyright (c) 2014 Dzianis Asanovich. All rights reserved.
//

#import "SectionsViewController.h"
#import "HealthKitManager.h"
#import "AllDataViewController.h"

@interface SectionsViewController ()

@property (nonatomic, strong) IBOutlet UITableView * mainTableView;

@end

@implementation SectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _sections = [_sections sortedArrayWithOptions: 0 usingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        return [obj1 compare: obj2];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Using HealthKit APIs

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sections.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"nutritionCell"];
    UILabel * label = (UILabel *)[cell viewWithTag: 1];
    NSString * sectionName = _sections[indexPath.row];
    sectionName = [HealthKitManager getIdentifierReadable: sectionName];
    label.text = sectionName;
    
    return cell;
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showDataList"])
    {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [_mainTableView indexPathForCell:cell];
        [_mainTableView deselectRowAtIndexPath: indexPath animated: YES];
        NSString * choosedIdentifier = [_sections objectAtIndex: indexPath.row];
        
        AllDataViewController *allDataViewController = (AllDataViewController*)[segue destinationViewController];
        allDataViewController.identifier = choosedIdentifier;
        allDataViewController.title = [HealthKitManager getIdentifierReadable: allDataViewController.identifier];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"showDataList"])
    {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [_mainTableView indexPathForCell:cell];
        [_mainTableView deselectRowAtIndexPath: indexPath animated: YES];
        NSString * choosedIdentifier = [_sections objectAtIndex: indexPath.row];
        if ([[HealthKitManager getObjectTypeForIdentifier: choosedIdentifier] isKindOfClass: [HKSampleType class]])
        {
            return  YES;
        }
        else
        {
            [self showCharachteristic: choosedIdentifier];
            return NO;
        }
    }
    return YES;
}

- (void) showCharachteristic: (NSString *) choosedIdentifier
{
    NSError * error;
    NSString * resultString = @"";
    NSString * title;
    if ([choosedIdentifier isEqualToString: HKCharacteristicTypeIdentifierDateOfBirth])
    {
        NSDate * date = [[HealthKitManager sharedInstance].healthStore dateOfBirthWithError: &error];
        if (date)
        {
            NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
            [dateformate setDateFormat:@"dd/MM/yyyy"];
            resultString = [dateformate stringFromDate: date];
        }
        title = @"Date of birth";
    }
    else if ([choosedIdentifier isEqualToString: HKCharacteristicTypeIdentifierBiologicalSex])
    {
        HKBiologicalSexObject * sex = [[HealthKitManager sharedInstance].healthStore biologicalSexWithError: &error];
        if (sex)
        {
            NSDictionary * results = @{@(HKBiologicalSexNotSet) : @"Not Set", @(HKBiologicalSexMale) : @"Male", @(HKBiologicalSexFemale) : @"Female"};
            resultString = results[@(sex.biologicalSex)];
        }
        title = @"Sex";
    }
    else if ([choosedIdentifier isEqualToString: HKCharacteristicTypeIdentifierBloodType])
    {
        HKBloodTypeObject * object = [[HealthKitManager sharedInstance].healthStore bloodTypeWithError: &error];
        if (object)
        {
            NSDictionary * results = @{@(HKBloodTypeNotSet) : @"Not Set",
                                       @(HKBloodTypeAPositive) : @"A+",
                                       @(HKBloodTypeANegative) : @"A-",
                                       @(HKBloodTypeBPositive) : @"B+",
                                       @(HKBloodTypeBNegative) : @"B-",
                                       @(HKBloodTypeABPositive) : @"AB+",
                                       @(HKBloodTypeABNegative) : @"AB-",
                                       @(HKBloodTypeOPositive) : @"O+",
                                       @(HKBloodTypeONegative) : @"O-"};
            resultString = results[@(object.bloodType)];
        }
        title = @"Blood type";
    }
    
    if (!error)
    {
        [[[UIAlertView alloc] initWithTitle: title  message: resultString delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle: @"Error" message: error.localizedDescription delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
    }
}

@end
