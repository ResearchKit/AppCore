//
//  YMLPointLayer.m
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/22/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import "YMLPointLayer.h"

@implementation YMLPointLayer

- (id)init
{
    self = [super init];
    if (self) {
        _fillColor = [UIColor greenColor];
        _strokeColor = [UIColor whiteColor];
        _lineWidth = 2;
        _size = CGSizeMake(15, 15);
        _symbol = YMLPointSymbolCircle;
        self.contentsScale = [[UIScreen mainScreen] scale];
   }
    return self;
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if (self) {
		if ([layer isKindOfClass:[YMLPointLayer class]]) {
			YMLPointLayer *other = (YMLPointLayer *)layer;
			_fillColor = other.fillColor;
            _strokeColor = other.strokeColor;
            _lineWidth = other.lineWidth;
            _size = other.size;
            _symbol = other.symbol;
            self.contentsScale = [[UIScreen mainScreen] scale];
		}
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
	
    // TODO: implement differnet shapes (circle, square, diamond, etc.)
    switch (self.symbol) {
        case YMLPointSymbolCircle:
            CGContextAddPath(ctx, [[UIBezierPath bezierPathWithOvalInRect:(CGRect){CGPointZero, self.size}] CGPath]);
            break;
            
        case YMLPointSymbolBar:
            CGContextAddPath(ctx, [[UIBezierPath bezierPathWithRect:(CGRect){CGPointZero, self.size}] CGPath]);
           break;
            
        default:
            break;
    }
    
	// Color it
	CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
	CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
	CGContextSetLineWidth(ctx, self.lineWidth);
    
	CGContextDrawPath(ctx, kCGPathFillStroke);
}

@end
