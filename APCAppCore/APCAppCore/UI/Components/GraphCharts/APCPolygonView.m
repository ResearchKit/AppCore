//
//  APCPolygonView.m
//  APCAppCore
//
//  Created by Everest Liu on 2/27/16.
//  Copyright © 2016 Thread, Inc. All rights reserved.
//

#import "APCPolygonView.h"

@implementation APCPolygonView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame andNumberOfSides:(int)sides {
	if (self = [super initWithFrame:frame]) {
		self.numberOfSides = sides;
		self.backgroundColor = [UIColor clearColor];
	}

	return self;
}

#pragma mark - Polygon Methods

- (NSArray *)polygonPointArrayWithXOrigin:(CGFloat)x
								  yOrigin:(CGFloat)y
								   radius:(CGFloat)radius
								   offset:(CGFloat)offset {

	CGFloat angle = M_PI * (2 / self.numberOfSides);
	NSMutableArray *points = [[NSMutableArray alloc] init];
	for (int i = 0; i <= self.numberOfSides; i++) {
		CGFloat xpo = (CGFloat) (x + radius * cos(angle * i - (M_PI * offset / 180)));
		CGFloat ypo = (CGFloat) (y + radius * sin(angle * i - (M_PI * offset / 180)));
		[points addObject:[NSValue valueWithCGPoint:CGPointMake(xpo, ypo)]];
	}

	return [points copy];
}

- (CGPathRef)polygonPathWithX:(CGFloat)x
							y:(CGFloat)y
					   radius:(CGFloat)radius
					   offset:(CGFloat)offset {

	CGMutablePathRef mutableCGPath = CGPathCreateMutable();
	NSArray *points = [self polygonPointArrayWithXOrigin:x yOrigin:y radius:radius offset:offset];
	NSValue *initialPoint = (NSValue *) points[0];
	CGPoint cpg = initialPoint.CGPointValue;
	CGPathMoveToPoint(mutableCGPath, nil, cpg.x, cpg.y);
	for (NSValue *pointValue in points) {
		CGPoint point = pointValue.CGPointValue;
		CGPathAddLineToPoint(mutableCGPath, nil, point.x, point.y);
	}

	CGPathCloseSubpath(mutableCGPath);
	return mutableCGPath;
}

- (UIBezierPath *)drawPolygonBezierWithX:(CGFloat)x
									   y:(CGFloat)y
								  radius:(CGFloat)radius
								   color:(UIColor *)color
								  offset:(CGFloat)offset {

	CGPathRef path = [self polygonPathWithX:x y:y radius:radius offset:offset];
	UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:path];
	bezierPath.lineWidth = 2;
	[color setStroke];
	[bezierPath stroke];

	return bezierPath;
}

- (CAShapeLayer *)drawPolygonLayerWithX:(CGFloat)x
									  y:(CGFloat)y
								 radius:(CGFloat)radius
								 offset:(CGFloat)offset {

	CAShapeLayer *shape = [[CAShapeLayer alloc] init];
	shape.path = [self polygonPathWithX:x y:y radius:radius offset:offset];
	shape.strokeColor = self.tintColor.CGColor;
	shape.lineWidth = 2;
	return shape;
}

#pragma mark - other

- (void)drawRect:(CGRect)rect {
	NSLog(@"drawingRect");
	[self drawPolygonBezierWithX:CGRectGetMidX(rect)
							   y:CGRectGetMidY(rect)
						  radius:CGRectGetWidth(rect) / 4
						   color:[UIColor redColor]
						  offset:0];
}

@end
