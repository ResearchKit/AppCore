//
//  MeasuresViewController.m
//  HealthKitSelector
//
//  Created by Dzianis Asanovich on 10/21/14.
//  Copyright (c) 2014 Dzianis Asanovich. All rights reserved.
//

#import "MeasuresViewController.h"
#import "SectionsViewController.h"
#import "HealthKitManager.h"

@interface MeasuresViewController ()
{
    NSArray * measuresKeys;
}

@property (nonatomic, strong) IBOutlet UITableView * mainTableView;
@end

@implementation MeasuresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    measuresKeys = [[[HealthKitManager sharedInstance] getMeasures] allKeys];
    self.title = @"Health Helper";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return measuresKeys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"measureCell"];
    UILabel * label = (UILabel *)[cell viewWithTag: 1];
    NSString * sectionName = measuresKeys[indexPath.row];
    
    label.text = sectionName;
    
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showSections"])
    {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [_mainTableView indexPathForCell:cell];
        [_mainTableView deselectRowAtIndexPath: indexPath animated: YES];
        SectionsViewController *sectionsViewController = (SectionsViewController*)[segue destinationViewController];
        NSString * key = measuresKeys[indexPath.row];
        sectionsViewController.sections = [[[HealthKitManager sharedInstance] getMeasures] objectForKey: key];
        
        sectionsViewController.title = key;
    }
}

@end
