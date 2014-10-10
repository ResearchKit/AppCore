//
//  APCParametersDashboardTableViewController.m
//  ParametersDashboard
//
//  Created by Justin Warmkessel on 9/19/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "APCParametersDashboardTableViewController.h"
#import "APCDebugWindow.h"
#import "APCAppleCore.h"

#import <QuartzCore/QuartzCore.h>


static NSString *APCParametersDashboardCellIdentifier = @"APCParametersCellIdentifier";
static NSString *APCParametersCoreDataCellIdentifier = @"APCParametersCoreDataCellIdentifier";
static NSString *APCParametersUserDefaultsCellIdentifier = @"APCParametersUserDefaultsCellIdentifier";

static NSString *APCTitleOfParameterSection = @"Parameters";
static NSString *APCTitleOfCoreDataParameterSection = @"Reset";
static NSString *APCTitleOfUserDefaultsParameterSection = @"NSUserdefaults";


typedef NS_ENUM(NSInteger, APCParametersEnum)
{
    kCoreDataDefault = 0,
    kParametersDefaults = 1,
    kUserDefault = 2
};


@interface APCParametersDashboardTableViewController ()

@property (nonatomic, strong) NSArray *sections;

@property  (weak, nonatomic)     APCDataSubstrate        *dataSubstrate;
@property  (strong, nonatomic)   NSManagedObjectContext  *localMOC;

@end


@implementation APCParametersDashboardTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Debug Screen";
    
    //Setup sections
    
    //TODO: If you want to include NSUserDefaults then uncomment the line below.
//    self.sections = @[APCParametersDashboardCellIdentifier, APCParametersCoreDataCellIdentifier, APCParametersUserDefaultsCellIdentifier];
    self.sections = @[APCParametersDashboardCellIdentifier, APCParametersCoreDataCellIdentifier];
    
    //TODO parameters should be loaded at launch of application
    self.parameters = [[APCParameters alloc] initWithFileName:@"APCParameters.json"];
    [self.parameters setDelegate:self];

    //Setup persistent parameter types like Core Data
    self.coreDataParameters = [NSMutableArray new];
    self.coreDataParameters = [@[@"App Reset"] mutableCopy];
//    self.coreDataParameters = [@[@"Core Data Reset", @"Parameters", @"NSUserDefaults"] mutableCopy];
    
    //Setup NSUserDefaults
    self.userDefaultParameters = [[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] mutableCopy];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*********************************************************************************/
#pragma mark - Table view data source
/*********************************************************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger rowCount = 0;
    
    if (section == kCoreDataDefault)
    {
        rowCount = [self.coreDataParameters count];
    }
    else if (section == kParametersDefaults)
    {
        rowCount = [[self.parameters allKeys] count];
    }
    else if (section == kUserDefault)
    {

        rowCount = [self.userDefaultParameters count];
    }
    return  rowCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    NSString *sectionTitle;
    
    if (section == kCoreDataDefault)
    {
        sectionTitle = APCTitleOfCoreDataParameterSection;
    }
    else if (section == kParametersDefaults)
    {
        sectionTitle = APCTitleOfParameterSection;
    }
    else if (section == kUserDefault)
    {
        sectionTitle = APCTitleOfUserDefaultsParameterSection;
    }
    
    return sectionTitle;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat height = 0;
    
    if (indexPath.section == kCoreDataDefault) {
        
        height = [APCParametersCoreDataCell heightOfCell];
        
        
    }
    else if (indexPath.section == kParametersDefaults)
    {
        height = [APCParametersCell heightOfCell];
    }
    
    else if (indexPath.section == kUserDefault) {
        height = [APCParametersUserDefaultCell heightOfCell];
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (indexPath.section == kCoreDataDefault)
    {
        APCParametersCoreDataCell *coreDataCell = [tableView dequeueReusableCellWithIdentifier:APCParametersCoreDataCellIdentifier];
        [coreDataCell setDelegate:self];
        
        coreDataCell.resetTitle.text = [self.coreDataParameters objectAtIndex:indexPath.row];

        if (indexPath.row == kCoreDataDefault)
        {
            coreDataCell.resetInstructions.text = @"Resets the app to fresh install state.";
            [coreDataCell.resetButton addTarget:self action:@selector(resetApp) forControlEvents:UIControlEventTouchUpInside];
        }
        
        cell = coreDataCell;
    }
    
    else if (indexPath.section == kParametersDefaults)
    {
        
        APCParametersCell *parametersCell = [tableView dequeueReusableCellWithIdentifier:APCParametersDashboardCellIdentifier];
        parametersCell.delegate = self;

        NSString *key = self.parameters.allKeys[indexPath.row];
        id value = [self.parameters objectForKey:key];
        
        if (!parametersCell) {
            parametersCell = [tableView dequeueReusableCellWithIdentifier:APCParametersDashboardCellIdentifier];
            parametersCell.delegate = self;
        }
        
        parametersCell.parameterTitle.text = key;
        
        if ([value isKindOfClass:[NSString class]]) {
            parametersCell.parameterTextInput.text = value;
            [parametersCell.parameterTextInput setKeyboardType:UIKeyboardTypeAlphabet];
            
        }
        else if ([value isKindOfClass:[NSNumber class]])
        {
            parametersCell.parameterTextInput.text = [value stringValue];
            [parametersCell.parameterTextInput setKeyboardType:UIKeyboardTypeDecimalPad];
        }
        
        cell = parametersCell;
    }
    else if (indexPath.section == kUserDefault)
    {
        APCParametersUserDefaultCell *userDefaultCell = [tableView dequeueReusableCellWithIdentifier:APCParametersUserDefaultsCellIdentifier];
        
        NSString *key = [self.userDefaultParameters objectAtIndex:indexPath.row];
        userDefaultCell.parameterTitle.text = key;
        
        id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if ([value isKindOfClass:[NSString class]])
        {
            userDefaultCell.parameterTextInput.text = (NSString *)value;
        }
        else if ([value isKindOfClass:[NSNumber class]])
        {
            userDefaultCell.parameterTextInput.text = (NSString *)[value stringValue];
            [userDefaultCell.parameterTextInput setKeyboardType:UIKeyboardTypeDecimalPad];
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            //Exlicitly ignoring arrays
            NSLog(@"NSArray %@", value);
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            //Exlicitly ignoring dictionaries
            NSLog(@"NSDictionary %@", value);
        }
        else
        {
            NSLog(@"%@", value);
        }
        
        cell = userDefaultCell;
    }
    
    return cell;
}

/*********************************************************************************/
#pragma mark - Reset Methods
/*********************************************************************************/

- (void) resetParameters {
    [self.tableView endEditing:YES];
    
    [self.parameters reset];
    [self.tableView reloadData];
}

- (void) resetApp
{
    APCAppDelegate * appDelegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
    UIViewController * vc =  [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    appDelegate.window.rootViewController = vc;
    [appDelegate clearNSUserDefaults];
    [APCKeychainStore resetKeyChain];
    [appDelegate.dataSubstrate resetCoreData];
    [[NSNotificationCenter defaultCenter] postNotificationName:APCUserLogOutNotification object:self];
}

- (void)resetUserDefaults {
    [self.tableView endEditing:YES];
    APCAppDelegate * appDelegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
    [appDelegate clearNSUserDefaults];
    [self.tableView reloadData];
}

- (void)resetCoreData {
    
    NSFileManager  *manager = [NSFileManager defaultManager];
    
    // the preferred way to get the apps documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // grab all the files in the documents dir
    NSArray *allFiles = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    // filter the array for only sqlite files
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.sqlite'"];
    NSArray *sqliteFiles = [allFiles filteredArrayUsingPredicate:fltr];
    
    // use fast enumeration to iterate the array and delete the files
    for (NSString *sqliteFile in sqliteFiles)
    {
        NSError *error = nil;
        [manager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:sqliteFile] error:&error];
        NSAssert(!error, @"Assertion: Error removing sqlite file.");
    }
}


/*********************************************************************************/
#pragma mark - CUSTOM CELL Delegate Methods
/*********************************************************************************/

- (void) inputCellValueChanged:(APCParametersCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *key = self.parameters.allKeys[indexPath.row];
    
    id previousValue = [self.parameters objectForKey:key];
    
    if ([previousValue isKindOfClass:[NSString class]]) {
        [self.parameters setString:cell.parameterTextInput.text forKey:key];
    }
    else if ([previousValue isKindOfClass:[NSNumber class]])
    {
        NSNumber *number = previousValue;
        
        CFNumberType numberType = CFNumberGetType((CFNumberRef)number);
        
        if (numberType == kCFNumberSInt32Type)
        {
            NSInteger integer = [cell.parameterTextInput.text intValue];
            [self.parameters setInteger:integer forKey:key];
        }
        else if (numberType == kCFNumberSInt64Type)
        {
            NSInteger integer = [cell.parameterTextInput.text intValue];
            [self.parameters setInteger:integer forKey:key];
        }
        else if (numberType == kCFNumberFloat64Type)
        {
            float floatNum = [cell.parameterTextInput.text floatValue];
            [self.parameters setFloat:floatNum forKey:key];
        }
    }
}

/*********************************************************************************/
#pragma mark - InputCellDelegate
/*********************************************************************************/

- (void)parameters:(APCParameters *)parameters didFailWithError:(NSError *)error {
    NSLog(@"Did fail with error %@", error);
    NSAssert(!error, @"Assertion: An error occurred which had something to do with your .json file.");
}

- (void)parameters:(APCParameters *)parameters didFailWithValue:(id)value {
    NSLog(@"Did fail with value %@", value);

    UIAlertController *alertController = [[UIAlertController alloc] init];
    
    NSString *message = [NSString stringWithFormat:@"Warning: The value you input must conform to the previous value type that was set: %@", value];
    [alertController setMessage:message];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/*********************************************************************************/
#pragma mark - Buttons
/*********************************************************************************/

- (IBAction)donePressed:(id)sender {
    [self.tableView endEditing:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.navigationController.view setAlpha:0];
        
    } completion:^(BOOL finished) {
        APCDebugWindow * window = (APCDebugWindow*) self.navigationController.view.window;
        [self.navigationController.view removeFromSuperview];
        [self.navigationController removeFromParentViewController];
        window.toggleDebugWindow = NO;
    }];

}


@end
