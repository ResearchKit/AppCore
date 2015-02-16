// 
//  APCDebugWindow.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCDebugWindow.h"
#import "APCAppCore.h"
#import "APCParametersDashboardTableViewController.h"


@interface APCDebugWindow ()
@property (strong, nonatomic) APCParametersDashboardTableViewController *controller;

@end

@implementation APCDebugWindow

- (void)motionEnded:(UIEventSubtype) __unused motion withEvent:(UIEvent *)event {
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
