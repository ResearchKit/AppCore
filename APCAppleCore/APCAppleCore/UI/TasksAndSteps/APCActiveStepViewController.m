//
//  APHStepViewController.m
//  Parkinson
//
//  Created by Henry McGilton on 11/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCActiveStepViewController.h"
#import "APCAppleCore.h"

@interface APCActiveStepViewController ()

@end

@implementation APCActiveStepViewController

    //
    //    override RKSTActiveStepViewController stepDidFinish
    //
- (void)stepDidFinish
{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerDidFinish:navigationDirection:)] == YES) {
            [self.delegate stepViewControllerDidFinish:self navigationDirection:RKSTStepViewControllerNavigationDirectionForward];
        }
    }
}

@end
