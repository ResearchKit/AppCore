//
//  YMLAxisView.m
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/17/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import "YMLAxisView.h"
#import "Enumerations.h"
#import "YMLDefaultFormatter.h"

#define FUDGE_FACTOR 1.00
#define DEFAULT_HORIZONTAL_AXIS_HEIGHT  30
#define DEFAULT_VERTICAL_AXIS_WIDTH     75

#define IDEAL_LABEL_COUNT_HORIZONTAL_PAD    8
#define IDEAL_LABEL_COUNT_HORIZONTAL_PHONE    6
#define IDEAL_LABEL_COUNT_VERTICAL_PAD      8
#define IDEAL_LABEL_COUNT_VERTICAL_PHONE      7

@interface YMLAxisView()

@property (nonatomic, strong) NSMutableArray *axisLabels;
@property (nonatomic, assign) BOOL shouldAutoCalculate;
@property (nonatomic, assign) YMLAxisPosition position;

@end

@implementation YMLAxisView

- (id)initWithPosition:(YMLAxisPosition)position
{
    self = [super init];
    if (self) {
        // Initialization code
        [self doInitYMLAxisView:position];
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self doInitYMLAxisView:YMLAxisPositionLeft];
    }
    return self;
}

- (void)doInitYMLAxisView:(YMLAxisPosition)position
{
    _font = [UIFont boldSystemFontOfSize:13];
    _textColor = [UIColor colorWithWhite:0.21 alpha:1];
    _shadowColor = [UIColor clearColor];
    _shadowOffset = CGSizeMake(0, 1);
    _insets = UIEdgeInsetsZero;
    _position = position;
    _minimumInterItemSpacing = 10;
    _shouldAutoCalculate = YES;
    _axisLabels = [NSMutableArray array];
    _size = CGSizeMake(DEFAULT_VERTICAL_AXIS_WIDTH, DEFAULT_HORIZONTAL_AXIS_HEIGHT);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setMin:(CGFloat)min
{
    if (_min == min)
        return;
    
    _min = min;
    [self setNeedsLayout];
}

- (void)setMax:(CGFloat)max
{
    if (_max == max)
        return;
    
    _max = max;
    [self setNeedsLayout];
}

- (void)setValues:(NSArray *)values
{
    if ([_values isEqual:values])
        return;
    
    _values = values;
    [self setNeedsLayout];
}

- (void)setPositions:(NSArray *)positions
{
    if ([_positions isEqual:positions])
        return;
    
    _positions = positions;
    [self setNeedsLayout];
}

- (BOOL)isHorizontal
{
    return self.position == YMLAxisPositionTop || self.position == YMLAxisPositionBottom;
}

// TODO: redraw or invalidate on change other properties as appropriate

- (void)layoutSubviews
{
    if ([self.positions count] > 0)
    {
        [self fixedLayout];
        return;
    }
    
    NSString *sample = @"100";
    BOOL isHorizontal = [self isHorizontal];
    if (isHorizontal)
    {
        // horizontal is more complicated because width depends upon specific values
        CGFloat base;
        if (self.isPercent)
            base = powf(10, floorf(log10f(self.max * 100))) / 100;
        else
            base = powf(10, floorf(log10f(self.max)));
        
        sample = [self displayValueForValue:@(base)];
    }
    else
    {
        // vertical is simpler because height is same for all labels
    }
    
    CGFloat width = isHorizontal? self.bounds.size.width - (self.insets.left + self.insets.right) : self.bounds.size.height - (self.insets.top + self.insets.bottom);
    CGSize sampleLabelSize = [sample sizeWithFont:self.font];
    CGFloat sampleLabelWidth = isHorizontal? sampleLabelSize.width : sampleLabelSize.height;
    BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    int idealLabelNumber = isHorizontal? (isPad? IDEAL_LABEL_COUNT_HORIZONTAL_PAD : IDEAL_LABEL_COUNT_HORIZONTAL_PHONE) : (isPad? IDEAL_LABEL_COUNT_VERTICAL_PAD : IDEAL_LABEL_COUNT_VERTICAL_PHONE);
    int maxNumberOfLabels = MIN(idealLabelNumber, floorf(width / (sampleLabelWidth + 10)));
    //NSLog(@"%@ (%@), max # = %d", sample, NSStringFromCGSize(sampleLabelSize), maxNumberOfLabels);
    CGFloat interval = self.max / maxNumberOfLabels;
    CGFloat base = (self.isPercent)? powf(10, floorf(log10f(interval * 100))) / 100 : powf(10, floorf(log10f(interval)));
    if (interval < 8 * FUDGE_FACTOR * base)
    {
        if (interval < 6 * FUDGE_FACTOR * base)
        {
            if (interval < 5 * FUDGE_FACTOR * base)
            {
                if (interval < 4 * FUDGE_FACTOR * base)
                {
                    if (interval < 2 * FUDGE_FACTOR * base)
                    {
                        if (interval >= FUDGE_FACTOR * base)
                            base *= 2;
                    }
                    else
                        base *= 4;
                }
                else
                    base *= 5;
            }
            else
                base *= 6;
        }
        else
            base *= 8;
    }
    else
        base *= 10;
    
    //NSLog(@"Interval = %.2f (%.2f), Base = %d", interval, log10f(interval), (int)base);
    
    // remove old labels
    for (UIView *label in self.axisLabels)
        [label removeFromSuperview];
    
    self.axisLabels = [NSMutableArray array];
    
    int labelIndex = 1;
    CGFloat labelInterval = (width * base) / self.max;
    CGFloat center;
    CGFloat value = base;
    CGFloat leftMargin = isHorizontal? self.insets.left : self.insets.bottom;
    CGFloat rightMargin = isHorizontal? self.insets.right : self.insets.top;
    CGFloat boundsWidth = isHorizontal? self.bounds.size.width : self.bounds.size.height;
    CGRect labelFrame;
    
    if (self.max == 0 && self.min == 0)
        return;
    
    CGSize maxLabelSize = CGSizeZero;
    
    while (YES)
    {
        center = leftMargin + (labelInterval * labelIndex);
        NSString *labelText = [self displayValueForValue:@(value)];
        CGSize labelSize = [labelText sizeWithFont:self.font];
        if (labelSize.width > maxLabelSize.width)
            maxLabelSize.width = labelSize.width;
        if (labelSize.height > maxLabelSize.height)
            maxLabelSize.height = labelSize.height;
        CGFloat labelWidth = isHorizontal? labelSize.width : labelSize.height;
        if (isHorizontal)
        {
        if ((center + labelWidth/2) > boundsWidth - self.minimumInterItemSpacing)
            break; // don't go too near right edge
        if (center > boundsWidth - rightMargin)
            break; // don't go past max value label
        }
        else
        {
            if ((boundsWidth - (center + labelWidth/2)) < self.minimumInterItemSpacing)
                break; // don't go too near top edge
            if ((boundsWidth - center) < rightMargin)
                break; // don't go above max value label
        }
        
        if (isHorizontal)
            labelFrame = CGRectIntegralScaled((CGRect){{center - labelWidth/2, (self.bounds.size.height - labelSize.height)/2}, labelSize});
        else
            labelFrame = CGRectIntegralScaled((CGRect){{10, boundsWidth - (center + labelWidth/2)}, labelSize});
        
        UILabel *axisLabel = [[UILabel alloc] initWithFrame:labelFrame];
        axisLabel.font = self.font;
        axisLabel.textColor = self.textColor;
        axisLabel.shadowColor = self.shadowColor;
        axisLabel.shadowOffset = self.shadowOffset;
        axisLabel.backgroundColor = [UIColor clearColor];
        axisLabel.text = labelText;
        axisLabel.adjustsFontSizeToFitWidth = YES;
        [axisLabel setMinimumScaleFactor:0.66];
        
        [self addSubview:axisLabel];
        [self.axisLabels addObject:axisLabel];
        
        value += base;
        labelIndex++;
    }
    
    // center by max width and left or right justify
    if (!isHorizontal)
    {
        // don't let labels overflow bounds
        if (maxLabelSize.width > self.bounds.size.width - self.minimumInterItemSpacing * 2)
            maxLabelSize.width = self.bounds.size.width - self.minimumInterItemSpacing * 2;
        
        CGFloat left = (self.bounds.size.width - maxLabelSize.width) / 2;
        for (UILabel *label in self.axisLabels)
        {
            label.textAlignment = self.position == YMLAxisPositionLeft? NSTextAlignmentRight : NSTextAlignmentLeft;
            label.frame = CGRectIntegralMake(left, label.frame.origin.y, maxLabelSize.width, label.frame.size.height);
        }
    }
}

- (void)fixedLayout
{
    NSArray *values = self.values;
    
    if ([self.values count] == 0 && (self.max - self.min) != 0)
    {
        NSMutableArray *newValues = [NSMutableArray arrayWithCapacity:self.positions.count];
        CGFloat fullWidth = [self isHorizontal]? self.bounds.size.width - (self.insets.left + self.insets.right) : self.bounds.size.height - (self.insets.top + self.insets.bottom);
        for (int index = 0; index < self.positions.count; index++)
        {
            CGFloat position = [self.positions[index] floatValue];
            CGFloat proportion = [self isHorizontal]? (position - self.insets.left) / fullWidth : (self.bounds.size.height - self.insets.bottom - position) / fullWidth;
            [newValues addObject:[NSNumber numberWithFloat:proportion * (self.max - self.min)]];
        }
        
        values = [NSArray arrayWithArray:newValues];
    }
    
    int count = MIN(self.positions.count, values.count);
    
	if (count > self.axisLabels.count) {
        // add extra labels
		int addCount = count - self.axisLabels.count;
		for (int i = 0; i < addCount; i++) {
            UILabel *axisLabel = [[UILabel alloc] init];
            axisLabel.font = self.font;
            axisLabel.textColor = self.textColor;
            axisLabel.backgroundColor = [UIColor clearColor];
            axisLabel.adjustsFontSizeToFitWidth = YES;
            [axisLabel setMinimumScaleFactor:0.66];

            [self addSubview:axisLabel];
            [self.axisLabels addObject:axisLabel];
		}
	}
	else if (count < self.axisLabels.count) {
        // delete excess labels
		int deleteCount = self.axisLabels.count - count;
        
		for (int i = 0; i < deleteCount; i++) {
			[self.axisLabels[0] removeFromSuperview];
            [self.axisLabels removeObjectAtIndex:0];
		}
	}
    
    // configure labels
    CGFloat midX = self.insets.left + (self.bounds.size.width - (self.insets.left + self.insets.right)) / 2;
    CGFloat midY = self.insets.top + (self.bounds.size.height - (self.insets.top + self.insets.bottom)) / 2;
    
    CGFloat leftPosition = [self.positions[0] floatValue] > self.insets.left? self.insets.left : 0;
    CGFloat rightPosition = [[self.positions lastObject] floatValue] < self.bounds.size.width - self.insets.right? self.bounds.size.width - self.insets.right : self.bounds.size.width;
    CGFloat lastPosition = leftPosition;
    
    for (int index = 0; index < count; index++)
    {
        CGFloat position = [self.positions[index] floatValue];
        UILabel *label = self.axisLabels[index];
        label.text = [self displayValueForValue:values[index]];
        [label sizeToFit];
        label.center = CGPointCenterIntegralScaled([self isHorizontal]? CGPointMake(position, midY) : CGPointMake(midX, position), label.bounds.size);
        
        if ([self isHorizontal])
        {
            CGFloat nextPosition = index < count - 1? [self.positions[index + 1] floatValue] : rightPosition;
            if ((label.bounds.size.width + self.minimumInterItemSpacing)/2 > MIN(position - lastPosition, nextPosition - position) / 2)
            {
                label.bounds = (CGRect){CGPointZero, { MIN(position - lastPosition, nextPosition - position) - self.minimumInterItemSpacing, label.bounds.size.height } };
                label.center = CGPointCenterIntegralScaled(label.center, label.bounds.size);
           }
            
            lastPosition = position;
        }
    }
}

- (NSString *)displayValueForValue:(id)value
{
    id<YMLAxisFormatter> formatter = self.formatter;
    if (!formatter)
        formatter = [YMLDefaultFormatter defaultFormatter];
    
    return [formatter displayValueForValue:value];
}

- (CGSize)minimumSize
{
    [self layoutIfNeeded];
    CGRect rect;
    BOOL first = YES;
    for (UILabel* label in self.axisLabels)
    {
        if (first)
        {
            rect = label.frame;
            first = NO;
        }
        else
        {
            rect = CGRectUnion(rect, label.frame);
        }
    }
    
    if (!CGSizeEqualToSize(rect.size, CGSizeZero))
        return CGSizeMake(rect.size.width + (self.insets.left + self.insets.right), rect.size.height + (self.insets.top + self.insets.bottom));
    else
        return CGSizeZero;
}

@end
