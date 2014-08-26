//
//  YMLBarPlotView.m
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/1/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import "YMLBarPlotView.h"
#import "YMLBarSegmentLayer.h"
#import "YMLAxisView.h"
#import "YMLScrollableChartView.h"
#import "Enumerations.h"

#define ANIMATION_DURATION 0.5

@interface YMLBarPlotView()

@property (nonatomic, strong) NSMutableArray *normalizedValues;
@property (nonatomic, strong) NSMutableArray *barTotals;
@property (nonatomic, assign) CGFloat maxTotalValue;
@property (nonatomic, strong) NSMutableArray *bars;
@property (nonatomic, strong) NSMutableArray *valueLabels;
@property (nonatomic, strong) NSMutableArray *titleLabels;
@property (nonatomic, strong) NSMutableArray *accessoryViews;
@property (nonatomic, strong) UIImage *barImage;
@property (nonatomic, assign) UIEdgeInsets capInsets;
@property (nonatomic, assign) UIRectCorner barCorners;
@property (nonatomic, assign) CGSize barCornerRadii;

@end

@implementation YMLBarPlotView

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
        [self doInitYMLBarPlotView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self doInitYMLBarPlotView];
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

- (void)doInitYMLBarPlotView
{
    _capInsets = UIEdgeInsetsZero;
    _barCorners = 0;
    _barCornerRadii = CGSizeZero;
    _barColor = [UIColor colorWithHue:(2./3) saturation:0.60 brightness:0.85 alpha:1.0];
    _positionLabelOnBar = YES;
    _labelAlignment = NSTextAlignmentCenter;
    _shouldShowNoDataLabel = YES;
    
    _bars = [NSMutableArray array];
    _valueLabels = [NSMutableArray array];
    _titleLabels = [NSMutableArray array];
    _accessoryViews = [NSMutableArray array];
    
    _barShadowColor = [UIColor blackColor];
    _selectedBarShadowColor = [UIColor blackColor];
    _barShadowOpacity = 0.25;
    _selectedBarShadowOpacity = 1;
    _barShadowOffset = CGSizeMake(1, 0);
    _selectedBarShadowOffset = CGSizeMake(1, 0);
    _barShadowRadius = 0.5;
    _selectedBarShadowRadius = 0.5;
    
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
    
    [self updateBars];
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

#pragma mark - Public Instance Methods

- (void)setBarImage:(UIImage *)image capInsets:(UIEdgeInsets)insets
{
    [self setBarImage:image];
    [self setCapInsets:insets];
    
    // TODO: update all bar contents
}

- (void)setBarShapeByRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)radii
{
    [self setBarCorners:corners];
    [self setBarCornerRadii:radii];
    
    if (![self hasImage])
    {
        for (YMLBarSegmentLayer *segment in self.bars)
            segment.cornerRadii = radii;
    }
    
    [self setNeedsLayout];
}

- (void)setBarColor:(UIColor *)barColor
{
    if (barColor == _barColor)
        return;
    
    _barColor = barColor;

    if (![self hasImage])
    {
        for (YMLBarSegmentLayer *segment in self.bars)
            segment.fillColor = barColor;
    }    
}

#pragma mark - Private Instance Methods

- (BOOL)hasImage
{
    return self.barImage != nil;
}

- (BOOL)hasResizableImage
{
    if (!self.barImage)
        return NO;
    
    return !UIEdgeInsetsEqualToEdgeInsets(self.capInsets, UIEdgeInsetsZero);
}

- (BOOL)updateValueLabel:(UIView *)labelView atIndexPath:(NSIndexPath *)indexPath
{
    if (![super updateValueLabel:labelView atIndexPath:indexPath])
        return NO;
    
    if (self.orientation == YMLChartOrientationVertical)
    {
        UILabel *label = (UILabel *)labelView;
        label.adjustsFontSizeToFitWidth = YES;
        [label setMinimumScaleFactor:(2./3)];
    }
    
    return YES;
}

-(void)updateBars {
	
    CALayer *containerLayer = self.layer;
	BOOL isHorizontal = self.orientation == YMLChartOrientationHorizontal;
    [CATransaction setAnimationDuration:ANIMATION_DURATION];
    
	// Adjust number of slices
    int oldCount = [self.bars count];
    int newCount = [self.values count];
    //BOOL initialDisplay = (oldCount == 0);
	if (newCount > oldCount) {
		
		int count = newCount - oldCount;
		for (int i = 0; i < count; i++) {
            CALayer *bar = nil;
            if ([self hasImage])
            {
                bar = [CALayer layer];
                bar.contents = (__bridge id)self.barImage.CGImage;
                bar.contentsScale = [UIScreen mainScreen].scale;
                CGSize imageSize = self.barImage.size;
                bar.contentsCenter = CGRectMake(self.capInsets.left / imageSize.width, self.capInsets.top / imageSize.height, (imageSize.width - (self.capInsets.left + self.capInsets.right))/ imageSize.width, (imageSize.height - (self.capInsets.top + self.capInsets.bottom)) / imageSize.height);
            }
            else
            {
                YMLBarSegmentLayer *barSegment = [YMLBarSegmentLayer layer];
                barSegment.orientation = self.orientation;
                barSegment.fillColor = self.barColor;
                barSegment.needsDisplayOnBoundsChange = YES;
                barSegment.cornerRadii = self.barCornerRadii;
                barSegment.segmentPosition = SegmentPositionFirst | SegmentPositionLast;
                bar = barSegment;
            }
			bar.frame = self.bounds;
            
            [self.bars addObject:bar];
			[containerLayer addSublayer:bar];
            
            if (self.showLabels)
            {
                UIView *label = [self valueLabel];
                label.alpha = 0;
                [self.valueLabels addObject:label];
                [self.chart.labelContainerView addSubview:label];
            }
            
            if (self.showTitles)
            {
                UIView *label = [self titleLabel];
                label.alpha = 0;
                [self.titleLabels addObject:label];
                [self.chart.labelContainerView addSubview:label];
            }
            
            if (self.showAccessoryViews)
            {
                UIView *accessory = [self.accessoryDelegate accessoryViewForPlotView:self];
                [self.accessoryViews addObject:accessory];
                [self.chart.labelContainerView addSubview:accessory];
            }
		}
	}
	else if (newCount < oldCount) {
		int count = oldCount - newCount;
        
		for (int i = 0; i < count; i++) {
            [self removeLayer:[self.bars lastObject] fromSuperlayerAnimated:YES];
            [self.bars removeLastObject];
            
            if (self.showLabels)
            {
                [self removeView:[self.valueLabels lastObject] fromSuperviewAnimated:YES];
                [self.valueLabels removeLastObject];
            }
            if (self.showAccessoryViews)
            {
                [self removeView:[self.accessoryViews lastObject] fromSuperviewAnimated:YES];
                [self.accessoryViews removeLastObject];
            }
		}
        
        while ([self.titleLabels count] > newCount)
        {
            [self removeView:[self.titleLabels lastObject] fromSuperviewAnimated:YES];
            [self.titleLabels removeLastObject];
        }
	}
	
    // arrange the bars
	// Set the angles on the slices
	int index = 0;
	CGFloat count = newCount;
    CGFloat barInterval = count <= 1? 0 : ((isHorizontal?(self.bounds.size.height - (self.topMargin + self.bottomMargin + self.barWidth)) : self.bounds.size.width - (self.leftMargin + self.rightMargin + self.barWidth)) / (count - 1));
    if ([self.chart isKindOfClass:[YMLScrollableChartView class]])
    {
        YMLScrollableChartView *scrollableChart = (YMLScrollableChartView *)self.chart;
        barInterval = isHorizontal? scrollableChart.barInterval.height : scrollableChart.barInterval.width;
    }
    
    CGFloat labelMaxWidth = self.reservedWidth;
    if (self.showLabels)
    {
        NSUInteger valueCount = self.values.count;
        for (NSUInteger idx = 0; idx < valueCount; idx++) {
            
            UILabel *valueLabel = self.valueLabels[index];
            [self updateValueLabel:valueLabel atIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            if (!isHorizontal)
            {
                if (CGRectGetWidth(valueLabel.bounds) > (barInterval - self.labelGap.width))
                {
                    CGRect bounds = valueLabel.bounds;
                    bounds.size.width = floorf(barInterval - self.labelGap.width);
                    valueLabel.bounds = bounds;
                }
            }

            if (!self.positionLabelOnBar)
            {
                if (isHorizontal)
                {
                    if ((valueLabel.bounds.size.width + self.labelGap.width) > labelMaxWidth)
                        labelMaxWidth = valueLabel.bounds.size.width + self.labelGap.width;
                }
                else
                {
                    if ((valueLabel.bounds.size.height + self.labelGap.height) > labelMaxWidth)
                        labelMaxWidth = valueLabel.bounds.size.height + self.labelGap.height;
                }
            }
        
            index++;
        }        
    }
    
    if (self.showAccessoryViews)
    {
        index = 0;
        NSUInteger valuesCount = self.values.count;
        for (NSUInteger idx = 0; idx < valuesCount; idx++) {
            UIView *accessoryView = self.accessoryViews[index];
            [self.accessoryDelegate plotView:self updateAccessory:accessoryView atIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            CGSize accessorySize = accessoryView.frame.size;
            if (isHorizontal)
            {
                if ((accessorySize.width + self.accessoryGap.width) > labelMaxWidth)
                    labelMaxWidth = accessorySize.width + self.accessoryGap.width;
            }
            else
            {
                if ((accessorySize.height + self.accessoryGap.height) > labelMaxWidth)
                    labelMaxWidth = accessorySize.height + self.accessoryGap.height;
            }
            
            index++;
        }
    }
    
    if (labelMaxWidth > self.reservedWidth)
        self.reservedWidth = labelMaxWidth;
    
    CGFloat maxBarLength = isHorizontal? (self.bounds.size.width - (self.reservedWidth + self.leftMargin + self.rightMargin)) : (self.bounds.size.height - (self.reservedWidth + self.topMargin + self.bottomMargin));
    
    index = 0;
    NSMutableArray *positions = [NSMutableArray array];
    YMLAxisView *titleAxis = [self titleAxis];
    //[CATransaction setAnimationDuration:2];
    
    if ([self hasResizableImage])
    {
        [CATransaction setCompletionBlock:^{
            for (CALayer *bar in self.bars)
            {
                if (bar.frame.size.height <= (self.capInsets.top + 1))
                {
                    bar.contentsGravity = kCAGravityBottom;
                }
                else
                {
                    bar.contentsGravity = kCAGravityResize;
                }
            }
        }];
    }
    
    NSUInteger valuesCount = self.values.count;
    for (NSUInteger idx = 0; idx<valuesCount; idx++) {
        CALayer *bar = self.bars[index];
        BOOL isSelected = (index == self.selectedIndex);
        CGFloat barWidth = isSelected? (self.barWidth * self.selectedBarScaleFactor) : self.barWidth;
        CGFloat barLength = (maxBarLength * [self.normalizedValues[index] floatValue]);
        if (isnan(barLength))
            barLength = 0;
        CGRect oldFrame = bar.frame;
        if (isHorizontal)
        {
            bar.frame = CGRectIntegralMake(self.leftMargin, self.topMargin + (barInterval * index) + ((self.barWidth - barWidth) / 2), barLength, barWidth);
        }
        else
        {
            
            bar.frame = CGRectIntegralMake(self.leftMargin + (barInterval * index) + ((self.barWidth - barWidth) / 2), self.topMargin + (maxBarLength - barLength), barWidth, barLength);
        }
       
        CGPathRef oldPath = CGPathRetain(bar.shadowPath);
        
        bar.shadowOpacity = isSelected? self.selectedBarShadowOpacity : self.barShadowOpacity;
        bar.shadowRadius = isSelected? self.selectedBarShadowRadius : self.barShadowRadius;
        bar.shadowOffset = isSelected? self.selectedBarShadowOffset : self.barShadowOffset;
        bar.shadowColor = isSelected? self.selectedBarShadowColor.CGColor : self.barShadowColor.CGColor;
        
        CGPathRef newPath = [self shadowPathForBar:bar];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        [animation setFromValue:(__bridge id)oldPath];
        [animation setToValue:(__bridge id)newPath];
        [animation setFillMode:kCAFillModeForwards];
        [animation setRemovedOnCompletion:YES];
        [bar addAnimation:animation forKey:@"shadowPath"];
        //bar.shadowPath = newPath;
        
        CGPathRelease(oldPath);
        
        if (titleAxis)
        {
            CGPoint center = [self convertPoint:bar.position toView:titleAxis];
            if (isHorizontal)
                [positions addObject:@(center.y)];
            else
                [positions addObject:@(center.x)];
        }
        
        if (![self hasImage])
            [bar setNeedsDisplay];
        else if ([self hasResizableImage])
        {
            if (oldFrame.size.height >= (self.capInsets.top + 1) || bar.frame.size.height >= (self.capInsets.top + 1))
                bar.contentsGravity = kCAGravityResize;
        }

        if (self.showLabels)
        {
            UILabel *valueLabel = self.valueLabels[index];
            CGPoint oldPosition = valueLabel.layer.position;
            CGFloat oldAlpha = valueLabel.layer.opacity;
            CGFloat newAlpha = 1;
            
            CGPoint position = CGPointZero;
            if (self.positionLabelOnBar)
            {
                if (isHorizontal)
                {
                    switch (self.labelAlignment) {
                        case NSTextAlignmentLeft:
                            position = CGPointMake(CGRectGetMinX(bar.frame) + valueLabel.bounds.size.width / 2 + self.labelGap.width, CGRectGetMidY(bar.frame));
                            break;
                            
                        case NSTextAlignmentRight:
                            position = CGPointMake(CGRectGetMaxX(bar.frame) - (valueLabel.bounds.size.width / 2 + self.labelGap.width), CGRectGetMidY(bar.frame));
                            break;
                            
                        case NSTextAlignmentCenter:
                        default:
                            position = CGPointMake(CGRectGetMidX(bar.frame), CGRectGetMidY(bar.frame));
                            break;
                    }
                    
                    if (position.x < valueLabel.bounds.size.width / 2 + self.labelGap.width)
                        position.x = valueLabel.bounds.size.width / 2 + self.labelGap.width;
                }
                else
                {
                    position = CGPointMake(CGRectGetMidX(bar.frame), CGRectGetMinY(bar.frame) - (self.labelGap.height + (valueLabel.bounds.size.height / 2)));
                    if (position.y > CGRectGetMaxY(bar.frame) - (valueLabel.bounds.size.height / 2 + self.labelGap.height))
                        position.y = CGRectGetMaxY(bar.frame) - (valueLabel.bounds.size.height / 2 + self.labelGap.height);
                }
            }
            else
            {
                if (isHorizontal)
                    position = CGPointMake(CGRectGetMaxX(bar.frame) + self.labelGap.width + (valueLabel.bounds.size.width / 2), CGRectGetMidY(bar.frame));
                else
                    position = CGPointMake(CGRectGetMidX(bar.frame), CGRectGetMinY(bar.frame) - (self.labelGap.height + (valueLabel.bounds.size.height / 2)));
            }
            
            position = CGPointCenterIntegralScaled(position, valueLabel.bounds.size);
            
            if ([self.delegate respondsToSelector:@selector(plotView:newPositionForLabel:withPosition:atIndexPath:)])
                position = [self.delegate plotView:self newPositionForLabel:valueLabel withPosition:position atIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            BOOL opacityChange = oldAlpha != newAlpha;
            if (opacityChange)
            {
                // animate opacity
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                animation.fromValue = @(valueLabel.layer.opacity);
                animation.toValue = @(newAlpha);
                [valueLabel.layer addAnimation:animation forKey:@"opacity"];
            }
            valueLabel.layer.opacity = newAlpha;
            
            if (newAlpha == 1)
            {
                if (!opacityChange)
                {
                    CABasicAnimation *labelAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
                    [labelAnimation setFromValue:[NSValue valueWithCGPoint:oldPosition]];
                    [labelAnimation setToValue:[NSValue valueWithCGPoint:position]];
                    [labelAnimation setFillMode:kCAFillModeForwards];
                    [labelAnimation setRemovedOnCompletion:YES];
                    [valueLabel.layer addAnimation:labelAnimation forKey:@"position"];
                }
                
                valueLabel.layer.position = position;
            }
        }
        
        if (self.showTitles)
        {
            UILabel *titleLabel = self.titleLabels[index];
            [self updateTitleLabel:titleLabel atIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            CGRect oldFrame = titleLabel.frame;
            CGFloat oldAlpha = titleLabel.layer.opacity;
            CGFloat newAlpha = 1;
            
            // Note: horizontal support only, for vertical charts it's probably better to use a title axis
            CGSize titleSize = titleLabel.frame.size;
            CGRect titleFrame = CGRectIntegralMake(self.titleGap.width, CGRectGetMinY(bar.frame) - (titleSize.height + self.titleGap.height), titleSize.width, titleSize.height);
            
            BOOL opacityChange = oldAlpha != newAlpha;
            if (opacityChange)
            {
                // animate opacity
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                animation.fromValue = @(titleLabel.layer.opacity);
                animation.toValue = @(newAlpha);
                [titleLabel.layer addAnimation:animation forKey:@"opacity"];
            }
            titleLabel.layer.opacity = newAlpha;
            
            if (newAlpha == 1)
            {
                CGPoint position = CGPointMake(CGRectGetMidX(titleFrame), CGRectGetMidY(titleFrame));
                CGRect bounds = (CGRect){CGPointZero, titleFrame.size};
                if (!opacityChange)
                {
                    CGPoint oldPosition = CGPointMake(CGRectGetMidX(oldFrame), CGRectGetMidY(oldFrame));
                    CGRect oldBounds = (CGRect){CGPointZero, oldFrame.size};
                    
                    CABasicAnimation *titleAnimation;
                    titleAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
                    [titleAnimation setFromValue:[NSValue valueWithCGPoint:oldPosition]];
                    [titleAnimation setToValue:[NSValue valueWithCGPoint:position]];
                    [titleAnimation setFillMode:kCAFillModeForwards];
                    [titleAnimation setRemovedOnCompletion:YES];
                    [titleLabel.layer addAnimation:titleAnimation forKey:@"position"];
                    
                    titleAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
                    [titleAnimation setFromValue:[NSValue valueWithCGRect:oldBounds]];
                    [titleAnimation setToValue:[NSValue valueWithCGRect:bounds]];
                    [titleAnimation setFillMode:kCAFillModeForwards];
                    [titleAnimation setRemovedOnCompletion:YES];
                    [titleLabel.layer addAnimation:titleAnimation forKey:@"bounds"];
                }
                
                titleLabel.layer.position = position;
                titleLabel.layer.bounds = bounds;
            }
        }
        
        if (self.showAccessoryViews)
        {
            UIView *accessoryView = self.accessoryViews[index];
            
            CGSize accessorySize = accessoryView.frame.size;
            CGFloat accessoryValue = [self.accessoryDelegate plotView:self normalizedValueAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            CGFloat accessoryBarLength = isnormal(accessoryValue)? scaled_roundf(maxBarLength * accessoryValue) : 0;
            if (isHorizontal)
            {
                if (self.showLabels && self.positionLabelOnBar)
                {   // handle case where on bar label is past end of label - needs to be set at max of valueLabel.maxX + gap.
                    UILabel *valueLabel = self.valueLabels[index];
                    CGFloat right = CGRectGetMaxX(valueLabel.frame);
                    if (right > accessoryBarLength)
                        accessoryBarLength = right;
                }
                accessoryView.layer.position = CGPointIntegralMake(CGRectGetMinX(bar.frame) + accessoryBarLength + self.accessoryGap.width + (accessorySize.width / 2), CGRectGetMidY(bar.frame), accessorySize);
            }
            else
                accessoryView.layer.position = CGPointIntegralMake(CGRectGetMidX(bar.frame), CGRectGetMaxY(bar.frame) - (accessoryBarLength + self.accessoryGap.height + (accessorySize.height / 2)), accessorySize);
        }
        
        index++;
    }
    
    // if needed hide zero values and display No Data
    BOOL hideData = self.values != nil && self.maxTotalValue == 0 && _shouldShowNoDataLabel;
    if (!hideData && self.values.count == 0)
        hideData = YES;
    [self.chart showNoDataLabel:hideData];
    for (UIView *label in self.valueLabels)
        label.hidden = hideData;
    for (UIView *label in self.titleLabels)
        label.hidden = hideData;
    for (UIView *accessory in self.accessoryViews)
        accessory.hidden = hideData;

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

- (void)removeLayer:(CALayer *)layer fromSuperlayerAnimated:(BOOL)animated
{
    if (!animated)
    {
        [layer removeFromSuperlayer];
        return;
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [layer removeFromSuperlayer];
    }];
    
    layer.opacity = 0;
    [CATransaction commit];
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
    if ((self.showLabels && !self.positionLabelOnBar) || self.showAccessoryViews || self.reservedWidth > 0)
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

#pragma mark - Touch Gesture handling

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath notify:(BOOL)notify
{
    int newSelection = indexPath? indexPath.row : -1;
    if (self.selectedIndex != newSelection)
    {
        self.selectedIndex = newSelection;
        if (notify && indexPath && [self.touchDelegate respondsToSelector:@selector(plotView:didSelectItemAtIndexPath:)])
            [self.touchDelegate plotView:self didSelectItemAtIndexPath:indexPath];
        
        [self setNeedsLayout];
    }
}

#pragma mark - Tooltips

- (NSIndexPath *)featureIndexForPoint:(CGPoint)point
{
    __block int barIndex = -1;
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
            barIndex = idx;
            *stop = YES;
        }
    }];
    
    if (barIndex < 0)
        return nil;
    return [NSIndexPath indexPathForRow:barIndex inSection:0];
}

@end
