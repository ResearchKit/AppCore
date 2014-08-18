//
//  RKEnvelopedData.h
//  Itasca
//
//  Created by John Earl on 7/9/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKErrors.h>


typedef enum
{
    /*
     * Packed bzip2 format: bzip2 compress of the following stream:
     *   Four-byte version indicator
     *   Four-byte header length
     *   <JSON header>
     *   1..N of:
     *     Four-byte data length
     *     <data blob>
     *
     * The JSON header content can be parsed to indicate how many data blobs
     * to expect.
     */
    RKDataArchiveFormatPackedBzip2 = 0,
    
    /*
     * Zip format archive.
     *    info.json - contains the header content. The "items" key contains
     *      an array with information about each of the other files that
     *      is included in the zip, including filename, mime type, and timestamp.
     *    1..N other files
     */
    RKDataArchiveFormatZip = 1,
    
    /*
     * MIME multipart, then bzip2 compressed
     *
     *
     */
    RKDataArchiveFormatMimeBzip2 = 2
} RKDataArchiveFormat;

@class RKItemIdentifier;
@class RKCMS;

/**
 * Helper for creating a zip archive containing one or more data files
 * and an "info.json" that indicates the item and study identifiers,
 * and identifies the task instance.
 *
 * Includes a method for wrapping the zip in a CMS envelope.
 *
 * Structured as a holder object with a method to construct the zip,
 * so that the actual packaging can be delayed and computed on a suitable
 * queue.
 */
@interface RKDataArchive : NSObject<NSCopying>

/**
 * @brief Designated initializer.
 *
 * @param itemIdentifier   Identifier of the step, task or passive data collection
 *      for which this data was collected
 * @param studyIdentifier  current study
 * @param taskInstanceUUID UUID of the specific instance of the task
 * @param extraMetadata    Extra metadata being produced
 */
- (instancetype)initWithItemIdentifier:(RKItemIdentifier *)itemIdentifier
                       studyIdentifier:(NSString *)studyIdentifier
                      taskInstanceUUID:(NSUUID *)taskInstanceUUID
                         extraMetadata:(NSDictionary*)extraMetadata;

/**
 * @brief Add a file to the archive
 *
 * @param data        The data to include in the archive
 * @param filename    The filename to use
 * @param contentType The content type of the data
 * @param timestamp   The last-modified time of the data
 */
- (void)addContentWithData:(NSData *)data
                  filename:(NSString *)filename
               contentType:(NSString *)contentType
                 timestamp:(NSDate *)timestamp;

/**
 * @brief Reset all the files that have been added (does not affect metadata)
 */
- (void)resetContent;

@property (copy) NSDictionary *extraMetadata;
@property (copy) NSString *studyIdentifier;

- (NSData *)archivedDataWithFormat:(RKDataArchiveFormat)format error:(NSError * __autoreleasing *)error;

@end
