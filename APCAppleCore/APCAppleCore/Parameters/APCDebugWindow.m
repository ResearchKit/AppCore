//
//  APCDebugWindow.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 9/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDebugWindow.h"
#import "APCParametersDashboardTableViewController.h"


@interface APCDebugWindow ()
@property (strong, nonatomic) APCParametersDashboardTableViewController *controller;
@property (assign) BOOL blah;
@end

@implementation APCDebugWindow

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (self.enable) {
        if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
            NSLog(@"Global Shake!");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceShaken" object:self];
            
            
            [self presentModalllViewController];
        }
    }
}

- (void)presentModalllViewController {
    
    if (!self.blah) {
        self.controller = [[APCParametersDashboardTableViewController alloc] init];
        self.controller.view.frame = [[UIScreen mainScreen] bounds];
        
        [self addSubview:self.controller.view];
        self.blah = YES;
    } else {
        [self.controller.view removeFromSuperview];
        [self.controller removeFromParentViewController];
        self.blah = NO;
    }
}

@end
