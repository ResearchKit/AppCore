//
//  RKDataArchive.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKErrors.h>


@class RKItemIdentifier;
@class RKCMS;
@class RKDataLoggerManager;

/**
 * Helper for creating a zip archive containing one or more data files
 * and an "info.json" that indicates the item and study identifiers,
 * and identifies the task instance.
 *
 * The zip is created in a temporary file on the file system. As files are added,
 * they are added directly to the zip. When the archive data or archive URL
 * are requested, the metadata is also written out and the zip is closed.
 */
@interface RKDataArchive : NSObject

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
                         extraMetadata:(NSDictionary *)extraMetadata
                        fileProtection:(NSString *)fileProtection;

/**
 * @brief Add data to the archive
 *
 * @param data        The data to include in the archive
 * @param filename    The filename to use
 * @param contentType The content type of the data
 * @param timestamp   The last-modified time of the data
 * @param error
 * @return YES on success, NO on failure. If there is a failure,
 *   the entire archive is reset.
 */
- (BOOL)addContentWithData:(NSData *)data
                  filename:(NSString *)filename
               contentType:(NSString *)contentType
                 timestamp:(NSDate *)timestamp
                     error:(NSError * __autoreleasing *)error;

/**
 * @brief Add file to the archive
 *
 * @param url         The URL to find the file
 * @param contentType The content type of the data
 * @param error
 * @return YES on success, NO on failure. If there is a failure,
 *   the entire archive is reset.
 */
- (BOOL)addFileWithURL:(NSURL *)url
           contentType:(NSString *)contentType
                 error:(NSError * __autoreleasing *)error;

/**
 * @brief Reset all the files that have been added (does not affect metadata)
 *
 * @discussion Adding a file to an RKDataArchive, or requesting archive data or
 * an archive URL, creates a temporary file on disk. This method will delete that
 * file, if it exists, and should be called to clean up a partially used
 * archiver or if the archive file is no longer needed.
 */
- (void)resetContent;

@property (copy) NSDictionary *extraMetadata;
@property (copy) NSString *studyIdentifier;
@property (copy) RKItemIdentifier *itemIdentifier;
@property (copy) NSUUID *taskInstanceUUID;

@property (readonly) unsigned long long totalArchivedBytes;

/**
 * @brief Return a zip archive of the data.
 *
 * @discussion Once this method is called, further calls to add data
 * or files, or change properties that should be serialized, will
 * throw an exception.
 */
- (NSData *)archiveDataWithError:(NSError * __autoreleasing *)error;

/**
 * @brief Return the URL of a zip archive of the data.
 *
 * @discussion Once this method is called, further calls to add data
 * or files, or change properties that should be serialized, will
 * throw an exception.
 */
- (NSURL *)archiveURLWithError:(NSError * __autoreleasing *)error;

/*
 * @brief Return the data for the archive, encrypted using the specified certificate.
 *
 * @discussion Encrypts the zip archive using Cryptographic Message Syntax (CMS;
 * see RFC 5083), using the X.509 PEM certificate specified in identity. This
 * is provided to make it easier to keep archive data "encrypted at rest" while
 * using NSURLSession for background upload.
 *
 * @param identity X.509 PEM certificate for CMS encryption
 * @param error    Any error while producing the archive or encrypting it
 *
 * @return CMS encrypted zip archive, or nil on error.
 *
 */
- (NSData *)archiveDataEncryptedWithIdentity:(NSData *)identity error:(NSError * __autoreleasing *)error;

@end

@interface RKDataArchive (RKDataLoggerManager)

/*
 * @brief Creates an archive of files from a data logger manager.
 *
 * @discussion Enumerates the files pending upload from a data logger manager,
 * adding them to an archive until either there are no more files, the maximum
 * input bytes is reached, or we have added the maximum number of files. File
 * protection is supported on the archive during creation.
 *
 * @param manager        The data logger manager from which to grab files
 * @param itemIdentifier Identifier to use in the archive's index
 * @param studyIdentifier Study identifier to put in the archive's index
 * @param fileProtection Level of file protection to use. Recommend
 *   NSFileProtectionCompleteUnlessOpen or NSFileProtectionCompleteUntilFirstUserAuthentication
 * @param maxBytes       Maximum number of uncompressed bytes to add to the archive
 * @param maxFiles       Maximum number of files to add to the archive
 * @param pendingFiles   OUT array containing the URLs of the files that are in the archive
 * @param error          OUT error, if any.
 *
 * @return URL of resulting archive file, or nil on error.
 *
 */
+ (NSURL *)makeArchiveFromDataLoggerManager:(RKDataLoggerManager *)manager
                             itemIdentifier:(RKItemIdentifier *)itemIdentifier
                            studyIdentifier:(NSString *)studyIdentifier
                             fileProtection:(NSString *)fileProtection
                          maximumInputBytes:(unsigned long long)maxBytes
                               maximumFiles:(NSInteger)maxFiles
                               pendingFiles:(NSArray * __autoreleasing *)pendingFiles
                                      error:(NSError * __autoreleasing *)error;

/*
 * @brief Creates an archive of files from a data logger manager.
 *
 * @discussion Enumerates the files pending upload from a data logger manager,
 * adding them to an archive until either there are no more files, the maximum
 * input bytes is reached, or we have added the maximum number of files. File
 * protection is supported on the archive during creation.
 *
 * A temporary archive file is created during this process, which is deleted
 * before returning.
 *
 * @param manager        The data logger manager from which to grab files
 * @param itemIdentifier Identifier to use in the archive's index
 * @param studyIdentifier Study identifier to put in the archive's index
 * @param fileProtection Level of file protection to use. Recommend
 *   NSFileProtectionCompleteUntilFirstUserAuthentication
 * @param maxBytes       Maximum number of uncompressed bytes to add to the archive
 * @param maxFiles       Maximum number of files to add to the archive
 * @param identity       X.509 PEM certificate for CMS encryption.
 * @param pendingFiles   OUT array containing the URLs of the files that are in the archive
 * @param error          OUT error, if any.
 *
 * @return CMS encrypted zip archive, or nil on error.
 *
 */
+ (NSData *)makeEncryptedArchiveFromDataLoggerManager:(RKDataLoggerManager *)manager
                                       itemIdentifier:(RKItemIdentifier *)itemIdentifier
                                      studyIdentifier:(NSString *)studyIdentifier
                                       fileProtection:(NSString *)fileProtection
                                    maximumInputBytes:(unsigned long long)maxBytes
                                         maximumFiles:(NSInteger)maxFiles
                                             identity:(NSData *)identity
                                         pendingFiles:(NSArray * __autoreleasing *)pendingFiles
                                                error:(NSError * __autoreleasing *)error;

@end
