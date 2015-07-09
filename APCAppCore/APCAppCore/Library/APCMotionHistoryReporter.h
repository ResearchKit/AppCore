// 
//  APCMotionHistoryReporter.h 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// Copyright (c) 2015, Boston Children's Hospital. All rights reserved. 
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

/// Callback when motion history reporter is done.
typedef void (^APCMotionHistoryReporterCallback)(NSArray * __nullable motionReports, NSError * __nullable error);

@interface APCMotionHistoryReporter : NSObject

NS_ASSUME_NONNULL_BEGIN
+ (APCMotionHistoryReporter *)sharedInstance;

/** Start motion history collection. You will need to listen to the "APCMotionHistoryReporterDoneNotification" notification and call the
 *  shared instance's `retrieveMotionReport`.
 *
 *  If you start the history reporter while it hasn't finished a previous run, nothing will happen.
 */
- (void)startMotionCoProcessorDataFrom:(NSDate *)startDate andEndDate:(NSDate *)endDate andNumberOfDays:(NSInteger)numberOfDays;

/** Start motion history collection and return the report in a callback.
 *
 *  If you start the history reporter while it hasn't finished a previous run, the callback will be called with an error in the
 *  "APCAppCoreErrorDomain" with error code 51.
 */
- (void)startMotionCoProcessorDataFrom:(NSDate *)startDate andEndDate:(NSDate *)endDate andNumberOfDays:(NSInteger)numberOfDays callback:(APCMotionHistoryReporterCallback)callback;

- (BOOL)isDataReady;

- (NSArray *)retrieveMotionReport;
NS_ASSUME_NONNULL_END

@end
