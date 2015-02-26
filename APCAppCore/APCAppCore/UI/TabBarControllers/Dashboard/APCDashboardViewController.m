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
    self.view.backgroundColor = [UIColor whiteColor];
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
            
            graphCell.discreteGraphView.hidden = YES;
            graphCell.lineGraphView.hidden = NO;
            
        } else if (graphItem.graphType == kAPCDashboardGraphTypeDiscrete) {
            graphView = (APCDiscreteGraphView *)graphCell.discreteGraphView;
            graphCell.discreteGraphView.datasource = graphItem.graphData;
            
            graphCell.lineGraphView.hidden = YES;
            graphCell.discreteGraphView.hidden = NO;
        }
        
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
        
        [self.lineCharts addObject:graphView];
        
        [graphView refreshGraph];
        
        
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
    
    BOOL retVal = YES;
    
    if (![gestureRecognizer isEqual:self.tableView.panGestureRecognizer] && ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint translation = [panGesture translationInView:self.tableView];
        retVal = fabs(translation.x) > fabs(translation.y);
    }
    NSLog(@"%d", retVal);
    
    return retVal;
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

- (void)dashboardInsightDidAskForMoreInfoForCell:(APCDashboardInsightsTableViewCell *) __unused cell
{
    
}

@end
