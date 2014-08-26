//
//  YMLScrollableChartView.h
//  Avero
//
//  Created by Mark Pospesel on 12/28/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import "YMLChartView.h"

// chart view where plot content frame is scrollable
@interface YMLScrollableChartView : YMLChartView

@property (nonatomic, assign) CGSize barInterval;
@property (nonatomic, weak, readonly) UIScrollView *scrollView;

@end
