//
//  OverViewController.m
//  Flow
//
//  Created by Karthik Keyan on 8/21/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "DashBoard.h"
#import "HKManager.h"
#import "ChartDataService.h"
#import "YMLLineChartView.h"
#import "YMLTimeLineChartView.h"
#import "DashBoardViewController.h"

static NSUInteger const kDashBoardCardMargin        = 10;

@interface DashBoardViewController () <YMLTimeLineChartViewDataSource, ChartDataServiceDelegate>

@property (nonatomic, readwrite) DashBoardCard cards;

@property (nonatomic, strong) ChartDataService *chartDataService;

@property (nonatomic, strong) UIScrollView *cardsScrollView;

@end

@implementation DashBoardViewController {
    YMLLineChartView *lineCharView;
}

- (void) loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[HKManager sharedManager] authorizeWithCompletion:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
        else {
//            NSDate *date = [NSDate date];
//            for (int i = 0; i < 3; i++) {
//                date = [date dateByAddingTimeInterval:(60 * 60) + i];
//                
//                int lowerBound = 70;
//                int upperBound = 90;
//                int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
//                
//                NSLog(@"%i", rndValue);
//                
//                [[HKManager sharedManager] storeHeartBeatsAtMinute:rndValue startDate:date endDate:date completion:^(NSError *err) {
//                    if (err) {
//                        NSLog(@"%@", err);
//                    }
//                }];
//            }
            
            [[HKManager sharedManager] heartBeatsCompletion:^(NSArray *result, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableArray *yAxis = [NSMutableArray array];
                    NSMutableArray *xAxis = [NSMutableArray array];
                    NSMutableArray *values = [NSMutableArray array];
                    
                    HKUnit *unit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
                    
                    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                    dateFormater.dateFormat = @"HH";
                    
                    for (HKQuantitySample *sample in result) {
                        CGFloat x = [[dateFormater stringFromDate:sample.startDate] integerValue];
                        CGFloat y = [[sample quantity] doubleValueForUnit:unit];
                        
                        [xAxis addObject:@(x)];
                        [yAxis addObject:@(y)];
                        [values addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                    }
                    
                    lineCharView.xUnits = xAxis;
                    lineCharView.yUnits = @[@(70), @(75), @(80), @(85), @(90)];
                    
                    lineCharView.values = values;
                    [lineCharView draw];
                });
            }];
        }
    }];
    
    
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
    
    lineCharView = [[YMLLineChartView alloc] initWithFrame:frame];
    lineCharView.layer.borderColor = [UIColor grayColor].CGColor;
    lineCharView.layer.borderWidth = 1.0;
    lineCharView.layer.cornerRadius = 5;
    lineCharView.layer.masksToBounds = YES;
    lineCharView.xUnits = @[@(8), @(9), @(10), @(11), @(12)];
    lineCharView.yUnits = @[@(70), @(75), @(80), @(85), @(90)];
    lineCharView.values = @[
                            [NSValue valueWithCGPoint:CGPointMake(8, 75)],
                            [NSValue valueWithCGPoint:CGPointMake(9, 85)],
                            [NSValue valueWithCGPoint:CGPointMake(10, 75)],
                            [NSValue valueWithCGPoint:CGPointMake(11, 90)],
                            [NSValue valueWithCGPoint:CGPointMake(12, 80)]
                            ];
    
    lineCharView.lineLayer.strokeColor = [UIColor redColor].CGColor;
    lineCharView.lineLayer.shadowOpacity = 0.5;
    lineCharView.lineLayer.shadowOffset = CGSizeMake(0, 1);
    lineCharView.lineLayer.shadowRadius = 2;
    lineCharView.lineLayer.lineWidth = 1.5;
    lineCharView.markerColor = [UIColor grayColor];
    lineCharView.markerRadius = 3;
    
    [self.cardsScrollView addSubview:lineCharView];
    
    [lineCharView draw];
    
    self.cardsScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.cardsScrollView.bounds), CGRectGetMaxY(lineCharView.frame));
}

- (void) addStepsCard {
    
}

- (void) addMedicationCard {
    CGRect frame = [self nextFrameForCard];
    frame.size.height = 150;
    
    YMLTimeLineChartView *timeLineChartView = [[YMLTimeLineChartView alloc] initWithFrame:frame orientation:YMLChartOrientationHorizontal];
    timeLineChartView.datasource = self;
    timeLineChartView.layer.borderColor = [UIColor grayColor].CGColor;
    timeLineChartView.layer.borderWidth = 1.0;
    timeLineChartView.layer.cornerRadius = 5;
    timeLineChartView.layer.masksToBounds = YES;
    [self.cardsScrollView addSubview:timeLineChartView];
    
    [timeLineChartView redrawCanvas];
    [timeLineChartView addBar:[YMLTimeLineChartBarLayer layer] fromUnit:10 toUnit:12 animation:YES];
    [timeLineChartView addBar:[YMLTimeLineChartBarLayer layer] fromUnit:9.5 toUnit:10.5 animation:YES];
    [timeLineChartView addBar:[YMLTimeLineChartBarLayer layer] fromUnit:8 toUnit:10 animation:YES];

    self.cardsScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.cardsScrollView.bounds), CGRectGetMaxY(timeLineChartView.frame));
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
