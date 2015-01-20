//
//  APCLineGraphView.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCLineGraphView.h"
#import "APCCircleView.h"
#import "APCAxisView.h"

static CGFloat const kYAxisPaddingFactor = 0.166f;
static CGFloat const kAPCGraphLeftPadding = 4.f;
static CGFloat const kTitleLeftPadding = 12.f;
static CGFloat const kAxisMarkingRulerLength = 8.0f;

static NSString * const kFadeAnimationKey = @"LayerFadeAnimation";
static NSString * const kGrowAnimationKey = @"LayerGrowAnimation";

static CGFloat const kFadeAnimationDuration = 0.3;
static CGFloat const kGrowAnimationDuration = 0.3;
static CGFloat const kPopAnimationDuration  = 0.3;

static CGFloat const kSnappingClosenessFactor = 0.35f;

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

@property (nonatomic, strong) NSMutableArray *referenceLines;
@property (nonatomic, strong) NSMutableArray *pathLines;
@property (nonatomic, strong) NSMutableArray *dots;
@property (nonatomic, strong) CAShapeLayer *fillPathLayer;

@property (nonatomic) BOOL shouldAnimate;

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
    
    _referenceLines = [NSMutableArray new];
    _pathLines = [NSMutableArray new];
    _dots = [NSMutableArray new];
    
    _tintColor = [UIColor colorWithRed:244/255.f green:190/255.f blue:74/255.f alpha:1.f];
    
    _axisColor = [UIColor colorWithRed:100/255.f green:100/255.f blue:100/255.f alpha:1.f];
    _axisTitleColor = [UIColor colorWithRed:142/255.f green:142/255.f blue:147/255.f alpha:1.f];
    _axisTitleFont = [UIFont fontWithName:@"Helvetica" size:11.0f];
    
    _referenceLineColor = [UIColor colorWithRed:225/255.f green:225/255.f blue:229/255.f alpha:1.f];
    
    _scrubberLineColor = [UIColor grayColor];
    _scrubberThumbColor = [UIColor colorWithWhite:1 alpha:0.8];
    
    _shouldAnimate = YES;
    
    [self setupViews];
}

- (void)setupViews
{
    /* ----------------- */
    /* Basic Views */
    /* ----------------- */
    _leftTintView = [UIView new];
    _leftTintView.backgroundColor = _tintColor;
    [self addSubview:_leftTintView];
    
    _plotsView = [UIView new];
    _plotsView.backgroundColor = [UIColor clearColor];
    [self addSubview:_plotsView];
    
    /* ----------------- */
    /* Labels */
    /* ----------------- */
    _titleLabel = [UILabel new];
    _titleLabel.textColor = _tintColor;
    _titleLabel.font = [UIFont fontWithName:@"Helvetica" size:19.0f];
    [self addSubview:_titleLabel];
    
    _subTitleLabel = [UILabel new];
    _subTitleLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
    _subTitleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:16.0f];
    [self addSubview:_subTitleLabel];
    
    /* ----------------- */
    /* Scrubber Views */
    /* ----------------- */
    _scrubberLine = [UIView new];
    _scrubberLine.backgroundColor = _scrubberLineColor;
    _scrubberLine.alpha = 0;
    [self addSubview:_scrubberLine];
    
    _scrubberLabel = [UILabel new];
    _scrubberLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:12.0f];
    _scrubberLabel.alpha = 0;
    [self addSubview:_scrubberLabel];
    
    _scrubberThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self scrubberThumbSize].width, [self scrubberThumbSize].height)];
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

- (NSString *)formatNumber:(NSNumber *)value
{
    NSString *formattedNumber = nil;
    NSString *suffix = @"k";
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    if ([value doubleValue] < 1000) {
        [numberFormatter setMaximumFractionDigits:0];
        formattedNumber = [numberFormatter stringFromNumber:value];
    } else {
        NSNumber *divdedValue = @([value doubleValue]/1000);
        [numberFormatter setMaximumFractionDigits:2];
        formattedNumber =  [NSString stringWithFormat:@"%@%@", [numberFormatter stringFromNumber:divdedValue], suffix];
    }
    
    return formattedNumber;
}

#pragma mark - Appearance

- (void)updateTitleLabel
{
    if (self.isLandscapeMode) {
        
        self.titleLabel.font = [UIFont fontWithName:self.titleLabel.font.familyName size:24.0];
        
        CGFloat textWidth = [self.titleLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame)*0.40, kAPCGraphTopPadding) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size.width;
        
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(_leftTintView.frame) + kTitleLeftPadding, 0, textWidth, kAPCGraphTopPadding);
        
    } else {
        self.titleLabel.font = [UIFont fontWithName:self.titleLabel.font.familyName size:19.0];
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(_leftTintView.frame) + kTitleLeftPadding, 0, CGRectGetWidth(self.frame)*0.75, kAPCGraphTopPadding/2);
    }
}

- (void)updateSubTitleLabel
{
    if (self.isLandscapeMode) {
        
        self.subTitleLabel.font = [UIFont fontWithName:self.subTitleLabel.font.familyName size:16.0];
        
        CGFloat textWidth = [self.subTitleLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame)*0.40, kAPCGraphTopPadding) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.subTitleLabel.font} context:nil].size.width;
        
        self.subTitleLabel.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + kTitleLeftPadding, 0, textWidth, kAPCGraphTopPadding);
        
    } else {
        self.subTitleLabel.font = [UIFont fontWithName:self.subTitleLabel.font.familyName size:16.0];
        self.subTitleLabel.frame = CGRectMake(CGRectGetMaxX(_leftTintView.frame) + kTitleLeftPadding, kAPCGraphTopPadding/2, CGRectGetWidth(self.frame)*0.75, kAPCGraphTopPadding/2);
    }
}

- (void)updateScrubberLabel
{
    if (self.isLandscapeMode) {
        self.scrubberLabel.font = [UIFont fontWithName:self.scrubberLabel.font.familyName size:14.0f];
        self.scrubberLabel.frame = CGRectMake(2, 0, 100, 20);
    } else {
        self.scrubberLabel.font = [UIFont fontWithName:self.scrubberLabel.font.familyName size:12.0f];
        self.scrubberLabel.frame = CGRectMake(2, 0, 100, 20);
    }
}

- (CGSize)scrubberThumbSize
{
    CGSize thumbSize;
    
    if (self.isLandscapeMode) {
        thumbSize = CGSizeMake(15, 15);
    } else{
        thumbSize = CGSizeMake(10, 10);
    }
    
    return thumbSize;
}


#pragma mark - View Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat yAxisPadding = CGRectGetWidth(self.frame)*kYAxisPaddingFactor;
    
    //Basic Views
    _leftTintView.frame = CGRectMake(0, 0, 4, CGRectGetHeight(self.bounds) - kXAxisHeight);
    
    self.plotsView.frame = CGRectMake(kAPCGraphLeftPadding, kAPCGraphTopPadding, CGRectGetWidth(self.frame) - yAxisPadding - kAPCGraphLeftPadding, CGRectGetHeight(self.frame) - kXAxisHeight - kAPCGraphTopPadding);
    
    //Title Labels
    [self updateTitleLabel];
    [self updateSubTitleLabel];
    
    //Scrubber Views
    self.scrubberLine.frame = CGRectMake(0, kAPCGraphTopPadding, 1, CGRectGetHeight(self.plotsView.frame));
    [self updateScrubberLabel];
    self.scrubberThumbView.frame = CGRectMake(0, 0, [self scrubberThumbSize].width, [self scrubberThumbSize].height);
    self.scrubberThumbView.layer.cornerRadius = self.scrubberThumbView.bounds.size.height/2;
    
    //Clear subviews and sublayers
    [self.plotsView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
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
    
    if (self.shouldAnimate) {
        [self performSelector:@selector(animateLayersSequentially) withObject:nil afterDelay:0.2];
        
    }
}

#pragma mark - Data

//TODO: Commenting out as it is drawing an unwanted horizontal ref. line.
//Investigate.

//- (void)setDatasource:(id<APCLineGraphViewDataSource>)datasource
//{
//    if (datasource != _datasource) {
//        _datasource = datasource;
//        [self layoutSubviews];
//    }
//}

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
    self.xAxisView.landscapeMode = self.landscapeMode;
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
        if ([self.datasource respondsToSelector:@selector(lineGraph:titleForXAxisAtIndex:)]) {
            NSString *title = [self.datasource lineGraph:self titleForXAxisAtIndex:i];
            
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
    
    CGFloat rulerXPosition = CGRectGetWidth(self.yAxisView.bounds) - kAxisMarkingRulerLength + 2;
    
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
        axisTitleLabel.text = [self formatNumber:@(yValue)]; //[NSString stringWithFormat:@"%.1f  ", yValue];
        axisTitleLabel.backgroundColor = [UIColor clearColor];
        axisTitleLabel.textColor = self.axisTitleColor;
        axisTitleLabel.textAlignment = NSTextAlignmentRight;
        axisTitleLabel.font = self.isLandscapeMode ? [UIFont fontWithName:self.axisTitleFont.familyName size:16.0f] : self.axisTitleFont;
        axisTitleLabel.minimumScaleFactor = 0.8;
        [self.yAxisView addSubview:axisTitleLabel];//TODO: Add to Axis View
    }
}

- (void)drawhorizontalReferenceLines
{
    [self.referenceLines removeAllObjects];
    
    UIBezierPath *referenceLinePath = [UIBezierPath bezierPath];
    [referenceLinePath moveToPoint:CGPointMake(kAPCGraphLeftPadding, kAPCGraphTopPadding + CGRectGetHeight(self.plotsView.frame)/2)];
    [referenceLinePath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), kAPCGraphTopPadding + CGRectGetHeight(self.plotsView.frame)/2)];
    
    CAShapeLayer *referenceLineLayer = [CAShapeLayer layer];
    referenceLineLayer.strokeColor = self.referenceLineColor.CGColor;
    referenceLineLayer.path = referenceLinePath.CGPath;
    referenceLineLayer.lineDashPattern = self.isLandscapeMode ? @[@12, @7] : @[@6, @4];
    [self.layer addSublayer:referenceLineLayer];
    
    if (self.shouldAnimate) {
        referenceLineLayer.opacity = 0;
    }
    [self.referenceLines addObject:referenceLineLayer];
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
        referenceLineLayer.lineDashPattern = self.isLandscapeMode ? @[@12, @7] : @[@6, @4];
        [self.plotsView.layer addSublayer:referenceLineLayer];
        
        if (self.shouldAnimate) {
            referenceLineLayer.opacity = 0;
        }
        [self.referenceLines addObject:referenceLineLayer];
    }
}

- (void)drawGraphForPlotIndex:(NSInteger)plotIndex;
{
    [self prepareDataForPlotIndex:plotIndex];
    
    [self drawPointCirclesForPlotIndex:plotIndex];
    
    if ([self numberOfValidValues] > 1) {
        [self drawLinesForPlotIndex:plotIndex];
    }
}

- (void)drawPointCirclesForPlotIndex:(NSInteger)plotIndex
{
    [self.dots removeAllObjects];
    
    for (int i=0 ; i<self.yAxisPoints.count; i++) {
        
        CGFloat dataPointVal = [self.dataPoints[i] floatValue];
        
        CGFloat positionOnXAxis = ((CGRectGetWidth(self.plotsView.frame) / (self.yAxisPoints.count - 1)) * i);
        positionOnXAxis = round(positionOnXAxis);
        [self.xAxisPoints addObject:@(positionOnXAxis)];
        
        if (dataPointVal != NSNotFound) {
            CGFloat positionOnYAxis = ((NSNumber*)self.yAxisPoints[i]).floatValue;
            
            CGFloat pointSize = self.isLandscapeMode ? 9.0f : 7.0f;
            APCCircleView *point = [[APCCircleView alloc] initWithFrame:CGRectMake(0, 0, pointSize, pointSize)];
            point.tintColor = (plotIndex == 0) ? self.tintColor : self.referenceLineColor;
            point.center = CGPointMake(positionOnXAxis, positionOnYAxis);
            [self.plotsView.layer addSublayer:point.layer];
            
            if (self.shouldAnimate) {
                point.alpha = 0;
            }
            
            [self.dots addObject:point];
        }
    }
}

- (void)drawLinesForPlotIndex:(NSInteger)plotIndex
{
    [self.pathLines removeAllObjects];
    
    UIBezierPath *fillPath = [UIBezierPath bezierPath];
    
    CGFloat positionOnXAxis = CGFLOAT_MAX;
    CGFloat positionOnYAxis = CGFLOAT_MAX;
    
    BOOL emptyDataPresent = NO;
    
    for (int i=0; i<self.yAxisPoints.count; i++) {
        
        CGFloat dataPointVal = [self.dataPoints[i] floatValue];
        
        if (dataPointVal != NSNotFound) {
            
            UIBezierPath *plotLinePath = [UIBezierPath bezierPath];
            
            if (positionOnXAxis != CGFLOAT_MAX) {
                //Prev point exists
                [plotLinePath moveToPoint:CGPointMake(positionOnXAxis, positionOnYAxis)];
                if ([fillPath isEmpty]) {
                    [fillPath moveToPoint:CGPointMake(positionOnXAxis, CGRectGetHeight(self.plotsView.frame))];
                }
                [fillPath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis)];
            }
            positionOnXAxis = [self.xAxisPoints[i] floatValue];
            positionOnYAxis = [self.yAxisPoints[i] floatValue];
            
            
            
            if (![plotLinePath isEmpty]) {
                [plotLinePath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis)];
                [fillPath addLineToPoint:CGPointMake(positionOnXAxis, positionOnYAxis)];
                
                CAShapeLayer *plotLineLayer = [CAShapeLayer layer];
                plotLineLayer.path = plotLinePath.CGPath;
                plotLineLayer.fillColor = [UIColor clearColor].CGColor;
                plotLineLayer.strokeColor = (plotIndex == 0) ? self.tintColor.CGColor : self.referenceLineColor.CGColor;
                plotLineLayer.lineJoin = kCALineJoinRound;
                plotLineLayer.lineCap = kCALineCapRound;
                plotLineLayer.lineWidth = self.isLandscapeMode ? 3.0 : 2.0;
                
                if (emptyDataPresent) {
                    plotLineLayer.lineDashPattern = self.isLandscapeMode ? @[@12, @7] : @[@12, @6];
                    emptyDataPresent = NO;
                }
                
                [self.plotsView.layer addSublayer:plotLineLayer];
                
                if (self.shouldAnimate) {
                    plotLineLayer.strokeEnd = 0;
                }
                [self.pathLines addObject:plotLineLayer];
            } else {
                emptyDataPresent = NO;
            }
            
        } else {
            emptyDataPresent = YES;
        }
    }
    
    [fillPath addLineToPoint:CGPointMake(positionOnXAxis, CGRectGetHeight(self.plotsView.frame))];
    
    self.fillPathLayer = [CAShapeLayer layer];
    self.fillPathLayer.path = fillPath.CGPath;
    self.fillPathLayer.fillColor = (plotIndex == 0) ? [self.tintColor colorWithAlphaComponent:0.4].CGColor : [self.referenceLineColor colorWithAlphaComponent:0.2].CGColor;
    [self.plotsView.layer addSublayer:self.fillPathLayer];
    
    if (self.shouldAnimate) {
        self.fillPathLayer.opacity = 0;
    }
}

#pragma mark - Graph Calculations

- (NSInteger)numberOfValidValues
{
    NSInteger count = 0;
    
    for (NSNumber *dataVal in self.dataPoints) {
        if (dataVal.floatValue != NSNotFound) {
            count ++;
        }
    }
    return count;
}

- (void)calculateMinAndMaxPoints
{
    [self setDefaults];
    
    //Min
    if ([self.datasource respondsToSelector:@selector(minimumValueForLineGraph:)]) {
        self.minimumValue = [self.datasource minimumValueForLineGraph:self];
    } else {
        for (NSNumber *num in self.dataPoints) {
            if (num.floatValue < self.minimumValue) {
                self.minimumValue = num.floatValue;
            }
        }
    }
    
    //Max
    if ([self.datasource respondsToSelector:@selector(maximumValueForLineGraph:)]) {
        self.maximumValue = [self.datasource maximumValueForLineGraph:self];
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
        CGFloat dataPointValue = [self.dataPoints[i] floatValue];
        
        if (dataPointValue == NSNotFound){
            normalizedPointValue = canvasSize.height;
        } else if (self.minimumValue == self.maximumValue) {
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
    CGFloat value= 0;
    
    NSInteger positionIndex = 0;
    
    for (positionIndex = 0; positionIndex<self.xAxisPoints.count-1; positionIndex++) {
        CGFloat xAxisPointVal = [self.xAxisPoints[positionIndex] floatValue];
        if (xAxisPointVal > xPosition) {
            break;
        }
    }
    
    CGFloat x1 = [self.xAxisPoints[positionIndex - 1] floatValue];
    
    CGFloat x2 = [self.xAxisPoints[positionIndex] floatValue];
    
    CGFloat y1 = [self.dataPoints[positionIndex - 1] floatValue];
    y1 = [self safeValueForValue:y1];
    
    CGFloat y2 = [self.dataPoints[positionIndex] floatValue];
    y2 = [self safeValueForValue:y2];
    
    CGFloat slope = (y2 - y1)/(x2 - x1);
    
    //  (y2 - y3)/(x2 - x3) = m
    value = y2 - (slope * (x2 - xPosition));
    
    return value;
}

- (CGFloat)safeValueForValue:(CGFloat)value
{
    CGFloat safeValue = value;
    
    if (safeValue == NSNotFound) {
        safeValue = 0;
    }
    
    return safeValue;
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

- (CGFloat)snappedXPosition:(CGFloat)xPosition
{
    CGFloat widthBetweenPoints = CGRectGetWidth(self.plotsView.frame)/self.xAxisPoints.count;
    
    NSInteger positionIndex;
    for (positionIndex = 0; positionIndex<self.xAxisPoints.count; positionIndex++) {
        
        CGFloat dataPointVal = [self.dataPoints[positionIndex] floatValue];
        
        if (dataPointVal != NSNotFound) {
            CGFloat num = [self.xAxisPoints[positionIndex] floatValue];
            
            if (fabs(num - xPosition) < (widthBetweenPoints * kSnappingClosenessFactor)) {
                xPosition = num;
            }
        }
        
    }
    
    return xPosition;
}

#pragma mark - Animations

- (void)animateLayersSequentially
{
    CGFloat delay = 0.3;
    
    for (int i=0; i<self.referenceLines.count; i++) {
        CAShapeLayer *layer = self.referenceLines[i];
        delay += 0.1;
        [self animateLayer:layer withAnimationType:kAPCGraphAnimationTypeFade startDelay:delay];
    }
    
    for (int i=0; i<self.dots.count; i++) {
        CAShapeLayer *layer = [self.dots[i] shapeLayer];
        delay += 0.1;
        [self animateLayer:layer withAnimationType:kAPCGraphAnimationTypeFade startDelay:delay];
    }
    
    for (int i=0; i<self.pathLines.count; i++) {
        CAShapeLayer *layer = self.pathLines[i];
        delay += kGrowAnimationDuration;
        [self animateLayer:layer withAnimationType:kAPCGraphAnimationTypeGrow startDelay:delay];
    }
    
    delay += 0.2;
    
    [self animateLayer:self.fillPathLayer withAnimationType:kAPCGraphAnimationTypeFade startDelay:delay];
    
    self.shouldAnimate = NO;
}

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
    if ([self numberOfValidValues] > 0) {
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
}

#pragma mark - Touch

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ((self.dataPoints.count > 0) && [self numberOfValidValues] > 0) {
        CGPoint location = [gestureRecognizer locationInView:self.plotsView];
        
        location = CGPointMake(location.x - kAPCGraphLeftPadding, location.y);
        
        CGFloat maxX = round(CGRectGetWidth(self.plotsView.bounds));
        CGFloat minX = 0;
        
        CGFloat normalizedX = MAX(MIN(location.x, maxX), minX);
        location = CGPointMake(normalizedX, location.y);
        
        //---------------
        
        CGFloat snappedXPosition = [self snappedXPosition:location.x];
        self.scrubberLine.center = CGPointMake(snappedXPosition + kAPCGraphLeftPadding, self.scrubberLine.center.y);
        
        CGFloat scrubbingVal = [self valueForCanvasXPosition:(snappedXPosition)];
        [self.scrubberLabel setFrame:CGRectMake(CGRectGetMaxX(self.scrubberLine.frame) + 4, CGRectGetMinY(self.scrubberLine.frame), CGRectGetWidth(self.scrubberLabel.frame), CGRectGetHeight(self.scrubberLabel.frame))];
        self.scrubberLabel.text = [NSString stringWithFormat:@"%.0f", scrubbingVal];
        
        //---------------
        
        CGFloat scrubberYPos = [self canvasYPointForXPosition:snappedXPosition];
        if (scrubbingVal != NSNotFound) {
            [self.scrubberThumbView setCenter:CGPointMake(snappedXPosition + kAPCGraphLeftPadding, scrubberYPos + kAPCGraphTopPadding)];
            self.scrubberThumbView.alpha = 1;
            self.scrubberLabel.alpha = 1;
        } else {
            self.scrubberThumbView.alpha = 0;
            //            self.scrubberLabel.alpha = 0;
        }
        
        //---------------
        
        if ([self.delegate respondsToSelector:@selector(lineGraph:touchesMovedToXPosition:)]) {
            [self.delegate lineGraph:self touchesMovedToXPosition:snappedXPosition];
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
    if (self.dataPoints.count > 1) {
        self.scrubberLine.center = CGPointMake(xPosition + kAPCGraphLeftPadding, self.scrubberLine.center.y);
        [self.scrubberLabel setFrame:CGRectMake(self.scrubberLine.frame.origin.x + 5, kAPCGraphTopPadding, CGRectGetWidth(self.scrubberLabel.frame), CGRectGetHeight(self.scrubberLabel.frame))];
        self.scrubberLabel.text = [NSString stringWithFormat:@"%.2f", [self valueForCanvasXPosition:xPosition]];
        
        [self.scrubberThumbView setCenter:CGPointMake(xPosition + kAPCGraphLeftPadding, [self canvasYPointForXPosition:xPosition] + kAPCGraphTopPadding)];
    }
    
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    self.titleLabel.textColor = tintColor;
    self.leftTintView.backgroundColor = tintColor;
}

@end
