// 
//  APCDashboardViewController.m 
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
 
#import "APCDashboardViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCConstants.h"
#import "APCConcentricProgressView.h"
#import "UIFont+APCAppearance.h"
#import "APCAppDelegate.h"
#import "APCAppCore.h"

NSInteger const kNumberOfDaysToDisplay = 7;

static CGFloat const kAPCProgressViewCellHeight = 198.0f;
static CGFloat const kAPCLineGraphCellHeight = 225.0f;

@interface APCDashboardViewController ()<UIGestureRecognizerDelegate, APCConcentricProgressViewDataSource>

@property (nonatomic, strong) NSMutableArray *lineCharts;

@property (nonatomic, strong) APCPresentAnimator *presentAnimator;
@property (nonatomic, strong) APCFadeAnimator *fadeAnimator;

@end

@implementation APCDashboardViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        _dateFormatter = [NSDateFormatter new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lineCharts = [NSMutableArray new];
    self.items = [NSMutableArray new];
    
    _presentAnimator = [APCPresentAnimator new];
    _fadeAnimator = [APCFadeAnimator new];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpAppearance];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateVisibleRowsInTableView:)
                                                 name:APCScoringHealthKitDataIsAvailableNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateVisibleRowsInTableView:)
                                                 name:APCTaskResultsProcessedNotification
                                               object:nil];
  APCLogViewControllerAppeared();
}

-(void)setUpAppearance{
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:APCScoringHealthKitDataIsAvailableNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:APCTaskResultsProcessedNotification
                                                  object:nil];
    
    
    [super viewWillDisappear:animated];
}

- (void)updateVisibleRowsInTableView:(NSNotification *) __unused notification
{
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
}
//
#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *) __unused tableView
{
    return self.items.count;
}

- (NSInteger)tableView:(UITableView *) __unused tableView numberOfRowsInSection:(NSInteger)section
{
    APCTableViewSection *sectionItem = self.items[section];
    
    return sectionItem.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewItem *dashboardItem = [self itemForIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dashboardItem.identifier];

    if ([dashboardItem isKindOfClass:[APCTableViewDashboardProgressItem class]]) {
        
        APCTableViewDashboardProgressItem *progressItem = (APCTableViewDashboardProgressItem *)dashboardItem;
        APCDashboardProgressTableViewCell *progressCell = (APCDashboardProgressTableViewCell *)cell;
        
        progressCell.progressView.progress = progressItem.progress;
        progressCell.title = NSLocalizedString(@"Activity Completion", @"Activity Completion");
        [self.dateFormatter setDateFormat:@"MMMM d"];
        
        progressCell.subTitleLabel.text = [NSString stringWithFormat:@"%@, %@", NSLocalizedString(@"Today",@"Today"), [self.dateFormatter stringFromDate:[NSDate date]]];
        
        progressCell.delegate = self;
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardGraphItem class]]){
        
        APCTableViewDashboardGraphItem *graphItem = (APCTableViewDashboardGraphItem *)dashboardItem;
        APCDashboardGraphTableViewCell *graphCell = (APCDashboardGraphTableViewCell *)cell;
        APCBaseGraphView *graphView;
        
        if (graphItem.graphType == kAPCDashboardGraphTypeLine) {
            graphView = (APCLineGraphView *)graphCell.lineGraphView;
            graphCell.lineGraphView.datasource = graphItem.graphData;
            [graphCell.legendButton setAttributedTitle:graphItem.legend forState:UIControlStateNormal];
            graphCell.discreteGraphView.hidden = YES;
            graphCell.lineGraphView.hidden = NO;
            
        } else if (graphItem.graphType == kAPCDashboardGraphTypeDiscrete) {
            graphView = (APCDiscreteGraphView *)graphCell.discreteGraphView;
            graphCell.discreteGraphView.datasource = graphItem.graphData;
            [graphCell.legendButton setAttributedTitle:graphItem.legend forState:UIControlStateNormal];
            graphCell.lineGraphView.hidden = YES;
            graphCell.discreteGraphView.hidden = NO;
        }
        
        [graphCell.legendButton setUserInteractionEnabled:graphItem.legend ? YES : NO];
        
        graphView.delegate = self;
        graphView.tintColor = graphItem.tintColor;
        graphView.panGestureRecognizer.delegate = self;
        graphView.axisTitleFont = [UIFont appRegularFontWithSize:14.0f];
        
        graphView.maximumValueImage = graphItem.maximumImage;
        graphView.minimumValueImage = graphItem.minimumImage;
        
        graphCell.averageImageView.image = graphItem.averageImage;
        graphCell.title = graphItem.caption;
        graphCell.subTitleLabel.text = graphItem.detailText;
        
        graphCell.tintColor = graphItem.tintColor;
        graphCell.delegate = self;
        
        [graphView layoutSubviews];
        
        if (graphView != nil)
        {
            [self.lineCharts addObject:graphView];
        }
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardMessageItem class]]){
        
        APCTableViewDashboardMessageItem *messageItem = (APCTableViewDashboardMessageItem *)dashboardItem;
        APCDashboardMessageTableViewCell *messageCell = (APCDashboardMessageTableViewCell *)cell;
        
        messageCell.type = messageItem.messageType;
        messageCell.messageLabel.text = messageItem.detailText;
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardInsightsItem class]]){
        APCTableViewDashboardInsightsItem *insightHeader = (APCTableViewDashboardInsightsItem *)dashboardItem;
        APCDashboardInsightsTableViewCell *insightHeaderCell = (APCDashboardInsightsTableViewCell *)cell;
        
        insightHeaderCell.cellTitle = insightHeader.caption;
        insightHeaderCell.cellSubtitle = insightHeader.detailText;
        insightHeaderCell.tintColor = insightHeader.tintColor;
        insightHeaderCell.showTopSeparator = insightHeader.showTopSeparator;
        insightHeaderCell.delegate = self;
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardInsightItem class]]){
        APCTableViewDashboardInsightItem *insightItem = (APCTableViewDashboardInsightItem *)dashboardItem;
        APCDashboardInsightTableViewCell *insightCell = (APCDashboardInsightTableViewCell *)cell;
        
        insightCell.goodInsightCaption = insightItem.goodCaption;
        insightCell.badInsightCaption = insightItem.badCaption;
        insightCell.goodInsightBar = insightItem.goodBar;
        insightCell.badInsightBar = insightItem.badBar;
        insightCell.insightImage = insightItem.insightImage;
        insightCell.tintColor = insightItem.tintColor;
    
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardFoodInsightItem class]]){
        APCTableViewDashboardFoodInsightItem *foodInsightItem = (APCTableViewDashboardFoodInsightItem *)dashboardItem;
        APCDashboardFoodInsightTableViewCell *foodInsightCell = (APCDashboardFoodInsightTableViewCell *)cell;
        
        foodInsightCell.foodName = foodInsightItem.titleCaption;
        foodInsightCell.foodSubtitle = foodInsightItem.subtitleCaption;
        foodInsightCell.foodFrequency = foodInsightItem.frequency;
        foodInsightCell.insightImage = foodInsightItem.foodInsightImage;
        foodInsightCell.tintColor = foodInsightItem.tintColor;
        
    } else {
        cell.textLabel.text = dashboardItem.caption;
        cell.detailTextLabel.text = dashboardItem.detailText;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *) __unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    APCTableViewItem *dashboardItem = [self itemForIndexPath:indexPath];
    
    if ([dashboardItem isKindOfClass:[APCTableViewDashboardProgressItem class]]) {
        
        height = kAPCProgressViewCellHeight;
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardGraphItem class]]){
        
        height = kAPCLineGraphCellHeight;
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardMessageItem class]]){
        
        CGFloat basicCellHeight = 47.0f;
        CGFloat contentHeight = [dashboardItem.detailText boundingRectWithSize:CGSizeMake(284, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont appLightFontWithSize:16.0f]} context:nil].size.height;
        height = contentHeight + basicCellHeight;
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardInsightItem class]]){
        height = 90.0f;
    } else {
        height = 75.0f;
    }
    
    return height;
}

- (void)tableView:(UITableView *)__unused tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewItem *dashboardItem = [self itemForIndexPath:indexPath];
    
    if ([dashboardItem isKindOfClass:[APCTableViewDashboardGraphItem class]]){
        APCTableViewDashboardGraphItem *graphItem = (APCTableViewDashboardGraphItem *)dashboardItem;
        APCDashboardGraphTableViewCell *graphCell = (APCDashboardGraphTableViewCell *)cell;
        
        APCBaseGraphView *graphView;
        
        if (graphItem.graphType == kAPCDashboardGraphTypeLine) {
            graphView = (APCLineGraphView *)graphCell.lineGraphView;
            
        } else if (graphItem.graphType == kAPCDashboardGraphTypeDiscrete) {
            graphView = (APCDiscreteGraphView *)graphCell.discreteGraphView;
        }
        
        [graphView setNeedsLayout];
        [graphView layoutIfNeeded];
        [graphView refreshGraph];
}
}

#pragma mark - APCBaseGraphViewDelegate methods

- (void)graphViewTouchesBegan:(APCBaseGraphView *)graphView
{
    for (APCLineGraphView *currentGraph in self.lineCharts) {
        if (currentGraph != graphView) {
            [currentGraph setScrubberViewsHidden:NO animated:YES];
        }
    }
}

- (void)graphView:(APCBaseGraphView *)graphView touchesMovedToXPosition:(CGFloat)xPosition
{
    for (APCLineGraphView *currentGraph in self.lineCharts) {
        if (currentGraph != graphView) {
            [currentGraph scrubReferenceLineForXPosition:xPosition];
        }
    }
}

- (void)graphViewTouchesEnded:(APCBaseGraphView *)graphView
{
    for (APCLineGraphView *currentGraph in self.lineCharts) {
        if (currentGraph != graphView) {
            [currentGraph setScrubberViewsHidden:YES animated:YES];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {

    CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:gestureRecognizer.view.superview];
    BOOL retValue = fabs(translation.x) > fabs(translation.y);
    
    return retValue;
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id <UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController: (UIViewController *) presented
                                                                    presentingController: (UIViewController *) __unused presenting
                                                                        sourceController: (UIViewController *) __unused source
{
    id<UIViewControllerAnimatedTransitioning> animationController;
    
    if ([presented isKindOfClass:[APCGraphViewController class]]) {
        animationController = self.presentAnimator;
        self.presentAnimator.presenting = YES;
    } else if ([presented isKindOfClass:[APCDashboardMoreInfoViewController class]]){
        animationController = self.fadeAnimator;
        self.fadeAnimator.presenting = YES;
    }
    
    return animationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    id<UIViewControllerAnimatedTransitioning> animationController;
    
    if ([dismissed isKindOfClass:[APCGraphViewController class]]) {
        animationController = self.presentAnimator;
        self.presentAnimator.presenting = NO;
    } else if ([dismissed isKindOfClass:[APCDashboardMoreInfoViewController class]]){
        animationController = self.fadeAnimator;
        self.fadeAnimator.presenting = NO;
    }
    
    return animationController;
}

#pragma mark - APCDashboardTableViewCellDelegate methods

- (void)dashboardTableViewCellDidTapExpand:(APCDashboardTableViewCell *)cell
{
    if ([cell isKindOfClass:[APCDashboardGraphTableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        APCTableViewDashboardGraphItem *graphItem = (APCTableViewDashboardGraphItem *)[self itemForIndexPath:indexPath];
        
        CGRect initialFrame = [cell convertRect:cell.bounds toView:self.view.window];
        self.presentAnimator.initialFrame = initialFrame;
        
        APCGraphViewController *graphViewController = [[UIStoryboard storyboardWithName:@"APCDashboard" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCLineGraphViewController"];
        
        graphViewController.graphItem = graphItem;
        graphItem.graphData.scoringDelegate = graphViewController;
        [self.navigationController presentViewController:graphViewController animated:YES completion:nil];
    }
}

- (void)dashboardTableViewCellDidTapMoreInfo:(APCDashboardTableViewCell *)cell
{
    // Pop up implementation. Commented out for ActionSheet
     
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    APCTableViewDashboardItem *item = (APCTableViewDashboardItem *)[self itemForIndexPath:indexPath];
    
    APCDashboardMoreInfoViewController *moreInfoViewController = [[UIStoryboard storyboardWithName:@"APCDashboard" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCDashboardMoreInfoViewController"];
    moreInfoViewController.info = item.info;
    moreInfoViewController.titleString = item.caption;
    
    // Get the snapshot
    UIView *targetView = self.tabBarController.view;
    UIGraphicsBeginImageContextWithOptions(targetView.bounds.size, NO, targetView.window.screen.scale);
    [targetView drawViewHierarchyInRect:targetView.frame afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    moreInfoViewController.blurredImage = snapshotImage;
    
    //Present
    
    moreInfoViewController.transitioningDelegate = self;
    moreInfoViewController.modalPresentationStyle = UIModalPresentationCustom;
    [self.navigationController presentViewController:moreInfoViewController animated:YES completion:^{
        
    }];
}

#pragma mark - Public Methods

- (APCTableViewItem *)itemForIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSection *sectionItem = self.items[indexPath.section];
    APCTableViewRow *rowItem = sectionItem.rows[indexPath.row];
    
    APCTableViewItem *dashboardItem = rowItem.item;
    
    return dashboardItem;
}

- (APCTableViewItemType)itemTypeForIndexPath:(NSIndexPath *)indexPath
{
    APCTableViewSection *sectionItem = self.items[indexPath.section];
    APCTableViewRow *rowItem = sectionItem.rows[indexPath.row];
    
    APCTableViewItemType dashboardItemType = rowItem.itemType;
    
    return dashboardItemType;
}

#pragma mark - APCDashboardInsightsTableViewCell Delegate

- (void) dashboardInsightDidExpandForCell: (APCDashboardInsightsTableViewCell *) __unused cell
{
    
}

- (void)dashboardInsightDidAskForMoreInfoForCell:(APCDashboardInsightsTableViewCell *) __unused cell
{
    
}

@end
