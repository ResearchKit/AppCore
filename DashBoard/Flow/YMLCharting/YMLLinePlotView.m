//
//  YMLLinePlotView.m
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/22/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import "YMLAxisView.h"
#import "Enumerations.h"
#import "YMLPointLayer.h"
#import "YMLLinePlotView.h"
#import "YMLScrollableChartView.h"

#import <QuartzCore/QuartzCore.h>

@interface YMLLinePlotView()

@property (nonatomic, strong) NSMutableArray *normalizedValues;
@property (nonatomic, assign) CGFloat maxTotalValue;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, strong) CAShapeLayer *line;

@end

@implementation YMLLinePlotView

- (id)init
{
    self = [super init];
    if (self) {
        [self doInitYMLLinePlotView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self doInitYMLLinePlotView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self doInitYMLLinePlotView];
    }
    return self;
}

- (id)initWithOrientation:(YMLChartOrientation)orientation
{
    self = [super initWithOrientation:orientation];
    if (self)
    {
        [self doInitYMLLinePlotView];
    }
    return self;
}

- (void)doInitYMLLinePlotView
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
        for (NSNumber *value in self.values)
        {
            CGFloat totalValue = value.floatValue;
            if (isnormal(totalValue) && totalValue > self.maxTotalValue)
                self.maxTotalValue = totalValue;
        }
        
        for (NSNumber *value in self.values)
        {
            [self.normalizedValues addObject:isnormal(value.floatValue) && isnormal(self.maxTotalValue)? @(value.floatValue / self.maxTotalValue) : @(0.0)];
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
        for (NSNumber *value in self.values)
        {
            [self.normalizedValues addObject:isnormal(value.floatValue) && isnormal(self.maxTotalValue)? @(value.floatValue / self.maxTotalValue) : @(0.0)];
        }
    }
    
    [self setNeedsLayout];
}

- (NSArray *)returnNormalizedValues
{
    return self.normalizedValues;
}

-(void)updatePoints
{	
    self.line.frame = self.bounds;
    self.line.strokeColor = self.lineColor.CGColor;
    
    CALayer *containerLayer = self.layer;
	BOOL isHorizontal = self.orientation == YMLChartOrientationHorizontal;
    BOOL initialDisplay = (self.points.count == 0);
    
	// Adjust number of slices
	if (self.values.count > self.points.count) {
		
		int count = (int)(self.values.count - self.points.count);
		for (int i = 0; i < count; i++) {
			YMLPointLayer *point = [YMLPointLayer layer];
            point.size = self.pointSize;
            point.bounds = (CGRect){CGPointZero, self.pointSize};
            point.shadowOffset = (CGSize){0,1};
            point.shadowOpacity = 0.25;
            point.shadowRadius = 1;
            point.shadowPath = [UIBezierPath bezierPathWithOvalInRect:point.bounds].CGPath;
            point.symbol = self.symbol;
            point.fillColor = self.pointColor;
            point.lineWidth = 0;
            
            [self.points addObject:point];
			[containerLayer addSublayer:point];
            
            if (self.showLabels)
            {
                UILabel *label = [[UILabel alloc] init];
                label.backgroundColor = [UIColor clearColor];
                label.textColor = self.textColor;
                label.font = self.font;
                label.layer.zPosition = 1;
                
                [self.labels addObject:label];
                [self.chart.labelContainerView addSubview:label];
            }
		}
	}
	else if (self.values.count < self.points.count) {
		int count = (int) (self.points.count - self.values.count);
        
		for (int i = 0; i < count; i++) {
			[self.points[0] removeFromSuperlayer];
            [self.points removeObjectAtIndex:0];
		}
        
        if (self.showLabels)
        {
            [[self.labels lastObject] removeFromSuperview];
            [self.labels removeObjectAtIndex:self.labels.count - 1];
        }
	}
	
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
        for (NSNumber *value in self.values) {
            YMLPointLayer *point = self.points[index];
            CGFloat pointOffset = scaled_roundf(maxBarLength * [self.normalizedValues[index] floatValue]);
            if (isHorizontal)
            {
                point.position = CGPointIntegralMake(pointOffset, self.topMargin + scaled_roundf(barInterval * index + self.barWidth / 2), self.pointSize);
            }
            else
            {
                point.position = CGPointIntegralMake(self.leftMargin + scaled_roundf(barInterval * index + self.barWidth / 2), self.topMargin + maxBarLength - pointOffset, self.pointSize);
            }
            
            if (index == 0)
                [path moveToPoint:point.position];
            else
                [path addLineToPoint:point.position];
                        
            if (titleAxis)
            {
                CGPoint center = [self convertPoint:point.position toView:titleAxis];
                if (isHorizontal)
                    [positions addObject:@(center.y)];
                else
                    [positions addObject:@(center.x)];
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
            index++;
        }
    }
    
    //[self.chart showNoDataLabel:noData];
    for (UIView *label in self.labels)
        label.hidden = noData;

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
        for (CALayer *pointLayer in self.points)
            [self showLayer:pointLayer show:!noData];
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
