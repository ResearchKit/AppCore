//
//  YMLPieSliceLayer.m
//  Avero
//
//  Created by Mark Pospesel on 12/18/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import "YMLPieSliceLayer.h"

@interface YMLPieSliceLayer()

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@property (nonatomic) CGFloat radius;

@property (nonatomic, strong) CAShapeLayer *strokeLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation YMLPieSliceLayer

- (id)init {
    self = [super init];
    if (self) {
        _startAngle = 0;
        _endAngle = 0;
        
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.radius = 0.45;
        self.needsDisplayOnBoundsChange = YES;
		[self setNeedsDisplay];
        self.contentsScale = [[UIScreen mainScreen] scale];
        _strokeLayer = [CAShapeLayer layer];
        _strokeLayer.lineWidth = 2;
        _strokeLayer.lineJoin = kCALineJoinBevel;
        _strokeLayer.strokeColor = [UIColor whiteColor].CGColor;
        _strokeLayer.fillColor = [UIColor clearColor].CGColor;
        _strokeLayer.contentsScale = [[UIScreen mainScreen] scale];
        
        _gradientLayer = [CAGradientLayer layer];
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.lineWidth = 0;
        mask.lineJoin = kCALineJoinBevel;
        mask.contentsScale = _strokeLayer.contentsScale;
        _gradientLayer.contentsScale = _strokeLayer.contentsScale;
        _gradientLayer.mask = mask;
        
        [self addSublayer:_gradientLayer];
        [self addSublayer:_strokeLayer];
    }
	
    return self;
}

- (id)initWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle
{
    self = [self init];
    if (self) {
        _startAngle = startAngle;
        _endAngle = endAngle;
    }
    
    return self;
}

- (id)initWithLayer:(id)layer {
	if (self = [super initWithLayer:layer]) {
		if ([layer isKindOfClass:[YMLPieSliceLayer class]]) {
			YMLPieSliceLayer *other = (YMLPieSliceLayer *)layer;
			self.startAngle = other.startAngle;
			self.endAngle = other.endAngle;
            self.radius = other.radius;
            self.contentsScale = [[UIScreen mainScreen] scale];
		}
	}
	
	return self;
}

- (CGFloat)midAngle
{
    return (self.startAngle + self.endAngle) / 2;
}

- (CGPathRef)path
{
    return [(CAShapeLayer *)self.gradientLayer.mask path];
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    [self.gradientLayer setFrame:self.bounds];
    [self.strokeLayer setFrame:self.bounds];
}

- (void)setStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle radius:(CGFloat)radiusPercent animated:(BOOL)animated
{
    CGFloat oldStart = self.startAngle;
    CGFloat oldEnd = self.endAngle;
    CGFloat oldRadiusPercent = self.radius;
    
    self.startAngle = startAngle;
    self.endAngle = endAngle;
    self.radius = radiusPercent;
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) * self.radius;
    
    UIBezierPath *path = [self slicePathWithStartAngle:startAngle endAngle:endAngle];
    self.strokeLayer.path = path.CGPath;
    UIBezierPath *path2 = [self slicePathWithStartAngle:startAngle endAngle:endAngle];
    [(CAShapeLayer *)self.gradientLayer.mask setPath:path2.CGPath];
    if (self.shadowOpacity > 0)
    {
        UIBezierPath *path3 = [self slicePathWithStartAngle:startAngle endAngle:endAngle];
        [self setShadowPath:path3.CGPath];
    }
    else
        [self setShadowPath:nil];
    
    if (!animated || (oldStart == startAngle && oldEnd == endAngle && oldRadiusPercent == radiusPercent))
        return;
    
    CGFloat duration = 0.5;
    NSArray *frames = [self keyframePathsWithDuration:duration sourceStartAngle:oldStart sourceEndAngle:oldEnd destinationStartAngle:startAngle destinationEndAngle:endAngle sourceRadiusPercent:oldRadiusPercent destinationRadiusPercent:radiusPercent];
    
    [CATransaction begin];
    
    CGPoint p1 = CGPointMake(center.x + radius * cosf(self.startAngle), center.y + radius * sinf(self.startAngle));
    CGPoint p2 = CGPointMake(center.x + radius * cosf(self.endAngle), center.y + radius * sinf(self.endAngle));
    CGFloat minY = MIN(p1.y, MIN(p2.y, center.y));
    CGFloat maxY = MAX(p1.y, MAX(p2.y, center.y));
    if (startAngle <= 1.5 * M_PI && endAngle >= 1.5 * M_PI)
        minY = center.y - radius;
    if (startAngle <= 0.5 * M_PI && endAngle >= 0.5 * M_PI)
        maxY = center.y + radius;
    self.gradientLayer.startPoint = CGPointMake(0.5, minY / self.bounds.size.height);
    self.gradientLayer.endPoint = CGPointMake(0.5, maxY / self.bounds.size.height);
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    [pathAnimation setValues:frames];
    [pathAnimation setDuration:duration];
    [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [pathAnimation setRemovedOnCompletion:YES];
    [self.gradientLayer.mask addAnimation:pathAnimation forKey:@"path"];
    
    pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    [pathAnimation setValues:frames];
    [pathAnimation setDuration:duration];
    [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [pathAnimation setRemovedOnCompletion:YES];
    [self.strokeLayer addAnimation:pathAnimation forKey:@"path"];
    
    if (self.shadowOpacity > 0)
    {
        pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"shadowPath"];
        [pathAnimation setValues:frames];
        [pathAnimation setDuration:duration];
        [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [pathAnimation setRemovedOnCompletion:YES];
        [self addAnimation:pathAnimation forKey:@"shadowPath"];
    }
    
    [CATransaction commit];
}

- (void)removeFromSuperlayerAnimated:(BOOL)animated
{
    if (!animated)
    {
        [self removeFromSuperlayer];
        return;
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self removeFromSuperlayer];
    }];
    
    CGFloat finalAngle = M_PI * 1.5; // this should match insertion point (+ 2*M_PI)
    [self setStartAngle:finalAngle endAngle:finalAngle radius:self.radius animated:YES];
    [CATransaction commit];
}

- (NSArray *)colors
{
    return [self.gradientLayer colors];
}

- (void)setColors:(NSArray *)colors
{
    [self.gradientLayer setColors:colors];
}

- (NSArray *)keyframePathsWithDuration:(CGFloat) duration sourceStartAngle:(CGFloat)sourceStartAngle sourceEndAngle:(CGFloat)sourceEndAngle destinationStartAngle:(CGFloat)destinationStartAngle destinationEndAngle:(CGFloat)destinationEndAngle sourceRadiusPercent:(CGFloat)sourceRadiusPercent destinationRadiusPercent:(CGFloat)destinationRadiusPercent
{
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);

    return [YMLPieSliceLayer keyframePathsWithDuration:duration sourceStartAngle:sourceStartAngle sourceEndAngle:sourceEndAngle destinationStartAngle:destinationStartAngle destinationEndAngle:destinationEndAngle centerPoint:center size:self.bounds.size sourceRadiusPercent:sourceRadiusPercent destinationRadiusPercent:destinationRadiusPercent];
}

+ (NSArray *)keyframePathsWithDuration:(CGFloat) duration sourceStartAngle:(CGFloat)sourceStartAngle sourceEndAngle:(CGFloat)sourceEndAngle destinationStartAngle:(CGFloat)destinationStartAngle destinationEndAngle:(CGFloat)destinationEndAngle centerPoint:(CGPoint)centerPoint size:(CGSize)size sourceRadiusPercent:(CGFloat)sourceRadiusPercent destinationRadiusPercent:(CGFloat)destinationRadiusPercent
{
    NSUInteger frameCount = ceil(duration * 60);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:frameCount + 1];
    for (int frame = 0; frame <= frameCount; frame++)
    {
        CGFloat startAngle = sourceStartAngle + (((destinationStartAngle - sourceStartAngle) * frame) / frameCount);
        CGFloat endAngle = sourceEndAngle + (((destinationEndAngle - sourceEndAngle) * frame) / frameCount);
        CGFloat radiusPercent = sourceRadiusPercent + (((destinationRadiusPercent - sourceRadiusPercent) * frame) / frameCount);
        CGFloat radius = MIN(size.width, size.height) * radiusPercent;

        [array addObject:(id)([YMLPieSliceLayer slicePathWithStartAngle:startAngle endAngle:endAngle centerPoint:centerPoint radius:radius].CGPath)];
    }
    
    return [NSArray arrayWithArray:array];
}

- (UIBezierPath *)slicePathWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle
{
    CGPoint centerPoint = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) * self.radius;

    if (startAngle == endAngle)
        return nil;
    if (fabsf(endAngle - startAngle) >= 2 * M_PI)
    {
        return [UIBezierPath bezierPathWithOvalInRect:CGRectMake(centerPoint.x - radius, centerPoint.y - radius, radius * 2, radius * 2)];
    }
    else
        return [YMLPieSliceLayer slicePathWithStartAngle:startAngle endAngle:endAngle centerPoint:centerPoint radius:radius];
}

+ (UIBezierPath *)slicePathWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle centerPoint:(CGPoint)centerPoint radius:(CGFloat)radius
{
    BOOL clockwise = startAngle < endAngle;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:centerPoint];
    [path addArcWithCenter:centerPoint radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
    [path closePath];
    
    return path;
}

- (void)renderInContext:(CGContextRef)ctx
{
    CGPathRef clipPath = [self.strokeLayer path];
    if (!clipPath)
        return;
    
    // clip the gradient layer to mask it
    CGContextAddPath(ctx, clipPath);
    CGContextSaveGState(ctx);
    CGContextClip(ctx);
    [self.gradientLayer renderInContext:ctx];
    CGContextRestoreGState(ctx);
 
    // move the mask, then render the stroke layer
    [self.strokeLayer renderInContext:ctx];
 }

- (CGRect)boundingRect
{
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = (MIN(self.bounds.size.width, self.bounds.size.height) * self.radius) - (self.strokeLayer.lineWidth / 2);
    return CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2);
}

@end
