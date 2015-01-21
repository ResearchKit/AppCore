//
//  RKSTDataLogger.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKSTDefines.h>


typedef NS_ENUM(NSInteger, RKFileProtectionMode) {
    RKFileProtectionNone = 0,
    RKFileProtectionCompleteUntilFirstUserAuthentication,
    RKFileProtectionCompleteUnlessOpen,
    RKFileProtectionComplete
} RK_ENUM_AVAILABLE_IOS(8_3);

@class RKSTDataLogger;
@class HKUnit;

@protocol RKSTDataLoggerDelegate<NSObject>

/**
 * @brief Notifies when a log file rollover occurs.
 *
 * @param dataLogger
 * @param fileUrl URL of the newly renamed log file.
 */
- (void)dataLogger:(RKSTDataLogger *)dataLogger finishedLogFile:(NSURL *)fileUrl;

@optional
/**
 * @brief Notifies if the number of bytes of completed logs changes.
 *
 * @discussion If files are removed or added, or marked as uploaded or unmarked, a short
 * time later this delegate method will be called. Multiple directory changes
 * are rolled up into a single delegate callback.
 */
- (void)dataLoggerByteCountsDidChange:(RKSTDataLogger *)dataLogger;

@end


@class RKSTLogFormatter;

/**
 * @brief An RKSTDataLogger manages one "log" as a set of files in a directory.
 *
 * @discussion The current log file is at <directory>/<logName>.
 * Historic log files are at <directory>/<logName>-<timestamp>[-<count>]
 * where timestamp is of the form YYYYMMddHHmmss (Zulu) and indicates the time
 * the log finished (was rolled over). If more than one roll-over occurs within
 * one second, then additional log files may be created with increasing <count>.
 *
 * The user is responsible for managing the historic log files, but the RKSTDataLogger
 * provides tools for enumerating them (in sorted order).
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTDataLogger : NSObject

/**
 * @brief Convenience for a data logger with an RKSTJSONLogFormatter.
 *
 * @param url The URL of the directory in which to place log files
 * @param logName the prefix on the log file name. Should be an ASCII string,
 *   excluding "-", which is used as a separator in the log naming scheme.
 * @param delegate
 */
+ (RKSTDataLogger *)JSONDataLoggerWithDirectory:(NSURL *)url logName:(NSString *)logName delegate:(id<RKSTDataLoggerDelegate>)delegate;

- (instancetype)initWithDirectory:(NSURL *)url logName:(NSString *)logName formatter:(RKSTLogFormatter *)formatter delegate:(id<RKSTDataLoggerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@property (weak) id<RKSTDataLoggerDelegate> delegate;

@property (strong, readonly) RKSTLogFormatter *logFormatter;

/// If current log reaches this size, it is automatically rolled over
@property size_t maximumCurrentLogFileSize;

/// If current log file has been active this long, it is rolled over
@property NSTimeInterval maximumCurrentLogFileLifetime;

/// Number of bytes of log not marked uploaded, excluding the current file. Lazily updated.
@property unsigned long long pendingBytes;

/// Number of bytes of log marked uploaded. Lazily updated.
@property unsigned long long uploadedBytes;

/// Set the file protection mode to use for newly created files.
@property (assign) RKFileProtectionMode fileProtectionMode;

/// The prefix on the log file names
@property (copy, readonly) NSString *logName;

/// Force roll-over now.
- (void)finishCurrentLog;

/// The current log file's location
- (NSURL *)currentLogFileURL;

/**
 * @brief Enumerate URLs of completed log files, sorted oldest first
 *
 * @discussion Takes a snapshot of the current directory's relevant files, sorts them,
 * and then enumerates. Accordingly if changes are being made to the filesystem other
 * than through this object, errors may arise.
 */
- (BOOL)enumerateLogs:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error;

/// Enumerate URLs of completed log files not yet marked uploaded, sorted oldest first
- (BOOL)enumerateLogsNeedingUpload:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error;

/// Enumerate URLs of completed log files not yet marked uploaded, sorted oldest first
- (BOOL)enumerateLogsAlreadyUploaded:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error;

/**
 * @brief Appends an object to the log file, which will be formatted with logFormatter.
 * 
 * @discussion The default log formatter expects NSData; ask the logFormatter if it
 * canAcceptLogObjectOfClass: to determine if it will accept this object.
 *
 * Note that the current log file is created and opened lazily when a request to
 * log data is made. If an attempt is made to log data and there is no access due
 * to file protection, the log is immediately rolled over and a new file created.
 *
 * @param object Should be an object of a class that is accepted by the logFormatter.
 */
- (BOOL)append:(id)object error:(NSError * __autoreleasing *)error;

/**
 * @brief Appends multiple objects to the log file
 *
 * @discussion Formats and appends all the objects at once. May have efficiency
 * and atomicity gains for error handling, compared to multiple calls to append:
 *
 * @param objects Array of objects of a class that is accepted by the logFormatter.
 */
- (BOOL)appendObjects:(NSArray *)objects error:(NSError * __autoreleasing *)error;

/// Check whether a file has been marked uploaded.
- (BOOL)isFileUploadedAtURL:(NSURL *)url;

/**
 * @brief Mark or unmark a file uploaded
 *
 * @discussion Marks a file uploaded using an extended attribute on the filesystem.
 * This is intended for book-keeping use only, to track which files have already
 * been attached to a pending upload. When the upload is sufficiently "complete",
 * the file should be removed.
 */
- (BOOL)markFileUploaded:(BOOL)uploaded atURL:(NSURL *)url error:(NSError * __autoreleasing *)error;

/**
 * @brief Remove files, but only if they are marked uploaded.
 *
 * @discussion If a file is in the list, but is no longer marked uploaded, the file
 * is not removed. This permits unmarking files selectively if they could not be added
 * to the archive, then calling -removeUploadedFiles:withError: to remove only
 * the ones that are still marked uploaded.
 */
- (BOOL)removeUploadedFiles:(NSArray *)fileURLs withError:(NSError * __autoreleasing *)error;

/**
 * @brief Remove all files managed by this logger (i.e. with the logName prefix).
 *
 */
- (BOOL)removeAllFilesWithError:(NSError * __autoreleasing *)error;


@end

/**
 * @brief Base (default) log formatter.
 
 * @discussion A log formatter is used by a data logger to format objects
 * for output to the log, and to begin a new log file and end an existing log file.
 * RKSTLogFormatter accepts NSData and has neither a header nor a footer.
 *
 * The log formatter should ensure that the log is always in a valid state, so that
 * even if the app is killed, the log is still readable.
 */
@interface RKSTLogFormatter : NSObject

- (BOOL)canAcceptLogObjectOfClass:(Class)c;
- (BOOL)canAcceptLogObject:(id)object;

- (BOOL)beginLogWithFileHandle:(NSFileHandle *)fileHandle error:(NSError * __autoreleasing *)error;
- (BOOL)appendObject:(id)object fileHandle:(NSFileHandle *)fileHandle error:(NSError * __autoreleasing *)error;
- (BOOL)appendObjects:(NSArray *)objects fileHandle:(NSFileHandle *)fileHandle error:(NSError * __autoreleasing *)error;

@end

/**
 * @brief Log formatter for JSON output.
 *
 * @discussion Accepts NSDictionary. The JSON output is a dictionary with one key, "items",
 * with contains the array of logged items. The log itself does not contain
 * any timestamp information, so items themselves should include such fields
 * if desired.
 *
 * In addition to NSDictionary, also accepts CMMotionActivity and HKSample, converting
 * these to a dictionary before output.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTJSONLogFormatter : RKSTLogFormatter

@end


@class RKSTJSONDataLogger;
@class RKSTDataLoggerManager;


RK_CLASS_AVAILABLE_IOS(8_3)
@protocol RKSTDataLoggerManagerDelegate <NSObject>

/**
 * @brief The total size of files that are not marked uploaded, has reached a threshold.
 */
- (void)dataLoggerManager:(RKSTDataLoggerManager*)dataLogger pendingUploadBytesReachedThreshold:(unsigned long long)pendingUploadBytes;

/**
 * @brief The total size of files managed by any of the loggers has reached a threshold.
 */
- (void)dataLoggerManager:(RKSTDataLoggerManager*)dataLogger totalBytesReachedThreshold:(unsigned long long)totalBytes;

@end

/**
 * @brief Manager for a set of RKSTDataLogger's
 *
 * @discussion This manager can be used to organize the RKSTDataLogger logs in a directory,
 * and keep track of the total number of bytes stored on disk by each logger. The
 * delegate can be informed if either the number of bytes pending upload, or the total
 * number of bytes, exceeds configurable thresholds.
 *
 * The configuration of the loggers and their thresholds is persisted in a
 * configuration file in the log directory.
 *
 * If the number of bytes pending exceeds the threshold, the natural action is to
 * upload them. A block-based enumeration is provided for enumerating all the logs
 * pending upload. Use -enumerateLogsNeedingUpload:error: , and when a log has been
 * processed for upload, mark it uploaded using the logger.
 *
 * When the upload succeeds (or at least is successfully queued), the uploaded files
 * can be removed (across all the loggers) with -removeUploadedFiles:error:
 *
 * If the total bytes exceeds the threshold, the natural action is to remove log
 * files that have been marked uploaded, and then remove old log files until the
 * threshold is no longer exceeded. Use -removeOldAndUploadedLogsToThreshold:error:
 *
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTDataLoggerManager : NSObject<RKSTDataLoggerDelegate>

- (instancetype)initWithDirectory:(NSURL *)directory delegate:(id<RKSTDataLoggerManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@property (weak) id<RKSTDataLoggerManagerDelegate> delegate;

/// Threshold for delegate callback for total bytes not marked uploaded.
@property unsigned long long pendingUploadBytesThreshold;

/// Threshold for delegate callback for total bytes of completed logs.
@property unsigned long long totalBytesThreshold;

@property unsigned long long pendingUploadBytes;
@property unsigned long long totalBytes;

/// Add a data logger with a JSON log format, in the directory.
- (RKSTDataLogger *)addJSONDataLoggerForLogName:(NSString *)logName;

/// Add a data logger with a particular log formatter, in the directory.
- (RKSTDataLogger *)addDataLoggerForLogName:(NSString *)logName formatter:(RKSTLogFormatter *)formatter;

/// Retrieve data logger for specified log name.
- (RKSTDataLogger *)dataLoggerForLogName:(NSString *)logName;

/// Remove a data logger.
- (void)removeDataLogger:(RKSTDataLogger *)logger;

/// Return the set of log names of data loggers managed by this object.
- (NSArray *)logNames;

/**
 * @brief Enumerate all the logs needing upload, across all data loggers, sorted oldest first.
 *
 * @discussion Fetches all the data loggers' logs needing upload, then sorts them
 * oldest first.
 */
- (BOOL)enumerateLogsNeedingUpload:(void (^)(RKSTDataLogger *dataLogger, NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error;

/**
 * @brief Unmark the set of uploaded files
 * @discussion Indicate that these files should no longer be marked uploaded (say, because
 * the upload did not succeed).
 */
- (BOOL)unmarkUploadedFiles:(NSArray *)fileURLs error:(NSError *__autoreleasing *)error;

/**
 * @brief Remove a set of uploaded files
 * @discussion Analogous to similar method on RKSTDataLogger, but accepts an array of files
 * which may relate to any of the data loggers. It is an error to pass a URL which would not
 * belong to one of the loggers managed by this manager.
 */
- (BOOL)removeUploadedFiles:(NSArray *)fileURLs error:(NSError * __autoreleasing *)error;

/**
 * @brief Remove old and uploaded logs to bring total bytes down to a threshold
 * @discussion Removes uploaded logs first; then removes the oldest log files, across
 * all of the data loggers, until the total usage falls below a threshold.
 */
- (BOOL)removeOldAndUploadedLogsToThreshold:(unsigned long long)bytes error:(NSError *__autoreleasing *)error;

@end



