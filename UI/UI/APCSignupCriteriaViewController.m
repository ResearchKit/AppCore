//
//  APCSignupCriteriaViewController.m
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCCriteria.h"
#import "APCCriteriaCell.h"
#import "APCStepProgressBar.h"
#import "APCSignupCriteriaViewController.h"

static NSString const *kAPCCriteriaCellIdentifier    =   @"Criteria";


@interface APCSignupCriteriaViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *criterias;

@end

@implementation APCSignupCriteriaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.criterias = [NSMutableArray array];
    
    {
        APCCriteria *criteria = [APCCriteria new];
        criteria.question = @"I am a:";
        criteria.answers = @[ @"Patient", @"Caregiver" ];
        [self.criterias addObject:criteria];
    }
    
    {
        APCCriteria *criteria = [APCCriteria new];
        criteria.question = @"Do you have Parkinson's Desease?";
        criteria.answers = @[ @"Yes", @"No" ];
        [self.criterias addObject:criteria];
    }
    
    {
        APCCriteria *criteria = [APCCriteria new];
        criteria.question = @"What is the level of severity?";
        criteria.answers = @[ @"Mid", @"Moderate", @"Advanced" ];
        [self.criterias addObject:criteria];
    }
    
    [self addNavigationItems];
    [self setupProgressBar];
    [self addTableView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:3 animation:YES];
}

- (void) addNavigationItems {
    self.title = NSLocalizedString(@"Inclusion Criteria", @"");
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"") style:UIBarButtonItemStylePlain target:self action:@selector(finishSignUp)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
}

- (void) setupProgressBar {
    [self.stepProgressBar setCompletedSteps:2 animation:NO];

    self.stepProgressBar.rightLabel.text = NSLocalizedString(@"Mandatory", @"");
    [self setStepNumber:4 title:NSLocalizedString(@"Inclusion Criteria", @"")];
}

- (void) addTableView {
    CGRect frame = self.view.bounds;
    frame.origin.y = CGRectGetMaxY(self.stepProgressBar.frame);
    frame.size.height -= frame.origin.y;
    
    self.tableView = [UITableView new];
    self.tableView.frame = frame;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"APCCriteriaCell" bundle:nil] forCellReuseIdentifier:(NSString *)kAPCCriteriaCellIdentifier];
}


#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.criterias.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    APCCriteriaCell *cell = (APCCriteriaCell *)[tableView dequeueReusableCellWithIdentifier:(NSString *)kAPCCriteriaCellIdentifier];
    
    APCCriteria *criteria = self.criterias[indexPath.row];
    
    cell.questionLabel.text = criteria.question;
    cell.choices = criteria.answers;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 98;
}


#pragma mark - Private Methods

- (void) finishSignUp {
    
}

@end
