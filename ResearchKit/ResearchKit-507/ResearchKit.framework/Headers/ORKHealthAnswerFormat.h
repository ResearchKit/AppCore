//
//  ORKHealthAnswerFormat.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKAnswerFormat.h>
#import <HealthKit/HealthKit.h>


/**
 * @brief ORKHealthKitCharacteristicTypeAnswerFormat requests a characteristic value, depending on the HealthKit type requested.
 *
 * @discussion The actual UI used for collecting data with this answer format depends on the HealthKit type being collected.
 * The default value in the UI will be the most recent value pulled from HealthKit, if such a value exists.
 * When a step or item is presented using this answer format, authorization will be requested.
 *
 * @example Use this to let the user auto-fill their blood type or date of birth.
 */
ORK_CLASS_AVAILABLE
@interface ORKHealthKitCharacteristicTypeAnswerFormat : ORKAnswerFormat

+ (instancetype)answerFormatWithCharacteristicType:(HKCharacteristicType *)characteristicType;
- (instancetype)initWithCharacteristicType:(HKCharacteristicType *)characteristicType NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, copy) HKCharacteristicType *characteristicType;

@end

/**
 * @brief ORKHealthKitQuantityTypeAnswerFormat requests a quantity value, depending on the HealthKit type requested.
 *
 * @discussion The actual UI used for collecting data with this answer format depends on the HealthKit type being collected.
 * The default value in the UI will be the most recent value pulled from HealthKit, if such a value exists.
 * When a step or item is presented using this answer format, authorization will be requested.
 *
 * If a nil unit is supplied, the user's preferred unit will be pulled from HealthKit.
 *
 * @example Use this to let the user auto-fill their weight with the most recent sample from HealthKit.
 */
ORK_CLASS_AVAILABLE
@interface ORKHealthKitQuantityTypeAnswerFormat : ORKAnswerFormat

+ (instancetype)answerFormatWithQuantityType:(HKQuantityType *)quantityType unit:(HKUnit *)unit style:(ORKNumericAnswerStyle)style;
- (instancetype)initWithQuantityType:(HKQuantityType *)quantityType unit:(HKUnit *)unit style:(ORKNumericAnswerStyle)style NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, copy) HKQuantityType *quantityType;
@property (nonatomic, readonly, strong) HKUnit *unit;
@property (nonatomic, readonly) ORKNumericAnswerStyle numericAnswerStyle;


@end

