//
//  APCScene.m
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

#import "APCScene.h"
#import "APCContainerStepViewController.h"

@implementation APCScene

- (NSString *)identifier {
    if (_identifier == nil) {
        _identifier = [_storyboardName copy] ?: [_step.identifier copy];
    }
    return _identifier;
}

- (instancetype)initWithName:(NSString *_Nullable)storyboardId inStoryboard:(NSString *)storyboardName {
    NSParameterAssert([storyboardName length] > 0);
    self = [super init];
    if (self) {
        _identifier = [storyboardName copy];
        _storyboardId = [storyboardId copy];
        _storyboardName = [storyboardName copy];
    }
    return self;
}

- (instancetype)initWithStep:(ORKStep*)step {
    NSParameterAssert(step != nil);
    self = [super init];
    if (self) {
        _identifier = [step.identifier copy];
        _step = step;
    }
    return self;
}

- (NSBundle *)bundle {
    if (!_bundle) {
        _bundle = [NSBundle bundleForClass:[self class]];
    }
    return _bundle;
}

- (ORKStepViewController * _Nullable)instantiateStepViewController {
    UIViewController *vc = [self instantiateViewController];
    if (vc != nil && ![vc isKindOfClass:[ORKStepViewController class]]) {
        vc = [[APCContainerStepViewController alloc] initWithStep:self.step childViewController:vc];
    }
    return (ORKStepViewController *)vc;
}

- (UIViewController * _Nullable)instantiateViewController {
    
    UIViewController *viewController = nil;
    
    // Look for the view controller in a storyboard
    if (self.storyboardName) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:self.storyboardName bundle:self.bundle];
        if (self.storyboardId != nil) {
            viewController = [storyboard instantiateViewControllerWithIdentifier:self.storyboardId];
        }
        else {
            viewController = [storyboard instantiateInitialViewController];
        }
        // If the view controller returned by the storyboard is a step view controller
        // then point the step at it.
        if ([viewController isKindOfClass:[ORKStepViewController class]]) {
            ((ORKStepViewController*)viewController).step = self.step;
        }
    }
    
    // Factory method for creating the view controller that is defined on ORKStep
    // is private to ResearchKit so just define factory for the type of step that
    // that we are interested in.
    // TODO: clean this up when pointing against ResearchKit 1.3 (syoung 01/14/2016)
    if ((viewController == nil) && [self.step isKindOfClass:[ORKFormStep class]]) {
        viewController = [[ORKFormStepViewController alloc] initWithStep:self.step];
    }
    
    // Add the tab bar item (if applicable)
    if (self.tabBarItem) {
        viewController.tabBarItem = self.tabBarItem;
    }
    
    return viewController;
}

@end
