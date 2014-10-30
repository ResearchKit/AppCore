//
//  APCLineGraphView.m
//  YMLCharts
//
//  Created by Ramsundar Shandilya on 10/2/14.
//  Copyright (c) 2014 Ramsundar Shandilya. All rights reserved.
//

#import "APCLineGraphView.h"
#import "APCCircleView.h"
#import "APCAxisView.h"

static CGFloat const kYAxisPaddingFactor = 0.166f;
static CGFloat const kAPCGraphLeftPadding = 17.f;
static CGFloat const kTitleLeftPadding = 12.f;
static CGFloat const kAxisMarkingRulerLength = 8.0f;

static NSString * const kFadeAnimationKey = @"LayerFadeAnimation";
static NSString * const kGrowAnimationKey = @"LayerGrowAnimation";

static CGFloat const kFadeAnimationDuration = 0.8;
static CGFloat const kGrowAnimationDuration = 1.5;
static CGFloat const kPopAnimationDuration  = 0.3;

@interface APCLineGraphView ()

@property (nonatomic, strong) NSMutableArray *dataPoints;//actual data
@property (nonatomic, strong) NSMutableArray *xAxisPoints;
@property (nonatomic, strong) NSMutableArray *yAxisPoints;//normalised for this view

@property (nonatomic, strong) UIView *plotsView; //Holds the plots

@property (nonatomic, strong) APCAxisView *xAxisView;
@property (nonatomic, strong) UIView *yAxisView;

@property (nonatomic, strong) UIView *leftTintView;

@property (nonatomic, strong) UIView *scrubberLine;
@property (nonatomic, strong) UILabel *scrubberLabel;
@property (nonatomic, strong) UIView *scrubberThumbView;

@property (nonatomic, readwrite) CGFloat minimumValue;
@property (nonatomic, readwrite) CGFloat maximumValue;

@property (nonatomic, strong) NSMutableArray *xAxisTitles;
@property (nonatomic) NSInteger numberOfXAxisTitles;

@end

@implementation APCLineGraphView

@synthesize tintColor = _tintColor;

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _dataPoints = [NSMutableArray new];
    
    _xAxisPoints = [NSMutableArray new];
    _yAxisPoints = [NSMutableArray new];
    
    _xAxisTitles = [NSMutableArray new];
    
    _tintColor = [UIColor colorWithRed:244/255.f green:190/255.f blue:74/255.f alpha:1.f];
    
    _axisColor = [UIColor colorWithRed:100/255.f green:100/255.f blue:100/255.f alpha:1.f];
    _axisTitleColor = [UIColor colorWithRed:142/255.f green:142/255.f blue:147/255.f alpha:1.f];
    _axisTitleFont = [UIFont fontWithName:@"Helvetica" size:11.0f];
    
    _referenceLineColor = [UIColor colorWithRed:199/255.f green:199/255.f blue:204/255.f alpha:1.f];
    
    _scrubberLineColor = [UIColor grayColor];
    _scrubberThumbColor = [UIColor colorWithWhite:1 alpha:0.8];
    
    [self setupViews];
}

- (void)setupViews
{
    CGFloat yAxisPadding = CGRectGetWidth(self.frame)*kYAxisPaddingFactor;
    
    _leftTintView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, CGRectGetHeight(self.bounds) - kXAxisHeight)];
    _leftTintView.backgroundColor = _tintColor;
    [self addSubview:_leftTintView];
    
    _plotsView = [[UIView alloc] initWithFrame:CGRectMake(kAPCGraphLeftPadding, kAPCGraphTopPadding, CGRectGetWidth(self.frame) - yAxisPadding - kAPCGraphLeftPadding, CGRectGetHeight(self.frame) - kXAxisHeight - kAPCGraphTopPadding)]; //TODO: Fix frame
    _plotsView.backgroundColor = [UIColor clearColor];
    [self addSubview:_plotsView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftTintView.frame) + kTitleLeftPadding, 0, CGRectGetWidth(self.frame)*0.75, kAPCGraphTopPadding/2)];
    _titleLabel.textColor = _tintColor;
    _titleLabel.font = [UIFont fontWithName:@"Helvetica" size:19.0f];
    [self addSubview:_titleLabel];
    
    _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftTintView.frame), kAPCGraphTopPadding/2, CGRectGetWidth(self.frame)*0.75, kAPCGraphTopPadding/2)];
    _subTitleLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
    _subTitleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:16.0f];
    [self addSubview:_subTitleLabel];
    
    _scrubberLine = [[UIView alloc] initWithFrame:CGRectMake(0, kAPCGraphTopPadding, 1, CGRectGetHeight(self.plotsView.frame))];
    _scrubberLine.backgroundColor = _scrubberLineColor;
    _scrubberLine.alpha = 0;
    [self addSubview:_scrubberLine];
    
    _scrubberLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 100, 20)];
    _scrubberLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:12.0f];
    _scrubberLabel.alpha = 0;
    [self addSubview:_scrubberLabel];
    
    _scrubberThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _scrubberThumbView.layer.cornerRadius = _scrubberThumbView.bounds.size.height/2;
    _scrubberThumbView.layer.borderWidth = 1.0;
    _scrubberThumbView.backgroundColor = _scrubberThumbColor;
    _scrubberThumbView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _scrubberThumbView.alpha = 0;
    [self addSubview:_scrubberThumbView];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    _panGestureRecognizer.delaysTouchesBegan = YES;
    [self addGestureRecognizer:_panGestureRecognizer];
}

- (void)setDefaults
{
    _minimumValue = MAXFLOAT;
    _maximumValue = -MAXFLOAT;
}

#pragma mark - View Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat yAxisPadding = CGRectGetWidth(self.frame)*kYAxisPaddingFactor;
    
    _leftTintView.frame = CGRectMake(0, 0, 4, CGRectGetHeight(self.bounds) - kXAxisHeight);
    
    self.plotsView.frame = CGRectMake(kAPCGraphLeftPadding, kAPCGraphTopPadding, CGRectGetWidth(self.frame) - yAxisPadding - kAPCGraphLeftPadding, CGRectGetHeight(self.frame) - kXAxisHeight - kAPCGraphTopPadding);
    
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(_leftTintView.frame) + kTitleLeftPadding, 0, CGRectGetWidth(self.frame)*0.75, kAPCGraphTopPadding/2);
    self.subTitleLabel.frame = CGRectMake(CGRectGetMaxX(_leftTintView.frame) + kTitleLeftPadding, kAPCGraphTopPadding/2, CGRectGetWidth(self.frame)*0.75, kAPCGraphTopPadding/2);
    
    self.scrubberLine.frame = CGRectMake(0, kAPCGraphTopPadding, 1, CGRectGetHeight(self.plotsView.frame));
    
    //Clear subviews and sublayers
    [self.plotsView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    for (UIView *subView in [self.plotsView subviews]) {
        if (subView != self.scrubberLine && subView != _scrubberLabel) {
            [subView removeFromSuperview];
        }
    }
    
    [self drawXAxis];
    [self drawYAxis];
    [self drawhorizontalReferenceLines];
    [self drawVerticalReferenceLines];
    
    for (int i=0; i<[self numberOfPlots]; i++) {
        if ([self numberOfPointsinPlot:i] <= 1) {
            return;
        } else {
            [self drawGraphForPlotIndex:i];
        }
    }
    
    [self.xAxisView layoutSubviews];
}

#pragma mark - Data

- (NSInteger)numberOfPlots
{
    NSInteger numberOfPlots = 1;
    
    if ([self.datasource respondsToSelector:@selector(numberOfPlotsInLineGraph:)]) {
        numberOfPlots = [self.datasource numberOfPlotsInLineGraph:self];
    }
    
    return numberOfPlots;
}

- (NSInteger)numberOfPointsinPlot:(NSInteger)plotIndex
{
    NSInteger numberOfPoints = 0;
    
    if ([self.datasource respondsToSelector:@selector(lineGraph:numberOfPointsInPlot:)]) {
        numberOfPoints = [self.datasource lineGraph:self numberOfPointsInPlot:plotIndex];

    }
    
    return numberOfPoints;
}

- (NSInteger)numberOfXAxisTitles
{
    _numberOfXAxisTitles = 0;
    
    if ([self.datasource respondsToSelector:@selector(numberOfDivisionsInXAxisForGraph:)]) {
        _numberOfXAxisTitles = [self.datasource numberOfDivisionsInXAxisForGraph:self];
    } else {
        _numberOfXAxisTitles = [self numberOfPointsinPlot:0];
    }

    return _numberOfXAxisTitles;
}

- (void)prepareDataForPlotIndex:(NSInteger)plotIndex
{
    [self.dataPoints removeAllObjects];
    [self.xAxisPoints removeAllObjects];
    [self.yAxisPoints removeAllObjects];
    
    for (int i = 0; i<[self numberOfPointsinPlot:plotIndex]; i++) {
        
        if ([self.datasource respondsToSelector:@selector(lineGraph:plot:valueForPointAtIndex:)]) {
            CGFloat value = [self.datasource lineGraph:self plot:plotIndex valueForPointAtIndex:i];
            [self.dataPoints addObject:@(value)];
        }
    }
    
    [self.yAxisPoints addObjectsFromArray:[self normalizeCanvasPoints:self.dataPoints forRect:self.plotsView.frame.size]];
}

#pragma mark - Draw

- (void)drawXAxis
{
    //Add Title Labels
    
    if (self.xAxisView) {
        [self.xAxisView removeFromSuperview];
        self.xAxisView = nil;
    }
    
    self.xAxisView = [[APCAxisView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.plotsView.frame), CGRectGetWidth(self.plotsView.frame), kXAxisHeight)];
    self.xAxisView.tintColor = self.axisTitleColor;
    [self.xAxisView setupLabels:self.xAxisTitles forAxisType:kAPCGraphAxisTypeX];
    self.xAxisView.leftOffset = kAPCGraphLeftPadding;
    [self addSubview:self.xAxisView];
    
    UIBezierPath *xAxispath = [UIBezierPath bezierPath];
    [xAxispath moveToPoint:CGPointMake(0, 0)];
    [xAxispath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), 0)];
    
    CAShapeLayer *xAxisLineLayer = [CAShapeLayer layer];
    xAxisLineLayer.strokeColor = self.axisColor.CGColor;
    xAxisLineLayer.path = xAxispath.CGPath;
    [self.xAxisView.layer addSublayer:xAxisLineLayer];
    
    [self.xAxisTitles removeAllObjects];
    
    for (int i=0; i<self.numberOfXAxisTitles; i++) {
        if ([self.delegate respondsToSelector:@selector(lineGraph:titleForXAxisAtIndex:)]) {
            NSString *title = [self.delegate lineGraph:self titleForXAxisAtIndex:i];
            
            [self.xAxisTitles addObject:title];
            
            CGFloat positionOnXAxis = kAPCGraphLeftPadding + ((CGRectGetWidth(self.plotsView.frame) / (self.numberOfXAxisTitles - 1)) * i);
            
            UIBezierPath *rulerPath = [UIBezierPath bezierPath];
            [rulerPath moveToPoint:CGPointMake(positionOnXAxis, - kAxisMarkingRulerLength)];
            [rulerPath addLineToPoint:CGPointMake(positionOnXAxis, 0)];
            
            CAShapeLayer *rulerLayer = [CAShapeLayer layer];
            rulerLayer.strokeColor = self.axisColor.CGColor;
            rulerLayer.path = rulerPath.CGPath;
            [self.xAxisView.layer addSublayer:rulerLayer];
        }
    }
    
    xAxisLineLayer.opacity = 0;
    [self animateLayer:xAxisLineLayer withAnimationType:kAPCGraphAnimationTypeFade startDelay:0.3];
}

- (void)drawYAxis
{
    NSArray *yAxisLabelFactors = @[@0.2f,@0.8f];
    
    if (self.yAxisView) {
        [self.yAxisView removeFromSuperview];
        self.yAxisView = nil;
    }
    
    CGFloat axisViewXPosition = CGRectGetWidth(self.frame) * (1 - kYAxisPaddingFactor);
    CGFloat axisViewWidth = CGRectGetWidth(self.frame)*kYAxisPaddingFactor;
    
    self.yAxisView = [[UIView alloc] initWithFrame:CGRectMake(axisViewXPosition, kAPCGraphTopPadding, axisViewWidth, CGRectGetHeight(self.plotsView.frame))];
    [self addSubview:self.yAxisView];
    
    [self calculateMinAndMaxPoints];
    
    CGFloat rulerXPosition = CGRectGetWidth(self.yAxisView.bounds) - kAxisMarkingRulerLength;
    
    for (int i =0; i<yAxisLabelFactors.count; i++) {
        
        CGFloat factor = ((NSNumber *)yAxisLabelFactors[i]).floatValue;
        CGFloat positionOnYAxis = CGRectGetHeight(self.plotsView.frame) * (1 - factor);
        
        UIBezierPath *rulerPath = [UIBezierPath bezierPath];
        [rulerPath moveToPoint:CGPointMake(rulerXPosition, positionOnYAxis)];
        [rulerPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.yAxisView.bounds), positionOnYAxis)];
        
        CAShapeLayer *rulerLayer = [CAShapeLayer layer];
        rulerLayer.strokeColor = self.axisColor.CGColor;
        rulerLayer.path = rulerPath.CGPath;
        [self.yAxisView.layer addSublayer:rulerLayer];
        
        CGFloat labelHeight = 20;//TODO:Constant
        CGFloat labelYPosition = positionOnYAxis - labelHeight/2;
        
        CGFloat yValue = self.minimumValue + (self.maximumValue - self.minimumValue)*factor;
        
        UILabel *axisTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, labelYPosition, CGRectGetWidth(self.yAxisView.frame) - kAxisMarkingRulerLength, labelHeight)];
        axisTitleLabel.text = [NSString stringWithFormat:@"%.1f  ", yValue];
        axisTitleLabel.backgroundColor = [UIColor clearColor];
        axisTitleLabel.textColor = self.axisTitleColor;
        axisTitleLabel.textAlignment = NSTextAlignmentRight;
        axisTitleLabel.font = self.axisTitleFont;
        axisTitleLabel.minimumScaleFactor = 0.8;
        [self.yAxisView addSubview:axisTitleLabel];//TODO: Add to Axis View
    }
}

- (void)drawhorizontalReferenceLines
{
    UIBezierPath *referenceLinePath = [UIBezierPath bezierPath];
    [referenceLinePath moveToPoint:CGPointMake(kAPCGraphLeftPadding, kAPCGraphTopPadding + CGRectGetHeight(self.plotsView.frame)/2)];
    [referenceLinePath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), kAPCGraphTopPadding + CGRectGetHeight(self.plotsView.frame)/2)];
    
    CAShapeLayer *referenceLineLayer = [CAShapeLayer layer];
    referenceLineLayer.strokeColor = self.referenceLineColor.CGColor;
    referenceLineLayer.path = referenceLinePath.CGPath;
    referenceLineLayer.lineDashPattern = @[@5];
    [self.layer addSublayer:referenceLineLayer];
    
    referenceLineLayer.opacity = 0;
    [self animateLayer:referenceLineLayer withAnimationType:kAPCGraphAnimationTypeFade startDelay:0.3];
}

- (void)drawVerticalReferenceLines
{
    for (int i=1; i<self.numberOfXAxisTitles; i++) {
        
        CGFloat positionOnXAxis = ((CGRectGetWidth(self.plotsView.frame) / (self.numberOfXAxisTitles - 1)) * i);
        
        UIBezierPath *referenceLinePath = [UIBezierPath bezierPath];
        [referenceLinePath moveToPoint:CGPointMake(positionOnXAxis, 0)];
        [referenceLinePath addLineToPoint:CGPointMake(positionOnXAxis, CGRectGetHeight(self.plotsView.frame))];
        
        CAShapeLayer *referenceLineLayer = [CAShapeLayer layer];
        referenceLineLayer.strokeColor = self.referenceLineColor.CGColor;
        referenceLineLayer.path = referenceLinePath.CGPath;
        referenceLineLayer.lineDashPattern = @[@5];
        [self.plotsView.layer addSublayer:referenceLineLayer];
        
        CGFloat delay = 0.3 + i/10.f;
        referenceLineLayer.opacity = 0;
        [self animateLayer:referenceLineLayer withAnimationType:kAPCGraphAnimationTypeFade startDelay:delay];
    }
}

- (void)drawGraphForPlotIndex:(NSInteger)plotIndex;
{
    [self prepareDataForPlotIndex:plotIndex];
    
    [self drawPointCirclesForPlotIndex:plotIndex];
    [self drawLinesForPlotIndex:plotIndex];
}

- (void)drawPointCirclesForPlotIndex:(NSInteger)plotIndex
{
    for (int i=0 ; i<self.yAxisPoints.count; i++) {
        
        CGFloat positionOnXAxis = ((CGRectGetWidth(self.plotsView.frame) / (self.yAxisPoints.count - 1)) * i);
        [self.xAxisPoints addObject:@(positionOnXAxis)];
        
        CGFloat positionOnYAxis = ((NSNumber*)self.yAxisPoints[i]).floatValue;
        
        APCCircleView *point = [[APCCircleView alloc] initWithFrame:CGRectMake(0, 0, 7, 7)];
        point.tintColor = (plotIndex == 0) ? self.tintColor : self.referenceLineColor;
        point.center = CGPointMake(positionOnXAxis, positionOnYAxis);
        [self.plotsView addSubview:point];
        
        CGFloat delay = 0.8 + i/5.f;
        point.alpha = 0;
        [self animateLayer:point.shapeLayer withAnimationType:kAPCGraphAnimationTypeFade startDelay:delay];
    }
}

- (void)drawLinesForPlotIndex:(NSInteger)plotIndex
{
    UIBezierPath *plotLinePath = [UIBezierPath bezierPath];
    UIBezierPath *fillPath = [UIBezierPath bezierPath];
    
    //TODO: Check if fill path
    [fillPath moveToPoint:CGPointMake(CGRectGetWidth(self.plotsView.frame), CGRectGetHeight(self.plotsView.frame))];
    [fillPath addLineToPoint:CGPointMake(0, CGRectGetHeight(self.plotsView.frame))];
    
    [plotLinePath moveToPoint:CGPointMake(0, CGRectGetHeight(self.plotsView.frame))];
    
    for (int i=0; i<self.yAxisPoints.count; i++) {
        
        CGFloat positionOnXAxis = ((NSNumber*)self.xAxisPoints[i]).floatValue;
        CGFloat positionOnYAxis = ((NSNumber*)self.yAxisPoints[i]).floatValue;
        
        [fillPath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis)];
        [plotLinePath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis)];
    }
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = fillPath.CGPath;
    fillLayer.fillColor = (plotIndex == 0) ? [self.tintColor colorWithAlphaComponent:0.2].CGColor : [self.referenceLineColor colorWithAlphaComponent:0.2].CGColor;
    [self.plotsView.layer addSublayer:fillLayer];
    
    fillLayer.opacity = 0;
    [self animateLayer:fillLayer withAnimationType:kAPCGraphAnimationTypeFade startDelay:1.9];
    
    CAShapeLayer *plotLineLayer = [CAShapeLayer layer];
    plotLineLayer.path = plotLinePath.CGPath;
    plotLineLayer.fillColor = [UIColor clearColor].CGColor;
    plotLineLayer.strokeColor = (plotIndex == 0) ? self.tintColor.CGColor : self.referenceLineColor.CGColor;
    plotLineLayer.lineJoin = kCALineJoinRound;
    plotLineLayer.lineCap = kCALineCapRound;
    [self.plotsView.layer addSublayer:plotLineLayer];
    
    plotLineLayer.strokeEnd = 0;
    [self animateLayer:plotLineLayer withAnimationType:kAPCGraphAnimationTypeGrow startDelay:1];
}

#pragma mark - Graph Calculations

- (void)calculateMinAndMaxPoints
{
    [self setDefaults];
    
    //Min
    if ([self.delegate respondsToSelector:@selector(minimumValueForLineGraph:)]) {
        self.minimumValue = [self.delegate minimumValueForLineGraph:self];
    } else {
        for (NSNumber *num in self.dataPoints) {
            if (num.floatValue < self.minimumValue) {
                self.minimumValue = num.floatValue;
            }
        }
    }
    
    //Max
    if ([self.delegate respondsToSelector:@selector(maximumValueForLineGraph:)]) {
        self.maximumValue = [self.delegate maximumValueForLineGraph:self];
    } else {
        for (NSNumber *num in self.dataPoints) {
            if (num.floatValue > self.maximumValue) {
                self.maximumValue = num.floatValue;
            }
        }
    }
}

- (NSArray *)normalizeCanvasPoints:(NSArray *)dataPoints forRect:(CGSize)canvasSize
{
    [self calculateMinAndMaxPoints];
    
    NSMutableArray *normalizedPoints = [NSMutableArray new];
    
    for (int i=0; i<self.dataPoints.count; i++) {
        
        CGFloat normalizedPointValue;
        CGFloat dataPointValue = ((NSNumber*)self.dataPoints[i]).floatValue;
        
        if (self.minimumValue == self.maximumValue) {
            normalizedPointValue = canvasSize.height/2;
        } else {
            CGFloat range = self.maximumValue - self.minimumValue;
            CGFloat normalizedValue = (dataPointValue - self.minimumValue)/range * canvasSize.height;
            normalizedPointValue = canvasSize.height - normalizedValue;
        }
        [normalizedPoints addObject:@(normalizedPointValue)];
    }
    
    return [NSArray arrayWithArray:normalizedPoints];
}

/* Used when the user scrubs the plot */
- (CGFloat)valueForCanvasXPosition:(CGFloat)xPosition
{
    CGFloat value;
    
    NSInteger positionIndex;
    for (positionIndex = 0; positionIndex<self.xAxisPoints.count-1; positionIndex++) {
        CGFloat num = ((NSNumber *)self.xAxisPoints[positionIndex]).floatValue;
        if (xPosition < num) {
            break;
        }
    }
    
    CGFloat x1 = ((NSNumber *)self.xAxisPoints[positionIndex - 1]).floatValue;
    CGFloat x2 = ((NSNumber *)self.xAxisPoints[positionIndex]).floatValue;
    
    CGFloat y1 = ((NSNumber *)self.dataPoints[positionIndex - 1]).floatValue;
    CGFloat y2 = ((NSNumber *)self.dataPoints[positionIndex]).floatValue;
    
    CGFloat slope = (y2 - y1)/(x2 - x1);
    
    //  (y2 - y3)/(x2 - x3) = m
    value = y2 - (slope * (x2 - xPosition));
    
    return value;
}

- (CGFloat)canvasYPointForXPosition:(CGFloat)xPosition
{
    CGFloat canvasYPosition;
    
    NSInteger positionIndex;
    for (positionIndex = 0; positionIndex<self.xAxisPoints.count - 1; positionIndex++) {
        CGFloat num = ((NSNumber *)self.xAxisPoints[positionIndex]).floatValue;
        if (xPosition < num) {
            break;
        }
    }
    
    CGFloat x1 = ((NSNumber *)self.xAxisPoints[positionIndex - 1]).floatValue;
    CGFloat x2 = ((NSNumber *)self.xAxisPoints[positionIndex]).floatValue;
    
    CGFloat y1 = ((NSNumber *)self.yAxisPoints[positionIndex - 1]).floatValue;
    CGFloat y2 = ((NSNumber *)self.yAxisPoints[positionIndex]).floatValue;
    
    CGFloat slope = (y2 - y1)/(x2 - x1);
    
    //  (y2 - y3)/(x2 - x3) = m
    canvasYPosition = y2 - (slope * (x2 - xPosition));
    
    return canvasYPosition;
}

#pragma mark - Animations

- (void)animateLayer:(CAShapeLayer *)shapeLayer withAnimationType:(APCGraphAnimationType)animationType
{
    [self animateLayer:shapeLayer withAnimationType:animationType toValue:1.0];
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer withAnimationType:(APCGraphAnimationType)animationType toValue:(CGFloat)toValue
{
    [self animateLayer:shapeLayer withAnimationType:animationType toValue:toValue startDelay:0.0];
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer withAnimationType:(APCGraphAnimationType)animationType startDelay:(CGFloat)delay
{
    [self animateLayer:shapeLayer withAnimationType:animationType toValue:1.0 startDelay:delay];
}

- (void)animateLayer:(CAShapeLayer *)shapeLayer withAnimationType:(APCGraphAnimationType)animationType toValue:(CGFloat)toValue startDelay:(CGFloat)delay
{
    if (animationType == kAPCGraphAnimationTypeFade) {
        
        CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeAnimation.beginTime = CACurrentMediaTime() + delay;
        fadeAnimation.fromValue = @0;
        fadeAnimation.toValue = @(toValue);
        fadeAnimation.duration = kFadeAnimationDuration;
        fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        fadeAnimation.fillMode = kCAFillModeForwards;
        fadeAnimation.removedOnCompletion = NO;
        [shapeLayer addAnimation:fadeAnimation forKey:kFadeAnimationKey];
        
    } else if (animationType == kAPCGraphAnimationTypeGrow) {
        
        CABasicAnimation *growAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        growAnimation.beginTime = CACurrentMediaTime() + delay;
        growAnimation.fromValue = @0;
        growAnimation.toValue = @(toValue);
        growAnimation.duration = kGrowAnimationDuration;
        growAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        growAnimation.fillMode = kCAFillModeForwards;
        growAnimation.removedOnCompletion = NO;
        [shapeLayer addAnimation:growAnimation forKey:kGrowAnimationKey];
        
    } else if (animationType == kAPCGraphAnimationTypePop) {
        
        CABasicAnimation *popAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        popAnimation.beginTime = CACurrentMediaTime() + delay;
        popAnimation.fromValue = @0;
        popAnimation.toValue = @(toValue);
        popAnimation.duration = kPopAnimationDuration;
        popAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        popAnimation.fillMode = kCAFillModeForwards;
        popAnimation.removedOnCompletion = NO;
        [shapeLayer addAnimation:popAnimation forKey:kGrowAnimationKey];
        
    }
}

- (void)setScrubberViewsHidden:(BOOL)hidden animated:(BOOL)animated
{
    CGFloat alpha = hidden ? 0 : 1;
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.scrubberThumbView.alpha = alpha;
            self.scrubberLine.alpha = alpha;
            self.scrubberLabel.alpha = alpha;
        }];
    } else {
        self.scrubberThumbView.alpha = alpha;
        self.scrubberLine.alpha = alpha;
        self.scrubberLabel.alpha = alpha;
    }
    
}

#pragma mark - Touch

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (self.dataPoints.count > 0) {
        CGPoint location = [gestureRecognizer locationInView:self.plotsView];
        
        location = CGPointMake(location.x - kAPCGraphLeftPadding, location.y);
        
        CGFloat maxX = CGRectGetWidth(self.plotsView.bounds);
        CGFloat minX = 0;
        
        CGFloat normalizedX = MAX(MIN(location.x, maxX), minX);
        location = CGPointMake(normalizedX, location.y);
        
        self.scrubberLine.center = CGPointMake(location.x + kAPCGraphLeftPadding, self.scrubberLine.center.y);
        
        [self.scrubberLabel setFrame:CGRectMake(CGRectGetMaxX(self.scrubberLine.frame), CGRectGetMinY(self.scrubberLine.frame), CGRectGetWidth(self.scrubberLabel.frame), CGRectGetHeight(self.scrubberLabel.frame))];
        self.scrubberLabel.text = [NSString stringWithFormat:@"%.2f", [self valueForCanvasXPosition:location.x]];
        
        [self.scrubberThumbView setCenter:CGPointMake(location.x + kAPCGraphLeftPadding, [self canvasYPointForXPosition:location.x] + kAPCGraphTopPadding)];
        
        if ([self.delegate respondsToSelector:@selector(lineGraph:touchesMovedToXPosition:)]) {
            [self.delegate lineGraph:self touchesMovedToXPosition:location.x];
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self setScrubberViewsHidden:NO animated:YES];
            if ([self.delegate respondsToSelector:@selector(lineGraphTouchesBegan:)]) {
                [self.delegate lineGraphTouchesBegan:self];
            }
        } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
            [self setScrubberViewsHidden:YES animated:YES];
            if ([self.delegate respondsToSelector:@selector(lineGraphTouchesEnded:)]) {
                [self.delegate lineGraphTouchesEnded:self];
            }
        }
    }
}

#pragma mark - Public Methods

- (void)scrubReferenceLineForXPosition:(CGFloat)xPosition
{
    self.scrubberLine.center = CGPointMake(xPosition + kAPCGraphLeftPadding, self.scrubberLine.center.y);
    [self.scrubberLabel setFrame:CGRectMake(self.scrubberLine.frame.origin.x + 5, kAPCGraphTopPadding, CGRectGetWidth(self.scrubberLabel.frame), CGRectGetHeight(self.scrubberLabel.frame))];
    self.scrubberLabel.text = [NSString stringWithFormat:@"%.2f", [self valueForCanvasXPosition:xPosition]];
    
    [self.scrubberThumbView setCenter:CGPointMake(xPosition + kAPCGraphLeftPadding, [self canvasYPointForXPosition:xPosition] + kAPCGraphTopPadding)];
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    self.titleLabel.textColor = tintColor;
    self.leftTintView.backgroundColor = tintColor;
}
@end
