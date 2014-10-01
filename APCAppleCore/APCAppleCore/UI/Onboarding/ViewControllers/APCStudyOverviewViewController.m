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

@property (strong, nonatomic) IBOutlet UIView *headerView;
@end

@implementation APCStudyOverviewViewController

#pragma mark - 

- (instancetype)init
{
    if(self = [super initWithNibName:self.nibName bundle:[NSBundle appleCoreBundle]]){
        
    }
    
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIRectEdge)edgesForExtendedLayout
{
    return UIRectEdgeNone;
}

- (NSString *)nibName
{
    return @"APCStudyOverviewViewController";
}

- (void)setupTableView
{
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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
