//
//  YMLPlotView.m
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/19/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import "YMLPlotView.h"
#import "YMLAxisView.h"
#import "YMLChartView.h"
#import "NSArray+Helpers.h"
#import "YMLDefaultFormatter.h"
#import <QuartzCore/QuartzCore.h>

@interface YMLPlotView()

@property (nonatomic, weak) YMLChartView *chart;
@property (nonatomic, assign) YMLChartOrientation orientation;

@end

@implementation YMLPlotView

- (id)init
{
    return [self initWithOrientation:YMLChartOrientationVertical];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _orientation = YMLChartOrientationVertical;
        [self doInitYMLPlotView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _orientation = YMLChartOrientationVertical;
        [self doInitYMLPlotView];
    }
    return self;
}

- (id)initWithOrientation:(YMLChartOrientation)orientation
{
    self = [super init];
    if (self)
    {
        _orientation = orientation;
    }
    return self;
}

- (void)doInitYMLPlotView
{
    _textColor = [UIColor blackColor];
    _shadowColor = nil;
    _shadowOffset = CGSizeMake(0, 1);
    _font = [UIFont systemFontOfSize:15];
    _labelGap = CGSizeMake(10, 10);
    _noDataString = @"No Data";
    _showInLinePercentage = NO;
    
    // accessories
    _showAccessoryViews = NO;
    _accessoryGap = CGSizeMake(10, 10);
    
    // titles
    _titleTextColor = _textColor;
    _titleFont = _font;
    _titleShadowColor = [UIColor whiteColor];
    _titleShadowOffset = CGSizeMake(0, 1);
    _titleGap = CGSizeMake(10, 0);
    _showTitles = YES;
    
    // percent values
    _percentTextColor = _textColor;
    _percentFont = _font;
    _percentShadowColor = nil;
    _percentShadowOffset = CGSizeMake(0, 1);
    _showPercentLabels = NO;
    
    // tips
    _showTips = NO;
    _tipTextColor = _textColor;
    _tipTextShadowColor = nil;
    _tipTextShadowOffset = CGSizeMake(0, 1);
    _tipBackgroundColor = [UIColor colorWithWhite:0.975 alpha:0.85];
    _tipFont = _font;
    _tipGap = CGSizeMake(10, 5);
    _useTitleForTips = NO;
    
    self.clipsToBounds = YES;
    self.userInteractionEnabled = NO;
}

- (void)dealloc
{
    _chart = nil;
}

- (void)addedToChart:(YMLChartView *)chart
{
    self.chart = chart;
}

- (YMLAxisView *)scaleAxis
{
    if (self.scaleIndex > 0)
        return [[self.chart axisViewsForPosition:self.scalePosition] safeObjectAtIndex:self.scaleIndex];
    
    return [self.chart axisViewForPosition:self.scalePosition];
}

- (YMLAxisView *)titleAxis
{
    if (self.titleIndex > 0)
        return [[self.chart axisViewsForPosition:self.titlePosition] safeObjectAtIndex:self.titleIndex];
    
    return [self.chart axisViewForPosition:self.titlePosition];
}

- (BOOL)showTitles
{
    return _showTitles && ([self.titles count] > 0);
}

- (void)setValues:(NSArray *)values
{
	_values = values;
    
    [self valuesDidChange];
    
    [self setNeedsLayout];
}

- (void)valuesDidChange
{
    // override and implement
}

- (NSString *)displayValueForValue:(id)value
{
    id<YMLAxisFormatter> formatter = self.formatter;
    if (!formatter)
        formatter = [YMLDefaultFormatter defaultFormatter];
    
    return [formatter displayValueForValue:value];
}

- (NSString *)displayValueForTitle:(id)value
{
    id<YMLAxisFormatter> formatter = self.titleFormatter;
    if (!formatter)
        formatter = [YMLDefaultFormatter defaultFormatter];
    
    return [formatter displayValueForValue:value];
}

- (NSString *)displayValueForPercentLabel:(id)value
{
    id<YMLAxisFormatter> formatter = self.percentageFormatter;
    if (!formatter)
        formatter = [YMLDefaultFormatter defaultFormatter];
    
    return [formatter displayValueForValue:value];
}


- (NSString *)displayValueForTip:(id)value
{
    id<YMLAxisFormatter> formatter = self.tipFormatter;
    if (!formatter)
    {
        formatter = self.useTitleForTips? self.titleFormatter : self.formatter;
        if (!formatter)
            formatter = [YMLDefaultFormatter defaultFormatter];
    }
    
    return [formatter displayValueForValue:value];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Accessory Labels

- (BOOL)showAccessoryViews
{
    return _showAccessoryViews && [self.accessoryDelegate respondsToSelector:@selector(accessoryViewForPlotView:)];
}

#pragma mark - Value labels

- (UIView *)valueLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = self.font;
    label.textColor = self.textColor;
    label.shadowColor = self.shadowColor;
    label.shadowOffset = self.shadowOffset;
    
    return label;
}

- (BOOL)updateValueLabel:(UIView *)labelView atIndexPath:(NSIndexPath *)indexPath
{
    if (![labelView isKindOfClass:[UILabel class]])
        return NO;
    
    UILabel *label = (UILabel *)labelView;
    label.textColor = self.textColor;
    label.font = self.font;
    label.shadowColor = self.shadowColor;
    label.shadowOffset = self.shadowOffset;
    [label setText:[self valueLabel:label textForIndexPath:indexPath]];
    [label sizeToFit];
    
    return YES;
}

- (NSString *)valueLabel:(UIView *)labelView textForIndexPath:(NSIndexPath *)indexPath
{
    id value = [self.values safeObjectAtIndex:indexPath.row];
    
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
    
    NSString *valueString = nil;
    if([self.delegate respondsToSelector:@selector(plotView:textForLabel:withValue:atIndexPath:)])
        valueString = [self.delegate plotView:self textForLabel:labelView withValue:value atIndexPath:indexPath];
    else
        valueString = [self displayValueForValue:value];
    
    if(self.showInLinePercentage && self.percentageFormatter)
    {
        // append the percentage valued string to the $ valued string
        CGFloat total = 0.0f;
        for(NSNumber *number in self.values)
        {
            total += [number floatValue];
        }
        
        CGFloat shareVal = isnan(([self.values[indexPath.row] floatValue]/total))?0:([self.values[indexPath.row] floatValue]/total);
        
        valueString = [valueString stringByAppendingString:[NSString stringWithFormat:@"  (%@)",[self.percentageFormatter displayValueForValue:@(shareVal)]]];
    }
    
    return valueString;
}

- (void)valueLabelSetNoDataStyle:(UIView *)labelView
{
    if (![labelView isKindOfClass:[UILabel class]])
        return;
    
    UILabel *label = (UILabel *)labelView;
    label.textColor = self.chart.noDataTextColor;
    label.shadowColor = self.chart.noDataShadowColor;
    label.shadowOffset = self.chart.noDataShadowOffset;
}

#pragma mark - Title labels

- (UIView *)titleLabel
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = self.titleFont;
    titleLabel.textColor = self.titleTextColor;
    titleLabel.shadowColor = self.titleShadowColor;
    titleLabel.shadowOffset = self.titleShadowOffset;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [titleLabel setMinimumScaleFactor:(2./3)];
    
    return titleLabel;
}

- (BOOL)updateTitleLabel:(UIView *)titleView atIndexPath:(NSIndexPath *)indexPath
{
    if (![titleView isKindOfClass:[UILabel class]])
        return NO;
    
    UILabel *label = (UILabel *)titleView;
    label.textColor = self.titleTextColor;
    label.font = self.titleFont;
    label.shadowColor = self.titleShadowColor;
    label.shadowOffset = self.titleShadowOffset;
    [label setText:[self titleLabel:label textForIndexPath:indexPath]];
    [label sizeToFit];
    
    return YES;
}

- (NSString *)titleLabel:(UIView *)titleView textForIndexPath:(NSIndexPath *)indexPath
{
    id value = [self.titles safeObjectAtIndex:indexPath.row];
    if (!value)
        return nil;
    return [self displayValueForTitle:value];
}

#pragma mark - Percent Labels
- (UIView *)percentLabel{
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = self.percentFont;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = self.percentTextColor;
    label.shadowColor = self.percentShadowColor;
    label.shadowOffset = self.percentShadowOffset;
    return label;
}

- (BOOL)updatePercentLabel:(UIView *)labelView atIndexPath:(NSIndexPath *)indexPath
{
    if (![labelView isKindOfClass:[UILabel class]])
        return NO;
    
    UILabel *label = (UILabel *)labelView;
    label.textColor = self.percentTextColor;
    label.font = self.percentFont;
    label.shadowColor = self.percentShadowColor;
    label.shadowOffset = self.percentShadowOffset;
    [label setMinimumScaleFactor:(1./4)];
    label.adjustsFontSizeToFitWidth = YES;
    [label setText:[self percentLabel:label textForIndexPath:indexPath]];
    [label sizeToFit];
    
    return YES;
}
- (NSString *)percentLabel:(UIView *)labelView textForIndexPath:(NSIndexPath *)indexPath
{
    id value = [self.values safeObjectAtIndex:indexPath.row];
    
    if (!value)
    {
        return nil;
    }
    
    if ([value floatValue] == 0 && [self.delegate respondsToSelector:@selector(plotView:value:hasDataAtIndexPath:)])
    {
        if (![self.delegate plotView:self value:value hasDataAtIndexPath:indexPath])
        {
            return nil;
        }
    }
    
    // append the percentage valued string to the $ valued string
    CGFloat total = 0.0f;
    for(NSNumber *number in self.values)
    {
        total += [number floatValue];
    }
    
    NSString *valueString = [self.percentageFormatter displayValueForValue:@([self.values[indexPath.row] floatValue]/total)];
    return valueString;
}

#pragma mark - Tooltips

- (BOOL)isPointOverFeature:(CGPoint)point
{
    if (!self.showTips)
        return NO;
    
    return [self featureIndexForPoint:point] != nil;
}

- (NSIndexPath *)featureIndexForPoint:(CGPoint)point
{
    return nil;
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath notify:(BOOL)notify
{
    // Sub-class to override
}

- (UIView *)toolTipView
{
    if ([self.delegate respondsToSelector:@selector(toolTipViewForPlotView:)])
    {
        // custom tooltip view
        return [self.delegate toolTipViewForPlotView:self];
    }
    
    UIView *toolTipView = [self toolTipContainerView];
    UILabel *label = [self toolTipLabel];
    label.frame = toolTipView.bounds;
    label.tag = 1;
    
    [toolTipView addSubview:label];
    return toolTipView;
}

- (UIView *)toolTipContainerView
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0,0,80,20)];
    container.layer.cornerRadius = 10;
    container.backgroundColor = self.tipBackgroundColor;
    container.layer.shadowColor = [[UIColor blackColor] CGColor];
    container.layer.shadowOpacity = 0.75;
    container.layer.shadowRadius = 3;
    container.layer.shadowOffset = CGSizeMake(0, 5);
    
    return container;
}

- (UILabel *)toolTipLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = self.tipTextColor;
    label.shadowOffset = self.tipTextShadowOffset;
    label.shadowColor = self.tipTextShadowColor;
    label.text = @"...";
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    label.font = self.tipFont;
    return label;
}

- (BOOL)updateToolTip:(UIView *)toolTip atPosition:(CGPoint)position
{
    // size bubble to fit text
    NSIndexPath *indexPath = [self featureIndexForPoint:position];
    if (!indexPath)
        return NO; // don't update tooltip
    
    if ([self.delegate respondsToSelector:@selector(plotView:updateToolTip:atIndexPath:)])
    {
        // update custom tooltip view
        return [self.delegate plotView:self updateToolTip:toolTip atIndexPath:indexPath];
    }
    
	UILabel *tipValue = (UILabel *)[toolTip viewWithTag:1];
    NSString *tipText = nil;
    if ([self.delegate respondsToSelector:@selector(plotView:textForToolTip:atIndexPath:)])
        // update with custom text
        tipText = [self.delegate plotView:self textForToolTip:toolTip atIndexPath:indexPath];
    else
        tipText = [self toolTip:toolTip textForIndexPath:indexPath];
	[tipValue setText:tipText];
	CGSize textSize = [tipValue.text sizeWithFont:tipValue.font];
    
    CGFloat width = textSize.width + (self.tipGap.width * 2);
    CGFloat height = textSize.height + (self.tipGap.height * 2);
    toolTip.layer.cornerRadius = height / 2;
	[toolTip setBounds:(CGRect){CGPointZero, {width, height}}];
    
    return YES;
}

- (NSString *)toolTip:(UIView *)toolTip textForIndexPath:(NSIndexPath *)indexPath
{
    id value = [self.values safeObjectAtIndex:indexPath.row];
    if (!value)
        return nil;
    return [self displayValueForTip:value];
}

@end
