//
//  APCSegmentControl.m
//  UI
//
//  Created by Karthik Keyan on 9/11/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UIView+Category.h"
#import "APCSegmentControl.h"
#import "UISegmentedControl+Appearance.h"

@interface APCSegmentControl ()

@property (nonatomic, strong) CALayer *borderLayer;

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
    
    CGFloat segmentWidth = self.innerWidth/self.borderLayer.sublayers.count;
    
    for (int i = 0; i < self.borderLayer.sublayers.count; i++) {
        CALayer *separator = self.borderLayer.sublayers[i];
        separator.frame = CGRectMake(segmentWidth * (i + 1), 0, 1, self.innerHeight);
    }
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
        self.borderLayer = [CALayer layer];
        [self.layer addSublayer:self.borderLayer];
    }
    
    [self.borderLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    self.borderLayer.frame = self.bounds;
    self.borderLayer.borderColor = [UISegmentedControl borderColor].CGColor;
    self.borderLayer.borderWidth = 1.0;
    
    for (int i = 0; i < self.numberOfSegments; i++) {
        CALayer *separator = [CALayer layer];
        separator.backgroundColor = [UISegmentedControl borderColor].CGColor;
        [self.borderLayer addSublayer:separator];
    }
}

@end
