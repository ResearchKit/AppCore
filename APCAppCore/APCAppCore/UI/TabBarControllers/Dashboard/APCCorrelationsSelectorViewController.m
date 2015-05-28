//
//  APCCorrelationsSelectorViewController.m
//  APCAppCore
//
// Copyright (c) 2015, Apple Inc. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "APCCorrelationsSelectorViewController.h"
#import "APCScoring.h"
#import "UIColor+APCAppearance.h"

@interface APCCorrelationsSelectorViewController ()
@property (strong, nonatomic) APCScoring *scoring;
@property (strong, nonatomic) NSArray *scoringObjects;
@property (assign, nonatomic) BOOL section0Selected;
@property (weak, nonatomic) APCScoring *series1SelectedObject;
@property (weak, nonatomic) APCScoring *series2SelectedObject;
@end

@implementation APCCorrelationsSelectorViewController

- (id)initWithScoringObjects:(NSArray *)scoringObjects
{
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [self.tableView setBackgroundColor:[UIColor appSecondaryColor4]];
        self.section0Selected = NO;
        self.scoringObjects = scoringObjects;
        [self setTitle:@"Data Correlations"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void) viewWillAppear:(BOOL)__unused animated
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView
{
    // Return the number of sections.
    return 2;//series 1 and series 2
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section
{
    // Both sections shall have the same number of rows
    return self.scoringObjects.count;
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)__unused tableView viewForHeaderInSection:(NSInteger)section
{
    
    UITableViewHeaderFooterView *headerView;
    
    if (section == 0) {
        headerView = [[UITableViewHeaderFooterView alloc]init];
        headerView.textLabel.text = NSLocalizedString(@"Select Series 1", nil);
    }else{
        if (self.section0Selected) {
            headerView = [[UITableViewHeaderFooterView alloc]init];
            headerView.textLabel.text = NSLocalizedString(@"Select Series 2", nil);
        }
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForHeaderInSection:(NSInteger)__unused section
{
    
    float defaultHeight = 44.0;
    if (section == 0) {
        return defaultHeight;
    }else{
        return self.section0Selected ? defaultHeight: 0.00f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    APCScoring *scoringObject = [self.scoringObjects objectAtIndex:indexPath.row];
    cell.textLabel.text = scoringObject.caption;
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    
    switch (indexPath.section) {
        case 0:
            if (scoringObject == self.series1SelectedObject) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
            break;
        case 1:
            //set section 1 hidden until section 0 has a selected cell
            if (!self.section0Selected) {
                [cell setHidden:YES];
            }else{
                [cell setHidden:NO];
                if (scoringObject == self.series2SelectedObject) {
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
            }
            
            break;
            
        default:
            break;
    }

    return cell;
}
- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //get the scoring object based on the current select
    if (indexPath.section == 0) {
        //initialize a new scoring object - cannot corrupt the original data by indexing
        APCScoring *referenceScoring = [self.scoringObjects objectAtIndex:indexPath.row];
        [self updateSection:indexPath.section WithSelectedScoringObject:referenceScoring];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    //correlate for section 2 selection
    if (indexPath.section == 1) {
        APCScoring *correlatedScoring = [self.scoringObjects objectAtIndex:indexPath.row];
        [self updateSection:indexPath.section WithSelectedScoringObject:correlatedScoring];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];

}

- (void)updateSection:(NSUInteger)section WithSelectedScoringObject:(APCScoring *)selectedObject
{
    
    if (section == 0) {
        
        self.series1SelectedObject = selectedObject;
        if (selectedObject.quantityType) {
            //HK Data initializer
            self.scoring = [[APCScoring alloc]initWithHealthKitQuantityType:selectedObject.quantityType unit:selectedObject.unit numberOfDays:-7];
        }else{
            //Task type initializer
            self.scoring = [[APCScoring alloc]initWithTask:selectedObject.taskId numberOfDays:-7 valueKey:selectedObject.valueKey];
        }
        
        self.scoring.series1Name = selectedObject.caption;
        self.section0Selected = YES;
        
        if (self.series2SelectedObject) {
            [self.scoring correlateWithScoringObject:self.series2SelectedObject];
        }
        
    }else if (section == 1 && self.section0Selected){
        
        self.series2SelectedObject = selectedObject;
        self.scoring.series2Name = selectedObject.caption;
        [self.scoring correlateWithScoringObject:selectedObject];
        if ([self.delegate respondsToSelector:@selector(viewController:didChangeCorrelatedScoringDataSource:)]) {
            [self.delegate viewController:self didChangeCorrelatedScoringDataSource:self.scoring];
        }
    }
}

@end
