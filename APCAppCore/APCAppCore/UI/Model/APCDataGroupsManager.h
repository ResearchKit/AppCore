//
//  APCDataGroupsManager.h
//  APCAppCore
//
// Copyright (c) 2015, Sage Bionetworks. All rights reserved.
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
#import <ResearchKit/ResearchKit.h>

NS_ASSUME_NONNULL_BEGIN

@class APCUser, APCTableViewRow, APCTableViewItem;

extern NSString * const APCDataGroupsStepIdentifier;

/**
 *  Manager to configure and handle setting and updating of the data groups during onboarding and from the profile.
 *
 *  This superclass returns information about the data groups used by this app. The generic version included in AppCore
 *  uses a dictionary to define the data groups, which group (if any) is the "control" group, and to allow updating of
 *  data groups via either a survey result (onboarding) or a tableViewItem (profile). This manager does *not* include a 
 *  pointer to the user and is intended as a temporary object for managing state during onboarding or while viewing or 
 *  editing the user's profile.
 */
@interface APCDataGroupsManager : NSObject

@property (nonatomic, readonly) BOOL hasChanges;
@property (nonatomic, readonly) NSArray * _Nullable dataGroups;
@property (nonatomic, readonly) NSDictionary * _Nullable mapping;

- (instancetype)initWithDataGroups:(NSArray * _Nullable)dataGroups mapping:(NSDictionary * _Nullable)mapping;

- (BOOL)needsUserInfoDataGroups;
- (BOOL)isStudyControlGroup;

- (NSArray <APCTableViewRow *> * _Nullable)surveyItems;
- (ORKFormStep * _Nullable)surveyStep;
- (ORKStepResult * _Nullable)stepResult;

- (void)setSurveyAnswerWithItem:(APCTableViewItem*)item;
- (void)setSurveyAnswerWithStepResult:(ORKStepResult *)result;

@end

NS_ASSUME_NONNULL_END