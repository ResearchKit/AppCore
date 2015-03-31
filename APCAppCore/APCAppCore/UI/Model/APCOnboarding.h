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
 
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ResearchKit/ResearchKit.h>

#import "APCSignUpTask.h"
#import "APCSignInTask.h"

typedef NS_ENUM(NSUInteger, APCOnboardingTaskType) {
    kAPCOnboardingTaskTypeSignUp,
    kAPCOnboardingTaskTypeSignIn,
};

@protocol APCOnboardingDelegate;
@class APCScene;

@interface APCOnboarding : NSObject

@property (nonatomic, readonly) APCOnboardingTask *onboardingTask;

@property (nonatomic, strong) ORKStep *currentStep;

@property (nonatomic, strong) NSMutableDictionary *scenes;

@property (nonatomic, strong) NSMutableDictionary *sceneData;

@property (nonatomic, weak) id <APCOnboardingDelegate> delegate;

@property (nonatomic, readonly) APCOnboardingTaskType taskType;

- (instancetype)initWithDelegate:(id)object taskType:(APCOnboardingTaskType)taskType;

- (UIViewController *)viewControllerForSceneIdentifier:(NSString *)identifier;

- (void)setScene:(APCScene *)scene forIdentifier:(NSString *)identifier;

- (UIViewController *)nextScene;

- (void)popScene;

@end

@protocol APCOnboardingDelegate <NSObject>

@required

- (APCScene *)inclusionCriteriaSceneForOnboarding:(APCOnboarding *)onboarding;

@optional

- (APCScene *)customInfoSceneForOnboarding:(APCOnboarding *)onboarding;

@end

/*************************************/

@interface APCScene : NSObject

@property (nonatomic, strong) NSString *name; //Refers to StoryboardID
@property (nonatomic, strong) NSString *storyboardName;
@property (nonatomic, strong) NSBundle *bundle;

@end
