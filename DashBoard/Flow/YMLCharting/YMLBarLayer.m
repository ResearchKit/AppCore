//
//  YMLBarLayer.m
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/4/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import "YMLBarLayer.h"
#import "YMLBarSegmentLayer.h"

@interface YMLBarLayer()

@property (nonatomic, strong) NSMutableArray *normalizedValues;

@end

@implementation YMLBarLayer

- (id)init
{
    self = [super init];
    if (self)
    {
        //self.backgroundColor = [[UIColor blueColor] CGColor];
    }
    return self;
}

- (id)initWithLayer:(id)layer
{
	if (self = [super initWithLayer:layer]) {
		if ([layer isKindOfClass:[YMLBarLayer class]]) {
			YMLBarLayer *other = (YMLBarLayer *)layer;
			_subValues = other.subValues;
 		}
	}
	
	return self;
    
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    
    [self updateSegments];
}


#pragma mark - Properties

- (void)setSubValues:(NSArray *)subValues
{
	_subValues = subValues;
    
	self.normalizedValues = [NSMutableArray arrayWithCapacity:[subValues count]];
	if (subValues) {
        
		// total
		CGFloat total = 0.0;
        for (NSNumber *value in subValues) {
            CGFloat floatValue = value.floatValue;
            if (isnormal(floatValue))
                total += floatValue;
		}
		
		// normalize
        for (NSNumber *value in subValues) {
            [self.normalizedValues addObject:(isnormal(total) && isnormal(value.floatValue)? @(value.floatValue / total) : @(0.0))];
        }
	}

    [self setNeedsLayout];
}

- (void)setBarColors:(NSArray *)barColors
{
    if (_barColors != barColors)
    {
        _barColors = barColors;
        
        if (barColors)
        {
            int index = 0;
            for (YMLBarSegmentLayer *segment in self.sublayers)
            {
                [segment setFillColor:self.barColors[index]];
                index++;
            }
        }
    }
}

- (void)setCornerRadii:(CGSize)cornerRadii
{
    if (CGSizeEqualToSize(cornerRadii, self.cornerRadii))
        return;
    
    [super setCornerRadii:cornerRadii];
    
    for (YMLBarSegmentLayer *segment in self.sublayers)
    {
        segment.cornerRadii = cornerRadii;
    }
}

- (NSArray *)segments
{
    // Note: later we might wish to store them in their own array (in case there are other layers that are not segments)
    return self.sublayers;
}

#pragma mark - Private Instance Methods

- (void)updateSegments
{
    CALayer *containerLayer = self;
	BOOL isHorizontal = self.orientation == YMLChartOrientationHorizontal;
    
	// Adjust number of slices
	if (self.subValues.count > containerLayer.sublayers.count) {
		
		int count = self.subValues.count - containerLayer.sublayers.count;
		for (int i = 0; i < count; i++) {
			YMLBarSegmentLayer *segment = [YMLBarSegmentLayer layer];
			segment.frame = self.bounds;
            segment.orientation = self.orientation;
            segment.needsDisplayOnBoundsChange = YES;
            segment.cornerRadii = self.cornerRadii;
			[containerLayer addSublayer:segment];
		}
	}
	else if (self.subValues.count < containerLayer.sublayers.count) {
		int count = containerLayer.sublayers.count - self.subValues.count;
        
		for (int i = 0; i < count; i++) {
			[[containerLayer.sublayers objectAtIndex:0] removeFromSuperlayer];
		}
	}
	
    // arrange the bars
	// Set the angles on the slices
	int index = 0;
    CGFloat count = [self.subValues count];
    CGFloat left = 0;
    CGFloat runningTotal = 0;
	for (NSUInteger idx =0; idx<count; idx++) {
		
		YMLBarSegmentLayer *segment = [containerLayer.sublayers objectAtIndex:index];
        segment.segmentPosition = index == 0? SegmentPositionFirst : 0;
        if (index == count - 1)
            segment.segmentPosition |= SegmentPositionLast;
        
        if (index < [self.barColors count])
            segment.fillColor = self.barColors[index];
        else
            segment.fillColor = [UIColor colorWithHue:index/count saturation:0.60 brightness:0.85 alpha:1.0];
        runningTotal += [self.normalizedValues[index] floatValue];
        if (isHorizontal)
        {
            segment.frame = CGRectMake(left, 0, scaled_roundf((self.bounds.size.width * runningTotal) - left), self.bounds.size.height);
            left = segment.frame.origin.x + segment.frame.size.width;
        }
        else
        {
            CGFloat segmentHeight = scaled_roundf((self.bounds.size.height * runningTotal) - left);
            segment.frame = CGRectMake(0, self.bounds.size.height - (left + segmentHeight), self.bounds.size.width, segmentHeight);
            left += segmentHeight;
        }
        
        [segment setNeedsDisplay];
		index++;
	}
    
}

@end

