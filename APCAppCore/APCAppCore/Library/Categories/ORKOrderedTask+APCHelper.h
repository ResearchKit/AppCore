//
//  ORKOrderedTask+APCHelper.h
//  APCAppCore
//
//  Created by Shannon Young on 12/9/15.
//  Copyright © 2015 Apple, Inc. All rights reserved.
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