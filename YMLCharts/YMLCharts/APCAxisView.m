//
//  APCAxisView.m
//  YMLCharts
//
//  Created by Ramsundar Shandilya on 10/9/14.
//  Copyright (c) 2014 Ramsundar Shandilya. All rights reserved.
//

#import "APCAxisView.h"


@interface APCAxisView ()

@property (nonatomic, strong) NSMutableArray *titleLabels;
@property (nonatomic) APCGraphAxisType axisType;
@end

@implementation APCAxisView

@synthesize tintColor = _tintColor;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _titleLabels = [NSMutableArray new];
    }
    
    return self;
}

- (void)layoutSubviews
{
    CGFloat labelWidth = (CGFloat)CGRectGetWidth(self.bounds)/(self.titleLabels.count - 1);
    
    CGFloat labelHeight = (self.axisType == kAPCGraphAxisTypeX) ? CGRectGetHeight(self.bounds) : 20;
    
    for (int i=0; i<self.titleLabels.count; i++) {
        
        CGFloat positionX = (self.axisType == kAPCGraphAxisTypeX) ? ((i-0.5)*labelWidth) : 0;
        
        UILabel *label = (UILabel *)self.titleLabels[i];
        label.frame  = CGRectMake(positionX, 0, labelWidth, labelHeight);
    }
}

- (void)setupLabels:(NSArray *)titles forAxisType:(APCGraphAxisType)type
{
    self.axisType = type;
    
    for (int i=0; i<titles.count; i++) {
        
        UILabel *label = [UILabel new];
        label.text = titles[i];
        label.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.7;
        label.textColor = self.tintColor;
        [self addSubview:label];
        
        [self.titleLabels addObject:label];
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    for (UILabel *label in self.titleLabels) {
        label.textColor = tintColor;
    }
}

@end
