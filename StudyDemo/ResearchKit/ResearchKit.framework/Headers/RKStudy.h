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

@protocol RKStudyCollectorDelegate;

/**
 * @brief Individual study
 *
 * A study object represents an individual study. Each study has one uploader
 * and zero or more background data collectors.
 *
 */
@interface RKStudy : NSObject

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
- (BOOL)updateParticipating:(BOOL)participating withJoinDate:(NSDate *)joinDate  error:(NSError* __autoreleasing *)error;


@end



@interface RKStudy(RKUploader)

/**
 * @brief The primary uploader. This will be the default uploader for newly added collectors.
 */
@property (strong, readonly) RKUploader *primaryUploader;

/**
 * @brief The uploaders for this study.
 *
 */
@property (copy, readonly) NSArray *uploaders;

/**
 * @brief Add an uploader to the study with the specified endpoint.
 *
 * If it is the first uploader added, it will be marked primary by default.
 *
 * @param endpoint the URL where uploaded data should be sent
 * @param identity X.509 PEM certificate for encrypting data using Cryptographic
 *      Message Syntax before sending. If nil, CMS is not used.
 * @param archiveFormat The format of archive to use for upload.
 *
 */
- (RKUploader*)addUploaderWithEndpoint:(NSURL *)endpoint identity:(NSData *)identity archiveFormat:(RKDataArchiveFormat)archiveFormat error:(NSError* __autoreleasing *)error;

/**
 * @brief Remove an uploader from the study.
 *
 */
- (BOOL)removeUploader:(RKUploader *)uploader  error:(NSError* __autoreleasing *)error;

/**
 * @brief Updates which is the primary uploader.
 */
- (BOOL)updatePrimaryUploader:(RKUploader *)uploader  error:(NSError* __autoreleasing *)error;

@end



@interface RKStudy(RKCollector)

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
- (RKHealthCollector *)addHealthCollectorWithSampleType:(HKSampleType*)sampleType unit:(HKUnit *)unit startDate:(NSDate *)startDate error:(NSError* __autoreleasing *)error;

/**
 * @brief Add an RKCMActivityCollector
 *
 * @param joinDateOffset Offset relative to join date when data collection should start
 *
 */
- (RKMotionActivityCollector *)addMotionActivityCollectorWithStartDate:(NSDate *)startDate error:(NSError* __autoreleasing *)error;

/**
 * @brief Assigns a collector to an uploader.
 *
 * If a collector is assigned to an uploader, then data produced by the collector will
 * be automatically sent to the uploader, and the collector will only collect data if
 * the uploader is ready to receive it.
 *
 * If a collector is added while there is a primary uploader, that uploader will
 * automatically be assigned to the collector.
 *
 * @param collector The collector that should be assigned to an uploader.
 *
 * @param uploader The uploader. If nil, the collector will be removed from any uploader specified.
 */
- (BOOL)assignCollector:(RKCollector *)collector toUploader:(RKUploader *)uploader error:(NSError* __autoreleasing *)error;

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


