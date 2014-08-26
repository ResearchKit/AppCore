//
//  YMLAxisView.h
//  PieChartDemo
//
//  Created by Mark Pospesel on 10/17/12.
//  Copyright (c) 2012 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMLAxisFormatter.h"
#import "YMLChartEnumerations.h"

@interface YMLAxisView : UIView

@property (nonatomic, assign) CGFloat min;
@property (nonatomic, assign) CGFloat max;
@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) NSArray *positions;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign, readonly) YMLAxisPosition position;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) id<YMLAxisFormatter> formatter;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) CGFloat minimumInterItemSpacing;
@property (nonatomic, assign, getter = isPercent) BOOL percent;

- (NSString *)displayValueForValue:(id)value;

- (id)initWithPosition:(YMLAxisPosition)position;

- (CGSize)minimumSize;

@end
