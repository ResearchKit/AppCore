//
//  YMLChartView.m
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/19/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import "YMLChartView.h"
#import "YMLAxisView.h"
#import "YMLPlotView.h"
#import "Enumerations.h"
#import "NSArray+Helpers.h"

#import <QuartzCore/QuartzCore.h>

NSString * const kYMLChartToolTipWillAppear = @"com.yml.charting.toolTipWillAppear";
NSString * const kYMLChartToolTipDidAppear = @"com.yml.charting.toolTipDidAppear";

#define SWIPE_THRESHOLD 150

@interface YMLChartView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableDictionary *axes;
@property (nonatomic, strong) NSMutableArray *mutablePlots;
@property (nonatomic, assign) CGRect plotFrame;
@property (nonatomic, strong) UIView *labelContainerView;
@property (nonatomic, assign, getter = isPanning) BOOL panning;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation YMLChartView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self doInitYMLChartView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // Initialization code
        [self doInitYMLChartView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self doInitYMLChartView];
    }
    return self;
}

- (void)doInitYMLChartView
{
    _axes = [NSMutableDictionary dictionary];
    _mutablePlots = [NSMutableArray array];
    _supportsToolTips = YES;
    _showToolTipOnTouchDown = YES;

    _inHorizontalScrollView = NO;
    _inVerticalScrollView = NO;
    _labelContainerView = [[UIView alloc] initWithFrame:self.frame];
    _labelContainerView.backgroundColor = [UIColor clearColor];
    _labelContainerView.userInteractionEnabled = NO;
    [self addSubview:_labelContainerView];
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGesture.delegate = self;
    if (self.supportsToolTips)
        [self addGestureRecognizer:self.panGesture];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.tapGesture.delegate = self;
    if (self.supportsSelection)
        [self addGestureRecognizer:self.tapGesture];
    
    _noDataLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _noDataLabel.backgroundColor = [UIColor clearColor];
    _noDataLabel.textColor = [UIColor colorWithWhite:0.45 alpha:1];
    _noDataLabel.shadowColor = [UIColor whiteColor];
    _noDataLabel.shadowOffset = CGSizeMake(0,1);
    _noDataLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    _noDataLabel.text = @"No Data";
    _noDataLabel.hidden = YES;
    _noDataLabel.textAlignment = NSTextAlignmentCenter;
    _noDataLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_noDataLabel];
    
    //self.clipsToBounds = YES;
}

- (void)dealloc
{
    // zero out weak reference to self
    for (YMLPlotView *plot in self.mutablePlots)
    {
        [plot addedToChart:nil];
    }
    [self.mutablePlots removeAllObjects];
    _mutablePlots = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setBackgroundView:(UIView *)backgroundView
{
    if (backgroundView == _backgroundView)
        return;
    
    [_backgroundView removeFromSuperview];
    _backgroundView = backgroundView;
    if (backgroundView)
    {
        backgroundView.frame = self.bounds;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self insertSubview:backgroundView atIndex:0];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    __block CGRect plotFrame = self.bounds;
    
    [self.axes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        YMLAxisPosition position = (YMLAxisPosition)[key integerValue];
        NSArray *axes = nil;
        if ([obj isKindOfClass:[NSArray class]])
            axes = obj;
        else
            axes = [NSArray arrayWithObject:obj];
        
        for (YMLAxisView *axis in axes)
        {
            switch (position) {
                case YMLAxisPositionLeft:
                    axis.frame = CGRectMake(plotFrame.origin.x, 0, axis.size.width, self.bounds.size.height);
                    plotFrame.origin.x += axis.size.width;
                    plotFrame.size.width -= axis.size.width;
                    break;
                    
                case YMLAxisPositionTop:
                    axis.frame = CGRectMake(0, plotFrame.origin.y, self.bounds.size.width, axis.size.height);
                    plotFrame.origin.y += axis.size.height;
                    plotFrame.size.height -= axis.size.height;
                    break;
                    
                case YMLAxisPositionRight:
                    axis.frame = CGRectMake(CGRectGetMaxX(plotFrame) - axis.size.width, 0, axis.size.width, self.bounds.size.height);
                    plotFrame.size.width -= axis.size.width;
                    break;
                    
                case YMLAxisPositionBottom:
                    axis.frame = CGRectMake(0, CGRectGetMaxY(plotFrame) - axis.size.height, self.bounds.size.width, axis.size.height);
                    plotFrame.size.height -= axis.size.height;
                    break;
                    
                default:
                    break;
            }
        }
    }];
    
    self.plotFrame = [self plotFrameLayout:plotFrame];
    [self.labelContainerView setFrame:self.plotFrame];
    for (YMLPlotView *plot in self.mutablePlots)
    {
        plot.frame = self.plotFrame;
    }
}

- (CGRect)plotFrameLayout:(CGRect)proposedPlotFrame
{
    return proposedPlotFrame;
}

- (void)setSupportsToolTips:(BOOL)supportsToolTips
{
    if (self.supportsToolTips == supportsToolTips)
        return;
    
    _supportsToolTips = supportsToolTips;
    if (supportsToolTips)
    {
        [self addGestureRecognizer:self.panGesture];
    }
    else
    {
        [self removeGestureRecognizer:self.panGesture];
    }
}

- (void)setSupportsSelection:(BOOL)supportsSelection
{
    if (self.supportsSelection == supportsSelection)
        return;
    
    _supportsSelection = supportsSelection;
    if (supportsSelection)
    {
        [self addGestureRecognizer:self.tapGesture];
    }
    else
    {
        [self removeGestureRecognizer:self.tapGesture];
    }
}

- (void)setAxisFormatter:(id<YMLAxisFormatter>)axisFormatter forPosition:(YMLAxisPosition)position
{
    [[self axisViewForPosition:position forceCreate:YES] setFormatter:axisFormatter];
}

- (YMLAxisView *)axisViewForPosition:(YMLAxisPosition)position
{
    return [self axisViewForPosition:position forceCreate:NO];
}

- (YMLAxisView *)axisViewForPosition:(YMLAxisPosition)position atIndex:(NSUInteger)index
{
    if (index == 0)
        return [self axisViewForPosition:position];
    
    return [[self axisViewsForPosition:position] safeObjectAtIndex:index];
}

- (void)addAxisView:(YMLAxisView *)axisView toPosition:(YMLAxisPosition)position
{
    axisView.backgroundColor = [UIColor clearColor];
    [self insertAxis:axisView];

    id axes = self.axes[@(position)];
    if (!axes)
    {
        // first value, set to dictionary
        self.axes[@(position)] = axisView;
        return;
    }
    
    if ([axes isKindOfClass:[NSArray class]])
    {
        // 3rd (or more) value, add to existing array
        [axes addObject:axisView];
    }
    else
    {
        // 2nd value, switch to an array
        NSArray *array = [NSArray arrayWithObjects:axes, axisView, nil];
        self.axes[@(position)] = array;
    }
}

- (void)insertAxis:(YMLAxisView *)axisView
{
    [self insertSubview:axisView belowSubview:self.labelContainerView];    
}

- (void)addPlot:(YMLPlotView *)plot withScaleAxis:(YMLAxisPosition)scalePosition titleAxis:(YMLAxisPosition)titlePosition
{
    if (scalePosition != YMLAxisPositionNone)
    {
        [self axisViewForPosition:scalePosition forceCreate:YES];
    }
    if (titlePosition != YMLAxisPositionNone)
    {
        [self axisViewForPosition:titlePosition forceCreate:YES];
    }
    
    plot.scalePosition = scalePosition;
    plot.titlePosition = titlePosition;
    [plot addedToChart:self];
    [self insertPlot:plot];
    [self.mutablePlots addObject:plot];
}

- (void)insertPlot:(YMLPlotView *)plot
{
    [self insertSubview:plot belowSubview:self.labelContainerView];
}

- (NSArray *)plots
{
    return self.mutablePlots;
}

#pragma mark - Private Instance Methods

- (YMLAxisView *)axisViewForPosition:(YMLAxisPosition)position forceCreate:(BOOL)forceCreate
{
    id axes = self.axes[@(position)];
    if (!axes && forceCreate)
    {
        YMLAxisView *axis = [[YMLAxisView alloc] initWithPosition:position];
        axis.backgroundColor = [UIColor clearColor];//colorWithWhite:0.65 alpha:1]; // TODO: property to set the color
        [self insertAxis:axis];
        
        self.axes[@(position)] = axis; // cache it
        
        return axis;
    }
    
    if ([axes isKindOfClass:[NSArray class]])
        return [axes firstObjectOrNil];
    else
        return axes;
}

- (NSArray *)axisViewsForPosition:(YMLAxisPosition)position
{
    id axes = self.axes[@(position)];
    if (!axes)
        return nil;
    
    if ([axes isKindOfClass:[NSArray class]])
        return axes;
    else 
        return [NSArray arrayWithObject:axes];
}

#pragma mark - Touch Gestures

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = [recognizer state];
    
	if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
	{
		// create and show tip
       [self updateToolTip:recognizer];
       [self setPanning:YES];
	}
	else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
	{
		// cleanup tip
		[self removeToolTip];
		[self setPanning:NO];
	}
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    if ([recognizer state] != UIGestureRecognizerStateEnded)
        return;
    
    for (YMLPlotView *plot in self.mutablePlots)
    {
        NSIndexPath *potentialPath = [plot featureIndexForPoint:[recognizer locationInView:plot]];
        if (potentialPath)
        {
            [plot selectItemAtIndexPath:potentialPath notify:YES];
            break;
        }
    };
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// show the ToolTip on touch down
    // only if it is a single touch
    if (self.supportsToolTips && self.showToolTipOnTouchDown && event.allTouches.count == 1)
    {
        [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            if ([self updateToolTip:obj])
            {
                *stop = YES;
            }
        }];
    }
	
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	// cleanup ToolTip if we're not panning
	if (![self isPanning])
		[self removeToolTip];
	
	[super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// cleanup ToolTip if we're not panning
	if (![self isPanning])
		[self removeToolTip];
	
	[super touchesEnded:touches withEvent:event];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer != self.panGesture)
        return YES;
    
    if (!self.supportsToolTips)
        return NO;
    
	// if we have a significant vertical velocity (up or down), assume user is trying to pan the
	// scroll view, and don't recognize the pan on this chart
	CGPoint velocity = [self.panGesture velocityInView:self];
    return (!self.isInHorizontalScrollView || fabsf(velocity.x) < SWIPE_THRESHOLD) && (!self.isInVerticalScrollView || fabsf(velocity.y) < SWIPE_THRESHOLD);
}

#pragma mark - Value labels

- (void)showNoDataLabel:(BOOL)show
{
    [self showNoDataLabel:show animated:NO];
}

- (void)showNoDataLabel:(BOOL)show animated:(BOOL)animated
{
    if (!animated)
    {
        self.noDataLabel.hidden = !show;
        self.noDataLabel.alpha = 1;
        return;
    }
    
    if (self.noDataLabel.hidden)
    {
        self.noDataLabel.alpha = 0;
        self.noDataLabel.hidden = NO;
    }
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

        self.noDataLabel.alpha = show? 1 : 0;
    
    } completion:^(BOOL finished) {
        
        self.noDataLabel.hidden = !show;
    
    }];
}

- (UIFont *)noDataFont
{
    return self.noDataLabel.font;
}

- (void)setNoDataFont:(UIFont *)noDataFont
{
    [self.noDataLabel setFont:noDataFont];
}

- (UIColor *)noDataTextColor
{
    return self.noDataLabel.textColor;
}

- (void)setNoDataTextColor:(UIColor *)noDataTextColor
{
    [self.noDataLabel setTextColor:noDataTextColor];
}

- (UIColor *)noDataShadowColor
{
    return self.noDataLabel.shadowColor;
}

- (void)setNoDataShadowColor:(UIColor *)noDataShadowColor
{
    [self.noDataLabel setShadowColor:noDataShadowColor];
}

- (CGSize)noDataShadowOffset
{
    return self.noDataLabel.shadowOffset;
}

- (void)setNoDataShadowOffset:(CGSize)noDataShadowOffset
{
    [self.noDataLabel setShadowOffset:noDataShadowOffset];
}

#pragma mark - Tooltip methods

- (BOOL)isTouchOverFeature:(id)recognizer
{
    __block BOOL overFeature = NO;
    [self.mutablePlots enumerateObjectsUsingBlock:^(YMLPlotView *plot, NSUInteger idx, BOOL *stop) {
        if ([plot isPointOverFeature:[recognizer locationInView:plot]])
        {
            *stop = YES;
            overFeature = YES;
        }
    }];
    
    return overFeature;
}

- (UIView *)makeToolTip
{
	if (!self.toolTip)
	{
        for (YMLPlotView *plot in self.mutablePlots)
        {
            UIView *plotToolTip = [plot toolTipView];
            if (plotToolTip)
            {
                [self setToolTip:plotToolTip];
                [[NSNotificationCenter defaultCenter] postNotificationName:kYMLChartToolTipWillAppear object:self];
                [self addSubview:plotToolTip];
                // when displaying tooltip bring this view to front of others so that tooltip (subview)
                // is always in front of adjacent views
                //[[self superview] bringSubviewToFront:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:kYMLChartToolTipDidAppear object:self];
                break;
            }
        }
	}
	
	return self.toolTip;
}

- (void)removeToolTip
{
    [self.toolTip removeFromSuperview];
    [self setToolTip:nil];
}

- (BOOL)updateToolTip:(id)recognizer
{
    if (![self isTouchOverFeature:recognizer] && !self.toolTip)
        return NO;
    
    UIView *toolTip = [self makeToolTip];
    if (!toolTip)
        return NO;
    
    for (YMLPlotView *plot in self.mutablePlots)
    {
        if ([plot updateToolTip:toolTip atPosition:[recognizer locationInView:plot]])
            break;
    }
    	
	// limit ToolTip range to roughly that of the chart
	CGPoint touchPoint = [recognizer locationInView:self];
	if (touchPoint.x < 0)
        touchPoint.x = 0;
    else if (touchPoint.x > self.bounds.size.width)
        touchPoint.x = self.bounds.size.width;
    if (touchPoint.y < 0)
        touchPoint.y = 0;
    else if (touchPoint.y > self.bounds.size.height)
        touchPoint.y = self.bounds.size.height;
    
    // Keep ToolTip in chart frame
    CGRect tipFrame = CGRectMake(touchPoint.x - self.toolTip.bounds.size.width / 2, touchPoint.y - self.toolTip.bounds.size.height, self.toolTip.bounds.size.width, self.toolTip.bounds.size.height);
    
    if (CGRectGetMinX(tipFrame) < CGRectGetMinX(_plotFrame))
    {
        touchPoint.x += CGRectGetMinX(_plotFrame) - (CGRectGetMinX(tipFrame));
    }
    else if (CGRectGetMaxX(tipFrame) > CGRectGetMaxX(_plotFrame))
    {
        touchPoint.x -= CGRectGetMaxX(tipFrame) - CGRectGetMaxX(_plotFrame);
    }
    if (CGRectGetMinY(tipFrame) < CGRectGetMinY(_plotFrame))
    {
        touchPoint.y += CGRectGetMinY(_plotFrame) - (CGRectGetMinY(tipFrame));
    }
    else if (CGRectGetMaxY(tipFrame) > CGRectGetMaxY(_plotFrame))
    {
        touchPoint.y -= CGRectGetMaxY(tipFrame) - CGRectGetMaxY(_plotFrame);
    }
    
	// move it so bottom edge is 30 points above the touch so finger won't be in the way
    // TODO: toolTip offset (default = CGSizeMake(0, -20) for positioning tip relative to touch
    // Also perhaps which edge of tip to align to (top, left, bottom, right)
	[toolTip setCenter:CGPointIntegralMake(touchPoint.x, touchPoint.y - (20 + (toolTip.bounds.size.height / 2)), toolTip.bounds.size)];
    
    return YES;
}


@end
