//
//  PieSliceLayer.m
//  PieChart
//
//  Created by Pavan Podila on 2/20/12.
//  Copyright (c) 2012 Pixel-in-Gene. All rights reserved.
//

#import "PieSliceLayer.h"

@interface PieSliceLayer()

@property (nonatomic, strong) UIBezierPath *path;

@end

@implementation PieSliceLayer

@dynamic startAngle, endAngle, radius, sliceShadowOpacity;
@synthesize fillColor, strokeColor, strokeWidth;

-(CABasicAnimation *)makeAnimationForKey:(NSString *)key {
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
	anim.fromValue = [[self presentationLayer] valueForKey:key];
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	anim.duration = 0.5;

	return anim;
}

- (id)init {
    self = [super init];
    if (self) {
		self.fillColor = [UIColor grayColor];
        self.strokeColor = [UIColor blackColor];
		self.strokeWidth = 1.0;
        self.radius = 0.5;
        self.needsDisplayOnBoundsChange = YES;
		[self setNeedsDisplay];
        self.contentsScale = [[UIScreen mainScreen] scale];
    }
	
    return self;
}

-(id<CAAction>)actionForKey:(NSString *)event {
	if ([event isEqualToString:@"startAngle"] ||
		[event isEqualToString:@"endAngle"] ||
		[event isEqualToString:@"radius"]) {
        self.path = nil;
		return [self makeAnimationForKey:event];
	}
	
	/*if ([event isEqualToString:@"sliceShadowOpacity"]) {
		return [self makeAnimationForKey:event];
	}*/
	
	return [super actionForKey:event];
}

- (id)initWithLayer:(id)layer {
	if (self = [super initWithLayer:layer]) {
		if ([layer isKindOfClass:[PieSliceLayer class]]) {
			PieSliceLayer *other = (PieSliceLayer *)layer;
			self.startAngle = other.startAngle;
			self.endAngle = other.endAngle;
			self.fillColor = other.fillColor;
            self.radius = other.radius;
            self.sliceShadowOpacity = other.sliceShadowOpacity;

			self.strokeColor = other.strokeColor;
			self.strokeWidth = other.strokeWidth;
            self.contentsScale = [[UIScreen mainScreen] scale];
            self.gradient = other.gradient;
		}
	}
	
	return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
	if ([key isEqualToString:@"startAngle"] || [key isEqualToString:@"endAngle"] || [key isEqualToString:@"radius"] /*|| [key isEqualToString:@"sliceShadowOpacity"]*/) {
		return YES;
	}
	
	return [super needsDisplayForKey:key];
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    self.path = nil;
}

-(void)drawInContext:(CGContextRef)ctx {
	
	//if (self.sliceShadowOpacity > 0)
      //  CGContextSetShadowWithColor(ctx, CGSizeZero, 5, [[UIColor colorWithWhite:0 alpha:self.sliceShadowOpacity] CGColor]);
    	
    CGContextAddPath(ctx, [self.path CGPath]);
    
	// Color it
	CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
	CGContextSetLineWidth(ctx, self.strokeWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinBevel);

    if (self.gradient)
    {
        CGContextSaveGState(ctx);
        
        CGContextClip(ctx);
        CGRect boundingRect = [self boundingRect];
        CGContextDrawLinearGradient(ctx, self.gradient, CGPointMake(0, CGRectGetMinY(boundingRect)), CGPointMake(0, CGRectGetMaxY(boundingRect)), kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
        
        CGContextRestoreGState(ctx);
        
        CGContextAddPath(ctx, [self.path CGPath]);
        CGContextStrokePath(ctx);
    }
    else
    {
        CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
        CGContextDrawPath(ctx, kCGPathFillStroke);
    }
}

- (CGRect)boundingRect
{
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = (MIN(self.bounds.size.width, self.bounds.size.height) * self.radius) - (self.strokeWidth / 2);
    return CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2);
}

- (UIBezierPath *)path
{
    if (!_path)
    {
        
        // Create the path
        CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        CGFloat radius = (MIN(self.bounds.size.width, self.bounds.size.height) * self.radius) - (self.strokeWidth / 2);
        
        int clockwise = self.startAngle < self.endAngle;
        
        if (fabsf(self.endAngle - self.startAngle) >= 2 * M_PI)
        {
            _path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2)];
        }
        else
        {
            _path = [UIBezierPath bezierPath];
            [_path addArcWithCenter:center radius:radius startAngle:self.startAngle endAngle:self.endAngle clockwise:clockwise];
            [_path addLineToPoint:center];
            [_path closePath];
        }
    }
    
    return _path;
}

#pragma mark - Properties

- (void)setGradient:(CGGradientRef)gradient
{
    if (_gradient == gradient)
        return;
    
    _gradient = gradient;
    [self setNeedsDisplay];
}


@end
