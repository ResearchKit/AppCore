//
//  APCBadgeLabel.m
//  APCAppCore
//
//  Created by Farhan Ahmed on 2/16/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCBadgeLabel.h"

@implementation APCBadgeLabel

- (void)sharedInit
{
    self.layer.cornerRadius = roundf(self.frame.size.width/2);
    self.layer.borderColor  = [[UIColor redColor] CGColor];
    self.layer.borderWidth  = 2.0;
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

@end
