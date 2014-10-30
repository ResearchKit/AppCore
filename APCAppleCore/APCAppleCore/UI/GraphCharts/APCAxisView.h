//
//  APCAxisView.h
//  YMLCharts
//
//  Created by Ramsundar Shandilya on 10/9/14.
//  Copyright (c) 2014 Ramsundar Shandilya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCGraphConstants.h"

@interface APCAxisView : UIView

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic) CGFloat leftOffset;

- (void)setupLabels:(NSArray *)titles forAxisType:(APCGraphAxisType)type;

@end
