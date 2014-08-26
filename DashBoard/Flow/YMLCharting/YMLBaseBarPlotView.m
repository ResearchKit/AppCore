//
//  YMLBaseBarPlotView.m
//  Avero
//
//  Created by Mark Pospesel on 1/24/13.
//  Copyright (c) 2013 ymedialabs.com. All rights reserved.
//

#import "YMLBaseBarPlotView.h"

@interface YMLBaseBarPlotView()

@end

@implementation YMLBaseBarPlotView

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self doInitYMLBaseBarPlotView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self doInitYMLBaseBarPlotView];
    }
    return self;
}

- (id)initWithOrientation:(YMLChartOrientation)orientation
{
    self = [super initWithOrientation:orientation];
    if (self)
    {
    }
    return self;
}

- (void)doInitYMLBaseBarPlotView
{
    _selectedBarScaleFactor = 1;
    _selectedIndex = -1;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
