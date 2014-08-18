//
//  RKCollector.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <ResearchKit/RKErrors.h>

@class RKStudy;
@class RKUploader;
@class RKCollector;
@class RKHealthCollector;
@class RKMotionActivityCollector;
@class RKItemIdentifier;

typedef void (^RKHealthCollectorDataHandler)(RKHealthCollector *collector, NSNumber *anchor, NSArray *objects);

typedef void (^RKMotionActivityCollectorDataHandler)(RKMotionActivityCollector *collector, NSDate *startDate, NSArray *objects);

@interface RKCollector : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief itemIdentifier to be provided to an uploader.
 *
 */
@property (copy, readonly) RKItemIdentifier *itemIdentifier;

/**
 * @brief uploader, if any, to which data should be sent when collected.
 *
 */
@property (strong, readonly) RKUploader *uploader;

/**
 * @brief Serialization helper that produces serialized output.
 *
 * Subclasses should implement to provide a default serialization for upload.
 */
-(NSData*)serializedDataForObjects:(NSArray*)objects;

@end


@interface RKHealthCollector : RKCollector

@property (copy, readonly) HKSampleType *sampleType;
@property (copy, readonly) HKUnit *unit;
@property (copy, readonly) NSDate *startDate;

// Last anchor already seen
@property (copy, readonly) NSNumber *lastAnchor;

/**
 * If set, the handler is called each time data is collected
 */
@property (copy) RKHealthCollectorDataHandler dataHandler;

@end



@interface RKMotionActivityCollector : RKCollector

@property (copy, readonly) NSDate *startDate;

// Last date already seen
@property (copy, readonly) NSDate *lastDate;

/**
 * If set, the handler is called each time data is collected.
 */
@property (copy) RKMotionActivityCollectorDataHandler dataHandler;

@end




