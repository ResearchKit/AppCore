// 
//  APCPieGraphView.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCPieGraphView.h"

static CGFloat const kAnimationDuration = 0.35f;

@interface APCPieGraphView ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@property (nonatomic) CGFloat plotRegionHeight;

@property (nonatomic, strong) NSMutableArray *actualValues;

@property (nonatomic, strong) NSMutableArray *normalizedValues;

@property (nonatomic) CGFloat sumOfValues;

@end


@implementation APCPieGraphView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _legendPaddingHeight = CGRectGetHeight(self.frame) * 0.3;
    _plotRegionHeight = (CGRectGetHeight(self.frame) - _legendPaddingHeight);
    _pieGraphRadius = _plotRegionHeight * 0.55 * 0.5; //The 0.5 is to get radius from diameter
    
    _lineWidth = CGRectGetHeight(self.frame)/20.0f;
    
    _circleLayer = [CAShapeLayer layer];
    _circleLayer.fillColor = [UIColor clearColor].CGColor;
    _circleLayer.strokeColor = [UIColor colorWithWhite:0.96 alpha:1.000].CGColor;
    _circleLayer.lineWidth = _lineWidth;
    
    _legendDotRadius = 9;
    
    _shouldAnimate = YES;
    _shouldAnimateLegend = YES;
    
    _actualValues = [NSMutableArray new];
    _normalizedValues = [NSMutableArray new];
    _sumOfValues = 0;
    
    _legendFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    _percentageFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    
    _titleLabel = [UILabel new];
    [_titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:_pieGraphRadius/6.0f]];
    [_titleLabel setTextColor:[UIColor colorWithWhite:0.55 alpha:1.0]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    _valueLabel = [UILabel new];
    [_valueLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:_pieGraphRadius/3.0f]];
    [_valueLabel setTextColor:[UIColor colorWithWhite:0.17 alpha:1.0]];
    [_valueLabel setTextAlignment:NSTextAlignmentCenter];
}


#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.circleLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    [self updateValues];
    
    self.circleLayer.frame = CGRectMake(CGRectGetWidth(self.frame)/2 - self.pieGraphRadius, _plotRegionHeight/2 - self.pieGraphRadius, self.pieGraphRadius * 2, self.pieGraphRadius * 2);
    self.circleLayer.path = [self circularPath].CGPath;
    [self.layer addSublayer:self.circleLayer];

    //Reset Data
    [self.actualValues removeAllObjects];
    [self.normalizedValues removeAllObjects];
    
    [self normalizeActualValues];
    
    [self drawTitleLabels];
    
    [self drawPieGraph];
    [self drawPercentageLabels];
    [self drawLegend];
    
    
}

- (void)updateValues
{
    _plotRegionHeight = (CGRectGetHeight(self.frame) - _legendPaddingHeight);
    
    _pieGraphRadius = _plotRegionHeight * 0.55 * 0.5;
    
    [_titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:_pieGraphRadius/6.0f]];
    
    [_valueLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:_pieGraphRadius/3.0f]];
}

- (UIBezierPath *)circularPath
{
    CGPoint center = CGPointMake(CGRectGetWidth(self.circleLayer.bounds)/2, CGRectGetHeight(self.circleLayer.bounds)/2);
    CGFloat radius = self.pieGraphRadius;
    
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = 3*M_PI_2;
    
    UIBezierPath *circularArcBezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    return circularArcBezierPath;
}

#pragma mark - Private Methods

- (NSInteger)numberOfSegments
{
    NSInteger count = 0;
    
    if ([self.datasource respondsToSelector:@selector(numberOfSegmentsInPieGraphView)]) {
        count = [self.datasource numberOfSegmentsInPieGraphView];
    }
    
    return count;
}

- (UIColor *)colorForSegmentAtIndex:(NSInteger)index
{
    UIColor *color = nil;
    
    if ([self.datasource respondsToSelector:@selector(pieGraphView:colorForSegmentAtIndex:)]) {
        color = [self.datasource pieGraphView:self colorForSegmentAtIndex:index];
    } else{
        
        //Default colors
        NSInteger numberOfSegments = [self numberOfSegments];
        if(numberOfSegments > 1){
            CGFloat divisionFactor = (CGFloat)(1/(CGFloat)(numberOfSegments -1));
            color = [UIColor colorWithWhite:(divisionFactor * index) alpha:1.0f];
        } else{
            color = [UIColor grayColor];
        }
    }
    
    return color;
}

- (CGFloat)valueForSegmentAtIndex:(NSInteger)index
{
    CGFloat value = 0;
    
    if ([self.datasource respondsToSelector:@selector(pieGraphView:valueForSegmentAtIndex:)]) {
        value = [self.datasource pieGraphView:self valueForSegmentAtIndex:index];
    }
    
    return value;
}

#pragma mark - Draw 

- (void)drawPieGraph
{
    CGFloat cumulativeValue = 0;
    
    for (NSInteger idx = 0; idx < [self numberOfSegments]; idx++) {
        
        CAShapeLayer *segmentLayer = [CAShapeLayer layer];
        segmentLayer.fillColor = [[UIColor clearColor] CGColor];
        segmentLayer.frame = self.circleLayer.bounds;
        segmentLayer.path = self.circleLayer.path;
        segmentLayer.lineCap = self.circleLayer.lineCap;
        segmentLayer.lineWidth = self.circleLayer.lineWidth;
        
        segmentLayer.strokeColor = [self colorForSegmentAtIndex:idx].CGColor;
        
        CGFloat value = ((NSNumber *)self.normalizedValues[idx]).floatValue;
        
        if (value != 0) {
            
            if (idx == 0) {
                segmentLayer.strokeStart = 0.0;
            } else {
                segmentLayer.strokeStart = cumulativeValue;
            }
            
            segmentLayer.strokeEnd = cumulativeValue;
            
            [self.circleLayer addSublayer:segmentLayer];
            
            if (self.shouldAnimate) {
                
                CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                strokeAnimation.fromValue = @(segmentLayer.strokeStart);
                strokeAnimation.toValue = @(cumulativeValue + value);
                strokeAnimation.duration = kAnimationDuration + 0.1;
                strokeAnimation.removedOnCompletion = NO;
                strokeAnimation.fillMode = kCAFillModeForwards;
                strokeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [segmentLayer addAnimation:strokeAnimation forKey:@"strokeAnimation"];
            }
        }
        
        cumulativeValue += value;
    }
}

- (void)drawPercentageLabels
{
    CGRect boundingBox = CGPathGetBoundingBox(self.circleLayer.path);
    
    CGFloat cumulativeValue = 0;
    
    for (NSInteger idx = 0; idx < [self numberOfSegments]; idx++) {
        CGFloat value = ((NSNumber *)self.normalizedValues[idx]).floatValue;
        
        
        if (value != 0) {
            CGFloat angle = (value/2 + cumulativeValue) * M_PI * 2;
            
            NSInteger offset = self.lineWidth/2 + 20;
            
            CGPoint labelCenter = CGPointMake(cos(angle - M_PI_2) * (self.pieGraphRadius + offset) + boundingBox.size.width/2,
                                              sin(angle - M_PI_2) * (self.pieGraphRadius + offset) + boundingBox.size.height/2);
            
            NSString *text = [NSString stringWithFormat:@"%0.0f%%", (value < .01) ? 1 :value * 100];
            CATextLayer *textLayer = [CATextLayer layer];
            textLayer.string = text;
            textLayer.fontSize = 14.0;
            textLayer.foregroundColor = [self colorForSegmentAtIndex:idx].CGColor;
            
            CGFloat textWidth = [text boundingRectWithSize:CGSizeMake(100, 21) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:textLayer.fontSize]} context:nil].size.width;
            
            textLayer.frame = CGRectMake(0, 0, textWidth, 21);
            textLayer.position = labelCenter;
            textLayer.alignmentMode = @"center";
            textLayer.contentsScale = [[UIScreen mainScreen] scale];
            
            [self.circleLayer addSublayer:textLayer];
            
            cumulativeValue += value;
            
            if (self.shouldAnimate) {
                
                CABasicAnimation *textAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                textAnimation.fromValue = @0;
                textAnimation.toValue = @1;
                textAnimation.duration = 0.3;
                textAnimation.removedOnCompletion = NO;
                textAnimation.fillMode = kCAFillModeForwards;
                textAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                [textLayer addAnimation:textAnimation forKey:@"textAnimation"];
            }
        }
    }
    
}

- (void)drawLegend
{
    for (NSInteger idx = 0; idx < [self numberOfSegments]; idx++) {
        
        CGFloat dotSegmentWidth = (CGRectGetWidth(self.frame)/[self numberOfSegments]);
        CGFloat dotXPosition = dotSegmentWidth * (idx + 0.5);
        
        CAShapeLayer *dot = [CAShapeLayer layer];
        dot.frame = CGRectMake(0, 0, self.legendDotRadius*2, self.legendDotRadius*2);
        dot.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, CGRectGetWidth(dot.bounds), CGRectGetHeight(dot.bounds))
                                              cornerRadius:self.legendDotRadius].CGPath;
        dot.position = CGPointMake(dotXPosition, self.plotRegionHeight + self.legendDotRadius);
        dot.fillColor = [self colorForSegmentAtIndex:idx].CGColor;
        [self.layer addSublayer:dot];
        
        NSString *text = @"";
        if ([self.datasource respondsToSelector:@selector(pieGraphView:titleForSegmentAtIndex:)]) {
            text = [self.datasource pieGraphView:self titleForSegmentAtIndex:idx];
        }
        
        CGFloat labelPadding = 5;
        
        UILabel *textLabel = [UILabel new];
        textLabel.text = text;
        textLabel.font = self.legendFont;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.adjustsFontSizeToFitWidth = YES;
        textLabel.frame = CGRectMake(labelPadding + dotSegmentWidth * idx, self.plotRegionHeight + 2*self.legendDotRadius, dotSegmentWidth - 2*labelPadding, self.legendPaddingHeight - self.legendDotRadius*2);
        textLabel.numberOfLines = 2;
        textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:textLabel];

        if (self.shouldAnimateLegend) {
            
            CABasicAnimation *dotAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            dotAnimation.fromValue = [NSValue valueWithCGPoint:self.circleLayer.position];
            dotAnimation.toValue = [NSValue valueWithCGPoint:dot.position];
            dotAnimation.beginTime = CACurrentMediaTime() + 0.05*idx;
            dotAnimation.duration = kAnimationDuration;
            dotAnimation.removedOnCompletion = NO;
            dotAnimation.fillMode = kCAFillModeForwards;
            dotAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [dot addAnimation:dotAnimation forKey:@"dotAnimation"];
            
            CABasicAnimation *textAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            textAnimation.fromValue = @0;
            textAnimation.toValue = @1;
            textAnimation.beginTime = CACurrentMediaTime() + 0.05*idx;
            textAnimation.duration = dotAnimation.duration;
            textAnimation.removedOnCompletion = NO;
            textAnimation.fillMode = kCAFillModeForwards;
            textAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [textLabel.layer addAnimation:textAnimation forKey:@"textAnimation"];
        }
    }
}

- (void)drawTitleLabels
{
    CGFloat labelWidth = self.pieGraphRadius * 1.2;
    
    CGFloat labelXPos = CGRectGetMidX(self.circleLayer.frame) - labelWidth/2;
    CGFloat labelYPos = CGRectGetMidY(self.circleLayer.frame);
    
    [self.valueLabel setFrame:CGRectMake(labelXPos, labelYPos, labelWidth, self.pieGraphRadius*0.4)];
    [self addSubview:self.valueLabel];
    
    [self.titleLabel setFrame:CGRectMake(labelXPos, CGRectGetMaxY(self.valueLabel.frame), labelWidth, CGRectGetHeight(self.valueLabel.frame)*0.6)];
    [self addSubview:self.titleLabel];    
}

#pragma mark - Data Normalization

- (void)normalizeActualValues
{
    self.sumOfValues = 0;
    
    for (int idx=0; idx < [self numberOfSegments]; idx++) {
        
        CGFloat value = [self valueForSegmentAtIndex:idx];
        
        [self.actualValues addObject:@(value)];
        self.sumOfValues += value;
    }
    
    for (int idx=0; idx < [self numberOfSegments]; idx++) {
        CGFloat value = 0;
        
        if (self.sumOfValues != 0) {
            value = ((NSNumber *)self.actualValues[idx]).floatValue/self.sumOfValues;
        }
        
        [self.normalizedValues addObject:@(value)];
    }
}

@end
