//
//  ORKOrderedTask+APCHelper.h
//  APCAppCore
//
// Copyright (c) 2015 Apple, Inc. All rights reserved.
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

#import <ResearchKit/ResearchKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Values that identify the button that was tapped in a tapping sample.
 */
typedef NS_OPTIONS(NSInteger, APCTapHandOption) {
    /// Which hand to use is undefined
    APCTapHandOptionUndefined = 0,
    
    /// Task should test the left hand
    APCTapHandOptionLeft = 1 << 1,
    
    /// Task should test the right hand
    APCTapHandOptionRight = 1 << 2,
    
    /// Task should test both hands (random order)
    APCTapHandOptionBoth = APCTapHandOptionLeft | APCTapHandOptionRight,
};

extern NSString *const APCTapInstructionStepIdentifier;
extern NSString *const APCTapTappingStepIdentifier;
extern NSString *const APCRightHandIdentifier;
extern NSString *const APCLeftHandIdentifier;

@interface ORKOrderedTask (APCHelper)

/**
 Returns a predefined task that consists of two finger tapping.
 
 In a two finger tapping task, the participant is asked to rhythmically and alternately tap two
 targets on the device screen.
 
 A two finger tapping task can be used to assess basic motor capabilities including speed, accuracy,
 and rhythm.
 
 Data collected in this task includes touch activity and accelerometer information.
 
 @param identifier              The task identifier to use for this task, appropriate to the study.
 @param intendedUseDescription  A localized string describing the intended use of the data
 collected. If the value of this parameter is `nil`, the default
 localized text will be displayed.
 @param duration                The length of the count down timer that runs while touch data is
 collected.
 @param options                 Options that affect the features of the predefined task.
 @param handOptions             Options for determining which hand(s) to test.
 
 @return An active two finger tapping task that can be presented with an `ORKTaskViewController` object.
 */
+ (ORKOrderedTask *)twoFingerTappingIntervalTaskWithIdentifier:(NSString *)identifier
                                        intendedUseDescription:(nullable NSString *)intendedUseDescription
                                                      duration:(NSTimeInterval)duration
                                                       options:(ORKPredefinedTaskOption)options
                                                   handOptions:(APCTapHandOption)handOptions;

@end

NS_ASSUME_NONNULL_END