//
//  RKUploader.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKStudy.h>
#import <ResearchKit/RKErrors.h>

@class RKStudy;
@class RKItemIdentifier;
@class RKDataArchive;

/**
 * Uploader.
 *
 * Defines the endpoint, encryption identity, and other connection parameters
 * to use for upload.
 *
 */

@interface RKUploader : NSObject

- (instancetype)init NS_UNAVAILABLE;


/**
 * @brief Study for which data will be uploaded.
 *
 */
@property (copy, readonly) NSString *studyIdentifier;

/**
 * @brief Subject for which data will be uploaded.
 *
 */
@property (copy, readonly) NSUUID *subjectUUID;

/**
 * @brief Endpoint for uploaded blobs.
 *
 */
@property (copy, readonly) NSURL *endpoint;

/**
 * @brief PEM identity for the receiver of data for this study.
 *
 */
@property (copy, readonly) NSData *identity;

/*!
 * @brief Specifies whether this uploader is the primary uploader.
 */
@property (getter=isPrimary, readonly) BOOL primary;

/**
 * @brief Returns TRUE if the queue is full.
 */
- (BOOL)isQueueFull;

/**
 * @brief Queues data for sending using the RKUploader.
 *
 * This method can be called from any thread or queue.
 *
 * @param data The data to send.
 * @param itemId An identifier for the task, step, or collector the data was collected for.
 * @param taskInstanceUUID UUID identifying the task instance for which this item was collected. Can be nil.
 * @param mimeType The MIME type of the collected data
 * @param error Indication of any error queueing the data to send
 *
 * @return TRUE if the data has been successfully queued to send. Actual
 *   receipt of the data is not guaranteed.
 *
 */
- (BOOL)queueData:(NSData *)data
  itemIdentifier:(RKItemIdentifier *)itemIdentifier
taskInstanceUUID:(NSUUID*)taskInstanceUUID
        mimeType:(NSString *)mimeType
           error:(NSError * __autoreleasing *)errorOut;

/**
 * @brief Send the data referred to by the archiver.
 *
 * This method can be called from any thread or queue.
 *
 * @param archiver Archiver which can generate a suitable archive of the data to send. The archiver
 *     will be copied.
 * @param error Indication of ny error queueing the data to send
 *
 * @return TRUE if the data has been successfully queued to send.
 *
 */
- (BOOL)queueArchive:(RKDataArchive *)archive error:(NSError * __autoreleasing *)errorOut;


@end
