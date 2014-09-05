//
//  RKStudy.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <ResearchKit/RKErrors.h>
#import <ResearchKit/RKDataArchive.h>




@class RKUploader;
@class RKCollector;
@class RKHealthCollector;
@class RKMotionActivityCollector;
@class RKItemIdentifier;
@class RKStudy;

/**
 * @brief Study delegate
 *
 * @discussion Each study can have a delegate. The delegate should be attached
 * before calling -resume to enable data collection. These callbacks will arrive
 * on an arbitrary queue.
 *
 */
@protocol RKStudyDelegate <NSObject>

@optional

/**
 * @brief Reports health data collection
 * @discussion Will be called on an arbitrary queue.
 * @return Return NO if the collected objects could not be consumed (will stop further collection)
 */
- (BOOL)study:(RKStudy *)study healthCollector:(RKHealthCollector *)collector anchor:(NSNumber *)anchor didCollectObjects:(NSArray /* <HKSample> */ *)objects;

/**
 * @brief Reports activity data collection
 * @discussion Will be called on an arbitrary queue.
 * @return Return NO if the collected objects could not be consumed (will stop further collection)
 */
- (BOOL)study:(RKStudy *)study motionActivityCollector:(RKMotionActivityCollector *)collector startDate:(NSDate *)startDate didCollectObjects:(NSArray /* <CMMotionActivity> */ *)objects;

/*
 * @brief Collection is about to begin
 * @discussion Will be called on an arbitrary queue.
 * @return YES if it is ok to begin collecting data
 */
- (BOOL)passiveCollectionShouldBeginForStudy:(RKStudy *)study;

/*
 * @brief Collection has finished
 * @discussion Will be called on an arbitrary queue.
 */
- (void)passiveCollectionDidFinishForStudy:(RKStudy *)study;

@end


/**
 * @brief Individual study
 *
 * A study object represents an individual study. Each study has one uploader
 * and zero or more background data collectors.
 *
 */
@interface RKStudy : NSObject

/**
 * @brief Delegate for receiving data collection and other information about the study.
 */
@property (weak) id<RKStudyDelegate> delegate;

/**
 * @brief The identifier of the study.
 *
 * Initialized when the study is created with RKStudyManager.
 */
@property (copy, readonly) NSString *studyIdentifier;

/**
 * @brief The unique identifier of the subject.
 *
 * Randomly generated when the subject first begins to participate.
 */
@property (copy, readonly) NSUUID *subjectUUID;

/**
 * @brief The most recent date that the subject joined the study.
 */
@property (copy, readonly) NSDate *joinDate;

/**
 * @brief Whether the subject is currently participating in the study.
 */
@property (getter=isParticipating, readonly) BOOL participating;


/*!
 * @brief Changes the participation state of the study.
 *
 * @param participating YES if the subject is participating in the study. NO, otherwise.
 *
 * @param joinDate The date at which the participant joined the study.
 *
 * @return YES on success
 */
- (BOOL)updateParticipating:(BOOL)participating withJoinDate:(NSDate *)joinDate  error:(NSError * __autoreleasing *)error;


@end



@interface RKStudy (RKCollector)

/**
 * @brief Array of any active RKCollector objects for this study.
 *
 * For HealthKit data, there will be one collector for each HealthKit type
 * being collected. Other types of data will typically have a single collector,
 * such as for Core Motion activity log information.
 *
 */
@property (copy, readonly) NSArray *collectors;

/**
 * @brief Add an RKHKCollector
 *
 * @param objectType HealthKit object type
 *
 * @param unit HealthKit unit into which data should be collected
 *
 * @param startDate Samples should be collected starting at this date
 */
- (RKHealthCollector *)addHealthCollectorWithSampleType:(HKSampleType *)sampleType unit:(HKUnit *)unit startDate:(NSDate *)startDate error:(NSError * __autoreleasing *)error;

/**
 * @brief Add an RKCMActivityCollector
 *
 * @param joinDateOffset Offset relative to join date when data collection should start
 *
 */
- (RKMotionActivityCollector *)addMotionActivityCollectorWithStartDate:(NSDate *)startDate error:(NSError* __autoreleasing *)error;

/**
 * @brief Remove the specified collector
 */
- (BOOL)removeCollector:(RKCollector *)collector error:(NSError* __autoreleasing *)error;



/**
 * @brief Trigger passive data collection and upload
 *
 * This method triggers running all the RKCollector collections associated with
 * the present study, if needed. All resulting uploads are queued up, and only
 * released for upload once the collection process is complete.
 *
 * If the uploader becomes full (too much data queued), then it will stop.
 *
 * If there is no uploader, data can be intercepted via a data collection block
 * on the RKCollector.
 *
 */
- (void)tryCollectingData;


@end


