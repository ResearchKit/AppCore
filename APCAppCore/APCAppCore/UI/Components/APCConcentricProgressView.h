// 
//  APCConcentricProgressView.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

@protocol APCConcentricProgressViewDataSource;

@interface APCConcentricProgressView : UIView

@property (nonatomic) CGFloat lineWidth;

@property (nonatomic, weak) id <APCConcentricProgressViewDataSource> datasource;

@property (nonatomic) BOOL shouldAnimate;

@end


@protocol APCConcentricProgressViewDataSource <NSObject>
@optional
- (NSUInteger)numberOfComponentsInConcentricProgressView;

- (CGFloat)concentricProgressView:(APCConcentricProgressView *)concentricProgressView valueForComponentAtIndex:(NSUInteger)index;

- (UIColor *)concentricProgressView:(APCConcentricProgressView *)concentricProgressView colorForComponentAtIndex:(NSUInteger)index;

@end
