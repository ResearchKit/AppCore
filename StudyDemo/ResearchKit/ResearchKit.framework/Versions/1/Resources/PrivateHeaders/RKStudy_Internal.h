//
//  RKStudy_Private.h
//  Itasca
//
//  Created by John Earl on 7/1/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/RKErrors.h>
#import <ResearchKit/RKStudyStore.h>
#import <ResearchKit/RKStudy.h>

@class RKUploadCollector;

// Expose setters for internal use
@interface RKStudy ()<NSSecureCoding>

-(instancetype)initWithStudyStore:(RKStudyStore*)studyStore studyIdentifier:(NSString*)studyIdentifier;

@property (weak) RKStudyStore *studyStore;

@property (copy) NSString *studyIdentifier;

@property (copy) NSUUID *subjectUUID;

@property (copy) NSDate *joinDate;

@property (getter=isParticipating) BOOL participating;

@property (strong) RKUploader *primaryUploader;

@property (copy) NSArray *uploaders;

@property (copy) NSArray *collectors;

@property (strong) RKUploadCollector *uploadCollector;

/**
 * Stop any in-progress data collection for the study (may allow pending
 * uploads to resume)
 */
-(void)stopCollectingData;

// Invalidates the study: stops all uploaders and stops collecting data
- (void)invalidateStudy;


// Try collecting data, but only if needed
- (void)tryCollectingDataIfNeeded;


- (BOOL)_collectionShouldBegin:(RKUploadCollector *)collector;
- (void)_collectionDidFinish:(RKUploadCollector *)collector;

@end



@interface RKStudy (RKUploader)

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
- (RKUploader*)addUploaderWithEndpoint:(NSURL *)endpoint identity:(NSData *)identity error:(NSError * __autoreleasing *)error;

/**
 * @brief Remove an uploader from the study.
 *
 */
- (BOOL)removeUploader:(RKUploader *)uploader  error:(NSError* __autoreleasing *)error;

/**
 * @brief Updates which is the primary uploader.
 */
- (BOOL)updatePrimaryUploader:(RKUploader *)uploader  error:(NSError* __autoreleasing *)error;


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


@end



