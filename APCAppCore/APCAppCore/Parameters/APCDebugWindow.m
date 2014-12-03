//
//  APCDebugWindow.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 9/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDebugWindow.h"
#import "APCAppleCore.h"
#import "APCParametersDashboardTableViewController.h"


@interface APCDebugWindow ()
@property (strong, nonatomic) APCParametersDashboardTableViewController *controller;

@end

@implementation APCDebugWindow

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (self.enableDebuggerWindow) {
        if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceShaken" object:self];
    
            [self presentModalViewController];
        }
    }
}

- (void)presentModalViewController {
    
    if (!self.toggleDebugWindow) {
        self.controller = [[UIStoryboard storyboardWithName:@"APCParameters" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"ParametersVC"];
        self.controller.view.frame = [[UIScreen mainScreen] bounds];
        
        [self addSubview:self.controller.view];
        self.toggleDebugWindow = YES;
    } else {
        [self.controller.view removeFromSuperview];
        [self.controller removeFromParentViewController];
        self.toggleDebugWindow = NO;
    }
}

@end
