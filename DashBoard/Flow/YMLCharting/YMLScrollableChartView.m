//
//  YMLScrollableChartView.m
//  Avero
//
//  Created by Mark Pospesel on 12/28/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import "YMLScrollableChartView.h"
#import "YMLPlotView.h"
#import "YMLAxisView.h"

@interface YMLScrollableChartView()

@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation YMLScrollableChartView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self doInitYMLScrollableChartView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // Initialization code
        [self doInitYMLScrollableChartView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self doInitYMLScrollableChartView];
    }
    return self;
}

- (void)doInitYMLScrollableChartView
{
    _barInterval = CGSizeMake(20, 20);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    [self insertSubview:scrollView belowSubview:self.labelContainerView];
    _scrollView = scrollView;
    
    [self.scrollView addSubview:self.labelContainerView];
}

- (CGRect)plotFrameLayout:(CGRect)proposedPlotFrame
{
    self.scrollView.frame = proposedPlotFrame;
    CGSize plotSize = proposedPlotFrame.size;
    BOOL hasBars = NO;
    
    for (YMLPlotView *plot in self.plots)
    {
        BOOL isHorizontal = plot.orientation == YMLChartOrientationHorizontal;
        NSUInteger barCount = [plot.values count];
        
        if (isHorizontal)
        {
            CGFloat height = (plot.topMargin + plot.bottomMargin) + (self.barInterval.height * barCount);
            if (height > plotSize.height)
                plotSize.height = height;
        }
        else
        {
            CGFloat width = (plot.leftMargin + plot.rightMargin) + (self.barInterval.width * barCount);
            if (width > plotSize.width)
                plotSize.width = width;
        }
        
        if (barCount > 0)
            hasBars = YES;
    }
    
    if (hasBars)
        self.scrollView.contentSize = plotSize;
    
    // we return a rect offset to {0,0} because plots will be subviews of a scrollview
    return (CGRect){CGPointZero, plotSize};
}

- (void)insertAxis:(YMLAxisView *)axisView
{
    [self addSubview:axisView];
}

- (void)insertPlot:(YMLPlotView *)plot
{
    [self.scrollView insertSubview:plot belowSubview:self.labelContainerView];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.supportsToolTips)
    {
        if ([super gestureRecognizerShouldBegin:gestureRecognizer])
        {
            self.scrollView.scrollEnabled = NO;
            return YES;
        }
        else
        {
            self.scrollView.scrollEnabled = YES;
            [self removeToolTip];
            return NO;
        }
    }
    
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (void)removeToolTip
{
    [super removeToolTip];

    // enable the scroll
    self.scrollView.scrollEnabled = YES;
}

- (BOOL)updateToolTip:(id)recognizer
{
    if (!self.scrollView.isScrollEnabled)
    {
        if ([super updateToolTip:recognizer])
        {
            // Calculate the boundaries of the tool tip
            CGFloat toolTipX = CGRectGetMinX(self.toolTip.frame);
            CGFloat toolTipY = CGRectGetMinY(self.toolTip.frame);
            toolTipX =(toolTipX<CGRectGetMinX(self.scrollView.frame))?CGRectGetMinX(self.scrollView.frame):toolTipX;
            toolTipY =(toolTipY<CGRectGetMinY(self.scrollView.frame))?CGRectGetMinY(self.scrollView.frame):toolTipY;
            
            //overlap with title text
            self.toolTip.frame = CGRectMake(toolTipX, toolTipY, self.toolTip.frame.size.width, self.toolTip.frame.size.height);
        }
        return YES;
    }
    else
        return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
