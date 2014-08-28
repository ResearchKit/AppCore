//
//  YMLLineChartView.m
//  Flow
//
//  Created by Karthik Keyan on 8/27/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "YMLLineChartView.h"
#import "YMLChartUnitsView.h"

@interface YMLLineChartView ()

@property (nonatomic, strong) UIBezierPath *path;

@property (nonatomic, strong) NSMutableArray *markers;

@end

@implementation YMLLineChartView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.path = [UIBezierPath bezierPath];
        
        [self initValues];
        [self initLayers];
        [self addAxis];
    }
    
    return self;
}

- (void) initValues {
    _markers = [NSMutableArray new];
    
    _markerColor = [UIColor blackColor];
    
    _markerRadius = 3;
}

- (void) initLayers {
    _lineLayer = [CAShapeLayer layer];
    _lineLayer.strokeColor = [UIColor blackColor].CGColor;
    _lineLayer.fillColor = [UIColor clearColor].CGColor;
    _lineLayer.lineWidth = 1.0;
    [self.layer addSublayer:_lineLayer];
}

- (void) addAxis {
    {
        CGFloat margin = kYMLChartUnitsViewMinumumHeight;
        CGRect frame = CGRectMake(margin, self.bounds.size.height - margin, self.bounds.size.width - margin, kYMLChartUnitsViewMinumumHeight);
        
        self.xAxisUnitsView = [[YMLChartUnitsView alloc] initWithFrame:frame axisPosition:YMLChartAxisPositionBottom];
        [self addSubview:self.xAxisUnitsView];
    }
    
    {
        CGFloat margin = kYMLChartUnitsViewMinumumWidth;
        
        CGRect frame = CGRectMake(0, 0, kYMLChartUnitsViewMinumumWidth, self.bounds.size.height - margin);
        
        self.yAxisUnitsView = [[YMLChartUnitsView alloc] initWithFrame:frame axisPosition:YMLChartAxisPositionLeft];
        [self addSubview:self.yAxisUnitsView];
    }
}


#pragma mark - Public Methods

- (void) draw {
    [self drawXAxis];
    [self drawYAxis];
    [self drawPoints];
    [self layoutIfNeeded];
}


#pragma mark - Private Methods

- (void) drawXAxis {
    [self.xAxisUnitsView clear];
    
    self.xAxisUnitsView.units = self.xUnits;
    
    NSMutableArray *unitLabels = [NSMutableArray array];
    
    for (NSNumber *unit in self.xUnits.objectEnumerator) {
        UILabel *label = [UILabel new];
        label.text = [unit stringValue];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:10];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.5;
        [unitLabels addObject:label];
    }
    
    self.xAxisUnitsView.labels = unitLabels;
}

- (void) drawYAxis {
    [self.yAxisUnitsView clear];
    
    self.yAxisUnitsView.units = self.yUnits;
    
    NSMutableArray *unitLabels = [NSMutableArray array];
    
    for (NSNumber *unit in self.yUnits.reverseObjectEnumerator) {
        UILabel *label = [UILabel new];
        label.text = [unit stringValue];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:10];
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.5;
        [unitLabels addObject:label];
    }
    
    self.yAxisUnitsView.labels = unitLabels;
}

- (void) drawPoints {
    self.path = [UIBezierPath bezierPath];
    
    [self.markers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    for (NSValue *value in self.values) {
        CGPoint pointInUnits = [value CGPointValue];
        
        CGPoint pointInChart = CGPointMake([self.xAxisUnitsView locationForUnit:pointInUnits.x] + kYMLChartUnitsViewMinumumWidth, [self.yAxisUnitsView locationForUnit:pointInUnits.y]);
        
        {
            CALayer *pointMarkerLayer = [CALayer layer];
            pointMarkerLayer.backgroundColor = self.markerColor.CGColor;
            pointMarkerLayer.frame = CGRectMake(0, 0, self.markerRadius * 2, self.markerRadius * 2);
            pointMarkerLayer.position = pointInChart;
            pointMarkerLayer.cornerRadius = self.markerRadius;
            [self.layer addSublayer:pointMarkerLayer];
            
            [self.markers addObject:pointMarkerLayer];
        }
        
        
        {
            if ([[self.values firstObject] isEqual:value]) {
                [self.path moveToPoint:pointInChart];
            }
            else {
                [self.path addLineToPoint:pointInChart];
            }
        }
    }
    
    self.lineLayer.path = self.path.CGPath;
}

@end
