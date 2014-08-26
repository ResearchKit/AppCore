//
//  YMLStackedBarPlotView.m
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/30/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import "YMLStackedBarPlotView.h"
#import "YMLBarLayer.h"
#import "YMLAxisView.h"
#import "YMLScrollableChartView.h"
#import "YMLBarSegmentLayer.h"
#import "Enumerations.h"
#import "NSArray+Helpers.h"

#define DEFAULT_HORIZONTAL_AXIS_HEIGHT  30
#define DEFAULT_VERTICAL_AXIS_WIDTH     75

@interface YMLStackedBarPlotView()

@property (nonatomic, strong, readwrite) NSMutableArray *barTotals;
@property (nonatomic, strong, readwrite) NSMutableArray *bars;
@property (nonatomic, strong) NSMutableArray *titleLabels;
@property (nonatomic, strong) NSMutableArray *percentageLabels;
@property (nonatomic, assign) UIRectCorner barCorners;
@property (nonatomic, assign) CGSize barCornerRadii;

@end

@implementation YMLStackedBarPlotView

- (id)init
{
    self = [super init];
    if (self) { 
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self doInitYMLStackedBarPlotView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self doInitYMLStackedBarPlotView];
    }
    return self;
}

- (id)initWithOrientation:(YMLChartOrientation)orientation
{
    self = [super initWithOrientation:orientation];
    if (self)
    {
    }
    return self;
}

- (void)doInitYMLStackedBarPlotView
{
    _barCorners = 0;
    _barCornerRadii = CGSizeZero;

    _valueLabels = [NSMutableArray array];
    _titleLabels = [NSMutableArray array];
    _percentageLabels = [NSMutableArray array];
    _bars = [NSMutableArray array];
    _totalLabelGap = 10;
    _showTotalLabel = YES;
    
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
    
    [self updateBars];
}

#pragma mark - Properties

- (void)valuesDidChange;
{
    self.maxTotalValue = 0;
	self.normalizedValues = [NSMutableArray array];
    self.barTotals = [NSMutableArray array];
    
    if (self.values)
    {
        for (NSArray *subValues in self.values)
        {
            CGFloat totalValue = 0;
            for (NSNumber *value in subValues)
            {
                CGFloat floatValue = value.floatValue;
                if (isnormal(floatValue))
                    totalValue += floatValue;
            }
            [self.barTotals addObject:isnormal(totalValue)? @(totalValue) : @(0.0)];
            if (totalValue > self.maxTotalValue)
                self.maxTotalValue = totalValue;
        }
        
        for (NSNumber *barLength in self.barTotals)
        {
            [self.normalizedValues addObject:self.maxTotalValue == 0? @(0.0) : @(barLength.floatValue / self.maxTotalValue)];
        }
    }
    
    [self setNeedsLayout];
}

- (void)setBarColors:(NSArray *)barColors
{
    if (barColors == _barColors)
        return;
    
    _barColors = barColors;
    for (YMLBarLayer *barLayer in self.bars)
        barLayer.barColors = barColors;
}

- (void)setBarShapeByRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)radii
{
    [self setBarCorners:corners];
    [self setBarCornerRadii:radii];
    
    for (YMLBarLayer *bar in self.bars)
        bar.cornerRadii = radii;
    
    [self setNeedsLayout];
}

- (void)updateTotalLabels
{
    if (self.showTotalLabel)
    {
        int index = 0;
        for (UILabel *valueLabel in self.valueLabels)
        {
            YMLBarLayer *bar = self.bars[index];
            CGPoint position = CGPointZero;
            if (self.orientation == YMLChartOrientationHorizontal)
            {
                position = CGPointMake(CGRectGetMaxX(bar.frame) + self.totalLabelGap + (valueLabel.bounds.size.width / 2), CGRectGetMidY(bar.frame));
            }
            else
                position = CGPointMake(CGRectGetMidX(bar.frame), CGRectGetMinY(bar.frame) - (self.totalLabelGap + (valueLabel.bounds.size.height / 2)));
            
            position = CGPointCenterIntegralScaled(position, valueLabel.bounds.size);
            
            if (self.bars.count != 0)
            {
                //not initial chart, animate changing positions
                CABasicAnimation *labelAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
                [labelAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
                [labelAnimation setFromValue:[NSValue valueWithCGPoint:valueLabel.layer.position]];
                [labelAnimation setToValue:[NSValue valueWithCGPoint:position]];
                [labelAnimation setFillMode:kCAFillModeForwards];
                [labelAnimation setRemovedOnCompletion:YES];
                [valueLabel.layer addAnimation:labelAnimation forKey:@"position"];
                [CATransaction commit];
            }
            
            valueLabel.layer.position = position;
            
            index++;
        }
    }
}

#pragma mark - Private Instance Methods
-(void)updateBars
{
    CALayer *containerLayer = self.layer;
	BOOL isHorizontal = self.orientation == YMLChartOrientationHorizontal;
	// Adjust number of slices
	if (self.values.count > self.bars.count) {
		
		int count = self.values.count - self.bars.count;
        
		for (int i = 0; i < count; i++) {
			YMLBarLayer *bar = [YMLBarLayer layer];
            bar.orientation = self.orientation;
			bar.frame = self.bounds;
            bar.shadowOpacity = 0.25;
            bar.shadowRadius = 0.5;
            bar.barColors = self.barColors;
            bar.cornerRadii = self.barCornerRadii;
            [self.bars addObject:bar];
			[containerLayer addSublayer:bar];
            
            if (self.showTotalLabel)
            {
                UILabel *label = [[UILabel alloc] init];
                label.backgroundColor = [UIColor clearColor];
                label.textColor = self.textColor;
                label.font = self.font;
                
                [self.valueLabels addObject:label];
                [self addSubview:label];
            }
            
            if (self.showTitles)
            {
                UIView *label = [self titleLabel];
                [self.titleLabels addObject:label];
                [self.chart.labelContainerView addSubview:label];
            }
            
            if(self.showPercentLabels)
            {
                NSInteger percentageLblIndx = 0;
                for (percentageLblIndx = 0; percentageLblIndx<self.values.count; percentageLblIndx++)
                {
                    [self.values[percentageLblIndx] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        UIView *label = [self percentLabel];
                        [self.percentageLabels addObject:label];
                        [self addSubview:label];
                    }];
                }
            }
		}
	}
	else if (self.values.count < self.bars.count) {
		int count = self.bars.count - self.values.count;
        
		for (int i = 0; i < count; i++) {
			[self.bars[0] removeFromSuperlayer];
            [self.bars removeObjectAtIndex:0];
            
            if (self.showTotalLabel)
            {
                [[self.valueLabels lastObject] removeFromSuperview];
                [self.valueLabels removeObjectAtIndex:self.valueLabels.count - 1];
            }
            if (self.showTitles)
            {
                [[self.titleLabels lastObject] removeFromSuperview];
                [self.titleLabels removeObjectAtIndex:self.titleLabels.count - 1];
            }
            if(self.percentageLabels)
            {
                [[self.percentageLabels lastObject] removeFromSuperview];
                [self.percentageLabels removeObjectAtIndex:self.percentageLabels.count - 1];
            }
		}
	}
	
    // arrange the bars
	// Set the angles on the slices
	int index = 0;
	CGFloat count = self.values.count;
    CGFloat barInterval = count <= 1? 0 : ((isHorizontal?(self.bounds.size.height - (self.topMargin + self.bottomMargin + self.barWidth)) : self.bounds.size.width - (self.leftMargin + self.rightMargin + self.barWidth)) / (count - 1));
    if ([self.chart isKindOfClass:[YMLScrollableChartView class]])
    {
        YMLScrollableChartView *scrollableChart = (YMLScrollableChartView *)self.chart;
        barInterval = isHorizontal? scrollableChart.barInterval.height : scrollableChart.barInterval.width;
    }
    CGFloat labelMaxWidth = self.reservedWidth;
    
    if (self.showTotalLabel)
    {
        NSUInteger valuesCount = self.values.count;
        for (NSUInteger idx = 0; idx < valuesCount; idx++) {
            
            UILabel *valueLabel = self.valueLabels[index];
            [self updateValueLabel:valueLabel atIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
            if (isHorizontal)
            {
                if ((valueLabel.bounds.size.width + self.totalLabelGap) > labelMaxWidth)
                    labelMaxWidth = valueLabel.bounds.size.width + self.totalLabelGap;
            }
            else
            {
                if ((valueLabel.bounds.size.height + self.totalLabelGap) > labelMaxWidth)
                    labelMaxWidth = valueLabel.bounds.size.height + self.totalLabelGap;
            }
            
            index++;
        }
    }
    
    if (labelMaxWidth > self.reservedWidth)
        self.reservedWidth = labelMaxWidth;
    
    CGFloat maxBarLength = isHorizontal? (self.bounds.size.width - (labelMaxWidth + self.leftMargin + self.rightMargin)) : (self.bounds.size.height - (labelMaxWidth + self.topMargin + self.bottomMargin));
    
    index = 0;
    NSMutableArray *positions = [NSMutableArray array];
    YMLAxisView *titleAxis = [self titleAxis];
    
    for (NSArray *subValues in self.values) {
        YMLBarLayer *bar = self.bars[index];
        bar.subValues = subValues;
        CGFloat barWidth = (index == self.selectedIndex)? scaled_roundf(self.barWidth * 1.055555) : self.barWidth;
        CGFloat barLength = scaled_roundf(maxBarLength * [self.normalizedValues[index] floatValue]);
        if (isHorizontal)
        {
            bar.frame = CGRectOffset(CGRectMake(self.leftMargin, self.topMargin + scaled_roundf(barInterval * index), barLength, barWidth), self.bounds.origin.x, self.bounds.origin.y);
        }
        else
        {
            
            bar.frame = CGRectOffset(CGRectMake(self.leftMargin + scaled_roundf(barInterval * index), self.topMargin + labelMaxWidth + (maxBarLength - barLength), barWidth, barLength), self.bounds.origin.x, self.bounds.origin.y);
        }
        
        CGPathRef oldPath = CGPathRetain(bar.shadowPath);
        
        bar.shadowPath = [self shadowPathForBar:bar];
        if (isHorizontal)
            bar.shadowOffset = CGSizeMake(0, (index == self.selectedIndex)? 5 : 1);
        else
            bar.shadowOffset = CGSizeMake((index == self.selectedIndex)? 5 : 1, 0);
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        [animation setFromValue:(__bridge id)oldPath];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        [animation setToValue:(id)bar.shadowPath];
        [animation setFillMode:kCAFillModeForwards];
        [animation setRemovedOnCompletion:YES];
        [bar addAnimation:animation forKey:@"shadowPath"];
        
        CGPathRelease(oldPath);
        
        if (titleAxis)
        {
            CGPoint center = [self convertPoint:bar.position toView:titleAxis];
            if (isHorizontal)
                [positions addObject:@(center.y)];
            else
                [positions addObject:@(center.x)];
        }
        
        [self updateTotalLabels];
        
        if (self.showTitles)
        {
            UILabel *titleLabel = self.titleLabels[index];
            [self updateTitleLabel:titleLabel atIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            // Note: horizontal support only, for vertical charts it's probably better to use a title axis
            CGSize titleSize = titleLabel.frame.size;
            titleLabel.frame = CGRectIntegralMake(self.titleGap.width, CGRectGetMinY(bar.frame) - (titleSize.height + self.titleGap.height), titleSize.width, titleSize.height);
        }
        
        if(self.showPercentLabels && self.values.count>0)
        {
            // Calculate the total
            CGFloat total = 0.0f;
            for(NSNumber *number in self.values[index])
            {
                total +=  [number floatValue];
            }
            
            NSInteger percentageLblIndex = 0;
            
            CGFloat left = 0; // the xoffset of the labels from the origin of the stacked bar
            CGFloat leftMargin = 1.0f; // the left margin that is used for padding of labels from segment saperators set to 1
            
            [CATransaction begin];
            for (percentageLblIndex = 0; percentageLblIndex<[self.values[index] count]; percentageLblIndex++)
            {
                // get the concerned value
                NSNumber *value = [self.values[index] objectAtIndex:percentageLblIndex];
                UILabel *percentageLabel = self.percentageLabels[(percentageLblIndex + (index*[self.values[index] count]))];
                
                // update the normalized value
                [self updatePercentLabel:percentageLabel atIndexPath:[NSIndexPath indexPathForRow:percentageLblIndex inSection:index]];
                
                // set the label frame and the size
                CGSize percentageLabelSize = CGSizeMake(([value floatValue]/total) * bar.frame.size.width, percentageLabel.frame.size.height);
                CGRect labelFrame= CGRectZero;
                (percentageLblIndex == 0)?({labelFrame.origin = CGPointMake(left + 2*leftMargin, [bar frame].origin.y);}):({labelFrame.origin = CGPointMake(left + 4*leftMargin, [bar frame].origin.y);});
                labelFrame = CGRectIntegralMake(labelFrame.origin.x, labelFrame.origin.y, isnan(percentageLabelSize.width)?0:(scaled_roundf(percentageLabelSize.width) - 4*leftMargin), bar.frame.size.height);
                
                // update the percetage label and bring it front of the subview
                percentageLabel.frame = labelFrame;
                percentageLabel.alpha = 1;
                [self bringSubviewToFront:percentageLabel];
                
                left+=(isnan(percentageLabelSize.width)?0:percentageLabelSize.width);
                
                // if width of the label is smaller than minimum, then hide the label
                percentageLabel.hidden = (percentageLabel.frame.size.width < self.miniumLabelWidth)?YES:NO;
                
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
                [animation setFromValue:@(0)];
                [animation setDuration:2.];
                [animation setFillMode:kCAFillModeForwards];
                [animation setRemovedOnCompletion:YES];
                [percentageLabel.layer addAnimation:animation forKey:@"opacity"];
            }
            [CATransaction commit];
        }
        index++;
    }
    
    BOOL noData = self.values != nil && self.maxTotalValue == 0;
    [self.chart showNoDataLabel:noData];
    for (UIView *label in self.valueLabels)
        label.hidden = noData;
    for (UIView *label in self.titleLabels)
        label.hidden = noData;
    
    [titleAxis setPositions:[NSArray arrayWithArray:positions]];
    
    [self setScaleForWidth:(CGFloat)maxBarLength];
}

- (CGPathRef)shadowPathForBar:(CALayer *)bar
{
    if (!CGSizeEqualToSize(self.barCornerRadii, CGSizeZero) && self.barCorners != 0)
    {
        // rounded rect shadow
        return [[UIBezierPath bezierPathWithRoundedRect:bar.bounds byRoundingCorners:self.barCorners cornerRadii:self.barCornerRadii] CGPath];
    }
    else
        // rect shadow
        return [[UIBezierPath bezierPathWithRect:bar.bounds] CGPath];
}

- (void)setScaleForWidth:(CGFloat)width
{
    YMLAxisView *axis = [self scaleAxis];
    if (!axis)
        return;
    
	BOOL isHorizontal = self.orientation == YMLChartOrientationHorizontal;
    
    CGFloat left = self.frame.origin.x;
    CGFloat top = self.frame.origin.y;
    CGFloat right = CGRectGetMaxX(self.superview.bounds) - CGRectGetMaxX(self.frame);
    CGFloat bottom = CGRectGetMaxY(self.superview.bounds) - CGRectGetMaxY(self.frame);
    
    UIEdgeInsets currentInsets = axis.insets;
    axis.insets = (axis.position == YMLAxisPositionTop || axis.position == YMLAxisPositionBottom)?
    UIEdgeInsetsMake(currentInsets.top, left + self.leftMargin, currentInsets.bottom, right + self.rightMargin) :
    UIEdgeInsetsMake(top + self.topMargin, currentInsets.left, bottom + self.bottomMargin, currentInsets.right);
    axis.min = 0;
    if (self.showTotalLabel || self.reservedWidth > 0)
    {
        if (isHorizontal)
            axis.max = self.maxTotalValue * (self.frame.size.width - (self.leftMargin + self.rightMargin)) / width;
        else
            axis.max = self.maxTotalValue * (self.frame.size.height - (self.topMargin + self.bottomMargin)) / width;
    }
    else
    {
        axis.max = self.maxTotalValue;
    }
}

- (id)totalAtIndex:(NSUInteger)index
{
    return [self.barTotals objectAtIndexOrNil:index];
}

#pragma mark - Touch Gesture handling

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self];
    NSInteger oldSelection = self.selectedIndex;
    
    int index = 0;
    for (CALayer *bar in self.bars)
    {
        if (CGRectContainsPoint(bar.frame, point))
        {
            self.selectedIndex = index;
            break;
        }
        
        index++;
    }
    
    if (self.selectedIndex != oldSelection)
        [self setNeedsLayout];
}

#pragma mark - Value labels

- (NSString *)valueLabel:(UIView *)labelView textForIndexPath:(NSIndexPath *)indexPath
{
    id value = [self.barTotals safeObjectAtIndex:indexPath.section];
    
    if (!value)
    {
        [self valueLabelSetNoDataStyle:labelView];
        return self.noDataString;
    }
    
    if ([value floatValue] == 0 && [self.delegate respondsToSelector:@selector(plotView:value:hasDataAtIndexPath:)])
    {
        if (![self.delegate plotView:self value:value hasDataAtIndexPath:indexPath])
        {
            [self valueLabelSetNoDataStyle:labelView];
            return self.noDataString;
        }
    }
    
    return [self displayValueForValue:value];
}

#pragma mark - Percentage Label

- (NSString *)percentLabel:(UIView *)labelView textForIndexPath:(NSIndexPath *)indexPath
{
    CGFloat value = 0;
    CGFloat normalizedValue = 0;
    
    for (NSNumber* number in self.values[[indexPath section]]) {
        value += [number floatValue];
    }
    
    normalizedValue = [[self.values[[indexPath section]] objectAtIndex:[indexPath row]] floatValue]/value;
    normalizedValue = isnan(normalizedValue)?0:normalizedValue;
    
    return [self displayValueForPercentLabel:@(normalizedValue)];
}

#pragma mark - Tooltips

- (BOOL)isPointOverFeature:(CGPoint)point
{
    if (!self.showTips)
        return NO;
    
    __block BOOL pointInBar = NO;
    BOOL isHorizontal = self.orientation == YMLChartOrientationHorizontal;
    CGFloat dimension = isHorizontal? self.bounds.size.width : self.bounds.size.height;
    [self.bars enumerateObjectsUsingBlock:^(CALayer *bar, NSUInteger idx, BOOL *stop) {
        CGRect barFrame = bar.frame;
        if (isHorizontal)
        {
            barFrame.origin.x = 0;
            barFrame.size.width = dimension;
        }
        else
        {
            barFrame.origin.y = 0;
            barFrame.size.height = dimension;
        }
        
        if (CGRectContainsPoint(barFrame, point))
        {
            pointInBar = YES;
            *stop = YES;
        }
    }];
    
    return pointInBar;
}

- (NSIndexPath *)featureIndexForPoint:(CGPoint)point
{
    __block int barIndex = -1;
    __block int segmentIndex = -1;
    // find which bar point is in
    BOOL isHorizontal = self.orientation == YMLChartOrientationHorizontal;
    CGFloat dimension = isHorizontal? self.bounds.size.width : self.bounds.size.height;
    [self.bars enumerateObjectsUsingBlock:^(YMLBarLayer *barLayer, NSUInteger idx, BOOL *stop) {
        CGRect barFrame = barLayer.frame;
        if (isHorizontal)
        {
            barFrame.origin.x = 0;
            barFrame.size.width = dimension;
        }
        else
        {
            barFrame.origin.y = 0;
            barFrame.size.height = dimension;
        }
        if (CGRectContainsPoint(barFrame, point))
        {
            *stop = YES;
            barIndex = idx;
            
            // find which segment point is in
            [barLayer.segments enumerateObjectsUsingBlock:^(YMLBarSegmentLayer *segment, NSUInteger subIndex, BOOL *subStop) {
                CGRect segmentFrame = [barLayer convertRect:segment.frame toLayer:self.layer];
                if (CGRectContainsPoint(segmentFrame, point))
                {
                    *subStop = YES;
                    segmentIndex = subIndex;
                }
            }];
            
            // match to last segment if outside of bar
            if (segmentIndex < 0)
                segmentIndex = [barLayer.segments count] - 1;
        }
    }];
    
    if (barIndex < 0)
        return nil;
    return [NSIndexPath indexPathForRow:segmentIndex inSection:barIndex];
}

- (NSString *)toolTip:(UIView *)toolTip textForIndexPath:(NSIndexPath *)indexPath
{
    id value = [self.values safeObjectAtIndex:indexPath.section];
    if (!value)
        return nil;
    
    id subValue = [value safeObjectAtIndex:indexPath.row];
    if (!subValue)
        return [self displayValueForValue:[self.barTotals safeObjectAtIndex:indexPath.section]];
    return [self displayValueForValue:subValue];
}

@end
