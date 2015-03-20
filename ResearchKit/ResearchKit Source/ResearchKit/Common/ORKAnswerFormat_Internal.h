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


#import <ResearchKit/ResearchKit.h>
#import <HealthKit/HealthKit.h>
#import <ResearchKit/ORKAnswerFormat.h>

ORK_ASSUME_NONNULL_BEGIN

id ORKNullAnswerValue();

NSString *ORKHKBiologicalSexString(HKBiologicalSex biologicalSex);
NSString *ORKHKBloodTypeString(HKBloodType bloodType);
NSString *ORKQuestionTypeString(ORKQuestionType questionType);

// Need to mark these as designated initializers to avoid warnings once we designate the others.
#define ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(C) \
@interface C () \
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER; \
@end

ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKImageChoiceAnswerFormat);
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKValuePickerAnswerFormat);
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKTextChoiceAnswerFormat);
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKTextChoice);
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKImageChoice);
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKTimeOfDayAnswerFormat);
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKDateAnswerFormat);
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKTimeOfDayAnswerFormat);
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKNumericAnswerFormat);
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKScaleAnswerFormat);
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKContinuousScaleAnswerFormat);
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKTextAnswerFormat);
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKTimeIntervalAnswerFormat);

@interface ORKAnswerFormat ()

- (ORKAnswerFormat *)_impliedAnswerFormat;

- (ORK_NULLABLE NSCalendar *)_calendar;

- (BOOL)_isHealthKitAnswerFormat;

- (ORK_NULLABLE HKObjectType *)_healthKitObjectType;
- (ORK_NULLABLE HKUnit *)_healthKitUnit;
- (ORK_NULLABLE HKUnit *)_healthKitUserUnit;
- (void)_setHealthKitUserUnit:(ORK_NULLABLE HKUnit *)unit;

- (BOOL)_isAnswerValidWithString:(ORK_NULLABLE NSString *)text;

- (ORK_NULLABLE NSString *)_localizedInvalidValueStringWithAnswerString:(ORK_NULLABLE NSString *)text;

- (ORK_NONNULL Class)_questionResultClass;
- (ORKQuestionResult *)_resultWithIdentifier:(NSString *)identifier answer:(id)answer;

@end

@interface ORKNumericAnswerFormat ()

- (NSNumberFormatter *)_makeNumberFormatter;
- (ORK_NULLABLE NSString *)_sanitizedTextFieldText:(ORK_NULLABLE NSString *)text decimalSeparator:(ORK_NULLABLE NSString *)separator;

@end


/**
 * The ORKAnswerOption protocol defines brief option text for a option which can be included within ORK*ChoiceAnswerFormat.
 */
@protocol ORKAnswerOption <NSObject>

/**
 * Brief option text.
 */
- (NSString *)text;

/**
 * The value to be returned if this option is selected.
 *
 * Expected to be a scalar type serializable to JSON, e.g. NSNumber or NSString.
 * If no value is provided, the index of the option in the ORK*ChoiceAnswerFormat options list will be used.
 */
- (ORK_NULLABLE id)value;

@end

@protocol ORKScaleAnswerFormatProvider<NSObject>

- (ORK_NULLABLE NSNumber *)_minimumNumber;
- (ORK_NULLABLE NSNumber *)_maximumNumber;
- (ORK_NULLABLE NSNumber *)_defaultNumber;
- (ORK_NULLABLE NSString *)_localizedStringForNumber:(ORK_NULLABLE NSNumber *)number;
- (NSInteger)_numberOfSteps;
- (ORK_NULLABLE NSNumber *)_normalizedValueForNumber:(ORK_NULLABLE NSNumber *)number;

@end

@interface ORKScaleAnswerFormat() <ORKScaleAnswerFormatProvider>

@end

@interface ORKContinuousScaleAnswerFormat() <ORKScaleAnswerFormatProvider>

@end


@interface ORKTextChoice() <ORKAnswerOption>

@end

@interface ORKImageChoice() <ORKAnswerOption>

@end


@interface ORKTimeOfDayAnswerFormat ()

- (NSDate *)_pickerDefaultDate;

@end

@interface ORKDateAnswerFormat ()

- (NSDate *)_pickerDefaultDate;
- (ORK_NULLABLE NSDate *)_pickerMinimumDate;
- (ORK_NULLABLE NSDate *)_pickerMaximumDate;

- (NSCalendar *)_currentCalendar;

@end

@interface ORKTimeIntervalAnswerFormat ()

- (NSTimeInterval)_pickerDefaultDuration;

@end

@interface ORKTextAnswerFormat ()

@end

@interface ORKAnswerDefaultSource : NSObject

+ (instancetype)sourceWithHealthStore:(HKHealthStore *)healthStore;
- (instancetype)initWithHealthStore:(HKHealthStore *)healthStore NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly, ORK_NULLABLE) HKHealthStore *healthStore;

- (void)fetchDefaultValueForAnswerFormat:(ORK_NULLABLE ORKAnswerFormat *)answerFormat handler:(void(^)(id defaultValue, NSError *error))handler;

- (HKUnit *)defaultHealthKitUnitForAnswerFormat:(ORKAnswerFormat *)answerFormat;
- (void)updateHealthKitUnitForAnswerFormat:(ORKAnswerFormat *)answerFormat force:(BOOL)force;

@end

ORK_ASSUME_NONNULL_END

