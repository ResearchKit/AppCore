//
//  APCDataCollector.h
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
#import "APCCollectorProtocol.h"

typedef NSDate*(^APCInitialStartDatePredicateDesignator)();

@interface APCDataCollector : NSObject

/*
 Setting an anchor name will mean that you must explicitly setup your own predicates to prevent potential duplicate data from being queried. The argument for anchorName can be nil. 
 */
- (instancetype)initWithIdentifier:(NSString*)identifier
                    dateAnchorName:(NSString*)anchorName
                  launchDateAnchor:(APCInitialStartDatePredicateDesignator)launchDateAnchor;
- (void)start;
- (void)stop;
- (void)updateTracking;
- (NSDate*)launchDate;

@property (strong, nonatomic) NSString*                             anchorName;
@property (strong, nonatomic) APCInitialStartDatePredicateDesignator   launchDateAnchor;
@property (strong, nonatomic) id                                    receiver;
@property (strong, nonatomic) id                                    <APCCollectorProtocol> delegate;
@property (strong, nonatomic) NSString*                             identifier;

@end
