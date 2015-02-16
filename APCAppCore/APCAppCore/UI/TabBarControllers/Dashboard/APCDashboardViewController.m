// 
//  APCDashboardViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCDashboardViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCConstants.h"
#import "APCConcentricProgressView.h"
#import "UIFont+APCAppearance.h"
#import "APCAppDelegate.h"
#import "APCAppCore.h"

@interface APCDashboardViewController ()<UIGestureRecognizerDelegate, APCConcentricProgressViewDataSource>

@property (nonatomic, strong) NSMutableArray *lineCharts;

@property (nonatomic, strong) APCPresentAnimator *presentAnimator;
@property (nonatomic, strong) APCFadeAnimator *fadeAnimator;

@end

@implementation APCDashboardViewController

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
  APCLogViewControllerAppeared();
}

-(void)setUpAppearance{
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:APCScoringHealthKitDataIsAvailableNotification
                                                  object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)updateVisibleRowsInTableView:(NSNotification *) __unused notification
{
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
}

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
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardGraphItem class]]){
        
        APCTableViewDashboardGraphItem *graphItem = (APCTableViewDashboardGraphItem *)dashboardItem;
        APCDashboardLineGraphTableViewCell *graphCell = (APCDashboardLineGraphTableViewCell *)cell;
        
        if (graphItem.graphType == kAPCDashboardGraphTypeLine) {
            
            graphCell.graphView.datasource = graphItem.graphData;
            graphCell.graphView.delegate = self;
            graphCell.title = graphItem.caption;
            graphCell.subTitleLabel.text = graphItem.detailText;
            graphCell.graphView.tintColor = graphItem.tintColor;
            graphCell.graphView.panGestureRecognizer.delegate = self;
            graphCell.graphView.axisTitleFont = [UIFont appRegularFontWithSize:14.0f];
            
            graphCell.graphView.maximumValueImage = graphItem.maximumImage;
            graphCell.graphView.minimumValueImage = graphItem.minimumImage;
            graphCell.averageImageView.image = graphItem.averageImage;
            
            graphCell.tintColor = graphItem.tintColor;
            graphCell.delegate = self;
            [graphCell.graphView layoutSubviews];
            [self.lineCharts addObject:graphCell.graphView];
            
            [graphCell.graphView refreshGraph];
            
        } else if (graphItem.graphType == kAPCDashboardGraphTypePie) {
            
        } else if (graphItem.graphType == kAPCDashboardGraphTypeTimeline) {
            
        }
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardMessageItem class]]){
        
        APCTableViewDashboardMessageItem *messageItem = (APCTableViewDashboardMessageItem *)dashboardItem;
        APCDashboardMessageTableViewCell *messageCell = (APCDashboardMessageTableViewCell *)cell;
        
        messageCell.type = messageItem.messageType;
        messageCell.messageLabel.text = messageItem.detailText;
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardInsightsItem class]]){
        APCTableViewDashboardInsightsItem *insightHeader = (APCTableViewDashboardInsightsItem *)dashboardItem;
        APCDashboardInsightsTableViewCell *insightsHeaderCell = (APCDashboardInsightsTableViewCell *)cell;
        
        insightsHeaderCell.cellTitle = insightHeader.caption;
        insightsHeaderCell.cellSubtitle = insightHeader.detailText;
        insightsHeaderCell.tintColor = insightHeader.tintColor;
        insightsHeaderCell.delegate = self;
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardInsightItem class]]){
        APCTableViewDashboardInsightItem *insightItem = (APCTableViewDashboardInsightItem *)dashboardItem;
        APCDashboardInsightTableViewCell *insightCell = (APCDashboardInsightTableViewCell *)cell;
        
        insightCell.goodInsightCaption = insightItem.goodCaption;
        insightCell.badInsightCaption = insightItem.badCaption;
        insightCell.goodInsightBar = insightItem.goodBar;
        insightCell.badInsightBar = insightItem.badBar;
        insightCell.insightImage = insightItem.insightImage;
    
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardFoodInsightItem class]]){
        APCTableViewDashboardFoodInsightItem *foodInsightItem = (APCTableViewDashboardFoodInsightItem *)dashboardItem;
        APCDashboardFoodInsightTableViewCell *foodInsightCell = (APCDashboardFoodInsightTableViewCell *)cell;
        
        foodInsightCell.foodName = foodInsightItem.titleCaption;
        foodInsightCell.foodSubtitle = foodInsightItem.subtitleCaption;
        foodInsightCell.foodFrequency = foodInsightItem.frequency;
        foodInsightCell.insightImage = foodInsightItem.foodInsightImage;
        
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView;
    
    APCTableViewSection *sectionItem = self.items[section];
    
    if (sectionItem.sectionTitle.length > 0) {
        
        headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), tableView.sectionHeaderHeight)];
        headerView.contentView.backgroundColor = [UIColor whiteColor];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
        headerLabel.font = [UIFont appLightFontWithSize:16.0f];
        headerLabel.textColor = [UIColor appSecondaryColor1];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = sectionItem.sectionTitle;
        [headerView addSubview:headerLabel];
        [headerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *) __unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    APCTableViewItem *dashboardItem = [self itemForIndexPath:indexPath];
    
    if ([dashboardItem isKindOfClass:[APCTableViewDashboardProgressItem class]]) {
        
        height = 163.0f;
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardGraphItem class]]){
        
        APCTableViewDashboardGraphItem *graphItem = (APCTableViewDashboardGraphItem *)dashboardItem;
        
        if (graphItem.graphType == kAPCDashboardGraphTypeLine) {
            height = 204.0f;
            
        } else if (graphItem.graphType == kAPCDashboardGraphTypePie) {
            height = 204.0f;
            
        } else if (graphItem.graphType == kAPCDashboardGraphTypeTimeline) {
            height = 204.0f;
            
        }
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardMessageItem class]]){
        
        CGFloat basicCellHeight = 47.0f;
        CGFloat contentHeight = [dashboardItem.detailText boundingRectWithSize:CGSizeMake(284, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont appLightFontWithSize:16.0f]} context:nil].size.height;
        height = contentHeight + basicCellHeight;
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardInsightItem class]]){
        height = 90.0f;
    } else {
        height = 65.0f;
    }
    
    return height;
}

#pragma mark - APCLineGraphViewDelegate methods

- (void)lineGraphTouchesBegan:(APCLineGraphView *)graphView
{
    for (APCLineGraphView *lineGraph in self.lineCharts) {
        if (lineGraph != graphView) {
            [lineGraph setScrubberViewsHidden:NO animated:YES];
        }
    }
}

- (void)lineGraph:(APCLineGraphView *)graphView touchesMovedToXPosition:(CGFloat)xPosition
{
    for (APCLineGraphView *lineGraph in self.lineCharts) {
        if (lineGraph != graphView) {
            [lineGraph scrubReferenceLineForXPosition:xPosition];
        }
    }
}

- (void)lineGraphTouchesEnded:(APCLineGraphView *)graphView
{
    for (APCLineGraphView *lineGraph in self.lineCharts) {
        if (lineGraph != graphView) {
            [lineGraph setScrubberViewsHidden:YES animated:YES];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (![gestureRecognizer isEqual:self.tableView.panGestureRecognizer] && ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint translation = [panGesture velocityInView:self.tableView];
        return fabs(translation.x) > fabs(translation.y);
    }
    return YES;
}

#pragma mark - UIViewControllerTransitioningDelegate methods

- (id <UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController: (UIViewController *) presented
                                                                    presentingController: (UIViewController *) __unused presenting
                                                                        sourceController: (UIViewController *) __unused source
{
    id<UIViewControllerAnimatedTransitioning> animationController;
    
    if ([presented isKindOfClass:[APCLineGraphViewController class]]) {
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
    
    if ([dismissed isKindOfClass:[APCLineGraphViewController class]]) {
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
    if ([cell isKindOfClass:[APCDashboardLineGraphTableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        APCTableViewDashboardGraphItem *graphItem = (APCTableViewDashboardGraphItem *)[self itemForIndexPath:indexPath];
        
        CGRect initialFrame = [cell convertRect:cell.bounds toView:self.view.window];
        self.presentAnimator.initialFrame = initialFrame;
        
        APCLineGraphViewController *graphViewController = [[UIStoryboard storyboardWithName:@"APCDashboard" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCLineGraphViewController"];
        graphViewController.graphItem = graphItem;
        [self.navigationController presentViewController:graphViewController animated:YES completion:nil];
    }
}

- (void)dashboardTableViewCellDidTapMoreInfo:(APCDashboardTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    APCTableViewDashboardItem *item = (APCTableViewDashboardItem *)[self itemForIndexPath:indexPath];
    
    APCDashboardMoreInfoViewController *moreInfoViewController = [[UIStoryboard storyboardWithName:@"APCDashboard" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCDashboardMoreInfoViewController"];
    moreInfoViewController.info = item.info;
    moreInfoViewController.titleString = item.caption;
    
    //Blur
    UIImage *blurredImage = [self.tabBarController.view blurredSnapshotDark];
    moreInfoViewController.blurredImage = blurredImage;
    
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

@end
