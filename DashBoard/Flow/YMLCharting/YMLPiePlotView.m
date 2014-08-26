//
//  YMLPiePlotView.m
//  Avero
//
//  Created by Mark Pospesel on 12/3/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import "YMLPiePlotView.h"
#import <QuartzCore/QuartzCore.h>

#import "YMLPieSliceLayer.h"
#import "YMLChartView.h"
#import "YMLPiePlotTitleInfo.h"
#import "NSArray+Helpers.h"
#import "YMLCommon.h"
#import "Enumerations.h"

#define ANIMATION_DURATION 0.5

@interface YMLPiePlotView()

@property (nonatomic, strong) NSMutableArray *pieSliceLayers;
@property (nonatomic, strong) NSMutableArray *normalizedValues;
@property (nonatomic, strong) NSMutableArray *valueLabels;
@property (nonatomic, strong) NSMutableArray *titleLabels;
@property (nonatomic, strong) NSMutableArray *titleLines;
@property (nonatomic, assign) CGFloat largestSlice;
@property (nonatomic, assign) CGFloat sliceTotal;
@property (nonatomic, strong) CALayer *containerLayer;

@end

@implementation YMLPiePlotView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self doInitYMLPiePlotView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self doInitYMLPiePlotView];
    }
    return self;
}

- (void)doInitYMLPiePlotView
{
    _pieCenter = (CGPoint){0.5, 0.5};
    _radius = 0.475;
    _selectedRadius = 0.5;
    _selectedIndex = -1;
    _strokeWidth = 2;
    _labelPosition = 0.5;
    _labelByPercent = NO;
    _startAngle = -M_PI / 2;
    _clockwise = YES;
    _animateOnFirstLoad = YES;
    
    _containerLayer = [CALayer layer];
    _containerLayer.frame = self.bounds;
    self.containerLayer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerLayer.shadowOpacity = 0;
    self.containerLayer.shadowOffset = CGSizeMake(0, 0);
    self.containerLayer.shadowRadius = 3;
    
    _pieSliceLayers = [NSMutableArray array];
    _valueLabels = [NSMutableArray array];
    _titleLabels = [NSMutableArray array];
    _titleLines = [NSMutableArray array];
    
    [self.layer addSublayer:_containerLayer];
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
    
    [self updateSlices];
}

#pragma mark - Properties

- (NSArray *)percentValues
{
    return _normalizedValues; // should I cast to NSArray to prevent abuse?
}

- (void)valuesDidChange;
{
    self.largestSlice = 0;
	self.normalizedValues = [NSMutableArray array];
    self.sliceTotal = 0;
    if (self.values)
    {
        for (NSNumber *value in self.values)
        {
            CGFloat floatValue = value.floatValue;
            if (isnormal(floatValue))
            {
                self.sliceTotal += floatValue;
                if (floatValue > self.largestSlice)
                    self.largestSlice = floatValue;
            }
        }
        
        for (NSNumber *value in self.values)
        {
            [self.normalizedValues addObject:isnormal(value.floatValue) && isnormal(self.sliceTotal)? @(value.floatValue / self.sliceTotal) : @(0.0)];
        }
    }
    
    [self setNeedsLayout];
}

- (NSArray *)slices
{
    return [self.containerLayer sublayers];
}

#pragma mark - Private Instance Methods

-(void)updateSlices {

    [CATransaction begin];
    [CATransaction setAnimationDuration:ANIMATION_DURATION];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
	// Adjust number of slices
    BOOL boundsChanged = !CGRectEqualToRect(self.containerLayer.frame, self.bounds);
    self.containerLayer.frame = self.bounds;
    
    int oldCount = [self.pieSliceLayers count];
    int newCount = [self.normalizedValues count];
	if (newCount > oldCount) {
		
		int count = newCount - oldCount;
		for (int i = 0; i < count; i++) {
            CGFloat initAngle = (oldCount > 0)? self.startAngle + (2 * M_PI) : self.startAngle;
			YMLPieSliceLayer *slice = [[YMLPieSliceLayer alloc] initWithStartAngle:initAngle endAngle:initAngle];
			slice.frame = self.bounds;
            //slice.strokeColor = [UIColor whiteColor];
            slice.shadowRadius = 6;
			slice.shadowOffset = CGSizeZero;
			[self.containerLayer addSublayer:slice];
            [self.pieSliceLayers addObject:slice];
            
            if (self.showLabels)
            {
                UIView *labelView = nil;
                if (self.delegate && [self.delegate respondsToSelector:@selector(plotView:labelForSliceAtIndex:)])
                {
                    labelView = [self.delegate plotView:self labelForSliceAtIndex:i];
                }
                else
                {
                    labelView = [self valueLabel];
                }
                labelView.alpha = 0;
                [self.valueLabels addObject:labelView];
                [self.chart.labelContainerView addSubview:labelView];
            }
            if (self.showTitles)
            {
                UIView *titleView = nil;
                if (self.delegate && [self.delegate respondsToSelector:@selector(plotView:titleForSliceAtIndex:)])
                {
                    titleView = [self.delegate plotView:self titleForSliceAtIndex:i];
                }
                else
                {
                    titleView = [self titleLabel];
                }
                
                titleView.layer.opacity = 0;
                [self.titleLabels addObject:titleView];
                [self.chart.labelContainerView addSubview:titleView];
                
                CAShapeLayer *titleLine = [CAShapeLayer layer];
                titleLine.lineWidth = 1;
                titleLine.opacity = 0;
                titleLine.fillColor = [UIColor clearColor].CGColor;
                [self.titleLines addObject:titleLine];
                [self.chart.labelContainerView.layer addSublayer:titleLine];
            }
		}
	}
	else if (newCount < oldCount) {
        for (int i = newCount; i < oldCount; i++) {
            YMLPieSliceLayer *slice = [self.pieSliceLayers objectAtIndex:i];
            [slice removeFromSuperlayerAnimated:YES];
        }
        
        [self.pieSliceLayers removeObjectsInRange:NSMakeRange(newCount, oldCount - newCount)];
        
        while ([self.valueLabels count] > newCount)
        {
            [self removeView:[self.valueLabels lastObject] fromSuperviewAnimated:YES];
            [self.valueLabels removeLastObject];
        }
        while ([self.titleLabels count] > newCount)
        {
            [self removeView:[self.titleLabels lastObject] fromSuperviewAnimated:YES];
            [self.titleLabels removeLastObject];
        }
        while ([self.titleLines count] > newCount)
        {
            [self removeLayer:[self.titleLines lastObject] fromSuperlayerAnimated:YES];
            [self.titleLines removeLastObject];
        }
	}
	
	// Set the angles on the slices
	CGFloat count = newCount;
    CGRect plotFrame = CGRectMake(self.leftMargin, self.topMargin, self.bounds.size.width - (self.leftMargin + self.rightMargin), self.bounds.size.height - (self.topMargin + self.bottomMargin));
    CGPoint centerPoint = CGPointMake(plotFrame.origin.x + (plotFrame.size.width * _pieCenter.x), plotFrame.origin.y + (plotFrame.size.height * _pieCenter.y));
    CGFloat radius = MIN(plotFrame.size.width, plotFrame.size.height) * self.radius;

    //CGFloat duration = 0.5;
    
    //[CATransaction begin];
    NSMutableArray *rightSide = [NSMutableArray array];
    NSMutableArray *leftSide = [NSMutableArray array];
    
    
    int index = 0;
    CGFloat startAngle = self.startAngle;
    int colorCount = [self.gradients count];
    
    // need to position selected index label 1st
    if (self.showLabels && self.selectedIndex > 0)
    {
        UIView *labelView = self.valueLabels[index];
        if (self.delegate && [self.delegate respondsToSelector:@selector(plotView:updateLabel:forSliceAtIndex:)])
        {
            [self.delegate plotView:self updateLabel:labelView forSliceAtIndex:self.selectedIndex];
        }
        else
        {
            [self updateValueLabel:labelView atIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
        }
    }
    
    for (NSNumber *num in self.normalizedValues) {
		CGFloat angle = num.floatValue * 2 * M_PI * (self.clockwise? 1 : -1);
		
		YMLPieSliceLayer *slice = [self.pieSliceLayers objectAtIndex:index];
        
        if (index < colorCount)
            slice.colors = self.gradients[index];
        else
            slice.colors = @[(id)[UIColor colorWithHue:index/count saturation:0.80 brightness:0.95 alpha:1.0].CGColor, (id)[UIColor colorWithHue:index/count saturation:0.75 brightness:0.75 alpha:1.0].CGColor];
        
        //slice.strokeWidth = self.strokeWidth;
        slice.frame = plotFrame;
        slice.zPosition = index == self.selectedIndex? count : index;
        slice.shadowOpacity = index == self.selectedIndex? 1 : 0;
        UIColor *shadowColor = [[UIColor colorWithCGColor:(__bridge CGColorRef)[slice.colors firstObjectOrNil]] colorDarkerByPercent:25];
        slice.shadowColor = shadowColor.CGColor;
        
        [slice setNeedsLayout];
        [slice setStartAngle:startAngle endAngle:(startAngle + angle) radius:(index == self.selectedIndex? self.selectedRadius : self.radius) animated:self.animateOnFirstLoad];
        
        CGFloat midAngle = startAngle + (angle / 2);
        if (newCount == 1 || (midAngle >= - M_PI / 2 && midAngle <= M_PI / 2))
            [rightSide addObject:@(index)];
        else
            [leftSide addObject:@(index)];
        
        if (self.showLabels)
        {
            NSNumber *value = [self.values safeObjectAtIndex:index];
            UIView *labelView = self.valueLabels[index];
            CGFloat oldAlpha = labelView.layer.opacity;
            CGFloat newAlpha = 0;
            CGPoint oldCenter = labelView.layer.position;
            CGPoint newCenter = oldCenter;
            
            if (value.floatValue == 0 || num.floatValue == 0)
            {
                newAlpha = 0;
            }
            else
            {
                newAlpha = 1;
                CGFloat sliceRadius = MIN(plotFrame.size.width, plotFrame.size.height) * (index == self.selectedIndex? self.selectedRadius : self.radius);
                if (self.delegate && [self.delegate respondsToSelector:@selector(plotView:updateLabel:forSliceAtIndex:)])
                {
                    [self.delegate plotView:self updateLabel:labelView forSliceAtIndex:index];
                }
                else
                {
                    [self updateValueLabel:labelView atIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                }
                
                if (fabsf(angle) >= 2 * M_PI)
                    newCenter = centerPoint; // one big slice of 100%
                else
                    newCenter = CGPointMake(centerPoint.x + cosf(midAngle)*(sliceRadius * self.labelPosition), centerPoint.y + sinf(midAngle)*(sliceRadius * self.labelPosition));
                
                newCenter = CGPointCenterIntegralScaled(newCenter, labelView.bounds.size);
                labelView.layer.position = newCenter; // Test
                
                if (index != self.selectedIndex)
                {
                    for (int i = 0; i < index; i++)
                    {
                        UIView *label2 = self.valueLabels[i];
                        if (label2.alpha == 0)
                            continue;
                        
                        if ([self label:labelView intersectsLabel:label2])
                        {
                            newAlpha = 0;
                            break;
                        }
                    }
                    
                    // finally, check against selected index (if haven't done so already)
                    if (newAlpha > 0 && self.selectedIndex > index)
                    {
                        UIView *label2 = self.valueLabels[self.selectedIndex];
                        
                        if ([self label:labelView intersectsLabel:label2])
                        {
                            newAlpha = 0;
                        }
                    }
                }
            }
            
            BOOL opacityChange = oldAlpha != newAlpha;
            if (self.animateOnFirstLoad && opacityChange)
            {
                // animate opacity
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                animation.fromValue = @(labelView.layer.opacity);
                animation.toValue = @(newAlpha);
                [labelView.layer addAnimation:animation forKey:@"opacity"];
            }
            labelView.layer.opacity = newAlpha;
            
            if (newAlpha == 1)
            {
                if (self.animateOnFirstLoad && !opacityChange)
                {
                    // animate center
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
                    animation.fromValue = [NSValue valueWithCGPoint:oldCenter];
                    animation.toValue = [NSValue valueWithCGPoint:newCenter];
                    [labelView.layer addAnimation:animation forKey:@"position"];
                }
                
                labelView.layer.position = newCenter;
            }
        }
        
        startAngle += angle;
		index++;
	}
    
    BOOL noData = self.values != nil && self.sliceTotal == 0;
    [self.chart showNoDataLabel:noData animated:YES];
    
    if (self.showTitles)
    {
        [self positionTitles:rightSide centerPoint:centerPoint radius:radius onRight:YES startFromTop:NO sorted:NO];
        [self positionTitles:leftSide centerPoint:centerPoint radius:radius onRight:NO startFromTop:NO sorted:NO];
    }
    
    
    if (self.animateOnFirstLoad && (oldCount > 0) != (newCount > 0))
    {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.containerLayer.shadowOpacity = 0.5;
        [CATransaction commit];
        
        NSArray *keyframes = [YMLPieSliceLayer keyframePathsWithDuration:ANIMATION_DURATION sourceStartAngle:self.startAngle sourceEndAngle:self.startAngle + (oldCount > 0? 2 * M_PI : 0) destinationStartAngle:self.startAngle + (oldCount > 0? 2 * M_PI : 0) destinationEndAngle:self.startAngle + 2 * M_PI centerPoint:centerPoint size:plotFrame.size sourceRadiusPercent:self.radius destinationRadiusPercent:self.radius];
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            if (self.sliceTotal > 0)
            {
                self.containerLayer.shadowPath = [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(centerPoint.x - radius, centerPoint.y - radius, radius * 2, radius * 2)] CGPath];
            }
            else
            {
                self.containerLayer.shadowPath = nil;
                self.containerLayer.shadowOpacity = 0;
            }
            
            [self.containerLayer removeAnimationForKey:@"shadowPath"];
        }];
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"shadowPath"];
        animation.values = keyframes;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [self.containerLayer addAnimation:animation forKey:@"shadowPath"];
        [self.containerLayer setShadowPath:(CGPathRef)[keyframes lastObject]];
        
        [CATransaction commit];
    }
    else
    {
        if (self.sliceTotal > 0)
        {
            self.containerLayer.shadowPath = [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(centerPoint.x - radius, centerPoint.y - radius, radius * 2, radius * 2)] CGPath];
             self.containerLayer.shadowOpacity = 0.5;
        }
        else
        {
            self.containerLayer.shadowPath = nil;
            self.containerLayer.shadowOpacity = 0;
        }
    }
    
    if (boundsChanged)
        [self.containerLayer setNeedsDisplay];
    
    [CATransaction commit];
    [self setAnimateOnFirstLoad:YES];
}

- (BOOL)label:(UIView *)labelView intersectsLabel:(UIView *)label2
{
    BOOL intersects = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(plotView:label:intersectsLabel:)])
    {
        intersects = [self.delegate plotView:self label:labelView intersectsLabel:label2];
    }
    else
    {
        intersects = CGRectIntersectsRect(labelView.frame, label2.frame);
    }
    
    return intersects;
}

- (UIView *)titleForSlice:(NSUInteger)sliceIndex maxWidth:(CGFloat)maxWidth onRight:(BOOL)isRightSide
{
    UIView *titleView = [self.titleLabels safeObjectAtIndex:sliceIndex];
    if (self.delegate && [self.delegate respondsToSelector:@selector(plotView:updateTitle:forSliceAtIndex:maxWidth:rightSide:)])
    {
        [self.delegate plotView:self updateTitle:titleView forSliceAtIndex:sliceIndex maxWidth:maxWidth rightSide:isRightSide];
    }
    else
    {
        [self updateTitleLabel:titleView atIndexPath:[NSIndexPath indexPathForRow:sliceIndex inSection:0]];
        UILabel *title = (UILabel *)titleView;
        title.textAlignment = isRightSide? NSTextAlignmentLeft : NSTextAlignmentRight;
    }
    
    return titleView;
}

- (void)positionTitles:(NSArray *)sliceIndexes centerPoint:(CGPoint)centerPoint radius:(CGFloat)radius onRight:(BOOL)isRightSide startFromTop:(BOOL)startFromTop sorted:(BOOL)sorted
{
    NSMutableArray *infos = [NSMutableArray arrayWithCapacity:[sliceIndexes count]];
    
    for (NSNumber *number in sliceIndexes) {
        YMLPiePlotTitleInfo *info = [YMLPiePlotTitleInfo new];
        UIView *titleView = [self.titleLabels safeObjectAtIndex:[number unsignedIntegerValue]];
        info.oldFrame = titleView.frame;
        info.wasRightSide = CGRectGetMidX(titleView.frame) > centerPoint.x;
        [infos addObject:info];
    }
    
    __block CGFloat yOffset = self.topMargin;
    __block CGFloat requiredHeight = 0;
    __block BOOL labelsFit = YES;
    __block BOOL wouldBenefitFromStartFromTop = NO;
    CGFloat availableHeight = CGRectGetHeight(self.bounds) - self.topMargin - self.bottomMargin;
    
    CGFloat maxWidth = floorf(CGRectGetMaxX(self.bounds) - self.rightMargin - (centerPoint.x + radius + self.titleGap.width + 5));
    [sliceIndexes enumerateObjectsWithOptions:((self.isClockwise == isRightSide)? 0 : NSEnumerationReverse) usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        YMLPiePlotTitleInfo *titleInfo = infos[idx];
        
        NSUInteger i = [obj unsignedIntegerValue];
        UIView *titleView = [self titleForSlice:i maxWidth:maxWidth onRight:isRightSide];
        CGSize titleSize = titleView.bounds.size;
        if (titleSize.width > maxWidth)
            titleSize.width = maxWidth;
        YMLPieSliceLayer *slice = [self.pieSliceLayers objectAtIndex:i];
        CGFloat midAngle = slice.midAngle;
        if ([self.pieSliceLayers count] == 1)
            midAngle = isRightSide? 0 : M_PI; // for single 360° slice, place it on middle of this side
        CGFloat y = startFromTop? yOffset : (centerPoint.y + sinf(midAngle) * (radius * 0.9) - (titleSize.height / 2));
        if (y <= yOffset)
            y = yOffset;
        else
            wouldBenefitFromStartFromTop = YES;
 
        if (isRightSide)
            titleInfo.frame = CGRectIntegralMake(CGRectGetMaxX(self.bounds) - (self.rightMargin + maxWidth), y, titleSize.width, titleSize.height);
        else
            titleInfo.frame = CGRectIntegralMake(self.leftMargin + (maxWidth - titleSize.width), y, titleSize.width, titleSize.height);

        CAShapeLayer *titleLine = self.titleLines[i];
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGSize lineSize = CGSizeMake(2, 1);
        
        if (isRightSide)
        {
            [path moveToPoint:CGPointIntegralMake(CGRectGetMaxX(self.bounds) - (self.rightMargin + maxWidth + 5), CGRectGetMidY(titleInfo.frame), lineSize)];
        }
        else
        {
            [path moveToPoint:CGPointIntegralMake(self.leftMargin + maxWidth + 5, CGRectGetMidY(titleInfo.frame), lineSize)];
        }
        [path addLineToPoint:CGPointIntegralMake(centerPoint.x + cosf(midAngle) * (radius * 0.9), centerPoint.y + sinf(midAngle) * (radius * 0.9), lineSize)];
        titleInfo.path = path;
        titleLine.strokeColor = self.titleTextColor.CGColor;
        
        if (CGRectGetMaxY(titleInfo.frame) > CGRectGetMaxY(self.bounds) - self.bottomMargin)
        {
            titleInfo.alpha = 0;
            labelsFit = NO;
        }
        else
        {
            titleInfo.alpha = 1;
            titleView.hidden = NO;
            titleLine.hidden = NO;
            yOffset = CGRectGetMaxY(titleInfo.frame) + self.titleGap.height;
            requiredHeight += CGRectGetMaxY(titleInfo.frame) + ((idx < [sliceIndexes count] - 1)? self.titleGap.height : 0);
        }
    }];

    if (!labelsFit)
    {
        if (!startFromTop && wouldBenefitFromStartFromTop)
        {
            [self positionTitles:sliceIndexes centerPoint:centerPoint radius:radius onRight:isRightSide startFromTop:YES sorted:sorted];
            return;
        }
        else if (!sorted)
        {
            NSMutableArray *sorted = [NSMutableArray arrayWithArray:[sliceIndexes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSNumber *val1 = self.values[[obj1 unsignedIntegerValue]];
                NSNumber *val2 = self.values[[obj2 unsignedIntegerValue]];
               return [val2 compare:val1];
            }]];
            
            CGFloat usedHeight = 0;
            NSUInteger visibleTitleCount = 0;
            for (NSNumber *index in sorted)
            {
                //UIView *titleView = [self titleForSlice:[index unsignedIntegerValue] maxWidth:maxWidth onRight:isRightSide];
                YMLPiePlotTitleInfo *titleInfo = infos[[sliceIndexes indexOfObject:index]];
                CGSize titleSize = titleInfo.frame.size;
                if (usedHeight + titleSize.height > availableHeight)
                {
                    break;
                }
                else
                {                    
                    usedHeight += titleSize.height + self.titleGap.height;
                    visibleTitleCount++;
                }
            }
            
            for (NSUInteger idx = visibleTitleCount; idx < [sorted count]; idx++)
            {
                UIView *titleView = [self titleForSlice:[sorted[idx] unsignedIntegerValue] maxWidth:maxWidth onRight:isRightSide];
                CAShapeLayer *titleLine = self.titleLines[[sorted[idx] unsignedIntegerValue]];
                
                if (self.animateOnFirstLoad && titleLine.opacity > 0)
                {
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                    animation.fromValue = @(titleLine.opacity);
                    animation.toValue = @0;
                    
                    [titleLine addAnimation:animation forKey:@"opacity"];
                    
                    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
                    animation2.fromValue = @(titleView.layer.opacity);
                    animation2.toValue = @0;
                    
                    [titleView.layer addAnimation:animation2 forKey:@"opacity"];
                }
                
                titleView.layer.opacity = 0;
                titleLine.opacity = 0;
            }
            
            [sorted removeObjectsInRange:NSMakeRange(visibleTitleCount, [sorted count] - visibleTitleCount)];
            
            NSArray *unsorted = [sorted sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 compare:obj2];
            }];
            [self positionTitles:unsorted centerPoint:centerPoint radius:radius onRight:isRightSide startFromTop:NO sorted:YES];
            return;
        }
    }
    
    // animate    
    [infos enumerateObjectsUsingBlock:^(YMLPiePlotTitleInfo *info, NSUInteger idx, BOOL *stop) {
        NSUInteger i = [sliceIndexes[idx] unsignedIntegerValue];
        UIView *titleView = [self.titleLabels objectAtIndex:i];
        CAShapeLayer *titleLine = [self.titleLines objectAtIndex:i];
        
        CGPoint oldCenter = CGPointMake(CGRectGetMidX(titleView.frame), CGRectGetMidY(titleView.frame));
        CGPoint newCenter = CGPointMake(CGRectGetMidX(info.frame), CGRectGetMidY(info.frame));
        //titleView.alpha = info.alpha;
        
        BOOL opacityChange = titleLine.opacity != info.alpha;
        if (self.animateOnFirstLoad && opacityChange)
        {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation.fromValue = @(titleLine.opacity);
            animation.toValue = @(info.alpha);
            [titleLine addAnimation:animation forKey:@"opacity"];
            
            CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
            animation2.fromValue = @(titleView.layer.opacity);
            animation2.toValue = @(info.alpha);
            [titleView.layer addAnimation:animation2 forKey:@"opacity"];
        }
        titleLine.opacity = info.alpha;
        titleView.layer.opacity = info.alpha;
        
        if (info.alpha == 1)
        {
            // if we're not hiding, set path
            titleView.bounds = (CGRect){CGPointZero, info.frame.size};
            if (info.wasRightSide)
                oldCenter.x = CGRectGetMinX(info.oldFrame) + (CGRectGetWidth(info.frame) / 2);
            else
                oldCenter.x = CGRectGetMaxX(info.oldFrame) - (CGRectGetWidth(info.frame) / 2);
            
            if (self.animateOnFirstLoad && !opacityChange)
            {
                // if we're not fading in, animate path
                CGPathRef oldPath = CGPathRetain(titleLine.path);
                titleLine.path = info.path.CGPath;
                
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
                animation.fromValue = (__bridge id)(oldPath);
                animation.toValue = (__bridge id)(info.path.CGPath);
                
                [titleLine addAnimation:animation forKey:@"path"];
                CGPathRelease(oldPath);
                
                CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"position"];
                animation2.fromValue = [NSValue valueWithCGPoint:oldCenter];
                animation2.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(info.frame), CGRectGetMidY(info.frame))];
                
                [titleView.layer addAnimation:animation2 forKey:@"position"];
                titleView.layer.position = newCenter;
            }
            else
            {
                titleLine.path = info.path.CGPath;
                titleView.layer.position = newCenter;
            }
        }
    }];
}

- (void)removeView:(UIView *)view fromSuperviewAnimated:(BOOL)animated
{
    if (!animated)
    {
        [view removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
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
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = ANIMATION_DURATION;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fromValue = @(layer.opacity);
    animation.toValue = @0;
    
    layer.opacity = 0;
    [layer addAnimation:animation forKey:@"opacity"];
    [CATransaction commit];
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

#pragma mark - Value labels

- (NSString *)valueLabel:(UIView *)labelView textForIndexPath:(NSIndexPath *)indexPath
{
    if (!self.labelByPercent)
        return [super valueLabel:labelView textForIndexPath:indexPath];
    
    return [self displayValueForValue:[self.normalizedValues safeObjectAtIndex:indexPath.row]];
}

#pragma mark - Tooltips

- (BOOL)isPointOverFeature:(CGPoint)point
{
    if (!self.showTips)
        return NO;
    
    if ([self.values count] == 0 || self.sliceTotal == 0)
        return NO;
    
    CGRect plotFrame = CGRectMake(self.leftMargin, self.topMargin, self.bounds.size.width - (self.leftMargin + self.rightMargin), self.bounds.size.height - (self.topMargin + self.bottomMargin));
    CGPoint centerPoint = CGPointMake(plotFrame.origin.x + (plotFrame.size.width * _pieCenter.x), plotFrame.origin.y + (plotFrame.size.height * _pieCenter.y));
    CGFloat radius = MIN(plotFrame.size.width, plotFrame.size.height) * self.radius;
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(centerPoint.x - radius, centerPoint.y - radius, radius * 2, radius * 2)];
    
    return [circle containsPoint:point];
}

- (NSIndexPath *)featureIndexForPoint:(CGPoint)point
{
    //if (![self isPointOverFeature:point])
      //  return nil; // make sure point is in circle (quick check)
    
    __block int sliceIndex = -1;
    [self.pieSliceLayers enumerateObjectsUsingBlock:^(YMLPieSliceLayer *slice, NSUInteger idx, BOOL *stop) {
        if (CGPathContainsPoint(slice.path, NULL, [slice convertPoint:point fromLayer:self.layer], YES))
        {
            *stop = YES;
            sliceIndex = idx;
        }
    }];
    
    if (sliceIndex < 0)
        return nil;
    return [NSIndexPath indexPathForRow:sliceIndex inSection:0];
}

@end


