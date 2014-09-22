//
//  APCParametersDashboardTableViewController.m
//  ParametersDashboard
//
//  Created by Justin Warmkessel on 9/19/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "APCParametersDashboardTableViewController.h"

#import <QuartzCore/QuartzCore.h>


static NSString *APCParametersDashboardCellIdentifier = @"APCParametersCellIdentifier";
static NSString *APCTitleOfParameterSection = @"Parameters";
static NSInteger APCParametersCellHeight = 44.0;
static NSInteger APCParametersTableViewHeaderHeight = 70.0;

@interface APCParametersDashboardTableViewController ()


@end

@implementation APCParametersDashboardTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHeaderView];
    
    //TODO parameters should be loaded at launch of application.
    self.parameters = [[APCParameters alloc] initWithFileName:@"parameters.json"];
    [self.parameters setDelegate:self];
    
    //Force loading of AppleCore bundle.
    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:@"APCAppleCoreBundle" ofType:@"bundle"];
    
    NSBundle* bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString *nibName = NSStringFromClass([APCParametersCell class]);
    
    [self.tableView registerNib:[UINib nibWithNibName:nibName bundle:bundle] forCellReuseIdentifier:APCParametersDashboardCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*********************************************************************************/
#pragma mark - Table view data source
/*********************************************************************************/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  [[self.parameters allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return APCTitleOfParameterSection;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return APCParametersCellHeight;
}


- (APCParametersCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *key = self.parameters.allKeys[indexPath.row];
    id value = [self.parameters objectForKey:key];
    
    APCParametersCell *cell;
    
    //cell = [tableView dequeueReusableCellWithIdentifier:APCParametersDashboardCellIdentifier];
    cell = [APCParametersCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:APCParametersDashboardCellIdentifier type:InputCellTypeText];
    cell.delegate = self;
    
    if (!cell) {
        cell = [APCParametersCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:APCParametersDashboardCellIdentifier type:InputCellTypeText];
        cell.delegate = self;
    }
    
    cell.txtTitle.text = key;
    
    if ([value isKindOfClass:[NSString class]]) {
        cell.txtValue.text = value;
    }
    else {
        cell.txtValue.text = [value stringValue];
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
    
    
    UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectMake(260.0, 25.0, 50, 40)];
    [resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:resetButton];
    
    
    
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

- (void) reset {
    [self.tableView endEditing:YES];
    
    [self.parameters reset];
    [self.tableView reloadData];
}

/*********************************************************************************/
#pragma mark - InputCellDelegate
/*********************************************************************************/

- (void) inputCellValueChanged:(APCParametersCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *key = self.parameters.allKeys[indexPath.row];
    
    id previousValue = [self.parameters objectForKey:key];
    
    if ([previousValue isKindOfClass:[NSString class]]) {
        [self.parameters setString:cell.value forKey:key];
    }
    else
    {
        [self.parameters setNumber:cell.value forKey:key];

    }
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
