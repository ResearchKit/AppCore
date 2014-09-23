//
//  APCParametersDashboardTableViewController.m
//  ParametersDashboard
//
//  Created by Justin Warmkessel on 9/19/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "APCParametersDashboardTableViewController.h"
#import "APCAppleCore.h"

#import <QuartzCore/QuartzCore.h>


static NSString *APCParametersDashboardCellIdentifier = @"APCParametersCellIdentifier";
static NSString *APCParametersCoreDataCellIdentifier = @"APCParametersCoreDataCellIdentifier";
static NSString *APCParametersUserDefaultsCellIdentifier = @"APCParametersUserDefaultsCellIdentifier";

static NSString *APCTitleOfParameterSection = @"Parameters";
static NSString *APCTitleOfCoreDataParameterSection = @"Reset";
static NSString *APCTitleOfUserDefaultsParameterSection = @"NSUserdefaults";

static NSInteger APCParametersTableViewHeaderHeight = 70.0;


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
    
    [self setupHeaderView];
    
    //Setup sections
    
    //TODO: If you want to include NSUserDefaults then uncomment the line below.
    //self.sections = @[APCParametersDashboardCellIdentifier, APCParametersCoreDataCellIdentifier, APCParametersUserDefaultsCellIdentifier];
    self.sections = @[APCParametersDashboardCellIdentifier, APCParametersCoreDataCellIdentifier];
    
    //TODO parameters should be loaded at launch of application
    self.parameters = [[APCParameters alloc] initWithFileName:@"parameters.json"];
    [self.parameters setDelegate:self];
    
    //Force loading of AppleCore bundle

    
    NSBundle* bundle = [NSBundle appleCoreBundle];
    
    //Register custom nibs
    NSString *nibName = NSStringFromClass([APCParametersCell class]);
    [self.tableView registerNib:[UINib nibWithNibName:nibName bundle:bundle] forCellReuseIdentifier:APCParametersDashboardCellIdentifier];
    
    NSString *nibCoreDataCellName = NSStringFromClass([APCParametersCoreDataCell class]);
    [self.tableView registerNib:[UINib nibWithNibName:nibCoreDataCellName bundle:bundle] forCellReuseIdentifier:APCParametersCoreDataCellIdentifier];

    NSString *nibUserDefaultsCellName = NSStringFromClass([APCParametersUserDefaultCell class]);
    [self.tableView registerNib:[UINib nibWithNibName:nibUserDefaultsCellName bundle:bundle] forCellReuseIdentifier:APCParametersUserDefaultsCellIdentifier];

    
    //Setup persistent parameter types like Core Data
    self.coreDataParameters = [NSMutableArray new];
    self.coreDataParameters = [@[@"Core Data Reset", @"Parameters", @"NSUserDefautls"] mutableCopy];
    
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
    
    NSInteger rowCount;
    
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

    CGFloat height;
    
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


- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (indexPath.section == kCoreDataDefault)
    {
        APCParametersCoreDataCell *coreDataCell = [tableView dequeueReusableCellWithIdentifier:APCParametersCoreDataCellIdentifier];
        [coreDataCell setDelegate:self];
        
        coreDataCell.resetTitle.text = [self.coreDataParameters objectAtIndex:indexPath.row];
        [coreDataCell.resetButton setBackgroundImage:[self imageWithColor:[UIColor blueColor]] forState:UIControlStateHighlighted];

        
        if (indexPath.row == kCoreDataDefault)
        {
            coreDataCell.resetInstructions.text = @"This will delete all persisting object graph entities.";
            [coreDataCell.resetButton addTarget:self action:@selector(resetCoreData) forControlEvents:UIControlEventTouchUpInside];

        }
        else if (indexPath.row == kParametersDefaults)
        {
            coreDataCell.resetInstructions.text = @"This will reset original Parameters.";
            [coreDataCell.resetButton addTarget:self action:@selector(resetParameters) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (indexPath.row == kUserDefault)
        {
            coreDataCell.resetInstructions.text = @"This will delete all NSUserDefaults.";
            [coreDataCell.resetButton addTarget:self action:@selector(resetUserDefaults) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        cell = coreDataCell;
    }
    
    else if (indexPath.section == kParametersDefaults)
    {
        
        APCParametersCell *parametersCell = [tableView dequeueReusableCellWithIdentifier:APCParametersDashboardCellIdentifier];
        parametersCell.delegate = self;
        //[parametersCell.parameterTextInput setDelegate:self];

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
            NSLog(@"NSArray %@", value);
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
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
#pragma mark - Private methods
/*********************************************************************************/
- (void) setupHeaderView {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, APCParametersTableViewHeaderHeight)];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 25.0, 50, 40)];
    [saveButton setTitle:@"Done" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(dimissView) forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:saveButton];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)dimissView {
    [self.tableView endEditing:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view setAlpha:0];
        
    } completion:^(BOOL finished) {
        [self removeFromParentViewController];
        
    }];
}

- (void) resetParameters {
    [self.tableView endEditing:YES];
    
    [self.parameters reset];
    [self.tableView reloadData];
}

- (void)resetUserDefaults {
    [self.tableView endEditing:YES];
    NSDictionary *defaultsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    for (NSString *key in [defaultsDictionary allKeys]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
}

- (void)resetCoreData {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath =  [documentsDirectory stringByAppendingPathComponent:@"db.sqlite"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
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

- (void) resetDidComplete:(APCParametersCoreDataCell *)cell {
    NSLog(@"Core data did reset");
}


/*********************************************************************************/
#pragma mark - InputCellDelegate
/*********************************************************************************/

- (void)parameters:(APCParameters *)parameters didFailWithError:(NSError *)error {
    NSLog(@"Did fail with error %@", error);
}

- (void)parameters:(APCParameters *)parameters didFailWithValue:(id)value {
    NSLog(@"Did fail with value %@", value);
}

- (void)parameters:(APCParameters *)parameters didFailWithKey:(NSString *)key {
    NSLog(@"Did fail with key %@", key);
}

- (void)parameters:(APCParameters *)parameters didFinishSaving:(id)item {
    NSLog(@"Did finish saving");
}

- (void)parameters:(APCParameters *)parameters didFinishResetting:(id)item {
    NSLog(@"Did finish resetting");    
}

@end
