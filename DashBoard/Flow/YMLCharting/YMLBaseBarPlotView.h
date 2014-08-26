//
//  YMLBaseBarPlotView.h
//  Avero
//
//  Created by Mark Pospesel on 1/24/13.
//  Copyright (c) 2013 ymedialabs.com. All rights reserved.
//

#import "YMLPlotView.h"

@interface YMLBaseBarPlotView : YMLPlotView

// width of the bar line
@property (nonatomic, assign) CGFloat barWidth;
@property (nonatomic, assign) CGFloat selectedBarScaleFactor;

// selected bar index
@property (nonatomic, assign) NSInteger selectedIndex;

@end
