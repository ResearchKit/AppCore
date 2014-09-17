//
//  APCSignupCriteriaViewController.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCCriteriaCell.h"
#import "UIView+Category.h"
#import "NSDate+Category.h"
#import "APCTableViewItem.h"
#import "NSBundle+Category.h"
#import "APCSegmentControl.h"
#import "APCStepProgressBar.h"
#import "APCSignupCriteriaViewController.h"

static NSString const *kAPCSignupCriteriaTableViewCellIdentifier    =   @"Criteria";

static CGFloat const kAPCSignupCriteriaTableViewCellHeight          =   98.0;


@interface APCSignupCriteriaViewController () <UITableViewDataSource, UITableViewDelegate, APCConfigurableCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *criterias;

@end

@implementation APCSignupCriteriaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.criterias = [NSMutableArray array];
    
    {
        APCTableViewSegmentItem *item = [APCTableViewSegmentItem new];
        item.detailText = NSLocalizedString(@"I am a:", @"");
        item.segments = @[ NSLocalizedString(@"Patient", @""), NSLocalizedString(@"Caregiver", @"") ];
        item.selectedIndex = 0;
        [self.criterias addObject:item];
    }
    
    {
        APCTableViewSegmentItem *item = [APCTableViewSegmentItem new];
        item.detailText = NSLocalizedString(@"Do you have Parkinson's Disease?", @"");
        item.segments = @[ NSLocalizedString(@"Yes", @""), NSLocalizedString(@"No", @""), NSLocalizedString(@"I don't know", @"") ];
        item.selectedIndex = 2;
        [self.criterias addObject:item];
    }
    
    {
        APCTableViewDatePickerItem *item = [APCTableViewDatePickerItem new];
        item.detailText = NSLocalizedString(@"When were you diagnosed?", @"");
        item.caption = NSLocalizedString(@"Date", @"");
        item.placeholder = @"MMMM DD, YYYY";
        item.textAlignnment = NSTextAlignmentRight;
        item.date = [NSDate date];
        [self.criterias addObject:item];
    }
    
    {
        APCTableViewSegmentItem *item = [APCTableViewSegmentItem new];
        item.detailText = NSLocalizedString(@"What is the level of severity?", @"");
        item.segments = @[ NSLocalizedString(@"Mid", @""), NSLocalizedString(@"Moderate", @""), NSLocalizedString(@"Advanced", @"") ];
        item.selectedIndex = 1;
        [self.criterias addObject:item];
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
    frame.origin.y = self.stepProgressBar.bottom;
    frame.size.height -= frame.origin.y;
    
    self.tableView = [UITableView new];
    self.tableView.frame = frame;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"APCCriteriaCell" bundle:[NSBundle appleCoreBundle]] forCellReuseIdentifier:(NSString *)kAPCSignupCriteriaTableViewCellIdentifier];
}


#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.criterias.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    APCTableViewItem *item = self.criterias[indexPath.row];
    
    APCCriteriaCell *cell = (APCCriteriaCell *)[tableView dequeueReusableCellWithIdentifier:(NSString *)kAPCSignupCriteriaTableViewCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.questionLabel.text = item.detailText;
    cell.captionLabel.text = item.caption;
    
    if ([item isKindOfClass:[APCTableViewSegmentItem class]]) {
        cell.segmentControl.hidden = NO;
        
        [cell setSegments:[(APCTableViewSegmentItem *)item segments] selectedIndex:[(APCTableViewSegmentItem *)item selectedIndex]];
        cell.segmentControl.segmentBorderColor = [UIColor clearColor];
    }
    else if ([item isKindOfClass:[APCTableViewDatePickerItem class]]) {
        cell.captionLabel.hidden = NO;
        cell.valueTextField.hidden = NO;
        
        NSDate *date = [(APCTableViewDatePickerItem *)item date];
        cell.valueTextField.text = [date toStringWithFormat:[(APCTableViewDatePickerItem *)item dateFormat]];
        cell.valueTextField.placeholder = [(APCTableViewDatePickerItem *)item placeholder];
        cell.valueTextField.textAlignment = [(APCTableViewDatePickerItem *)item textAlignnment];
        cell.valueTextField.inputView = cell.datePicker;
        
        cell.datePicker.date = date;
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kAPCSignupCriteriaTableViewCellHeight;
}


#pragma mark - APCCriteriaCellDelegate

- (void) configurableCell:(APCConfigurableCell *)cell textValueChanged:(NSString *)text {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewTextFieldItem *criteria = self.criterias[indexPath.row];
    criteria.value = text;
}

- (void) configurableCell:(APCConfigurableCell *)cell dateValueChanged:(NSDate *)date {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    APCTableViewDatePickerItem *criteria = self.criterias[indexPath.row];
    criteria.date = cell.datePicker.date;
    
    cell.valueTextField.text = [cell.datePicker.date toStringWithFormat:nil];
}


#pragma mark - Private Methods

- (void) finishSignUp {
    
}

@end
