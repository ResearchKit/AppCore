//
//  APCDashboardViewController.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 11/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDashboardViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCConstants.h"
#import "APCConcentricProgressView.h"
#import "UIFont+APCAppearance.h"

@interface APCDashboardViewController ()<UIGestureRecognizerDelegate, APCConcentricProgressViewDataSource>

@property (nonatomic, strong) NSMutableArray *lineCharts;

@end

@implementation APCDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lineCharts = [NSMutableArray new];
    self.items = [NSMutableArray new];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
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
            graphCell.graphView.titleLabel.text = graphItem.caption;
            graphCell.graphView.subTitleLabel.text = graphItem.detailText;
            graphCell.graphView.tintColor = graphItem.tintColor;
            graphCell.graphView.panGestureRecognizer.delegate = self;
            graphCell.graphView.titleLabel.font = [UIFont appRegularFontWithSize:19.0f];
            graphCell.graphView.subTitleLabel.font = [UIFont appRegularFontWithSize:16.0f];
            
            graphCell.tintColor = graphItem.tintColor;
            graphCell.delegate = self;
            
            [self.lineCharts addObject:graphCell.graphView];
            
        } else if (graphItem.graphType == kAPCDashboardGraphTypePie) {
            
        } else if (graphItem.graphType == kAPCDashboardGraphTypeTimeline) {
            
        }
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardBadgesItem class]]) {
//        
//        APCTableViewDashboardBadgesItem *badgeItem = (APCTableViewDashboardBadgesItem *)dashboardItem;
        APCDashboardBadgesTableViewCell *badgeCell = (APCDashboardBadgesTableViewCell *)cell;
        
        badgeCell.concentricProgressView.datasource = self;
        
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardMessageItem class]]){
        
        APCTableViewDashboardMessageItem *messageItem = (APCTableViewDashboardMessageItem *)dashboardItem;
        APCDashboardMessageTableViewCell *messageCell = (APCDashboardMessageTableViewCell *)cell;
        
        messageCell.type = messageItem.messageType;
        messageCell.messageLabel.text = messageItem.detailText;
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
        headerView.contentView.backgroundColor = [UIColor appSecondaryColor4];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.bounds];
        headerLabel.font = [UIFont appLightFontWithSize:16.0f];
        headerLabel.textColor = [UIColor appSecondaryColor3];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = sectionItem.sectionTitle;
        [headerView addSubview:headerLabel];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    
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
        
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardBadgesItem class]]){
        
        height = 400.0f;
    } else if ([dashboardItem isKindOfClass:[APCTableViewDashboardMessageItem class]]){
        
        CGFloat basicCellHeight = 47.0f;
        CGFloat contentHeight = [dashboardItem.detailText boundingRectWithSize:CGSizeMake(284, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont appLightFontWithSize:16.0f]} context:nil].size.height;
        height = contentHeight + basicCellHeight;
        
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

#pragma mark - APCDashboardGraphTableViewCellDelegate methods

- (void)dashboardGraphViewCellDidTapExpandForCell:(APCDashboardLineGraphTableViewCell *)cell
{
    
}

#pragma mark - APCConcentricProgressViewDataSource methods

- (NSUInteger)numberOfComponentsInConcentricProgressView
{
    return 4;
}

- (CGFloat)concentricProgressView:(APCConcentricProgressView *)concentricProgressView valueForComponentAtIndex:(NSUInteger)index
{
    return (arc4random()%7 + 1)/10.0f;
}

- (UIColor *)concentricProgressView:(APCConcentricProgressView *)concentricProgressView colorForComponentAtIndex:(NSUInteger)index
{
    NSArray *colors = @[[UIColor appTertiaryBlueColor], [UIColor appTertiaryPurpleColor], [UIColor appTertiaryGreenColor], [UIColor appTertiaryYellowColor]];
    
    return colors[index];
}

@end
