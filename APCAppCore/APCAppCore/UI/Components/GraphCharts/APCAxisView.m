// 
//  APCAxisView.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCAxisView.h"


@interface APCAxisView ()

@property (nonatomic, strong) NSMutableArray *titleLabels;
@property (nonatomic) APCGraphAxisType axisType;
@end

@implementation APCAxisView

@synthesize tintColor = _tintColor;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _titleLabels = [NSMutableArray new];
    _leftOffset = 0;
}

- (void)layoutSubviews
{
    CGFloat labelWidth = (CGFloat)CGRectGetWidth(self.bounds)/(self.titleLabels.count - 1);
    
    CGFloat labelHeight = (self.axisType == kAPCGraphAxisTypeX) ? CGRectGetHeight(self.bounds) : 20;
    
    for (int i=0; i<self.titleLabels.count; i++) {
        
        CGFloat positionX = (self.axisType == kAPCGraphAxisTypeX) ? (self.leftOffset + (i-0.5)*labelWidth) : 0;
        
        UILabel *label = (UILabel *)self.titleLabels[i];
        if (i==0) {
            label.frame  = CGRectMake(positionX + labelWidth/2, 0, labelWidth, labelHeight);
        } else {
            label.frame  = CGRectMake(positionX, 0, labelWidth, labelHeight);
        }
        
    }
}

- (void)setupLabels:(NSArray *)titles forAxisType:(APCGraphAxisType)type
{
    self.axisType = type;
    
    for (int i=0; i<titles.count; i++) {
        
        UILabel *label = [UILabel new];
        label.text = titles[i];
        label.font = self.isLandscapeMode ? [UIFont fontWithName:@"Helvetica-Light" size:19.0] : [UIFont fontWithName:@"Helvetica-Light" size:12.0];
        label.numberOfLines = 2;
        label.textAlignment = (i == 0) ? NSTextAlignmentLeft : NSTextAlignmentCenter;
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
