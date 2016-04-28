//
//  APCScene.h
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

#import <UIKit/UIKit.h>
#import <ResearchKit/ResearchKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Simple container to hold on to a specific view controller in a storyboard.
 */
@interface APCScene : NSObject

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, strong) ORKStep *step;

/** Refers to the tabbar item (if applicable) */
@property (nonatomic, strong) UITabBarItem * _Nullable tabBarItem;

/** Refers to StoryboardID. */
@property (nonatomic, copy) NSString * _Nullable storyboardId;

/** The name of the storyboard. */
@property (nonatomic, copy) NSString * _Nullable storyboardName;

/** Defaults to the bundle this class resides in. */
@property (nonatomic, strong) NSBundle *bundle;

- (instancetype)initWithName:(NSString *_Nullable)storyboardId inStoryboard:(NSString *)storyboardName;
- (instancetype)initWithStep:(ORKStep*)step;

/** Instantiates the view controller as defined by this scene. */
- (UIViewController * _Nullable)instantiateViewController;

/** Instantiates a step view controller as defined by this scene. */
- (ORKStepViewController * _Nullable)instantiateStepViewController;

@end

NS_ASSUME_NONNULL_END
