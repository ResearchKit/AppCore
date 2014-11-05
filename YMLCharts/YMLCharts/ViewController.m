//
//  ViewController.m
//  YMLCharts
//
//  Created by Ramsundar Shandilya on 10/1/14.
//  Copyright (c) 2014 Ramsundar Shandilya. All rights reserved.
//

#import "ViewController.h"
#import "APCLineGraphView.h"

@interface ViewController () <APCLineChartViewDelegate, APCLineCharViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *topGraphView;
@property (weak, nonatomic) IBOutlet UIView *middleGraphView;
@property (weak, nonatomic) IBOutlet UIView *bottomGraphView;
@end

@implementation ViewController
{
//    APCLineGraphView *lineGraphView;
//    APCLineGraphView *lineGraphView2;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    lineGraphView = [[APCLineGraphView alloc] initWithFrame:self.topGraphView.frame];
//    lineGraphView.datasource = self;
//    lineGraphView.delegate = self;
//    [self.view addSubview:lineGraphView];
//    
//    [lineGraphView layoutSubviews];
//    
//    lineGraphView2 = [[APCLineGraphView alloc] initWithFrame:self.middleGraphView.frame];
//    lineGraphView2.datasource = self;
//    lineGraphView2.delegate = self;
//    [self.view addSubview:lineGraphView2];
//    
//    [lineGraphView2 layoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - APCLineCharViewDataSource

- (NSInteger)lineGraph:(APCLineGraphView *)graphView numberOfPointsInPlot:(NSInteger)plotIndex
{
    return 5;
}

- (NSInteger)numberOfPlotsInLineGraph:(APCLineGraphView *)graphView
{
    return 2;
}

- (CGFloat)lineGraph:(APCLineGraphView *)graphView plot:(NSInteger)plotIndex valueForPointAtIndex:(NSInteger)pointIndex
{
    CGFloat value;
    
    if (plotIndex == 0) {
        NSArray *values = @[@10.0, @16.0, @64.0, @56.0, @24.0];
        value = ((NSNumber *)values[pointIndex]).floatValue;
    } else {
        NSArray *values = @[@23.0, @46.0, @87.0, @12.0, @51.0];
        value = ((NSNumber *)values[pointIndex]).floatValue;
    }
    
    return value;
    
}

- (void)lineGraph:(APCLineGraphView *)graphView didTouchGraphWithXPosition:(CGFloat)xPosition
{
//    if (graphView == lineGraphView) {
//        [lineGraphView2 scrubReferenceLineForXPosition:xPosition];
//    }
}

- (CGFloat)minimumValueForLineGraph:(APCLineGraphView *)graphView
{
    return 0;
}

- (CGFloat)maximumValueForLineGraph:(APCLineGraphView *)graphView
{
    return 100;
}

- (NSString *)lineGraph:(APCLineGraphView *)graphView titleForXAxisAtIndex:(NSInteger)pointIndex
{
    return @"Sep";
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    
}

@end
