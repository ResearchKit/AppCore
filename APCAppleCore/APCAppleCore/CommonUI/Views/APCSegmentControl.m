//
//  APCSegmentControl.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/11/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UIView+Helper.h"
#import "APCSegmentControl.h"
#import "UISegmentedControl+Appearance.h"

static CGFloat const kAPCSegmentControlBorderWidth      = 1.0;


#pragma mark - APCSegmentControlBorderLayer

@implementation APCSegmentControlBorderLayer

- (NSArray *) segmentLayers {
    return self.sublayers;
}

@end


#pragma mark - APCSegmentControl

@interface APCSegmentControl ()

@end

@implementation APCSegmentControl

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self applyStyle];
    [self layoutBorders];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self applyStyle];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self applyStyle];
    }
    return self;
}

- (instancetype)initWithItems:(NSArray *)items {
    self = [super initWithItems:items];
    if (self) {
        [self applyStyle];
        [self layoutBorders];
    }
    return self;
}

- (void) insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated {
    [super insertSegmentWithTitle:title atIndex:segment animated:animated];
    
    [self layoutBorders];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.borderLayer.frame = self.bounds;
    
    CGFloat segmentWidth = self.innerWidth/self.borderLayer.segmentLayers.count;
    
    NSArray *segmentLayers = self.borderLayer.segmentLayers;
    for (int i = 0; i < segmentLayers.count; i++) {
        CALayer *separator = segmentLayers[i];
        separator.frame = CGRectMake(segmentWidth * (i + 1), 0, 1, self.innerHeight);
    }
}


#pragma mark - Getter

- (void) setSegmentBorderColor:(UIColor *)segmentBorderColor {
    if (_segmentBorderColor != segmentBorderColor) {
        _segmentBorderColor = segmentBorderColor;
        
        self.borderLayer.borderColor = segmentBorderColor.CGColor;
    }
}

- (UIColor *) borderColor {
    if (!_segmentBorderColor) {
        _segmentBorderColor = [UISegmentedControl borderColor];
    }
    
    return _segmentBorderColor;
}


#pragma mark - Public Methods

- (void) setSegmentColor:(UIColor *)color atIndex:(NSUInteger)index {
    [(CALayer *)self.borderLayer.segmentLayers[index] setBackgroundColor:color.CGColor];
}


#pragma mark - Private Methods

- (void) applyStyle {
    [self setTintColor:[UIColor clearColor]];
    [self setTitleTextAttributes:@{ NSFontAttributeName : [UISegmentedControl font]} forState:UIControlStateNormal];
    [self setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UISegmentedControl textColor]} forState:UIControlStateNormal];
    [self setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UISegmentedControl selectedTextColor]} forState:UIControlStateSelected];
}

- (void) layoutBorders {
    if (!self.borderLayer) {
        self.borderLayer = [APCSegmentControlBorderLayer layer];
        self.borderLayer.borderColor = self.borderColor.CGColor;
        self.borderLayer.borderWidth = kAPCSegmentControlBorderWidth;
        [self.layer addSublayer:self.borderLayer];
    }
    
    [self.borderLayer.segmentLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    self.borderLayer.frame = self.bounds;
    
    for (int i = 0; i < self.numberOfSegments; i++) {
        CALayer *separator = [CALayer layer];
        separator.backgroundColor = [UISegmentedControl borderColor].CGColor;
        [self.borderLayer addSublayer:separator];
    }
}

@end
