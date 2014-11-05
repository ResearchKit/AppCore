//
//  APCStudyOverviewViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 9/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCStudyOverviewViewController.h"

static NSString * const kStudyOverviewCellIdentifier = @"kStudyOverviewCellIdentifier";

@interface APCStudyOverviewViewController ()

@end

@implementation APCStudyOverviewViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupTableView];
    [self setUpAppearance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)setUpAppearance
{    
    [self.joinButton setBackgroundImage:[UIImage imageWithColor:[UIColor appPrimaryColor]] forState:UIControlStateNormal];
    [self.joinButton setTitleColor:[UIColor appSecondaryColor4] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[UIImage imageWithColor:[UIColor appSecondaryColor2]] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor appSecondaryColor4] forState:UIControlStateNormal];
    
    self.diseaseNameLabel.font = [UIFont appMediumFontWithSize:19];
    self.diseaseNameLabel.textColor = [UIColor appSecondaryColor1];
    self.diseaseNameLabel.adjustsFontSizeToFitWidth = YES;
    self.diseaseNameLabel.minimumScaleFactor = 0.5;
    
    self.dateRangeLabel.font = [UIFont appLightFontWithSize:16];
    self.dateRangeLabel.textColor = [UIColor appSecondaryColor3];
    
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStudyOverviewCellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (IBAction)signInTapped:(id)sender
{
    
}
- (IBAction)signUpTapped:(id)sender
{

}

#pragma mark - Public methods

- (NSArray *)studyDetailsFromJSONFile:(NSString *)jsonFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    NSMutableArray *studyDetailsArray = [[NSMutableArray alloc] init];
    
    if (!parseError) {
        
        self.diseaseName = jsonDictionary[@"disease_name"];
        self.diseaseNameLabel.text = self.diseaseName;
        self.dateRangeLabel.text = [jsonDictionary[@"from_date"] stringByAppendingFormat:@" - %@", jsonDictionary[@"to_date"]];
        self.logoImageView.image = [UIImage imageNamed:jsonDictionary[@"logo_name"]];
        
        NSArray *questions = jsonDictionary[@"questions"];
        
        for (NSDictionary *questionDict in questions) {
            
            APCStudyDetails *studyDetails = [APCStudyDetails new];
            studyDetails.title = questionDict[@"title"];
            studyDetails.details = questionDict[@"details"];
            
            [studyDetailsArray addObject:studyDetails];
        }
    }
    
    return [NSArray arrayWithArray:studyDetailsArray];
}

@end


@implementation APCStudyDetails


@end
