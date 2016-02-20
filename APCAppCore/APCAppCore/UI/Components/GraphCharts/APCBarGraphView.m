//
//  APCBarGraphView.m
//  APCAppCore
//
// Copyright (c) 2015, Apple Inc. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "APCBarGraphView.h"
#import "APCCircleView.h"
#import "APCAxisView.h"

static CGFloat const kYAxisPaddingFactor = 0.15f;
static CGFloat const kAPCGraphLeftPadding = 10.f;
static CGFloat const kAxisMarkingRulerLength = 8.0f;

static CGFloat const kSnappingClosenessFactor = 0.3f;


@interface APCShapeLayer : CAShapeLayer

+ (instancetype)layer;

@property (nonatomic, strong) UIBezierPath *finalPath;

@end

@implementation APCShapeLayer

+ (instancetype)layer
{
    return [super layer];
}

@end

@interface APCBarGraphView ()

@property (nonatomic, strong) NSMutableArray *dataPoints;//actual data
@property (nonatomic, strong) NSMutableArray *xAxisPoints;
@property (nonatomic, strong) NSMutableArray *yAxisPoints;//normalised for this view

@property (nonatomic, strong) APCAxisView *xAxisView;
@property (nonatomic, strong) UIView *yAxisView;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic) BOOL hasDataPoint;

@property (nonatomic, strong) UIView *scrubberLine;
@property (nonatomic, strong) UILabel *scrubberLabel;
@property (nonatomic, strong) UIView *scrubberThumbView;

@property (nonatomic, readwrite) CGFloat minimumValue;
@property (nonatomic, readwrite) CGFloat maximumValue;

@property (nonatomic, strong) NSMutableArray *xAxisTitles;
@property (nonatomic) NSInteger numberOfXAxisTitles;

@property (nonatomic, strong) NSMutableArray *referenceLines;
@property (nonatomic, strong) NSMutableArray *barLayers;

@property (nonatomic) BOOL shouldAnimate;

@end

@implementation APCBarGraphView

@synthesize tintColor = _tintColor;
@synthesize maximumValue = _maximumValue;
@synthesize minimumValue = _minimumValue;

/********************************/
#pragma mark - Init
/********************************/

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (void)sharedInit
{
    [super sharedInit];
    
    _dataPoints = [NSMutableArray new];
    
    _xAxisPoints = [NSMutableArray new];
    _yAxisPoints = [NSMutableArray new];
    
    _xAxisTitles = [NSMutableArray new];
    
    _referenceLines = [NSMutableArray new];
    _barLayers = [NSMutableArray new];
    
    _tintColor = [UIColor colorWithRed:244/255.f green:190/255.f blue:74/255.f alpha:1.f];
    
    _hasDataPoint = NO;
    _shouldAnimate = YES;
    
    _barWidth = 20.f;
    
    [self setupViews];
}

- (void)setupViews
{
    /* ----------------- */
    /* Basic Views */
    /* ----------------- */
    
    _plotsView = [UIView new];
    _plotsView.backgroundColor = [UIColor clearColor];
    [self addSubview:_plotsView];
    
    /* ----------------- */
    /* Scrubber Views */
    /* ----------------- */
    _scrubberLine = [UIView new];
    _scrubberLine.backgroundColor = self.scrubberLineColor;
    _scrubberLine.alpha = 0;
    [self addSubview:_scrubberLine];
    
    _scrubberLabel = [UILabel new];
    _scrubberLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:12.0f];
    _scrubberLabel.alpha = 0;
    _scrubberLabel.layer.cornerRadius = 2.0f;
    _scrubberLabel.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _scrubberLabel.layer.borderWidth = 1.0f;
    _scrubberLabel.textAlignment = NSTextAlignmentCenter;
    _scrubberLabel.frame = CGRectMake(2, 0, 100, 20);
    _scrubberLabel.backgroundColor = [UIColor colorWithWhite:0.98 alpha:0.8];
    [self addSubview:_scrubberLabel];
    
    _scrubberThumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self scrubberThumbSize].width, [self scrubberThumbSize].height)];
    _scrubberThumbView.layer.borderWidth = 1.0;
    _scrubberThumbView.backgroundColor = self.scrubberThumbColor;
    _scrubberThumbView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _scrubberThumbView.alpha = 0;
    [self addSubview:_scrubberThumbView];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    self.panGestureRecognizer.delaysTouchesBegan = YES;
    [self addGestureRecognizer:self.panGestureRecognizer];
}

- (void)setDefaults
{
    self.minimumValue = MAXFLOAT;
    self.maximumValue = -MAXFLOAT;
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

/********************************/
#pragma mark - Appearance
/********************************/

- (void)updateScrubberLabel
{
    if (self.isLandscapeMode) {
        self.scrubberLabel.font = [UIFont fontWithName:self.scrubberLabel.font.familyName size:14.0f];
    } else {
        self.scrubberLabel.font = [UIFont fontWithName:self.scrubberLabel.font.familyName size:12.0f];
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

/********************************/
#pragma mark - View Layout
/********************************/

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat yAxisPadding = CGRectGetWidth(self.frame)*kYAxisPaddingFactor;
    
    //Basic Views
    
    self.plotsView.frame = CGRectMake(kAPCGraphLeftPadding, kAPCGraphTopPadding, CGRectGetWidth(self.frame) - yAxisPadding - kAPCGraphLeftPadding, CGRectGetHeight(self.frame) - kXAxisHeight - kAPCGraphTopPadding);
    
    if (self.emptyLabel) {
        self.emptyLabel.frame = CGRectMake(kAPCGraphLeftPadding, kAPCGraphTopPadding, CGRectGetWidth(self.frame) - kAPCGraphLeftPadding, CGRectGetHeight(self.frame) - kXAxisHeight - kAPCGraphTopPadding);
    }
    
    //Scrubber Views
    self.scrubberLine.frame = CGRectMake(CGRectGetMinX(self.scrubberLine.frame), kAPCGraphTopPadding, 1, CGRectGetHeight(self.plotsView.frame));
    [self updateScrubberLabel];
    self.scrubberThumbView.frame = CGRectMake(CGRectGetMinX(self.scrubberThumbView.frame), CGRectGetMinY(self.scrubberThumbView.frame), [self scrubberThumbSize].width, [self scrubberThumbSize].height);
    self.scrubberThumbView.layer.cornerRadius = self.scrubberThumbView.bounds.size.height/2;
    
    [self.xAxisView layoutSubviews];
    
}

- (void)refreshGraph
{
    //Clear subviews and sublayers
    [self.plotsView.layer.sublayers makeObjectsPerformSelector:@selector(removeAllAnimations)];
    [self.plotsView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    [self drawXAxis];
    [self drawYAxis];
    
    if (self.showsHorizontalReferenceLines) {
        [self drawhorizontalReferenceLines];
    }
    
    if (self.showsVerticalReferenceLines) {
        [self drawVerticalReferenceLines];
    }
    
    [self calculateXAxisPoints];
    
    [self.barLayers removeAllObjects];
    
    for (int i=0; i<[self numberOfPlots]; i++) {
        if ([self numberOfPointsInPlot:i] <= 1) {
            return;
        } else {
            [self drawGraphForPlotIndex:i];
        }
    }
    
    if (!self.hasDataPoint) {
        [self setupEmptyView];
    } else {
        if (self.emptyLabel) {
            [self.emptyLabel removeFromSuperview];
        }
    }
    
    [self animateLayersSequentially];
    
}

- (void)setupEmptyView
{
    if (!_emptyLabel) {
        
        _emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(kAPCGraphLeftPadding, kAPCGraphTopPadding, CGRectGetWidth(self.frame) - kAPCGraphLeftPadding, CGRectGetHeight(self.frame) - kXAxisHeight - kAPCGraphTopPadding)];
        _emptyLabel.text = self.emptyText;
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.font = [UIFont fontWithName:@"Helvetica" size:25];
        _emptyLabel.textColor = [UIColor lightGrayColor];
    }
    
    [self addSubview:_emptyLabel];
}

/********************************/
#pragma mark - Data
/********************************/

- (NSInteger)numberOfPlots
{
    NSInteger numberOfPlots = 1;
    
    if ([self.datasource respondsToSelector:@selector(numberOfPlotsInBarGraph:)]) {
        numberOfPlots = [self.datasource numberOfPlotsInBarGraph:self];
    }
    
    return numberOfPlots;
}

- (NSInteger)numberOfPointsInPlot:(NSInteger)plotIndex
{
    NSInteger numberOfPoints = 0;
    
    if ([self.datasource respondsToSelector:@selector(barGraph:numberOfPointsInPlot:)]) {
        numberOfPoints = [self.datasource barGraph:self numberOfPointsInPlot:plotIndex];
        
    }
    
    return numberOfPoints;
}

- (NSInteger)numberOfXAxisTitles
{
    _numberOfXAxisTitles = 0;
    
    if ([self.datasource respondsToSelector:@selector(numberOfDivisionsInXAxisForBarGraph:)]) {
        _numberOfXAxisTitles = [self.datasource numberOfDivisionsInXAxisForBarGraph:self];
    } else {
        _numberOfXAxisTitles = [self numberOfPointsInPlot:0];
    }
    
    return _numberOfXAxisTitles;
}

- (UIColor *)colorForStackedLayerIndex:(NSInteger)index
{
    UIColor *fillColor = self.tintColor;
    
    if ([self.datasource respondsToSelector:@selector(barGraph:fillColorForStackedLayerAtIndex:)]) {
        fillColor = [self.datasource barGraph:self fillColorForStackedLayerAtIndex:index];
    } else {
        fillColor = [self.tintColor colorWithAlphaComponent:(1 - 0.25*index)];
    }
    
    return fillColor;
}

- (void)calculateXAxisPoints
{
    [self.xAxisPoints removeAllObjects];
    
    for (int i=0 ; i<[self.dataPoints count]; i++) {
        
        CGFloat positionOnXAxis = ((CGRectGetWidth(self.plotsView.frame) / (self.yAxisPoints.count - 1)) * i);
        positionOnXAxis = round(positionOnXAxis);
        [self.xAxisPoints addObject:@(positionOnXAxis)];
    }
}

- (void)prepareDataForPlotIndex:(NSInteger)plotIndex
{
    [self.dataPoints removeAllObjects];
    [self.yAxisPoints removeAllObjects];
    self.hasDataPoint = NO;
    for (int i = 0; i<[self numberOfPointsInPlot:plotIndex]; i++) {
        
        if ([self.datasource respondsToSelector:@selector(barGraph:plot:valueForPointAtIndex:)]) {
            APCStackedDataPoint *values = [self.datasource barGraph:self plot:plotIndex valueForPointAtIndex:i];
            
            if (values) {
                [self.dataPoints addObject:values];
                self.hasDataPoint = YES;
            }
        }
    }
    
    [self.yAxisPoints addObjectsFromArray:[self normalizeCanvasPoints:self.dataPoints forRect:self.plotsView.frame.size]];
}

/********************************/
#pragma mark - Draw
/********************************/

- (void)drawXAxis
{
    //Add Title Labels
    [self.xAxisTitles removeAllObjects];
    
    for (int i=0; i<self.numberOfXAxisTitles; i++) {
        if ([self.datasource respondsToSelector:@selector(barGraph:titleForXAxisAtIndex:)]) {
            NSString *title = [self.datasource barGraph:self titleForXAxisAtIndex:i];
            
            [self.xAxisTitles addObject:title];
        }
    }
    
    if (self.xAxisView) {
        [self.xAxisView removeFromSuperview];
        self.xAxisView = nil;
    }
    
    self.xAxisView = [[APCAxisView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.plotsView.frame), CGRectGetWidth(self.plotsView.frame), kXAxisHeight)];
    self.xAxisView.landscapeMode = self.landscapeMode;
    self.xAxisView.tintColor = self.tintColor;
    [self.xAxisView setupLabels:self.xAxisTitles forAxisType:kAPCGraphAxisTypeX];
    self.xAxisView.leftOffset = kAPCGraphLeftPadding;
    [self insertSubview:self.xAxisView belowSubview:self.plotsView];
    
    UIBezierPath *xAxispath = [UIBezierPath bezierPath];
    [xAxispath moveToPoint:CGPointMake(0, 0)];
    [xAxispath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), 0)];
    
    CAShapeLayer *xAxisLineLayer = [CAShapeLayer layer];
    xAxisLineLayer.strokeColor = self.axisColor.CGColor;
    xAxisLineLayer.path = xAxispath.CGPath;
    [self.xAxisView.layer addSublayer:xAxisLineLayer];
    
    for (NSUInteger i=0; i<self.xAxisTitles.count; i++) {
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

- (void)drawYAxis
{
    [self prepareDataForPlotIndex:0];
    
    if (self.yAxisView) {
        [self.yAxisView removeFromSuperview];
        self.yAxisView = nil;
    }
    
    CGFloat axisViewXPosition = CGRectGetWidth(self.frame) * (1 - kYAxisPaddingFactor);
    CGFloat axisViewWidth = CGRectGetWidth(self.frame)*kYAxisPaddingFactor;
    
    self.yAxisView = [[UIView alloc] initWithFrame:CGRectMake(axisViewXPosition, kAPCGraphTopPadding, axisViewWidth, CGRectGetHeight(self.plotsView.frame))];
    [self addSubview:self.yAxisView];
    
    
    CGFloat rulerXPosition = CGRectGetWidth(self.yAxisView.bounds) - kAxisMarkingRulerLength + 2;
    
    if (self.maximumValueImage && self.minimumValueImage) {
        //Use image icons as legends
        
        CGFloat width = CGRectGetWidth(self.yAxisView.frame)/2;
        CGFloat verticalPadding = 3.f;
        
        UIImageView *maxImageView = [[UIImageView alloc] initWithImage:self.maximumValueImage];
        maxImageView.contentMode = UIViewContentModeScaleAspectFit;
        maxImageView.frame = CGRectMake(CGRectGetWidth(self.yAxisView.bounds) - width, -width/2, width, width);
        [self.yAxisView addSubview:maxImageView];
        
        UIImageView *minImageView = [[UIImageView alloc] initWithImage:self.minimumValueImage];
        minImageView.contentMode = UIViewContentModeScaleAspectFit;
        minImageView.frame = CGRectMake(CGRectGetWidth(self.yAxisView.bounds) - width, CGRectGetMaxY(self.yAxisView.bounds) - width - verticalPadding, width, width);
        [self.yAxisView addSubview:minImageView];
        
    } else {
        
        NSArray *yAxisLabelFactors;
        
        if (self.minimumValue == self.maximumValue) {
            yAxisLabelFactors = @[@0.5f];
        } else {
            yAxisLabelFactors = @[@0.2f,@1.0f];
        }
        
        for (NSUInteger i =0; i<yAxisLabelFactors.count; i++) {
            
            CGFloat factor = [yAxisLabelFactors[i] floatValue];
            CGFloat positionOnYAxis = CGRectGetHeight(self.plotsView.frame) * (1 - factor);
            
            UIBezierPath *rulerPath = [UIBezierPath bezierPath];
            [rulerPath moveToPoint:CGPointMake(rulerXPosition, positionOnYAxis)];
            [rulerPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.yAxisView.bounds), positionOnYAxis)];
            
            CAShapeLayer *rulerLayer = [CAShapeLayer layer];
            rulerLayer.strokeColor = self.axisColor.CGColor;
            rulerLayer.path = rulerPath.CGPath;
            [self.yAxisView.layer addSublayer:rulerLayer];
            
            CGFloat labelHeight = 20;
            CGFloat labelYPosition = positionOnYAxis - labelHeight/2;
            
            CGFloat yValue = self.minimumValue + (self.maximumValue - self.minimumValue)*factor;
            
            UILabel *axisTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, labelYPosition, CGRectGetWidth(self.yAxisView.frame) - kAxisMarkingRulerLength, labelHeight)];
            
            if (yValue != 0) {
                axisTitleLabel.text = [NSString stringWithFormat:@"%0.0f", yValue];
            }
            axisTitleLabel.backgroundColor = [UIColor clearColor];
            axisTitleLabel.textColor = self.axisTitleColor;
            axisTitleLabel.textAlignment = NSTextAlignmentRight;
            axisTitleLabel.font = self.isLandscapeMode ? [UIFont fontWithName:self.axisTitleFont.familyName size:16.0f] : self.axisTitleFont;
            axisTitleLabel.minimumScaleFactor = 0.8;
            [self.yAxisView addSubview:axisTitleLabel];
        }
    }
    
}

- (void)drawhorizontalReferenceLines
{
    [self.referenceLines removeAllObjects];
    
    UIBezierPath *referenceLinePath = [UIBezierPath bezierPath];
    [referenceLinePath moveToPoint:CGPointMake(0, kAPCGraphTopPadding + CGRectGetHeight(self.plotsView.frame)/2)];
    [referenceLinePath addLineToPoint:CGPointMake(CGRectGetWidth(self.frame), kAPCGraphTopPadding + CGRectGetHeight(self.plotsView.frame)/2)];
    
    CAShapeLayer *referenceLineLayer = [CAShapeLayer layer];
    referenceLineLayer.strokeColor = self.referenceLineColor.CGColor;
    referenceLineLayer.path = referenceLinePath.CGPath;
    referenceLineLayer.lineDashPattern = self.isLandscapeMode ? @[@12, @7] : @[@6, @4];
    [self.plotsView.layer addSublayer:referenceLineLayer];
    
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
        
        [self.referenceLines addObject:referenceLineLayer];
    }
}

- (void)drawGraphForPlotIndex:(NSInteger)plotIndex
{
    [self prepareDataForPlotIndex:plotIndex];
    
    if ([self numberOfValidValues] > 0) {
        [self drawBarsForPlotIndex:plotIndex];
    }
}

- (void)drawBarsForPlotIndex:(NSInteger)plotIndex
{
    CGFloat positionOnXAxis = CGFLOAT_MAX;
    APCStackedDataPoint *positionOnYAxisValues = nil;
    
    CGFloat barWidth = MIN(self.barWidth, [self maximumAllowedBarWidth]);
    
    for (NSUInteger i=0; i<self.yAxisPoints.count; i++) {
        
        APCStackedDataPoint *dataPointVal = self.dataPoints[i];
        
        if (dataPointVal.total > 0) {

            positionOnXAxis = [self.xAxisPoints[i] floatValue];
            positionOnXAxis += [self offsetForPlotIndex:plotIndex];
            
            positionOnYAxisValues = ((APCStackedDataPoint *)self.yAxisPoints[i]);
            
            CGFloat prevYValue = CGRectGetHeight(self.plotsView.bounds);
            
            for (int j=0; j<[positionOnYAxisValues.stackedValues count]; j++) {
                
                CGFloat yPositionValue = [positionOnYAxisValues.stackedValues[j] floatValue];
                
                CGFloat barHeight = fabs(yPositionValue - prevYValue);
                
                UIBezierPath *barPath = [UIBezierPath bezierPathWithRect:CGRectMake(positionOnXAxis - barWidth/2, prevYValue - barHeight, barWidth, barHeight)];
                
                APCShapeLayer *barLayer = [APCShapeLayer layer];
                
                if (self.shouldAnimate) {
                    UIBezierPath *zeroHeightBarPath = [UIBezierPath bezierPathWithRect:CGRectMake(positionOnXAxis - barWidth/2, CGRectGetHeight(self.plotsView.bounds), barWidth, 0)];
                    barLayer.path = zeroHeightBarPath.CGPath;
                    barLayer.finalPath = barPath;
                    
                    [self.barLayers addObject:barLayer];
                    
                } else {
                    barLayer.path = barPath.CGPath;
                }
                
                barLayer.fillColor = [self colorForStackedLayerIndex:j].CGColor;
                [self.plotsView.layer addSublayer:barLayer];
                
                prevYValue = yPositionValue;
            }
        }
    }
}

- (CGFloat)offsetForPlotIndex:(NSInteger)plotIndex
{
    CGFloat barWidth = MIN(self.barWidth, [self maximumAllowedBarWidth]);
    
    NSInteger numberOfPlots = [self numberOfPlots];
    
    CGFloat offset = 0;
    
    if (numberOfPlots%2 == 0) {
        //Even
        offset = (plotIndex - numberOfPlots/2 + 0.5) * barWidth;
    } else {
        //Odd
        offset = (plotIndex - numberOfPlots/2) * barWidth;
    }
    
    return offset;
}

- (CGFloat)maximumAllowedBarWidth
{
    CGFloat maxWidth = CGRectGetWidth(self.plotsView.bounds)/[self.dataPoints count];
    maxWidth = maxWidth/[self numberOfPlots];
    
    return maxWidth;
}

#pragma mark - Graph Calculations

- (NSInteger)numberOfValidValues
{
    NSInteger count = 0;
    
    for (APCStackedDataPoint *dataVal in self.dataPoints) {
        if (dataVal.stackedValues) {
            count ++;
        }
    }
    return count;
}

- (void)calculateMinAndMaxPoints
{
    [self setDefaults];
    
    //Min
    if ([self.datasource respondsToSelector:@selector(minimumValueForBarGraph:)]) {
        self.minimumValue = [self.datasource minimumValueForBarGraph:self];
    } else {
        
        if (self.dataPoints.count) {
            self.minimumValue = ((APCStackedDataPoint *)self.dataPoints[0]).total;
            
            for (NSUInteger i=1; i<self.dataPoints.count; i++) {
                CGFloat num = ((APCStackedDataPoint *)self.dataPoints[i]).total;
                if ((self.minimumValue == NSNotFound) || (num < self.minimumValue)) {
                    self.minimumValue = num;
                }
            }
        }
        
    }
    
    //Max
    if ([self.datasource respondsToSelector:@selector(maximumValueForBarGraph:)]) {
        self.maximumValue = [self.datasource maximumValueForBarGraph:self];
    } else {
        if (self.dataPoints.count) {
            self.maximumValue = ((APCStackedDataPoint *)self.dataPoints[0]).total;
            
            for (NSUInteger i=1; i<self.dataPoints.count; i++) {
                CGFloat num = ((APCStackedDataPoint *)self.dataPoints[i]).total;
                if (((num != NSNotFound) && (num > self.maximumValue)) || (self.maximumValue == NSNotFound)) {
                    self.maximumValue = num;
                }
            }
        }
    }
}

- (NSArray *)normalizeCanvasPoints:(NSArray *) __unused dataPoints forRect:(CGSize)canvasSize
{
    [self calculateMinAndMaxPoints];
    
    NSMutableArray *normalizedPoints = [NSMutableArray new];
    
    for (NSUInteger i=0; i<self.dataPoints.count; i++) {
        
        APCStackedDataPoint *dataPointValue = (APCStackedDataPoint *)self.dataPoints[i];
        
        NSMutableArray *normalizedStackedValues = [NSMutableArray new];
        
        if (dataPointValue.total == 0){
            
            for (int j=0; j<[dataPointValue.stackedValues count]; j++) {
                [normalizedStackedValues addObject:@(canvasSize.height)];
            }
        } else if (self.minimumValue == self.maximumValue) {
            
            for (int j=0; j<[dataPointValue.stackedValues count]; j++) {
                [normalizedStackedValues addObject:@(0)];
            }
        } else {
            CGFloat range = self.maximumValue - self.minimumValue;
            
            CGFloat sum = 0;
            for (NSNumber *value in dataPointValue.stackedValues) {
                sum += value.floatValue;
                CGFloat normalizedValue = (sum - self.minimumValue)/range * canvasSize.height;
                normalizedValue = canvasSize.height - normalizedValue;
                
                [normalizedStackedValues addObject:@(normalizedValue)];
            }
        }
        
        APCStackedDataPoint *normalizedStackedPoint = [[APCStackedDataPoint alloc] initWithStackedValues:[NSArray arrayWithArray:normalizedStackedValues]];
        [normalizedPoints addObject:normalizedStackedPoint];
    }
    
    return [NSArray arrayWithArray:normalizedPoints];
}

/* Used when the user scrubs the plot */

//Scrubbing Value
- (CGFloat)valueForCanvasXPosition:(CGFloat)xPosition
{
    BOOL snapped = [self.xAxisPoints containsObject:@(xPosition)];
    
    CGFloat value = NSNotFound;
    
    NSUInteger positionIndex = 0;
    
    if (snapped) {
        for (positionIndex = 0; positionIndex<self.xAxisPoints.count-1; positionIndex++) {
            CGFloat xAxisPointVal = [self.xAxisPoints[positionIndex] floatValue];
            if (xAxisPointVal == xPosition) {
                break;
            }
        }
        
        value = ((APCStackedDataPoint *)self.dataPoints[positionIndex]).total;
        
    }
    
    return value;
}

//Scrubber Y position
- (CGFloat)canvasYPointForXPosition:(CGFloat)xPosition
{
    BOOL snapped = [self.xAxisPoints containsObject:@(xPosition)];
    
    CGFloat canvasYPosition = 0;
    
    NSUInteger positionIndex = 0;
    
    if (snapped) {
        for (positionIndex = 0; positionIndex<self.xAxisPoints.count-1; positionIndex++) {
            CGFloat xAxisPointVal = [self.xAxisPoints[positionIndex] floatValue];
            if (xAxisPointVal == xPosition) {
                break;
            }
        }
        
        canvasYPosition = [[((APCStackedDataPoint *)self.yAxisPoints[positionIndex]).stackedValues lastObject] floatValue];
    }
    
    return canvasYPosition;
}

//Valid - dataPoints[index]!= NSNotFound
- (NSInteger)nextValidPositionIndexForPosition:(NSInteger)positionIndex
{
    NSUInteger validPosition = positionIndex;
    
    while (validPosition < (self.dataPoints.count-1)) {
        if (((APCStackedDataPoint *)self.dataPoints[validPosition]).stackedValues) {
            break;
        }
        validPosition ++;
    }
    
    return validPosition;
}

- (NSInteger)prevValidPositionIndexForPosition:(NSInteger)positionIndex
{
    NSInteger validPosition = positionIndex - 1;
    
    while (validPosition > 0) {
        if (((APCStackedDataPoint *)self.dataPoints[validPosition]).stackedValues) {
            break;
        }
        validPosition --;
    }
    
    return validPosition;
}

- (CGFloat)snappedXPosition:(CGFloat)xPosition
{
    CGFloat widthBetweenPoints = CGRectGetWidth(self.plotsView.frame)/self.xAxisPoints.count;
    
    NSUInteger positionIndex;
    for (positionIndex = 0; positionIndex<self.xAxisPoints.count; positionIndex++) {
        
        CGFloat dataPointVal = ((APCStackedDataPoint *)self.dataPoints[positionIndex]).total;
        
        if (dataPointVal != NSNotFound) {
            CGFloat num = [self.xAxisPoints[positionIndex] floatValue];
            
            if (fabs(num - xPosition) < (widthBetweenPoints * kSnappingClosenessFactor)) {
                xPosition = num;
            }
        }
        
    }
    
    
    return xPosition;
}

/********************************/
#pragma mark - Animations
/********************************/

- (void)animateLayersSequentially
{
    CGFloat delay = 0.2;
    
    for (NSUInteger i=0; i<[self.barLayers count]; i++) {
        APCShapeLayer *layer = self.barLayers[i];
        [self animateLayer:layer withAnimationType:kAPCGraphAnimationTypePath toValue:(__bridge id)layer.finalPath.CGPath startDelay:delay];
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

/********************************/
#pragma mark - Touch
/********************************/

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ((self.dataPoints.count > 0) && [self numberOfValidValues] > 0) {
        CGPoint location = [gestureRecognizer locationInView:self.plotsView];
        
        location = CGPointMake(location.x, location.y);
        
        CGFloat maxX = round(CGRectGetWidth(self.plotsView.bounds));
        CGFloat minX = 0;
        
        CGFloat normalizedX = MAX(MIN(location.x, maxX), minX);
        location = CGPointMake(normalizedX, location.y);
        
        //---------------
        
        CGFloat snappedXPosition = [self snappedXPosition:location.x];
        [self scrubberViewForXPosition:snappedXPosition];
        
        //---------------
        
        if ([self.delegate respondsToSelector:@selector(graphView:touchesMovedToXPosition:)]) {
            [self.delegate graphView:self touchesMovedToXPosition:snappedXPosition];
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self setScrubberViewsHidden:NO animated:YES];
            if ([self.delegate respondsToSelector:@selector(graphViewTouchesBegan:)]) {
                [self.delegate graphViewTouchesBegan:self];
            }
        } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
            [self setScrubberViewsHidden:YES animated:YES];
            if ([self.delegate respondsToSelector:@selector(graphViewTouchesEnded:)]) {
                [self.delegate graphViewTouchesEnded:self];
            }
        }
    }
}

- (void)scrubberViewForXPosition:(CGFloat)xPosition
{
    
    self.scrubberLine.center = CGPointMake(xPosition + kAPCGraphLeftPadding, self.scrubberLine.center.y);
    
    CGFloat scrubbingVal = [self valueForCanvasXPosition:(xPosition)];
    
    self.scrubberLabel.text = [NSString stringWithFormat:@"%.0f", scrubbingVal];
    
    CGSize textSize = [self.scrubberLabel.text boundingRectWithSize:CGSizeMake(320, CGRectGetHeight(self.scrubberLabel.bounds)) options:(NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:self.scrubberLabel.font} context:nil].size;
    
    [self.scrubberLabel setFrame:CGRectMake(CGRectGetMaxX(self.scrubberLine.frame) + 6, CGRectGetMinY(self.scrubberLine.frame), textSize.width + 8, CGRectGetHeight(self.scrubberLabel.frame))];
    
    //---------------
    
    CGFloat scrubberYPos = [self canvasYPointForXPosition:xPosition];
    
    [self.scrubberThumbView setCenter:CGPointMake(xPosition + kAPCGraphLeftPadding, scrubberYPos + kAPCGraphTopPadding)];
    
    if (scrubbingVal >= self.minimumValue && scrubbingVal <= self.maximumValue) {
        self.scrubberLabel.alpha = 1;
        self.scrubberThumbView.alpha = 1;
    } else {
        self.scrubberLabel.alpha = 0;
        self.scrubberThumbView.alpha = 0;
    }
}

/********************************/
#pragma mark - Public Methods
/********************************/

- (void)scrubReferenceLineForXPosition:(CGFloat)xPosition
{
    if (self.dataPoints.count > 1) {
        [self scrubberViewForXPosition:xPosition];
    }
}
@end


/**************************************/
/* Stacked Data Point Implementation */
/************************************/

@implementation APCStackedDataPoint

- (instancetype)initWithStackedValues:(NSArray *)values
{
    self = [super init];
    if (self) {
        _total = 0;
        _stackedValues = values;
    }
    return self;
}

- (CGFloat)total
{
    CGFloat sum = 0;
    
    if (self.stackedValues) {
        for (NSNumber *value in self.stackedValues) {
            sum += [value floatValue];
        }
    }
    
    return sum;
}

@end
