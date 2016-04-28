// 
//  APCOnboarding.h 
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
#import "APCOnboardingTask.h"

#import <ResearchKit/ResearchKit.h>

@protocol APCOnboardingDelegate;
@class APCScene;


NS_ASSUME_NONNULL_BEGIN

@interface APCOnboarding : NSObject

@property (nonatomic, readonly) APCOnboardingTask *onboardingTask;

@property (nonatomic, strong) ORKStep *__nullable currentStep;

@property (nonatomic, strong) NSMutableDictionary *sceneData;

@property (nonatomic, weak) id <APCOnboardingDelegate> __nullable delegate;

@property (nonatomic, readonly) APCOnboardingTaskType taskType;

- (instancetype)initWithDelegate:(id<APCOnboardingDelegate>)object taskType:(APCOnboardingTaskType)taskType;

- (nullable UIViewController *)viewControllerForSceneIdentifier:(NSString *)identifier;

- (void)setScene:(APCScene *)scene forIdentifier:(NSString *)identifier;

- (nullable UIViewController *)nextScene;

- (void)popScene;

- (BOOL)isSignInSupported;

- (BOOL)hasNextStep:(ORKStep *)step;
- (BOOL)hasPreviousStep:(ORKStep *)step;

@end


@protocol APCOnboardingDelegate <APCOnboardingTaskDelegate>

@required

/**
 *  Return the scene for the desired type, or nil if the scene should be skipped.
 */
- (nullable APCScene *)onboarding:(APCOnboarding *)onboarding sceneOfType:(NSString *)type;

@optional

/**
 * Called whenever the step result changes for a given step
 */
- (void)onboarding:(APCOnboarding *)onboarding didFinishStepWithResult:(ORKStepResult*)stepResult;

/**
 * Called when finished
 */
- (void)onboardingDidFinish;

@end

NS_ASSUME_NONNULL_END
