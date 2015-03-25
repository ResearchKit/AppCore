//
//  APCGraphView.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCGraphConstants.h"

/**
 *  IMPORTANT: THIS IS AN ABSTRACT CLASS. IT HOLDS PROPERTIES & METHODS COMMON TO CLASSES LIKE APCLineGraphView & APCDiscreteGraphView.
 */

@protocol APCBaseGraphViewDelegate;

@interface APCBaseGraphView : UIView

@property (nonatomic, readonly) CGFloat minimumValue;

@property (nonatomic, readonly) CGFloat maximumValue;

@property (nonatomic, getter=isLandscapeMode) BOOL landscapeMode;

@property (nonatomic) BOOL showsVerticalReferenceLines;

@property (nonatomic) BOOL shouldAutomaticallyAnimate;

/* Appearance */

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, strong) UIColor *axisColor;

@property (nonatomic, strong) UIColor *axisTitleColor;

@property (nonatomic, strong) UIFont *axisTitleFont;

@property (nonatomic, strong) UIColor *referenceLineColor;

@property (nonatomic, strong) UIColor *scrubberThumbColor;

@property (nonatomic, strong) UIColor *scrubberLineColor;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, strong) NSString *emptyText;

//Support for image icons as legends
@property (nonatomic, strong) UIImage *maximumValueImage;

@property (nonatomic, strong) UIImage *minimumValueImage;

@property (nonatomic, weak) id <APCBaseGraphViewDelegate> delegate;

- (void)sharedInit;

- (NSInteger)numberOfPlots;

- (NSInteger)numberOfPointsinPlot:(NSInteger)plotIndex;

- (void)scrubReferenceLineForXPosition:(CGFloat)xPosition;

- (void)setScrubberViewsHidden:(BOOL)hidden animated:(BOOL)animated;

- (void)refreshGraph;

- (void)animateGraph;

@end


@protocol APCBaseGraphViewDelegate <NSObject>

@optional

- (void)graphViewTouchesBegan:(APCBaseGraphView *)graphView;

- (void)graphView:(APCBaseGraphView *)graphView touchesMovedToXPosition:(CGFloat)xPosition;

- (void)graphViewTouchesEnded:(APCBaseGraphView *)graphView;

@end
