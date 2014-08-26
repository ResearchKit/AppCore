//
//  OverViewController.m
//  Flow
//
//  Created by Karthik Keyan on 8/21/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "DashBoard.h"
#import "YMLAxisView.h"
#import "YMLChartView.h"
#import "YMLLinePlotView.h"
#import "ChartDataService.h"
#import "YMLTimeLineChartView.h"
#import "DashBoardViewController.h"

static NSUInteger const kDashBoardCardMargin        = 10;

@interface DashBoardViewController () <YMLTimeLineChartViewDataSource, ChartDataServiceDelegate>

@property (nonatomic, readwrite) DashBoardCard cards;

@property (nonatomic, strong) ChartDataService *chartDataService;

@property (nonatomic, strong) UIScrollView *cardsScrollView;

@end

@implementation DashBoardViewController

- (void) loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.cards = [[DashBoard new] availableCards];
    
    self.chartDataService = [ChartDataService new];
    self.chartDataService.delegate = self;
    [self.chartDataService subscribeToServiceType:ChartDataServiceTypeHeartRate];
    
    [self addScrollView];
    [self addCards];
}

- (void) addScrollView {
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.frame = self.view.frame;
    [self.view addSubview:scrollView];
    
    self.cardsScrollView = scrollView;
}

- (void) addCards {
    if (self.cards & DashBoardCardToday) {
        [self addTodayCard];
    }
    
    if (self.cards & DashBoardCardWeeklyProgress) {
        [self addWeeklyProgressCard];
    }
    
    if (self.cards & DashBoardCardAlert) {
        [self addAlertCard];
    }
    
    if (self.cards & DashBoardCardActivity) {
        [self addActivityCard];
    }
    
    if (self.cards & DashBoardCardSteps) {
        [self addStepsCard];
    }

    if (self.cards & DashBoardCardMedication) {
        [self addMedicationCard];
    }

    if (self.cards & DashBoardCardMyJournal) {
        [self addMyJournalCard];
    }
    
    if (self.cards & DashBoardCardComparisionOverview) {
        [self addComparisionOverviewCard];
    }
    
    if (self.cards & DashBoardCardHealthOverview) {
        [self addHealthOverviewCard];
    }
    
    self.cardsScrollView.contentSize = CGSizeMake(self.cardsScrollView.contentSize.width, self.cardsScrollView.contentSize.height + kDashBoardCardMargin);
}

- (CGRect) nextFrameForCard {
    return CGRectMake(kDashBoardCardMargin, self.cardsScrollView.contentSize.height + kDashBoardCardMargin, CGRectGetWidth(self.cardsScrollView.bounds) - (2 * kDashBoardCardMargin), 0);
}

- (void) addTodayCard {
    CGRect frame = [self nextFrameForCard];
    frame.origin.y += 20;
    frame.size.height = 100;
    
    NSString *string = @"Today's Activities, Week 1\n2 New Tasks, 1 Survey";
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 20;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16], NSParagraphStyleAttributeName : paragraphStyle} range:[string rangeOfString:@"Today's Activities, Week 1"]];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} range:[string rangeOfString:@"2 New Tasks, 1 Survey"]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor grayColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.attributedText = attributedString;
    [self.cardsScrollView addSubview:label];
    
    self.cardsScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.cardsScrollView.bounds), CGRectGetMaxY(label.frame));
}

- (void) addWeeklyProgressCard {
    
}

- (void) addAlertCard {
    
}

- (void) addActivityCard {
    CGRect frame = [self nextFrameForCard];
    frame.size.height = 150;
    
    YMLChartView *chartView = [[YMLChartView alloc] initWithFrame:frame];
    chartView.layer.borderColor = [UIColor grayColor].CGColor;
    chartView.layer.borderWidth = 1.0;
    chartView.layer.cornerRadius = 5;
    
    // X AXIS
    {
        YMLAxisView *coversAxis = [[YMLAxisView alloc ] initWithPosition:YMLAxisPositionBottom];
        coversAxis.size = CGSizeMake(CGRectGetWidth(chartView.frame), 20);
        coversAxis.font = [UIFont systemFontOfSize:10];
        coversAxis.textColor = [UIColor blackColor];
        coversAxis.minimumInterItemSpacing = 0;
        coversAxis.values = @[@"August 8", @"9", @"10", @"11"];
        [chartView addAxisView:coversAxis toPosition:YMLAxisPositionBottom];
    }
    
    // Y AXIS
    {
        YMLAxisView *coversAxis = [[YMLAxisView alloc ] initWithPosition:YMLAxisPositionLeft];
        coversAxis.size = CGSizeMake(20, CGRectGetHeight(chartView.frame));
        coversAxis.font = [UIFont systemFontOfSize:10];
        coversAxis.textColor = [UIColor blackColor];
        coversAxis.minimumInterItemSpacing = 0;
        coversAxis.values = @[@"10", @"50", @"30", @"40"];
        
        [chartView addAxisView:coversAxis toPosition:YMLAxisPositionLeft];
    }
    
    // line Plot 1
    {
        YMLLinePlotView *trendLinePlot = [[YMLLinePlotView alloc] initWithOrientation:YMLChartOrientationVertical];
        trendLinePlot.leftMargin = 10;
        trendLinePlot.topMargin = 10;
        trendLinePlot.rightMargin = 10;
        trendLinePlot.bottomMargin = 0;
        trendLinePlot.backgroundColor = [UIColor clearColor];
        trendLinePlot.pointColor = [UIColor blueColor];
        trendLinePlot.lineColor = [UIColor blueColor];
        trendLinePlot.pointSize = CGSizeMake(8, 8);
        trendLinePlot.lineWidth = 1;
        trendLinePlot.symbol = YMLPointSymbolCircle;
        trendLinePlot.values = @[@(10), @(5), @(10), @(5)];
        [chartView addPlot:trendLinePlot withScaleAxis:YMLAxisPositionLeft titleAxis:YMLAxisPositionBottom];
    }
    
    
    [self.cardsScrollView addSubview:chartView];
    
    self.cardsScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.cardsScrollView.bounds), CGRectGetMaxY(chartView.frame));
}

- (void) addStepsCard {
    
}

- (void) addMedicationCard {
    CGRect frame = [self nextFrameForCard];
    frame.size.height = 150;
    
    YMLTimeLineChartView *chartView = [[YMLTimeLineChartView alloc] initWithFrame:frame orientation:YMLChartOrientationHorizontal];
    chartView.datasource = self;
    chartView.layer.borderColor = [UIColor grayColor].CGColor;
    chartView.layer.borderWidth = 1.0;
    chartView.layer.cornerRadius = 5;
    chartView.layer.masksToBounds = YES;
    [self.cardsScrollView addSubview:chartView];
    
    [chartView redrawCanvas];
    [chartView addBar:[YMLTimeLineChartBarLayer layer] fromUnit:10 toUnit:12 animation:YES];
    [chartView addBar:[YMLTimeLineChartBarLayer layer] fromUnit:9.5 toUnit:10.5 animation:YES];
    [chartView addBar:[YMLTimeLineChartBarLayer layer] fromUnit:8 toUnit:10 animation:YES];

    self.cardsScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.cardsScrollView.bounds), CGRectGetMaxY(chartView.frame));
}

- (void) addMyJournalCard {
    
}

- (void) addComparisionOverviewCard {
    
}

- (void) addHealthOverviewCard {
    
}


#pragma mark - CharDataServiceDelegate

- (void) chartDataService:(ChartDataService *)service didReceiveNewValues:(NSEnumerator *)enumerator forServiceType:(ChartDataServiceType)serviceType {
    if (serviceType == ChartDataServiceTypeHeartRate) {
        
    }
}


#pragma mark - YMLTimeLineChartViewDataSource

- (NSArray *) timeLineChartViewUnits:(YMLTimeLineChartView *)chartView {
    return @[@(8), @(9), @(10), @(11), @(12)];
}

- (NSString *) timeLineChartView:(YMLTimeLineChartView *)chartView titleAtIndex:(NSInteger)index {
    NSArray *titles = @[@"August 8", @"9", @"10", @"11", @"12"];
    
    NSString *title;
    if (index < titles.count) {
        title = titles[index];
    }
    
    return title;
}


@end
