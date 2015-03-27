//
//  APCTaskReminder.m
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

#import "APCTaskReminder.h"

@implementation APCTaskReminder

-(id)initWithTaskID: (NSString *)taskID resultsSummaryKey:(NSString *)resultsSummaryKey completedTaskPredicate:(NSPredicate *)completedTaskPredicate reminderBody:(NSString *)reminderBody{
    
    self = [super init];
    NSAssert(taskID != nil, @"taskID cannot be nil");
    NSAssert(reminderBody != nil, @"reminderBody cannot be nil");
    NSAssert(completedTaskPredicate != nil, @"resultsSummaryPredicate cannot be nil");
    NSAssert(resultsSummaryKey != nil, @"resultsSummaryKey cannot be nil");
    
    if (self) {
        self.taskID = taskID;
        self.reminderBody = reminderBody;
        self.completedTaskPredicate = completedTaskPredicate;

        if (resultsSummaryKey) {
            self.resultsSummaryKey = resultsSummaryKey;
            self.reminderIdentifier = [NSString stringWithFormat:@"%@_%@_reminder", taskID, resultsSummaryKey];
        }else{
            self.reminderIdentifier = [NSString stringWithFormat:@"%@_reminder", taskID];
        }

    }
    return self;
    
}

-(id)initWithTaskID: (NSString *)taskID reminderBody:(NSString *)reminderBody{
    self = [super init];
    NSAssert(taskID != nil, @"taskID cannot be nil");
    NSAssert(reminderBody != nil, @"reminderBody cannot be nil");
    self.taskID = taskID;
    self.reminderBody = reminderBody;
    self.reminderIdentifier = [NSString stringWithFormat:@"%@_reminder", taskID];
    self.resultsSummaryKey = nil;
    self.completedTaskPredicate = nil;
    return self;
}

@end
