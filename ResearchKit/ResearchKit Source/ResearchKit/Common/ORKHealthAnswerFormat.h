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


#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKAnswerFormat.h>
#import <HealthKit/HealthKit.h>

ORK_ASSUME_NONNULL_BEGIN

/**
 `ORKHealthKitCharacteristicTypeAnswerFormat` is an answer format which can be used
 to request the user enter value corresponding to a HealthKit characteristic type.
 
 The actual UI used for collecting data with this answer format depends on the HealthKit type being collected.
 The default value in the UI will be the most recent value pulled from HealthKit, if such a value exists.
 When a step or item is presented using this answer format, authorization will be requested.
 
 Use this to let the user auto-fill their blood type or date of birth.
 */
ORK_CLASS_AVAILABLE
@interface ORKHealthKitCharacteristicTypeAnswerFormat : ORKAnswerFormat

/**
 Returns a new answer format for the specified characteristic type.
 
 @param characteristicType   The type to collect.
 @return Returns a new instance.
 */
+ (instancetype)answerFormatWithCharacteristicType:(HKCharacteristicType *)characteristicType;

/**
 Designated initializer.
 
 @param characteristicType   The type to collect.
 @return Returns a new instance.
 */
- (instancetype)initWithCharacteristicType:(HKCharacteristicType *)characteristicType NS_DESIGNATED_INITIALIZER;

/**
 The characteristic type to be collected by this answer format (read-only).
 */
@property (nonatomic, readonly, copy) HKCharacteristicType *characteristicType;

@end

/**
 `ORKHealthKitQuantityTypeAnswerFormat` is an answer format which can be used
 to request the user enter value corresponding to a HealthKit quantity type,
 such as systolic blood pressure.
 
 The actual UI used for collecting data with this answer format depends on the HealthKit type being collected.
 The default value in the UI will be the most recent value pulled from HealthKit, if such a value exists.
 When a step or item is presented using this answer format, authorization will be requested.
 
 If a `nil` unit is supplied, the user's preferred unit will be pulled from HealthKit on devices where
 this is supported.
 
 Use this answer format to let the user auto-fill their weight with the most
 recent sample from HealthKit.
 */
ORK_CLASS_AVAILABLE
@interface ORKHealthKitQuantityTypeAnswerFormat : ORKAnswerFormat


/**
 Returns a new answer format for the specified quantity type.
 
 @param quantityType   The type to collect.
 @param unit   The HealthKit unit to collect. If `nil`, the HealthKit default is used, where available.
 @param style   The numeric answer style to use when collecting this value.
 @return Returns a new instance.
 */
+ (instancetype)answerFormatWithQuantityType:(HKQuantityType *)quantityType unit:(ORK_NULLABLE HKUnit *)unit style:(ORKNumericAnswerStyle)style;

/**
 Designated initializer.
 
 @param quantityType   The type to collect.
 @param unit   The HealthKit unit to collect. If `nil`, the HealthKit default is used, where available.
 @param style   The numeric answer style to use when collecting this value.
 @return Returns a new instance.
 */
- (instancetype)initWithQuantityType:(HKQuantityType *)quantityType unit:(ORK_NULLABLE HKUnit *)unit style:(ORKNumericAnswerStyle)style NS_DESIGNATED_INITIALIZER;

/**
 The quantity type to collect (read-only).
 */
@property (nonatomic, readonly, copy) HKQuantityType *quantityType;

/**
 The HealthKit unit in which to collect the answer (read-only).
 
 The unit will be displayed when the user is typing in their answer, and will also
 be included in the question result generated by form items or question steps
 using this answer format.
 */
@property (nonatomic, readonly, strong, ORK_NULLABLE) HKUnit *unit;

/**
 The numeric answer style (read-only).
 */
@property (nonatomic, readonly) ORKNumericAnswerStyle numericAnswerStyle;


@end

ORK_ASSUME_NONNULL_END

