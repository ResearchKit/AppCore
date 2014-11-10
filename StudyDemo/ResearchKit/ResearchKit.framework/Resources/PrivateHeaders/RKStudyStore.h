//
//  RKStudyStore.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKErrors.h>

@class RKStudy;
@class RKUploader;
@protocol RKStudyDelegate;


/**
 * @brief Storage for a study database
 *
 * The study store is an interface to a study database which can contain
 * multiple studies.
 *
 * The application should instantiate a study
 * manager, check if a study with the desired ID is present, and if not, 
 * add and configure it.
 *
 * Automatic data collection begins once
 *
 */
@interface RKStudyStore : NSObject

/**
 * @brief Access to the shared study store.
 *
 * @discussion The shared study store is initialized on the first call to this
 * method. Once its configuration is updated, perhaps including attaching study
 * delegates, call -resume to resume any automated data collection.
 */
+ (RKStudyStore *)sharedStudyStore;


/**
 * @brief Array of RKStudy objects that represents the studies associated with the study manager.
 *
 * May return nil if studies are not available (e.g. if the screen is locked and data protection enabled).
 * If studies have been loaded, returns an empty array.
 */
@property (copy, readonly) NSArray *studies;

/**
 * @brief Retrieves a study with a particular identifier
 *
 * @param identifier The identifier for this study
 *
 * @return study object, or nil if no matching study found
 */
- (RKStudy *)studyWithIdentifier:(NSString *)identifier;

/**
 * @brief Creates a new study with the specified ID
 *
 * @param identifier The identifier for this study
 * @param delegate Delegate for the new study
 * @return newly created study object
 */
- (RKStudy *)addStudyWithIdentifier:(NSString *)identifier delegate:(id<RKStudyDelegate>)delegate error:(NSError * __autoreleasing *)error;

/**
 * @brief Removes the specified study.
 *
 * @return YES on success
 */
- (BOOL)removeStudy:(RKStudy *)study error:(NSError * __autoreleasing *)error;


/**
 * @brief Begin health and passive data collection
 *
 * @discussion This method should be called after initializing the store and
 * attaching study delegates as desired.
 *
 * @return NO if collection could not be enabled (usually because studies could
 * not be loaded - if the screen is locked).
 */
- (BOOL)resume;

@end


