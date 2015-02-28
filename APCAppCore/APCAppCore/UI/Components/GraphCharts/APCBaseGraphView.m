//
//  APCGraphView.m
//  AppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCBaseGraphView.h"

@implementation APCBaseGraphView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    _axisColor = [UIColor colorWithRed:217/255.f green:217/255.f blue:217/255.f alpha:1.f];
    _axisTitleColor = [UIColor colorWithRed:142/255.f green:142/255.f blue:147/255.f alpha:1.f];
    _axisTitleFont = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
    
    _referenceLineColor = [UIColor colorWithRed:225/255.f green:225/255.f blue:229/255.f alpha:1.f];
    
    _scrubberLineColor = [UIColor grayColor];
    _scrubberThumbColor = [UIColor colorWithWhite:1 alpha:1.0];
    
    _showsVerticalReferenceLines = NO;

    _emptyText = NSLocalizedString(@"No Data", @"No Data");
    
}

- (void)throwOverrideException
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__] userInfo:nil];
}

- (NSInteger)numberOfPlots
{
    [self throwOverrideException];
    
    return 0;
}

- (NSInteger)numberOfPointsinPlot:(NSInteger) __unused plotIndex
{
    [self throwOverrideException];
    
    return 0;
}

- (void)scrubReferenceLineForXPosition:(CGFloat) __unused xPosition
{
    [self throwOverrideException];
}

- (void)setScrubberViewsHidden:(BOOL) __unused hidden animated:(BOOL) __unused animated
{
    [self throwOverrideException];
}

- (void)refreshGraph
{
    [self throwOverrideException];
}

@end
