//
//  YMLTimeLineChartView.m
//  Flow
//
//  Created by Karthik Keyan on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "YMLTimeLineChartView.h"

static CGFloat const KYMLTimeLineChartUnitsViewMinumumHeight    = 20.0;
static CGFloat const kYMLTimeLineChartBarLineWidth              = 4.0;
static CGFloat const kYMLTimeLineChartPointerTopMargin          = 0.0;


#pragma mark - YMLTimeLineChartView

@interface YMLTimeLineChartView ()

@property (nonatomic, strong) NSMutableArray *horizontalBars;

@property (nonatomic, strong) YMLTimeLineChartUnitsView *bottomUnitsView;

@property (nonatomic, strong) CAShapeLayer *pointerLayer;

@property (nonatomic, strong) UILabel *pointerLabel;

@end


@implementation YMLTimeLineChartView

- (instancetype) initWithFrame:(CGRect)frame orientation:(YMLChartOrientation)orientation {
    self = [super initWithFrame:frame];
    if (self) {
        _orientation = orientation;
        
        [self initValues];
    }
    
    return self;
}


#pragma mark - Init

- (void) initValues {
    _distanceBetweenBars = 10;
    _horizontalBars = [NSMutableArray new];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    longPress.cancelsTouchesInView = NO;
    [self addGestureRecognizer:longPress];
}


#pragma mark - UILongPressGestureRecognizer

- (void) longPressGesture:(UILongPressGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    CGFloat value;
    if (self.orientation == YMLChartOrientationHorizontal) {
        value = [self.bottomUnitsView unitAtLocation:point.x];
    }
    else {
        value = [self.bottomUnitsView unitAtLocation:point.y];
    }
    
    if (value >= [self.bottomUnitsView.units.firstObject floatValue] && value <= [self.bottomUnitsView.units.lastObject floatValue]) {
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan:
                [self pickPointer:gesture];
                break;
                
            case UIGestureRecognizerStateChanged:
                [self movePointer:gesture];
                break;
                
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
                [self dropPointer:gesture];
                break;
                
            default:
                break;
        }
    }
}


#pragma mark - Private Methods

- (void) drawBottomUnits {
    if (!self.bottomUnitsView) {
        self.bottomUnitsView = [YMLTimeLineChartUnitsView new];
        self.bottomUnitsView.frame = CGRectMake(0, self.bounds.size.height - KYMLTimeLineChartUnitsViewMinumumHeight, self.bounds.size.width, KYMLTimeLineChartUnitsViewMinumumHeight);
        [self addSubview:self.bottomUnitsView];
    }
    
    self.bottomUnitsView.units = [self.datasource timeLineChartViewUnits:self];
    
    NSMutableArray *unitLabels = [NSMutableArray array];
    
    for (int i = 0; i < self.bottomUnitsView.units.count; i++) {
        UILabel *label = [UILabel new];
        label.text = [self.datasource timeLineChartView:self titleAtIndex:i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:10];
        [unitLabels addObject:label];
    }
    
    self.bottomUnitsView.labels = unitLabels;
}

- (void) drawPointer {
    CGFloat x = [self.bottomUnitsView locationForUnit:[self.bottomUnitsView.units.firstObject floatValue]];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(x, kYMLTimeLineChartPointerTopMargin)];
    [path addLineToPoint:CGPointMake(x, self.bounds.size.height)];
    
    self.pointerLayer = [CAShapeLayer layer];
    self.pointerLayer.strokeColor = [UIColor colorWithWhite:0.0 alpha:1.0].CGColor;
    self.pointerLayer.lineWidth = 0.5;
    self.pointerLayer.path = path.CGPath;
    self.pointerLayer.lineDashPattern = @[@(5)];
    self.pointerLayer.opacity = 0.0;
    [self.layer addSublayer:self.pointerLayer];
    
    self.pointerLabel = [UILabel new];
    self.pointerLabel.frame = CGRectMake(0, 0, 40, 16);
    self.pointerLabel.backgroundColor = [UIColor clearColor];
    self.pointerLabel.font = [UIFont systemFontOfSize:10.0];
    self.pointerLabel.alpha = 0.0;
    [self addSubview:self.pointerLabel];
}

- (void) pickPointer:(UILongPressGestureRecognizer *)gesture {
    [self.pointerLayer removeFromSuperlayer];
    [self.layer addSublayer:self.pointerLayer];
    
    [self movePointer:gesture];
    
    self.pointerLayer.opacity = 1.0;
    self.pointerLabel.alpha = 1.0;
}

- (void) movePointer:(UILongPressGestureRecognizer *)gesture {
    if (self.orientation == YMLChartOrientationHorizontal) {
        CGPoint center = [gesture locationInView:self];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        [path moveToPoint:CGPointMake(center.x, kYMLTimeLineChartPointerTopMargin)];
        [path addLineToPoint:CGPointMake(center.x, self.bounds.size.height)];
        
        self.pointerLayer.path = path.CGPath;
        
        self.pointerLabel.text = [NSString stringWithFormat:@"%0.2f", [self.bottomUnitsView unitAtLocation:center.x]];
        
        center.y = 10;
        
        if (center.x <= self.bounds.size.width/2) {
            center.x += 5;
            self.pointerLabel.textAlignment = NSTextAlignmentLeft;
        }
        else {
            self.pointerLabel.textAlignment = NSTextAlignmentRight;
            center.x -= (self.pointerLabel.frame.size.width + 5);
        }
        
        self.pointerLabel.frame = (CGRect){center.x, center.y, self.pointerLabel.frame.size.width, self.pointerLabel.frame.size.height};
    }
}

- (void) dropPointer:(UILongPressGestureRecognizer *)gesture {
    self.pointerLayer.opacity = 0.0;
    self.pointerLabel.alpha = 0.0;
}


#pragma mark - Public Methods

- (void) redrawCanvas {
    if (self.orientation == YMLChartOrientationHorizontal) {
        [self drawBottomUnits];
        [self drawPointer];
    }
    else {
        
    }
}

- (void) addBar:(YMLTimeLineChartBarLayer *)barLayer fromUnit:(CGFloat)fromUnit toUnit:(CGFloat)toUnit animation:(BOOL)animation {
    if (self.orientation == YMLChartOrientationHorizontal) {
        [self.layer addSublayer:barLayer];
        [self.horizontalBars addObject:barLayer];
        
        NSUInteger numberOfBars = self.horizontalBars.count;
        
        CGFloat fromX = [self.bottomUnitsView locationForUnit:fromUnit];
        CGFloat toX = [self.bottomUnitsView locationForUnit:toUnit];
        
        CGFloat y = self.bounds.size.height - self.bottomUnitsView.frame.size.height - (self.distanceBetweenBars * numberOfBars) - (barLayer.lineWidth * numberOfBars);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(fromX, y)];
        [path addLineToPoint:CGPointMake(toX, y)];
        barLayer.path = path.CGPath;
        
        if (animation) {
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            pathAnimation.duration = 0.7;
            pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
            pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
            [barLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
        }
    }
}

@end



#pragma mark - YMLTimeLineChartUnitsView

@implementation YMLTimeLineChartUnitsView

- (void) setLabels:(NSArray *)labels {
    if (labels != _labels) {
        [_labels makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        _labels = labels;
        
        for (UIView *label in _labels) {
            [self addSubview:label];
        }
        
        [self layoutIfNeeded];
    }
}

- (CGFloat) locationForUnit:(CGFloat)unit {
//    CGFloat x = CGFLOAT_MAX;
//    for (int i = 0; i < self.units.count; i++) {
//        if ([self.units[i] floatValue] ==  unit) {
//            UILabel *label = self.labels[i];
//            x = CGRectGetMidX(label.frame);
//            break;
//        }
//    }
//    
//    return x;
    
    CGFloat labelsWidth = self.bounds.size.width/self.labels.count;
    
    // y = mx + c
    CGFloat x1 = [self.units[0] floatValue];
    CGFloat y1 = labelsWidth/2;
    
    CGFloat x2 = [self.units.lastObject floatValue];
    CGFloat y2 = self.bounds.size.width - (labelsWidth/2);
    
    CGFloat m = (y2 - y1)/(x2 - x1);
    
    CGFloat c = y2 - (m * x2);
    
    CGFloat location = (m * unit) + c;
    
    return location;
    
}

- (CGFloat) unitAtLocation:(CGFloat)location {
    CGFloat labelsWidth = self.bounds.size.width/self.labels.count;
    
    // y = mx + c
    CGFloat x1 = labelsWidth/2;
    CGFloat y1 = [self.units[0] floatValue];
    
    CGFloat x2 = self.bounds.size.width - (labelsWidth/2);
    CGFloat y2 = [self.units.lastObject floatValue];
    
    CGFloat m = (y2 - y1)/(x2 - x1);
    
    CGFloat c = y2 - (m * x2);
    
    CGFloat unit = (m * location) + c;
    return unit;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    // Calculate Labels
    CGFloat labelWidth = self.bounds.size.width/self.units.count;
    
    for (int i = 0; i < self.labels.count; i++) {
        UILabel *label = self.labels[i];
        label.frame = CGRectMake(i * labelWidth, 0, labelWidth, self.bounds.size.height);
    }
}

@end



#pragma mark - YMLTimeLineChartBarLayer

@implementation YMLTimeLineChartBarLayer

+ (instancetype) layer {
    YMLTimeLineChartBarLayer *barLayer = [[YMLTimeLineChartBarLayer alloc] init];
    barLayer.fillColor = [UIColor blueColor].CGColor;
    barLayer.lineWidth = kYMLTimeLineChartBarLineWidth;
    barLayer.strokeColor = [UIColor blueColor].CGColor;
    barLayer.lineCap = @"round";
    
    return barLayer;
}

@end
