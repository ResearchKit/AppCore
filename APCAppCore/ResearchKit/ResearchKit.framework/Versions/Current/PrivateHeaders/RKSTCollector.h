//
//  RKSTCollector.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <ResearchKit/RKSTErrors.h>
#import <ResearchKit/RKSTDefines.h>

@class RKSTStudy;
@class RKSTCollector;
@class RKSTHealthCollector;
@class RKSTMotionActivityCollector;

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTCollector : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief identifier to be provided to an uploader.
 *
 */
@property (copy, readonly) NSString *identifier;


/**
 * @brief Serialization helper that produces serialized output.
 *
 * Subclasses should implement to provide a default serialization for upload.
 */
- (NSData *)serializedDataForObjects:(NSArray *)objects;

/**
 * @brief Serialization helper that produces objects suitable for serialization to JSON.
 *
 * Subclasses should implement to provide a default JSON serialization for upload.
 * Called by -serializedDataForObjects:
 */
- (NSArray *)serializableObjectsForObjects:(NSArray *)objects;

@end


RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTHealthCollector : RKSTCollector

@property (copy, readonly) HKSampleType *sampleType;
@property (copy, readonly) HKUnit *unit;
@property (copy, readonly) NSDate *startDate;

// Last anchor already seen
@property (copy, readonly) NSNumber *lastAnchor;


@end

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTHealthCorrelationCollector : RKSTCollector

@property (copy, readonly) HKCorrelationType *correlationType;
@property (copy, readonly) NSArray *sampleTypes;
@property (copy, readonly) NSArray *units;

@property (copy, readonly) NSDate *startDate;

@property (copy, readonly) NSNumber *lastAnchor;

@end



RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTMotionActivityCollector : RKSTCollector

@property (copy, readonly) NSDate *startDate;

// Last date already seen
@property (copy, readonly) NSDate *lastDate;


@end




