//
//  APCBadgeLabel.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCBadgeLabel.h"

@implementation APCBadgeLabel

- (void)sharedInit
{
    self.layer.cornerRadius = 15;
    self.layer.borderColor  = [[UIColor redColor] CGColor];
    self.layer.borderWidth  = 1.0;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self sharedInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self sharedInit];
    }
    
    return self;
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    if (text == nil || [text isEqualToString:@""]) {
        self.layer.borderWidth = 0;
    } else {
        self.layer.borderWidth = 1.0;
    }
    
    [self setNeedsDisplay];
}

@end
