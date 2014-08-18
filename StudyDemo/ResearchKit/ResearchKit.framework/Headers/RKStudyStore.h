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

@protocol RKStudyStoreDelegate;

/**
 * @brief Manager for a study database
 *
 * The study manager is an interface to a study database which can contain
 * multiple studies.
 *
 * The application should instantiate a study
 * manager, check if a study with the desired ID is present, and if not, 
 * add and configure it.
 *
 * In the initial release, the application is responsible for triggering
 * data collection/upload at an appropriate time, for each study that is
 * active. To trigger data collection, walk the studies array and call
 * -tryCollectingData on each study.
 *
 */
@interface RKStudyStore : NSObject

/**
 * @brief Designated initializer
 *
 * @param identifier Identifier for state restoration. This also identifies
 *    the study database. Although this identifier is local to the app,
 *    a reverse-domain identifier is recommended.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier delegate:(id<RKStudyStoreDelegate>)delegate;

@property (weak, readonly) id<RKStudyStoreDelegate> delegate;

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
- (RKStudy*)studyWithIdentifier:(NSString*)identifier;

/**
 * @brief Creates a new study with the specified ID
 *
 * @param identifier The identifier for this study
 * @return newly created study object
 */
- (RKStudy*)addStudyWithIdentifier:(NSString *)identifier error:(NSError* __autoreleasing *)error;

/**
 * @brief Removes the specified study.
 *
 * @return YES on success
 */
- (BOOL)removeStudy:(RKStudy *)study error:(NSError* __autoreleasing *)error;

/**
 * @brief Handles NSURLSession events
 *
 * @return YES if the study store has taken responsibility for the handler
 */
-(BOOL)handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler;

@end


/*!
 *  @const  RKStudyManagerRestoredCollectorsKey
 *
 *  @discussion An NSArray of <code>RKCollector</code> objects containing all collectors that were pending at the time the
 *				application was terminated by the system. When possible, all known information for each collector will be restored.
 *
 *  @see		studyManager:willRestoreState:
 *
 */
extern NSString * const RKStudyStoreRestoredCollectorsKey;

@protocol RKStudyStoreDelegate<NSObject>

@optional
/*!
 *  @method centralManager:willRestoreState:
 *
 *  @param studyStore      The study store providing this information.
 *  @param dict			A dictionary containing information about <i>studyManager</i> that was preserved by the system at the time the app was terminated.
 *
 *  @discussion			For apps that opt-in to state preservation and restoration, this is the first method invoked when your app is relaunched into
 *						the background to complete some Research-related task. Use this method to synchronize your app's state with the state of the
 *						RKStudyManager. This is guaranteed to be called before any data collection blocks would fire for newly available data.
 *
 *  @seealso            RKStudyStoreRestoredCollectorsKey
 *
 */
- (void)studyStore:(RKStudyStore *)studyStore willRestoreState:(NSDictionary *)dict;

/*!
 * @brief Reports an error observed on an uploader
 *
 * @param studyStore The current study store
 * @param uploader   The uploader where the error was detected
 * @param error      The error that was received
 *
 * Typical error conditions include not being able to write out the file that needs
 * upload, or an unrecoverable upload.
 */
- (void)studyStore:(RKStudyStore *)studyStore uploader:(RKUploader *)uploader didReceiveError:(NSError *)error;

/*!
 * @brief Provides an opportunity to customize uploaders' session configuration
 *
 * @param studyStore The current study store
 * @param uploader   The uploader for which the session is being created
 * @param configuration The configuration which will be used to resume the session
 *
 */
- (void)studyStore:(RKStudyStore *)studyStore uploader:(RKUploader *)uploader willStartSessionWithConfiguration:(NSURLSessionConfiguration *)configuration;

/*!
 * @brief Provides an opportunity to respond to auth challenges for uploaders
 *
 * @param studyStore The current study store
 * @param uploader   The uploader for which the session is being created
 * @param session    The NSURLSession being used by the uploader
 * @param task       The current upload task for which auth is being requested
 * @param challenge  The authentication challenge reported by the NSURLSession
 * @param completionHandler
 *
 * If this method is not implemented, the uploader will apply the default auth response.
 */
- (void)studyStore:(RKStudyStore *)studyStore uploader:(RKUploader *)uploader URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler;


/*!
 * @brief Provides an opportunity to respond to auth challenges for uploaders
 *
 * @param studyStore The current study store
 * @param uploader   The uploader for which the session is being created
 * @param session    The NSURLSession being used by the uploader
 * @param challenge  The authentication challenge reported by the NSURLSession
 * @param completionHandler
 *
 * If this method is not implemented, the uploader will apply the default auth response.
 */
- (void)studyStore:(RKStudyStore *)studyStore uploader:(RKUploader *)uploader URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler;

@end

