//
//  YMLChartUnitsView.m
//  Flow
//
//  Created by Karthik Keyan on 8/27/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "YMLChartUnitsView.h"

CGFloat const kYMLChartUnitsViewMinumumHeight       = 20.0;
CGFloat const kYMLChartUnitsViewMinumumWidth        = 20.0;

@implementation YMLChartUnitsView

- (instancetype) initWithFrame:(CGRect)frame axisPosition:(YMLChartAxisPosition)position {
    self = [super initWithFrame:frame];
    if (self) {
        _position = position;
    }
    
    return self;
}

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
    CGFloat location;
    
    if (self.position == YMLChartAxisPositionBottom) {
        CGFloat labelsWidth = self.bounds.size.width/self.labels.count;
        
        // y = mx + c
        CGFloat x1 = [self.units.firstObject floatValue];
        CGFloat y1 = labelsWidth/2;
        
        CGFloat x2 = [self.units.lastObject floatValue];
        CGFloat y2 = self.bounds.size.width - (labelsWidth/2);
        
        CGFloat m = (y2 - y1)/(x2 - x1);
        
        CGFloat c = y2 - (m * x2);
        
        location = (m * unit) + c;
    }
    else {
        CGFloat labelsHeight = self.bounds.size.height/self.labels.count;
        
        // y = mx + c
        CGFloat x1 = [self.units.lastObject floatValue];
        CGFloat y1 = labelsHeight/2;
        
        CGFloat x2 = [self.units.firstObject floatValue];
        CGFloat y2 = self.bounds.size.height - (labelsHeight/2);
        
        CGFloat m = (y2 - y1)/(x2 - x1);
        
        CGFloat c = y2 - (m * x2);
        
        location = (m * unit) + c;
    }
    
    return location;
}

- (CGFloat) unitAtLocation:(CGFloat)location {
    CGFloat unit;
    
    if (self.position == YMLChartAxisPositionBottom) {
        CGFloat labelsWidth = self.bounds.size.width/self.labels.count;
        
        // y = mx + c
        CGFloat x1 = labelsWidth/2;
        CGFloat y1 = [self.units.firstObject floatValue];
        
        CGFloat x2 = self.bounds.size.width - (labelsWidth/2);
        CGFloat y2 = [self.units.lastObject floatValue];
        
        CGFloat m = (y2 - y1)/(x2 - x1);
        
        CGFloat c = y2 - (m * x2);
        
        unit = (m * location) + c;
    }
    else {
        CGFloat labelsHeight = self.bounds.size.height/self.labels.count;
        
        // y = mx + c
        CGFloat x1 = labelsHeight/2;
        CGFloat y1 = [self.units.lastObject floatValue];
        
        CGFloat x2 = self.bounds.size.height - (labelsHeight/2);
        CGFloat y2 = [self.units.firstObject floatValue];
        
        CGFloat m = (y2 - y1)/(x2 - x1);
        
        CGFloat c = y2 - (m * x2);
        
        unit = (m * location) + c;
    }
    
    return unit;
}

- (void) clear {
    [self.labels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.units = nil;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (self.position == YMLChartAxisPositionBottom) {
        CGFloat labelWidth = self.bounds.size.width/self.units.count;
        
        for (int i = 0; i < self.labels.count; i++) {
            UILabel *label = self.labels[i];
            label.frame = CGRectMake(i * labelWidth, 0, labelWidth, self.bounds.size.height);
        }
    }
    else {
        CGFloat labelHeight = self.bounds.size.height/self.units.count;
        
        for (int i = 0; i < self.labels.count; i++) {
            UILabel *label = self.labels[i];
            label.frame = CGRectMake(0, i * labelHeight, self.bounds.size.width, labelHeight);
        }
    }
}

@end
