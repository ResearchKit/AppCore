//
//  APCTaskReminder.h
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

@interface APCTaskReminder : NSObject
@property (strong, nonatomic) NSString *reminderIdentifier;
@property (strong, nonatomic) NSString *reminderBody;
@property (strong, nonatomic) NSString *resultsSummaryKey;
@property (strong, nonatomic) NSPredicate *completedTaskPredicate;
@property (strong, nonatomic) NSString *taskID;

/**
 Initializer
 @param taskID the taskID declared in the json file for the activity
 @param resultsSummaryKey the key used to locate the result in the resultsSummary
 @param completedTaskPredicate A predicate determining whether the task retrieved from resultsSummary has been completed 
 @param reminderBody The message to be presented in the Profile and the Reminder
 */
-(id)initWithTaskID: (NSString *)taskID resultsSummaryKey:(NSString *)resultsSummaryKey completedTaskPredicate:(NSPredicate *)completedTaskPredicate reminderBody:(NSString *)reminderBody;
/**
 Convenience initializer
 @param taskID the taskID declared in the json file for the activity
 @param reminderBody The message to be presented in the Profile and the Reminder
 */
-(id)initWithTaskID: (NSString *)taskID reminderBody:(NSString *)reminderBody;
@end
