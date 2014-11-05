//
//  AddQuantityViewController.m
//  HealthKitSelector
//
//  Created by Dzianis Asanovich on 10/22/14.
//  Copyright (c) 2014 Dzianis Asanovich. All rights reserved.
//

#import "AddSampleViewController.h"
#import "ActionSheetStringPicker.h"
#import "ActionSheetDatePicker.h"
#import "HealthKitManager.h"
#import "CustomIOS7AlertView.h"
#import "UIAlertView+Blocks.h"
#import "WorkoutEventsViewController.h"

@interface AddSampleViewController ()
{
    NSArray * unitsArray;
    NSMutableArray * metadata;
    HKSampleType * currentSampleType;
    
    NSDate * startDate;
    NSDate * endDate;
    
    // Workout
    NSArray * workoutEvents;
    HKQuantity * energyQuantity;
    HKQuantity * distanceQuantity;
}

@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UIButton *unitButton;
@property (weak, nonatomic) IBOutlet UITableView *paramsTableView;

@property (weak, nonatomic) IBOutlet UIButton *startDateButton;
@property (weak, nonatomic) IBOutlet UIButton *endDateButton;

@property (weak, nonatomic) IBOutlet UIButton *distanceButton;
@property (weak, nonatomic) IBOutlet UIButton *energyButton;
@property (weak, nonatomic) IBOutlet UIButton *workoutEventsButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation AddSampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    metadata = [NSMutableArray array];
    startDate = endDate = [NSDate date];
    [self updateDates];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target: self action: @selector(saveClick:)];
    currentSampleType = (HKSampleType*)[HealthKitManager getObjectTypeForIdentifier: _identifier];
    if (_simpleQuantity)
    {
        _dateLabel.hidden = _startDateButton.hidden = _paramsTableView.hidden = YES;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self action: @selector(closeKeyboard:)];
}

-(void)closeKeyboard: (id) sender
{
    [_valueTextField resignFirstResponder];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target: self action: @selector(saveClick:)];
}

-(IBAction)startDateClick: (id) sender
{
    [self closeKeyboard: nil];
    [ActionSheetDatePicker showPickerWithTitle:@"Start Date" datePickerMode: UIDatePickerModeDateAndTime selectedDate:startDate doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        startDate = selectedDate;
        [self updateDates];
    } cancelBlock: nil origin:sender];
}

-(IBAction)endDateClick: (id) sender
{
    [self closeKeyboard: nil];
    
    ActionSheetDatePicker* picker = [[ActionSheetDatePicker alloc] initWithTitle:@"End Date" datePickerMode: UIDatePickerModeDateAndTime selectedDate:startDate doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin)
    {
        endDate = selectedDate;
        [self updateDates];
    } cancelBlock: nil origin:sender];
    
    picker.minimumDate = startDate;
    [picker showActionSheetPicker];
}


-(IBAction)sleepTypeClick: (id) sender
{
    NSArray * units = @[@"AnalysisInBed", @"AnalysisAsleep"];
    [ActionSheetStringPicker showPickerWithTitle:@"Select Unit" rows: units initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
     {
         [_unitButton setTitle: selectedValue forState: UIControlStateNormal];
     } cancelBlock:nil origin:sender];
}


- (IBAction)unitClick:(id)sender {
    [self closeKeyboard: nil];
    NSArray * units = [HealthKitManager getUnitsForIdentifier: _identifier];
    [ActionSheetStringPicker showPickerWithTitle:@"Select Unit" rows: units initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
     {
         [_unitButton setTitle: selectedValue forState: UIControlStateNormal];
     } cancelBlock: nil origin:sender];
}

-(IBAction)workoutTypeClick: (id) sender
{
    NSArray * types = [HealthKitManager getWorkouts];
    NSMutableArray * reducedIdentifiers = [NSMutableArray array];
    for (int i = 0; i < types.count; i++)
    {
        NSString * ident = types[i];
        [reducedIdentifiers addObject: [HealthKitManager getIdentifierReadable: ident]];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Select Type" rows: reducedIdentifiers initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
     {
         [_unitButton setTitle: types[selectedIndex] forState: UIControlStateNormal];
     } cancelBlock:nil origin:sender];
}


- (IBAction)distanceClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    AddSampleViewController * addSampleVC = [storyboard instantiateViewControllerWithIdentifier:@"addQuantitySample"];
    NSString * identifier = HKQuantityTypeIdentifierDistanceWalkingRunning;
    
    addSampleVC.identifier = identifier;
    addSampleVC.simpleQuantity = YES;
    addSampleVC.title = [HealthKitManager getIdentifierReadable: identifier];
    
    addSampleVC.returnSampleDelegate = self;
    UINavigationController *navController = self.navigationController;
    [navController pushViewController: addSampleVC animated:YES];
}

- (IBAction)energyClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    AddSampleViewController * addSampleVC = [storyboard instantiateViewControllerWithIdentifier:@"addQuantitySample"];
    NSString * identifier = HKQuantityTypeIdentifierActiveEnergyBurned;
    
    addSampleVC.identifier = identifier;
    addSampleVC.simpleQuantity = YES;
    addSampleVC.title = [HealthKitManager getIdentifierReadable: identifier];
    
    addSampleVC.returnSampleDelegate = self;
    UINavigationController *navController = self.navigationController;
    [navController pushViewController: addSampleVC animated:YES];
}

- (IBAction)workoutEventsClick:(id)sender {
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return metadata.count + 1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
    if (indexPath.row == metadata.count)
    {
        cell = [tableView dequeueReusableCellWithIdentifier: @"addNewCell"];
        UILabel * label = (UILabel *)[cell viewWithTag: 1];
        label.text = @"Add new param";
    }
    else
    {
        NSDictionary * dict = metadata[indexPath.row];
        NSString * dictKey = dict.allKeys.firstObject;
        id value = dict[dictKey];
        
        if ([value isKindOfClass: [HKSample class]])
        {
            HKSample * sampleValue = (HKSample*)value;
            cell = [tableView dequeueReusableCellWithIdentifier: @"addNewCell"];
            UILabel * label = (UILabel *)[cell viewWithTag: 1];
            label.text = [HealthKitManager getIdentifierReadable: sampleValue.sampleType.identifier];
        }
        else if ([value isKindOfClass: [NSString class]])
        {
            cell = [tableView dequeueReusableCellWithIdentifier: @"paramCell"];
            
            UILabel * keyLabel = (UILabel *)[cell viewWithTag: 1];
            UILabel * valueLabel = (UILabel *)[cell viewWithTag: 2];
            
            keyLabel.text = dictKey;
            valueLabel.text = value;
        }
    }
    return cell;
}

-(void)saveClick: (id) sender
{
    if ([currentSampleType isKindOfClass: [HKQuantityType class]])
    {
        if (!_valueTextField.text.length)
        {
            [[[UIAlertView alloc] initWithTitle: @"Error" message: @"Please, enter value" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
            return;
        }
        else if ([_unitButton.currentTitle hasPrefix: @"press"])
        {
            [[[UIAlertView alloc] initWithTitle: @"Error" message: @"Please, enter unit" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
            return;
        }
    }
    else if ([currentSampleType isKindOfClass: [HKCategoryType class]])
    {
        if ([_unitButton.currentTitle hasPrefix: @"press"])
        {
            [[[UIAlertView alloc] initWithTitle: @"Error" message: @"Please, enter type" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
            return;
        }
    }
    
    HKSample * finalSample = nil;
    if ([currentSampleType isKindOfClass: [HKQuantityType class]])
    {
        HKQuantity *quantity = [HKQuantity quantityWithUnit: [HKUnit unitFromString: _unitButton.currentTitle] doubleValue: [_valueTextField.text doubleValue]];
        
        NSMutableDictionary * newMetadata = [NSMutableDictionary dictionary];
        for (NSDictionary * dict in metadata)
        {
            [newMetadata addEntriesFromDictionary: dict];
        }
        
        finalSample = [HKQuantitySample quantitySampleWithType: (HKQuantityType*)currentSampleType  quantity: quantity startDate: startDate endDate: startDate metadata: newMetadata];
    }
    else if ([currentSampleType isKindOfClass: [HKCorrelationType class]])
    {
        NSMutableSet * subItems = [NSMutableSet set];
        NSMutableDictionary * newMetadata = [NSMutableDictionary dictionary];
        for (NSDictionary * dict in metadata)
        {
            NSString * key = dict.allKeys.firstObject;
            if ([dict[key] isKindOfClass: [NSString class]])
            {
                [newMetadata addEntriesFromDictionary: dict];
            }
            else
            {
                [subItems addObject: dict[key]];
            }
        }
        HKCorrelation * correlation = [HKCorrelation correlationWithType: (HKCorrelationType*)currentSampleType startDate: startDate endDate: startDate objects: subItems metadata: newMetadata];
        finalSample = correlation;
    }
    else if ([currentSampleType isKindOfClass: [HKCategoryType class]])
    {
        NSMutableDictionary * newMetadata = [NSMutableDictionary dictionary];
        for (NSDictionary * dict in metadata)
        {
            [newMetadata addEntriesFromDictionary: dict];
        }
        HKCategoryValueSleepAnalysis value = HKCategoryValueSleepAnalysisAsleep;
        if ([_unitButton.currentTitle hasPrefix: @"AnalysisInBed"])
        {
            value = HKCategoryValueSleepAnalysisInBed;
        }
        
        HKCategorySample * category = [HKCategorySample categorySampleWithType: (HKCategoryType*)currentSampleType value: value startDate:startDate endDate: endDate metadata: newMetadata];
        finalSample = category;
    }
    else if ([currentSampleType isKindOfClass: [HKWorkoutType class]])
    {
        NSMutableDictionary * newMetadata = [NSMutableDictionary dictionary];
        for (NSDictionary * dict in metadata)
        {
            [newMetadata addEntriesFromDictionary: dict];
        }
        
        HKCategoryValueSleepAnalysis value = HKCategoryValueSleepAnalysisAsleep;
        if ([_unitButton.currentTitle hasPrefix: @"AnalysisInBed"])
        {
            value = HKCategoryValueSleepAnalysisInBed;
        }
        
        NSArray * types = [HealthKitManager getWorkouts];
        
        NSUInteger workoutIndex = [types indexOfObjectPassingTest:^BOOL(NSString * obj, NSUInteger idx, BOOL *stop) {
            if ([obj isEqualToString: _unitButton.currentTitle]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        @try
        {
            HKWorkout * workout = [HKWorkout workoutWithActivityType: workoutIndex startDate: startDate endDate: endDate workoutEvents: workoutEvents totalEnergyBurned: energyQuantity totalDistance: distanceQuantity metadata:newMetadata];
            finalSample = workout;
        }
        @catch(NSException * exception)
        {
            [[[UIAlertView alloc] initWithTitle: @"Error" message: exception.description delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
        }
    }
    
    if (finalSample)
    {
        if (_returnSampleDelegate)
        {
            [_returnSampleDelegate newSample: finalSample];
            [self.navigationController popViewControllerAnimated: YES];
        }
        else
        {
            [[HealthKitManager sharedInstance].healthStore saveObject: finalSample withCompletion:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        [[[UIAlertView alloc] initWithTitle: @"Complete" message: @"Object saved succesfully" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
                        [self.navigationController popViewControllerAnimated: YES];
                    }
                    else {
                        [[[UIAlertView alloc] initWithTitle: @"Error" message: error.localizedDescription delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil] show];
                    }
                });
            }];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    [self closeKeyboard: nil];
    if (indexPath.row == metadata.count)
    {
        if ([currentSampleType isKindOfClass: [HKCorrelationType class]])
        {
            [UIAlertView showWithTitle: @"" message: @"Choose type of parameter" cancelButtonTitle: @"Cancel" otherButtonTitles: @[@"Simple", @"Other item"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
            {
                if (buttonIndex == 1)
                {
                    [self addSimpleParam];
                }
                else if (buttonIndex == 2)
                {
                    [self addOtherSampleParam];
                }
            }];
        }
        else
        {
            [self addSimpleParam];
        }
    }
}

- (void) addSimpleParam
{
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    UIView * view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 130)];
    UITextField * fieldKey = [[UITextField alloc] initWithFrame: CGRectMake(10, 20, 280, 30)];
    UITextField * fieldValue = [[UITextField alloc] initWithFrame: CGRectMake(10, 80, 280, 30)];
    fieldKey.backgroundColor = fieldValue.backgroundColor = [UIColor whiteColor];
    fieldKey.layer.cornerRadius = fieldValue.layer.cornerRadius = 10;
    fieldKey.placeholder = @"Key";
    fieldValue.placeholder = @"Value";
    fieldKey.textAlignment = fieldValue.textAlignment = NSTextAlignmentCenter;
    [view addSubview: fieldKey];
    [view addSubview: fieldValue];
    [alertView setContainerView: view];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"OK",nil]];
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        if (buttonIndex == 1)
        {
            [metadata addObject: @{fieldKey.text : fieldValue.text}];
            [_paramsTableView reloadData];
            [alertView close];
        }
    }];
    [alertView show];
}

- (void) addOtherSampleParam
{
    NSArray * identifiers = [[HealthKitManager sharedInstance] getQuantityIdentifiers];
    NSMutableArray * reducedIdentifiers = [NSMutableArray array];
    for (int i = 0; i < identifiers.count; i++)
    {
        NSString * ident = identifiers[i];
        [reducedIdentifiers addObject: [HealthKitManager getIdentifierReadable: ident]];
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Unit" rows: reducedIdentifiers initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
     {
         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
         AddSampleViewController * addSampleVC = [storyboard instantiateViewControllerWithIdentifier:@"addQuantitySample"];
         addSampleVC.identifier = identifiers[selectedIndex];
         addSampleVC.title = selectedValue;
         addSampleVC.returnSampleDelegate = self;
         UINavigationController *navController = self.navigationController;
         [navController pushViewController: addSampleVC animated:YES];
         
     }
     cancelBlock:^(ActionSheetStringPicker *picker)
     {
         NSLog(@"Block Picker Canceled");
     } origin: self.view];
}

- (void) newSample: (HKSample *) sample
{
    if ([(HKSampleType*)[HealthKitManager getObjectTypeForIdentifier:_identifier] isKindOfClass: [HKWorkoutType class]])
    {
        if ([sample.sampleType.identifier isEqualToString: HKQuantityTypeIdentifierDistanceWalkingRunning])
        {
            distanceQuantity = ((HKQuantitySample*)sample).quantity;
            [_distanceButton setTitle: [distanceQuantity description] forState: UIControlStateNormal];
        }
        if ([sample.sampleType.identifier isEqualToString: HKQuantityTypeIdentifierActiveEnergyBurned])
        {
            energyQuantity = ((HKQuantitySample*)sample).quantity;
            [_energyButton setTitle: [energyQuantity description] forState: UIControlStateNormal];
        }
    }
    else
    {
        NSDictionary * newDict = @{sample.sampleType.identifier : sample};
        [metadata addObject: newDict];
        [_paramsTableView reloadData];
    }
}

- (void) newWorkoutEvents: (NSArray *) newWorkouts
{
    workoutEvents = newWorkouts;
}

-(void) updateDates
{
    if ([startDate compare: endDate] == NSOrderedDescending)
    {
        endDate = startDate;
    }
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"dd/MM/yyyy HH:mm"];
    
    [_startDateButton setTitle: [dateformate stringFromDate: startDate] forState: UIControlStateNormal];
    [_endDateButton setTitle: [dateformate stringFromDate: endDate] forState: UIControlStateNormal];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString: @"workoutEvents"])
    {
        WorkoutEventsViewController * workoutEventsVC = segue.destinationViewController;
        workoutEventsVC.workoutEvents = workoutEvents;
        workoutEventsVC.returnSampleDelegate = self;
        workoutEventsVC.title = @"Workouts";
    }
}


@end
