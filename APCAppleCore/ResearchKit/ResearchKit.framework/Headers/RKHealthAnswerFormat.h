//
//  RKHealthAnswerFormat.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/RKAnswerFormat.h>
#import <HealthKit/HealthKit.h>



/**
 * @brief RKHealthAnswerFormat requests a numeric or characteristic value, depending on the HealthKit type requested.
 *
 * The actual UI used for collecting data with this answer format depends on the HealthKit type being collected.
 * The default value in the UI will be the most recent value pulled from HealthKit, if such a value exists.
 * When a step or item is presented using this answer format, authorization will be requested.
 *
 */
@interface RKHealthAnswerFormat : RKAnswerFormat

+ (instancetype)healthAnswerFormatWithQuantityType:(HKQuantityType *)quantityType unit:(HKUnit *)unit style:(RKNumericAnswerStyle)style;
+ (instancetype)healthAnswerFormatWithCharacteristicType:(HKCharacteristicType *)characteristicType;

@property (nonatomic, readonly, copy) HKQuantityType *quantityType;
@property (nonatomic, readonly, copy) HKCharacteristicType *characteristicType;
@property (nonatomic, readonly, strong) HKUnit *unit;
@property (nonatomic, readonly) RKNumericAnswerStyle numericAnswerStyle;


@end
