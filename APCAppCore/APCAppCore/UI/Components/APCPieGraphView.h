// 
//  APCPieGraphView.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

@protocol APCPieGraphViewDatasource;

@interface APCPieGraphView : UIView

@property (nonatomic) CGFloat pieGraphRadius;

@property (nonatomic) CGFloat legendDotRadius;

@property (nonatomic) CGFloat legendPaddingHeight;

@property (nonatomic) CGFloat lineWidth;

@property (nonatomic) BOOL shouldAnimate;

@property (nonatomic) BOOL shouldAnimateLegend;

@property (nonatomic) CGFloat animationDuration;

@property (nonatomic, strong) UIFont *legendFont;

@property (nonatomic, strong) UIFont *percentageFont;

@property (nonatomic, weak) id <APCPieGraphViewDatasource> datasource;

@property (nonatomic) BOOL hidesPercentageLabels;

@property (nonatomic) BOOL hidesLegend;

@property (nonatomic) BOOL hidesCenterLabels;

@property (nonatomic) UILabel *titleLabel;

@property (nonatomic) UILabel *valueLabel;

@end

@protocol APCPieGraphViewDatasource <NSObject>

@required

- (NSInteger)numberOfSegmentsInPieGraphView;

- (CGFloat)pieGraphView:(APCPieGraphView *)pieGraphView valueForSegmentAtIndex:(NSInteger)index;

@optional

- (UIColor *)pieGraphView:(APCPieGraphView *)pieGraphView colorForSegmentAtIndex:(NSInteger)index;

- (NSString *)pieGraphView:(APCPieGraphView *)pieGraphView titleForSegmentAtIndex:(NSInteger)index;

@end
