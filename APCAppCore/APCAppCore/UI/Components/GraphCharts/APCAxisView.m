// 
//  APCAxisView.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
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
    CGFloat segmentWidth = (CGFloat)CGRectGetWidth(self.bounds)/(self.titleLabels.count - 1);
    CGFloat labelWidth = segmentWidth;
    
    CGFloat labelHeight = (self.axisType == kAPCGraphAxisTypeX) ? CGRectGetHeight(self.bounds)*0.75 : 20;
    
    for (NSUInteger i=0; i<self.titleLabels.count; i++) {
        
        CGFloat positionX = (self.axisType == kAPCGraphAxisTypeX) ? (self.leftOffset + i*segmentWidth) : 0;
        
        if (i==0) {
            //Shift the first label to acoomodate the month text.
            positionX -= self.leftOffset;
        }
        
        UILabel *label = (UILabel *)self.titleLabels[i];
        
        if (label.text) {
            labelWidth = [label.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, labelHeight) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:label.font} context:nil].size.width;
            labelWidth = MAX(labelWidth, 15);
            labelWidth += self.landscapeMode ? 14 : 8; //padding
        }
        
        if (i==0) {
            label.frame  = CGRectMake(positionX, (CGRectGetHeight(self.bounds) - labelHeight)/2, labelWidth, labelHeight);
        } else {
            label.frame  = CGRectMake(positionX - labelWidth/2, (CGRectGetHeight(self.bounds) - labelHeight)/2, labelWidth, labelHeight);
        }
        
        if (i == self.titleLabels.count - 1) {
            //Last label
            
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = self.tintColor;
            label.layer.cornerRadius = CGRectGetHeight(label.frame)/2;
            label.layer.masksToBounds = YES;
        }
        
    }
}

- (void)setupLabels:(NSArray *)titles forAxisType:(APCGraphAxisType)type
{
    self.axisType = type;
    
    for (NSUInteger i=0; i<titles.count; i++) {
        
        UILabel *label = [UILabel new];
        label.text = titles[i];
        label.font = self.isLandscapeMode ? [UIFont fontWithName:@"Helvetica-Light" size:19.0] : [UIFont fontWithName:@"Helvetica-Light" size:12.0];
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
