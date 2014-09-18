//
//  YMLTimeLineChartView.m
//  Flow
//
//  Created by Karthik Keyan on 8/25/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "YMLTimeLineChartView.h"
#import "YMLChartUnitsView.h"

static CGFloat const kYMLTimeLineChartBarLineWidth              = 4.0;
static CGFloat const kYMLTimeLineChartPointerTopMargin          = 0.0;


#pragma mark - YMLTimeLineChartView

@interface YMLTimeLineChartView ()

@property (nonatomic, strong) NSMutableArray *horizontalBars;

@property (nonatomic, strong) YMLChartUnitsView *xAxisUnitsView;

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
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self pickPointer:gesture];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self movePointer:gesture];
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            [self dropPointer:gesture];
            break;
            
        default:
            break;
    }
}


#pragma mark - Private Methods

- (void) drawBottomUnits {
    CGRect frame = CGRectMake(0, self.bounds.size.height - kYMLChartUnitsViewMinumumHeight, self.bounds.size.width, kYMLChartUnitsViewMinumumHeight);
    
    if (!self.xAxisUnitsView) {
        self.xAxisUnitsView = [[YMLChartUnitsView alloc] initWithFrame:frame axisPosition:YMLChartAxisPositionBottom];
        [self addSubview:self.xAxisUnitsView];
    }
    
    self.xAxisUnitsView.frame = frame;
    self.xAxisUnitsView.units = [self.datasource timeLineChartViewUnits:self];
    
    NSMutableArray *unitLabels = [NSMutableArray array];
    
    for (int i = 0; i < self.xAxisUnitsView.units.count; i++) {
        UILabel *label = [UILabel new];
        label.text = [self.datasource timeLineChartView:self titleAtIndex:i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:10];
        [unitLabels addObject:label];
    }
    
    self.xAxisUnitsView.labels = unitLabels;
}

- (void) drawPointer {
    CGFloat x = [self.xAxisUnitsView locationForUnit:[self.xAxisUnitsView.units.firstObject floatValue]];
    
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

- (BOOL) canMovePointerForGesture:(UILongPressGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    CGFloat value;
    if (self.orientation == YMLChartOrientationHorizontal) {
        value = [self.xAxisUnitsView unitAtLocation:point.x];
    }
    else {
        value = [self.xAxisUnitsView unitAtLocation:point.y];
    }
    
    return (value >= [self.xAxisUnitsView.units.firstObject floatValue] && value <= [self.xAxisUnitsView.units.lastObject floatValue]);
}

- (void) pickPointer:(UILongPressGestureRecognizer *)gesture {
    if ([self canMovePointerForGesture:gesture]) {
        [self.pointerLayer removeFromSuperlayer];
        [self.layer addSublayer:self.pointerLayer];
        
        [self movePointer:gesture];
        
        self.pointerLayer.opacity = 1.0;
        self.pointerLabel.alpha = 1.0;
    }
}

- (void) movePointer:(UILongPressGestureRecognizer *)gesture {
    if ([self canMovePointerForGesture:gesture]) {
        if (self.orientation == YMLChartOrientationHorizontal) {
            CGPoint center = [gesture locationInView:self];
            
            UIBezierPath *path = [UIBezierPath bezierPath];
            
            [path moveToPoint:CGPointMake(center.x, kYMLTimeLineChartPointerTopMargin)];
            [path addLineToPoint:CGPointMake(center.x, self.bounds.size.height)];
            
            self.pointerLayer.path = path.CGPath;
            
            self.pointerLabel.text = [NSString stringWithFormat:@"%0.2f", [self.xAxisUnitsView unitAtLocation:center.x]];
            
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
}

- (void) dropPointer:(UILongPressGestureRecognizer *)gesture {
    self.pointerLayer.opacity = 0.0;
    self.pointerLabel.alpha = 0.0;
}


#pragma mark - Public Methods

- (void) layoutSubviews {
    [super layoutSubviews];
    
    [self redrawCanvas];
}

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
        
        CGFloat fromX = [self.xAxisUnitsView locationForUnit:fromUnit];
        CGFloat toX = [self.xAxisUnitsView locationForUnit:toUnit];
        
        CGFloat y = self.bounds.size.height - self.xAxisUnitsView.frame.size.height - (self.distanceBetweenBars * numberOfBars) - (barLayer.lineWidth * numberOfBars);
        
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



#pragma mark - YMLTimeLineChartBarLayer

@implementation YMLTimeLineChartBarLayer
+(instancetype)layer
{
    return [self layerWithColor:[UIColor blueColor]];
}

+ (instancetype) layerWithColor: (UIColor*) color
{
    YMLTimeLineChartBarLayer *barLayer = [[YMLTimeLineChartBarLayer alloc] init];
    barLayer.fillColor = color.CGColor;
    barLayer.lineWidth = kYMLTimeLineChartBarLineWidth;
    barLayer.strokeColor = color.CGColor;
    barLayer.lineCap = @"round";
    
    return barLayer;
}

@end
