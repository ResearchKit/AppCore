//
//  YMLMultiLinePlotView.m
//  Avero
//
//  Created by Mahesh on 4/29/14.
//  Copyright (c) 2014 ymedialabs.com. All rights reserved.
//

#import "YMLMultiLinePlotView.h"
#import <QuartzCore/QuartzCore.h>
#import "YMLAxisView.h"
#import "YMLPointLayer.h"
#import "YMLScrollableChartView.h"
#import "Enumerations.h"

@interface YMLMultiLinePlotView()

@property (nonatomic, strong) NSMutableArray *normalizedValues;
@property (nonatomic, assign) CGFloat maxTotalValue;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, strong) CAShapeLayer *line;

@property (nonatomic, strong) NSArray *oldValues;
@property (nonatomic, assign) CGFloat oldMax;
@property (nonatomic, assign) CGFloat oldReservedWidth;

@end

@implementation YMLMultiLinePlotView

- (id)init
{
    self = [super init];
    if (self) {
        [self doInitYMLMultiLinePlotView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self doInitYMLMultiLinePlotView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self doInitYMLMultiLinePlotView];
    }
    return self;
}

- (id)initWithOrientation:(YMLChartOrientation)orientation
{
    self = [super initWithOrientation:orientation];
    if (self)
    {
        [self doInitYMLMultiLinePlotView];
    }
    return self;
}

- (void)doInitYMLMultiLinePlotView
{
    _points = [NSMutableArray array];
    _labels = [NSMutableArray array];
    _pointSize = CGSizeMake(15, 15);
    _symbol = YMLPointSymbolCircle;
    _barWidth = 33;
    _line = [CAShapeLayer layer];
    _line.bounds = self.bounds;
    _line.fillColor = [UIColor clearColor].CGColor;
    _line.lineWidth = self.lineWidth;
    _line.shadowOffset = (CGSize){0,1};
    _line.shadowOpacity = 0.25;
    _line.shadowRadius = 1;
    _line.lineJoin = kCALineJoinBevel;
    _accessoryViews = [NSMutableArray array];
    _pointsPerRow = 1;
    
    [self.layer addSublayer:_line];
    self.clipsToBounds = YES;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */


#pragma mark - View Methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updatePoints];
}

#pragma mark - Properties

- (void)valuesDidChange;
{
    self.maxTotalValue = 0;
	self.normalizedValues = [NSMutableArray array];
    
    if (self.values)
    {
        for (NSArray *subValues in self.values)
        {
            for (NSNumber *value in subValues)
            {
                CGFloat totalValue = value.floatValue;
                if (isnormal(totalValue) && totalValue > self.maxTotalValue)
                    self.maxTotalValue = totalValue;
            }
        }
        
        for (NSArray *subvalues in self.values)
        {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.pointsPerRow];
            for(NSNumber *value in subvalues)
            {
                [array addObject:isnormal(value.floatValue) && isnormal(self.maxTotalValue)? @(value.floatValue / self.maxTotalValue) : @(0.0)];
            }
            
            [self.normalizedValues addObject:array];
        }
    }
    
    [self setNeedsLayout];
}

- (void)normalize:(CGFloat)maxValue
{
    if (self.maxTotalValue == maxValue)
        return;
    
    self.maxTotalValue = maxValue;
	self.normalizedValues = [NSMutableArray array];
    
    if (self.values)
    {
        for (NSArray *subvalues in self.values)
        {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.pointsPerRow];
            for (NSNumber *value in subvalues) {
                [array addObject:isnormal(value.floatValue) && isnormal(self.maxTotalValue)? @(value.floatValue / self.maxTotalValue) : @(0.0)];
            }
            [self.normalizedValues addObject:array];
        }
    }
    
    [self setNeedsLayout];
}

- (NSArray *)returnNormalizedValues
{
    return self.normalizedValues;
}

- (void)updatePoints
{
    if ((self.oldMax == self.maxTotalValue) & (self.oldReservedWidth == self.reservedWidth) & [self.oldValues isEqualToArray:self.normalizedValues])
        //nothing to update
        return;
    else
    {
        self.oldValues = [self returnNormalizedValues];
        self.oldMax = self.maxTotalValue;
        self.oldReservedWidth = self.reservedWidth;
    }
    
    self.line.frame = self.bounds;
    self.line.strokeColor = self.lineColor.CGColor;
    
    CALayer *containerLayer = self.layer;
	BOOL isHorizontal = self.orientation == YMLChartOrientationHorizontal;
    BOOL initialDisplay = (self.points.count == 0);
    
	// Adjust number of slices
	if (self.values.count > self.points.count) {
		
		int count = self.values.count - self.points.count;
		for (int i = 0; i < count; i++) {
            NSMutableArray *pointArray = [NSMutableArray arrayWithCapacity:self.pointsPerRow];
            NSMutableArray *labelsArray = [NSMutableArray arrayWithCapacity:self.pointsPerRow];
            
            for(int j = 0; j < self.pointsPerRow; j++ )
            {
                YMLPointLayer *point = [YMLPointLayer layer];
                point.size = self.pointSize;
                point.bounds = (CGRect){CGPointZero, self.pointSize};
                point.shadowOffset = self.line.shadowOffset;
                point.shadowOpacity = self.line.shadowOpacity;
                point.shadowRadius = self.line.shadowRadius;
                point.symbol = self.symbol;
                point.fillColor = self.pointsColor[j];
                point.lineWidth = 0;
                
                [pointArray addObject:point];
                [containerLayer addSublayer:point];
                
                if (self.showLabels)
                {
                    //individual label for each value
                    UILabel *label = [[UILabel alloc] init];
                    label.backgroundColor = [UIColor clearColor];
                    label.textColor = self.textColor;
                    label.font = self.font;
                    label.layer.zPosition = 1;
                    
                    [pointArray addObject:label];
                    [self.chart.labelContainerView addSubview:label];
                }
            }
            
            if (self.showAccessoryViews)
            {
                //single accessoryView per line
                UIView *accessory = [self.accessoryDelegate accessoryViewForPlotView:self];
                [self.accessoryViews addObject:accessory];
                [self.chart.labelContainerView addSubview:accessory];
            }
            
            [self.points addObject:pointArray];
            [self.labels addObject:labelsArray];
		}
	}
	else if (self.values.count < self.points.count) {
		int count = self.points.count - self.values.count;
        
		for (int i = 0; i < count; i++) {
            
            NSMutableArray *subPoints = [self.points lastObject];
            for (int j = 0; j < self.pointsPerRow; j++)
            {
                [[subPoints lastObject] removeFromSuperlayer];
                [subPoints removeLastObject];
            }
            [self.points removeLastObject];
            
            if (self.showLabels)
            {
                for (UIView *label in [self.labels lastObject])
                    [self removeView:label fromSuperviewAnimated:YES];
                [self.labels removeLastObject];
            }
            
            if (self.showAccessoryViews)
            {
                [self removeView:[self.accessoryViews lastObject] fromSuperviewAnimated:YES];
                [self.accessoryViews removeLastObject];
            }
        }
	}
    
    // get maximum accessory width and hide non-required accessory views
    if (self.showAccessoryViews)
    {
        int idx = 0;
        CGFloat maxAccessoryWidth = self.reservedWidth;
        for (UIView *accessoryView in self.accessoryViews)
        {
            BOOL shouldShowAccessoryView = YES;
            if ([self.accessoryDelegate respondsToSelector:@selector(accessoryViewAppearenceForPlotView:atIndexPath:)])
                shouldShowAccessoryView = [self.accessoryDelegate accessoryViewAppearenceForPlotView:self atIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            
            [accessoryView setHidden:!shouldShowAccessoryView];
            
            if (shouldShowAccessoryView)
            {
                //only one value show accessoryView
                [self.accessoryDelegate plotView:self updateAccessory:accessoryView atIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                if (accessoryView.frame.size.width > maxAccessoryWidth)
                    maxAccessoryWidth = accessoryView.frame.size.width;
            }

            idx++;
        }
        self.reservedWidth = maxAccessoryWidth;
    }
    
    if ([self.accessoryDelegate respondsToSelector:@selector(resolveOverlapsForLayers:)] & [self.accessoryDelegate respondsToSelector:@selector(resetLayers:)])
        //reset layers in delegate depending on the way overlaps were resolved
        [self.accessoryDelegate resetLayers:self.points];
    
    // arrange the bars
	// Set the angles on the slices
	CGFloat count = self.values.count;
    
    CGFloat barInterval = count <= 1? 0 : ((isHorizontal?(self.bounds.size.height - (self.topMargin + self.bottomMargin + self.barWidth)) : self.bounds.size.width - (self.leftMargin + self.rightMargin + self.barWidth)) / (count - 1));
    if ([self.chart isKindOfClass:[YMLScrollableChartView class]])
    {
        YMLScrollableChartView *scrollableChart = (YMLScrollableChartView *)self.chart;
        barInterval = isHorizontal? scrollableChart.barInterval.height : scrollableChart.barInterval.width;
    }
    
    CGFloat maxBarLength = isHorizontal? (self.bounds.size.width - (self.reservedWidth + self.leftMargin + self.rightMargin)) : (self.bounds.size.height - (self.reservedWidth + self.topMargin + self.bottomMargin));
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    self.line.lineWidth = self.lineWidth;
    
    int index = 0;
    NSMutableArray *positions = [NSMutableArray array];
    YMLAxisView *titleAxis = [self titleAxis];
    
    BOOL noData = [self.values count] > 0 && self.maxTotalValue == 0;
    BOOL wasNoData = self.line.opacity == 0;
    
    [CATransaction begin];
    //[CATransaction setAnimationDuration:3];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    if (noData || wasNoData)
    {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
    }
    
    if (!noData)
    {
        for (NSArray *subvalues in self.values) {
            int layerIndex = 0;
            
            NSArray *normalizedValues = self.normalizedValues[index];
            NSArray *layers = self.points[index];
            NSMutableArray *layersPositions = [NSMutableArray arrayWithCapacity:self.pointsPerRow];
            
            for(NSNumber *value in subvalues)
            {
                if (!isnan([value integerValue]))
                {
                    YMLPointLayer *point = layers[layerIndex];
                    point.hidden = noData;
                    
                    CGFloat pointOffset = scaled_roundf(maxBarLength * [normalizedValues[layerIndex] floatValue]);
                    if (isHorizontal)
                        point.position = CGPointIntegralMake(pointOffset, self.topMargin + scaled_roundf(barInterval * index + self.barWidth / 2), self.pointSize);
                    else
                        point.position = CGPointIntegralMake(self.leftMargin + scaled_roundf(barInterval * index + self.barWidth / 2), self.topMargin + maxBarLength - pointOffset, self.pointSize);
                    
                    if (index == 0)
                        [path moveToPoint:point.position];
                    else
                        [path addLineToPoint:point.position];
                    
                    if (titleAxis)
                    {
                        CGPoint center = [self convertPoint:point.position toView:titleAxis];
                        if (isHorizontal)
                            [layersPositions addObject:@(center.y)];
                        else
                            [layersPositions addObject:@(center.x)];
                    }
                    
                    if (self.showLabels)
                    {
                        UILabel *label = self.labels[index];
                        label.textColor = self.textColor;
                        label.font = self.font;
                        label.text = [self displayValueForValue:value];
                        CGPoint oldPosition = label.layer.position;
                        [label sizeToFit];
                        
                        CGPoint position = CGPointIntegralMake(point.position.x, point.position.y - ((self.pointSize.height / 2) + self.labelGap.height + (label.bounds.size.height / 2)), label.bounds.size);
                        
                        if (!initialDisplay)
                        {
                            CABasicAnimation *labelAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
                            [labelAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
                            [labelAnimation setFromValue:[NSValue valueWithCGPoint:oldPosition]];
                            [labelAnimation setToValue:[NSValue valueWithCGPoint:position]];
                            [labelAnimation setFillMode:kCAFillModeForwards];
                            [labelAnimation setRemovedOnCompletion:YES];
                            [label.layer addAnimation:labelAnimation forKey:@"position"];
                        }
                        
                        label.layer.position = position;
                    }
                    
                    [point setNeedsDisplay];
                    layerIndex++;
                }
            }
            
            //resolve overlaps via delegate
            if (layerIndex > 1)
                //more than one layer for each bar
                [CATransaction setCompletionBlock:^{
                    if ([self.delegate respondsToSelector:@selector(resolveOverlapsForLayers:)] )
                        [self.accessoryDelegate resolveOverlapsForLayers:layers];
                }];
            
            //hide remaining extra layers
            for (int idx = layerIndex; idx < self.pointsPerRow; idx++)
            {
                YMLPointLayer *point = [self.points[index] objectAtIndex:idx];
                point.bounds = CGRectZero;
            }
            
            if (self.showAccessoryViews)
            {
                UIView *accessoryView = self.accessoryViews[index];
                BOOL shouldShowAccessoryView = YES;
                if ([self.accessoryDelegate respondsToSelector:@selector(accessoryViewAppearenceForPlotView:atIndexPath:)])
                    shouldShowAccessoryView = [self.accessoryDelegate accessoryViewAppearenceForPlotView:self atIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                
                if (shouldShowAccessoryView)
                {
                    CGSize minSize = CGSizeMake(0, 0);
                    if ([self.accessoryDelegate respondsToSelector:@selector(labelSizeAtIndexPath:)])
                        minSize = [self.accessoryDelegate labelSizeAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                    
                    CGSize accessorySize = accessoryView.frame.size;
                    CGFloat accessoryValue = [self.accessoryDelegate plotView:self normalizedValueAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                    CGFloat accessoryBarLength = isnormal(accessoryValue)? scaled_roundf(maxBarLength * accessoryValue) : 0;
                    YMLPointLayer *thisLayer = [self.points[index] firstObject];
                    
                    if (isHorizontal)
                    {
                        CGFloat xValue;
                        
                        if (accessoryBarLength > minSize.width)
                            xValue = accessoryBarLength + self.accessoryGap.width + (accessorySize.width / 2);
                        else
                            xValue = minSize.width + self.accessoryGap.width + (accessorySize.width / 2);
                        
                        accessoryView.layer.position = CGPointIntegralMake(xValue, CGRectGetMidY(thisLayer.frame), accessorySize);
                        
                    }
                    else
                    {
                        CGFloat yValue;
                        
                        if (accessoryBarLength > minSize.height)
                            yValue = accessoryBarLength + self.accessoryGap.height + (accessorySize.height / 2);
                        else	
                            yValue = minSize.height + self.accessoryGap.height + (accessorySize.height / 2);
                        
                        accessoryView.layer.position = CGPointIntegralMake(CGRectGetMidX(thisLayer.frame), yValue, accessorySize);
                    }
                }
            }
            index++;
            [positions addObject:layersPositions];
        }
    }
    
    //[self.chart showNoDataLabel:noData];
    if (noData)
    {
        //hide everything
        if (self.showLabels)
            for (NSMutableArray *labelArray in self.labels)
                for (UIView *label in labelArray)
                    label.hidden = noData;
        
        for (NSMutableArray *points in self.points)
            for (YMLPointLayer *layer in points)
                layer.hidden = noData;
        
        for (UIView *accessory in self.accessoryViews)
                accessory.hidden = noData;
    }
    
    if (!noData)
    {
        CGPathRef oldPath = CGPathRetain(self.line.path);
        self.line.path = path.CGPath;
        
        if (!wasNoData)
        {
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            [pathAnimation setFromValue:(__bridge id)oldPath];
            [pathAnimation setToValue:(id)self.line.path];
            [pathAnimation setDuration:[CATransaction animationDuration]];
            [pathAnimation setTimingFunction:[CATransaction animationTimingFunction]];
            [pathAnimation setRemovedOnCompletion:YES];
            
            [self.line addAnimation:pathAnimation forKey:@"path"];
        }
        
        CGPathRelease(oldPath);
    }
    
    if (noData || wasNoData)
    {
        [CATransaction commit];
    }
    
    if (noData != wasNoData)
    {
        [self showLayer:self.line show:!noData];
        for (NSArray *subvalues in self.points)
            for(CALayer *pointLayer in subvalues)
            {
                [self showLayer:pointLayer show:!noData];
            }
    }
    
    [titleAxis setPositions:[NSArray arrayWithArray:positions]];

    [CATransaction commit];
    
    [self setScaleForWidth:maxBarLength];
    
}

- (void)showLayer:(CALayer *)layer show:(BOOL)show
{
    CGFloat toOpacity = show? 1 : 0;
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [pathAnimation setFromValue:@(layer.opacity)];
    [pathAnimation setToValue:@(toOpacity)];
    [pathAnimation setDuration:[CATransaction animationDuration]];
    [pathAnimation setTimingFunction:[CATransaction animationTimingFunction]];
    [pathAnimation setRemovedOnCompletion:YES];
    layer.opacity = toOpacity;
    [layer addAnimation:pathAnimation forKey:@"opacity"];
}

- (void)removeView:(UIView *)view fromSuperviewAnimated:(BOOL)animated
{
    if (!animated)
    {
        [view removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:[CATransaction animationDuration] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

- (void)setScaleForWidth:(CGFloat)width
{
    YMLAxisView *axis = [self scaleAxis];
    if (!axis)
        return;
    
    CGFloat left = self.frame.origin.x;
    CGFloat top = self.frame.origin.y;
    CGFloat right = CGRectGetMaxX(self.superview.bounds) - CGRectGetMaxX(self.frame);
    CGFloat bottom = CGRectGetMaxY(self.superview.bounds) - CGRectGetMaxY(self.frame);
    
    UIEdgeInsets currentInsets = axis.insets;
    axis.insets = (axis.position == YMLAxisPositionTop || axis.position == YMLAxisPositionBottom)?
    UIEdgeInsetsMake(currentInsets.top, left + self.leftMargin, currentInsets.bottom, right + self.rightMargin) :
    UIEdgeInsetsMake(top + self.topMargin, currentInsets.left, bottom + self.bottomMargin, currentInsets.right);
    axis.min = 0;
    if (self.reservedWidth > 0)
    {
        if (self.orientation == YMLChartOrientationHorizontal)
            axis.max = self.maxTotalValue * (self.frame.size.width - (self.leftMargin + self.rightMargin)) / width;
        else
            axis.max = self.maxTotalValue * (self.frame.size.height - (self.topMargin + self.bottomMargin)) / width;
    }
    else
    {
        axis.max = self.maxTotalValue;
    }
}


@end
