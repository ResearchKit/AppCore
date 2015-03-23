/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>

ORK_ASSUME_NONNULL_BEGIN

@class ORKActiveStepTimer;

typedef void (^ORKActiveStepTimerHandler)(ORKActiveStepTimer *timer, BOOL finished);


@interface ORKActiveStepTimer : NSObject

- (instancetype)initWithDuration:(NSTimeInterval)duration interval:(NSTimeInterval)interval runtime:(NSTimeInterval)runtime handler:(ORKActiveStepTimerHandler)handler;

@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, readonly) NSTimeInterval interval;

@property (nonatomic, readonly) NSTimeInterval runtime;

/*
 Handler callbacks are returned on interval boundaries. The timer automatically
 pauses itself when finished=YES.
 
 This handler is retained. Be careful not to create a retain cycle.
 */
@property (nonatomic, copy, readonly) ORKActiveStepTimerHandler handler;

- (void)pause; // pauses the timer
- (void)resume; // resumes the timer where it left off
- (void)reset; // sets runtime to 0. Stops the timer if it is running.

@end

ORK_ASSUME_NONNULL_END
