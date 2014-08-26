//
//  YMLBarSegmentLayer.m
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/4/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import "YMLBarSegmentLayer.h"

@implementation YMLBarSegmentLayer

- (id)init
{
    self = [super init];
    if (self) {
        _fillColor = [UIColor redColor];
        _separatorColor = [UIColor whiteColor];
        _separatorWidth = 1;
        _segmentPosition = SegmentPositionFirst;
    }
    return self;
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if (self) {
		if ([layer isKindOfClass:[YMLBarSegmentLayer class]]) {
			YMLBarSegmentLayer *other = (YMLBarSegmentLayer *)layer;
			_fillColor = other.fillColor;
            _separatorColor = other.separatorColor;
            _separatorWidth = other.separatorWidth;
            _segmentPosition = other.segmentPosition;
		}
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
	
    UIBezierPath *path = [UIBezierPath bezierPath];
    BOOL isFirst = (self.segmentPosition & SegmentPositionFirst) == SegmentPositionFirst;
    BOOL isLast = (self.segmentPosition & SegmentPositionLast) == SegmentPositionLast;
    
    if (!isFirst)
    {
        // draw separator on left (horizontal) or bottom (vertical)
        if (self.orientation == YMLChartOrientationHorizontal)
        {
            [path moveToPoint:CGPointMake(self.separatorWidth/2, 0)];
            [path addLineToPoint:CGPointMake(self.separatorWidth/2, self.bounds.size.height)];
        }
        else
        {
            [path moveToPoint:CGPointMake(0, self.bounds.size.height - (self.separatorWidth / 2))];
            [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height - (self.separatorWidth / 2))];
        }
    }
    
    if (isLast)
    {
        // clip right edge with curved radius
        CGContextSaveGState(ctx);
        CGContextAddPath(ctx, [[UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopRight | (self.orientation == YMLChartOrientationHorizontal? UIRectCornerBottomRight : UIRectCornerTopLeft) cornerRadii:self.cornerRadii] CGPath]);
        CGContextClip(ctx);
    }
    else
    {
        // draw separator on right (horizontal) or top (vertical)
        if (self.orientation == YMLChartOrientationHorizontal)
        {
            [path moveToPoint:CGPointMake(self.bounds.size.width - (self.separatorWidth*0.5), 0)];
            [path addLineToPoint:CGPointMake(self.bounds.size.width - (self.separatorWidth*0.5), self.bounds.size.height)];
        }
        else
        {
            [path moveToPoint:CGPointMake(0, self.separatorWidth*0.5)];
            [path addLineToPoint:CGPointMake(self.bounds.size.width, self.separatorWidth*0.5)];
        }
    }
    
	// Fill it
	CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    CGContextFillRect(ctx, self.bounds);
    
    // Stroke it
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path.CGPath);
	CGContextSetStrokeColorWithColor(ctx, self.separatorColor.CGColor);
	CGContextSetLineWidth(ctx, self.separatorWidth);
	CGContextDrawPath(ctx, kCGPathStroke);
    CGContextRestoreGState(ctx);
    
    if (isLast)
        CGContextRestoreGState(ctx);
}

#pragma mark - Properties

- (void)setFillColor:(UIColor *)fillColor
{
    if (fillColor == _fillColor)
        return;
    
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    if (separatorColor == _separatorColor)
        return;
    
    _separatorColor = separatorColor;
    [self setNeedsDisplay];
}

- (void)setSeparatorWidth:(CGFloat)separatorWidth
{
    if (separatorWidth == _separatorWidth)
        return;
    
    _separatorWidth = separatorWidth;
    [self setNeedsDisplay];
}

- (void)setSegmentPosition:(SegmentPosition)segmentPosition
{
    if (segmentPosition == _segmentPosition)
        return;
    
    _segmentPosition = segmentPosition;
    [self setNeedsDisplay];
}

@end
