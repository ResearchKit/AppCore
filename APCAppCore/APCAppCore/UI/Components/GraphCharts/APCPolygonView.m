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
		[self setupPolygon];
	}

	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self setupPolygon];
	}

	return self;
}

- (void)setupPolygon {
	self.backgroundColor = [UIColor clearColor];

	self.shapeLayer.lineWidth = 2.f;
	self.fillColor = [UIColor whiteColor];
	self.shapeLayer.path = [self layoutPath].CGPath;
}

#pragma mark - Polygon Methods

- (UIBezierPath *)layoutPath {
	CGPoint origin = CGPointMake(CGRectGetWidth(self.frame) / 2.f, CGRectGetHeight(self.frame) / 2.f);
	CGFloat radius = CGRectGetWidth(self.frame) / 4;

	CGFloat angle = (CGFloat) (M_PI * (2.f / self.numberOfSides));
	NSMutableArray *points = [[NSMutableArray alloc] init];
	for (int i = 0; i <= self.numberOfSides; i++) {
		CGFloat xpo = (CGFloat) (origin.x + radius * cos(angle * i));
		CGFloat ypo = (CGFloat) (origin.y + radius * sin(angle * i));
		[points addObject:[NSValue valueWithCGPoint:CGPointMake(xpo, ypo)]];
	}

	NSValue *initialPoint = (NSValue *) points[0];
	CGPoint cpg = initialPoint.CGPointValue;
	UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
	[bezierPath moveToPoint:cpg];
	for (NSValue *pointValue in points) {
		CGPoint point = pointValue.CGPointValue;
		[bezierPath addLineToPoint:point];
	}

	[bezierPath closePath];

	[bezierPath applyTransform:CGAffineTransformMakeTranslation(-origin.x, -origin.y)];
	[bezierPath applyTransform:CGAffineTransformMakeRotation((CGFloat) (M_PI / 2 - M_PI / self.numberOfSides))];
	[bezierPath applyTransform:CGAffineTransformMakeTranslation(origin.x, origin.y)];

	return bezierPath;
}

#pragma mark - other

+ (Class)layerClass {
	return CAShapeLayer.class;
}

- (CAShapeLayer *)shapeLayer {
	return (CAShapeLayer *) self.layer;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	self.shapeLayer.path = [self layoutPath].CGPath;
}

#pragma mark - Setter methods

- (void)setTintColor:(UIColor *)tintColor {
	_tintColor = tintColor;

	self.shapeLayer.strokeColor = _tintColor.CGColor;
}

- (void)setFillColor:(UIColor *)fillColor {
	_fillColor = fillColor;

	self.shapeLayer.fillColor = fillColor.CGColor;
}

@end
