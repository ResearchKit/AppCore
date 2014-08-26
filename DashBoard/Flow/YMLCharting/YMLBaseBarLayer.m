//
//  YMLBaseBarLayer.m
//  Avero
//
//  Created by Mark Pospesel on 1/24/13.
//  Copyright (c) 2013 ymedialabs.com. All rights reserved.
//

#import "YMLBaseBarLayer.h"

@implementation YMLBaseBarLayer

- (id)init
{
    self = [super init];
    if (self) {
        _cornerRadii = CGSizeZero;
        _orientation = YMLChartOrientationHorizontal;
        self.contentsScale = [[UIScreen mainScreen] scale];
    }
    return self;
}

- (id)initWithLayer:(id)layer
{
	if (self = [super initWithLayer:layer]) {
		if ([layer isKindOfClass:[YMLBaseBarLayer class]]) {
			YMLBaseBarLayer *other = (YMLBaseBarLayer *)layer;
            _orientation = other.orientation;
            _cornerRadii = other.cornerRadii;
            self.contentsScale = [[UIScreen mainScreen] scale];
		}
	}
	
	return self;
    
}

- (void)setOrientation:(YMLChartOrientation)orientation
{
    if (_orientation != orientation)
    {
        _orientation = orientation;
        [self setNeedsLayout];
    }
}

- (void)setCornerRadii:(CGSize)cornerRadii
{
    if (CGSizeEqualToSize(cornerRadii, _cornerRadii))
        return;
    
    _cornerRadii = cornerRadii;
    [self setNeedsDisplay];
}

@end
