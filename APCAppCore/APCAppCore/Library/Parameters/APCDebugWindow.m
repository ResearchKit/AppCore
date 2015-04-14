// 
//  APCDebugWindow.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
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
