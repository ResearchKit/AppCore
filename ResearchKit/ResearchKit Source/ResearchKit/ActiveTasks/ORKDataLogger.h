/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import <Foundation/Foundation.h>
#import <ResearchKit/ORKDefines.h>

ORK_ASSUME_NONNULL_BEGIN

@class ORKDataLogger;
@class HKUnit;

/**
 The delegate for the `ORKDataLogger` can handle data being logged to disk.
 */
@protocol ORKDataLoggerDelegate<NSObject>

/**
 Notifies when a log file rollover occurs.
 
 @param dataLogger  The data logger providing the notification.
 @param fileUrl URL of the newly renamed log file.
 */
- (void)dataLogger:(ORKDataLogger *)dataLogger finishedLogFile:(NSURL *)fileUrl;

@optional
/**
 Notifies if the number of bytes of completed logs changes.
 
 If files are removed or added, or marked as uploaded or unmarked, a short
 time later this delegate method will be called. Multiple directory changes
 are rolled up into a single delegate callback.
 
 @param dataLogger  The data logger providing the notification.
 */
- (void)dataLoggerByteCountsDidChange:(ORKDataLogger *)dataLogger;

@end


@class ORKLogFormatter;

/**
 An `ORKDataLogger` manages one "log" as a set of files in a directory.
 
 The `ORKDataLogger` class is an internal component used by some `ORKRecorder`
 subclasses for writing data to disk during tasks.
 
 The current log file is at `directory/logName`.
 Historic log files are at `directory/logName-(timestamp)-(count)`
 where timestamp is of the form `YYYYMMddHHmmss` (Zulu) and indicates the time
 the log finished (was rolled over). If more than one roll-over occurs within
 one second, then additional log files may be created with increasing `count`.
 
 The user is responsible for managing the historic log files, but the ORKDataLogger
 provides tools for enumerating them (in sorted order).
 
 The data logger contains a concept of whether a file has been "uploaded", which
 is tracked via file attributes. This feature can facilitate a workflow where
 log files are archived and queued for upload before actually sending them to
 a server. When archived and ready for upload, they could be marked "uploaded"
 via the ORKDataLogger. When upload is complete and the data has been handed
 off downstream, the files can then be deleted. If upload fails, the "uploaded"
 files could have that flag cleared, to indicate that they should be included
 in the next archiving attempt.
 */
ORK_CLASS_AVAILABLE
@interface ORKDataLogger : NSObject

/**
 Convenience factory method for a data logger with an `ORKJSONLogFormatter`.
 
 @param url The URL of the directory in which to place log files
 @param logName the prefix on the log file name. Should be an ASCII string,
   excluding "-", which is used as a separator in the log naming scheme.
 @param delegate  The initial delegate. May be `nil`.
 */
+ (ORKDataLogger *)JSONDataLoggerWithDirectory:(NSURL *)url logName:(NSString *)logName delegate:(ORK_NULLABLE id<ORKDataLoggerDelegate>)delegate;


/**
 Convenience intializer.
 
 @param url         The URL of the directory in which to place log files
 @param logName     The prefix on the log file name. Should be an ASCII string,
                    excluding "-", which is used as a separator in the log naming scheme.
 @param formatter   The type of formatter to use for the log. For example, `ORKJSONLogFormatter`.
 @param delegate    The initial delegate. May be `nil`.
 */
- (instancetype)initWithDirectory:(NSURL *)url logName:(NSString *)logName formatter:(ORKLogFormatter *)formatter delegate:(ORK_NULLABLE id<ORKDataLoggerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/// The delegate to be notified when file sizes change or the log rolls over.
@property (weak, ORK_NULLABLE) id<ORKDataLoggerDelegate> delegate;

/// The log formatter being used.
@property (strong, readonly) ORKLogFormatter *logFormatter;

/**
 Maximum current log file size.
 
 If the current log reaches this size, it is automatically rolled over.
 */
@property size_t maximumCurrentLogFileSize;

/**
 Maximum current log file lifetime.
 
 If current log file has been active this long, it is rolled over.
 */
@property NSTimeInterval maximumCurrentLogFileLifetime;

/// The number of bytes of log not marked uploaded, excluding the current file. Lazily updated.
@property unsigned long long pendingBytes;

/// The number of bytes of log marked uploaded. Lazily updated.
@property unsigned long long uploadedBytes;

/// Sets the file protection mode to use for newly created files.
@property (assign) ORKFileProtectionMode fileProtectionMode;

/// The prefix on the log file names.
@property (copy, readonly) NSString *logName;

/// Forces a roll-over now.
- (void)finishCurrentLog;

/// The current log file's location.
- (NSURL *)currentLogFileURL;

/**
 Enumerates URLs of completed log files, sorted oldest first.
 
 Takes a snapshot of the current directory's relevant files, sorts them,
 and then enumerates. Accordingly if changes are being made to the filesystem other
 than through this object, errors may arise.
 
 @param block   The block to call during enumeration.
 @param error   Any error detected during the enumeration
 @return Returns `YES`, if the enumeration was successful. `NO`, otherwise.
 */
- (BOOL)enumerateLogs:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error;

/**
 Enumerates URLs of completed log files not yet marked uploaded,
 sorted oldest first.
 
 Takes a snapshot of the current directory's completed non-uploaded log files, sorts them,
 and then enumerates. Accordingly if changes are being made to the filesystem other
 than through this object, errors may arise.
 
 @param block   The block to call during enumeration.
 @param error   Any error detected during the enumeration
 @return Returns `YES`, if the enumeration was successful. `NO`, otherwise.
 */
- (BOOL)enumerateLogsNeedingUpload:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error;

/**
 Enumerates URLs of completed log files not already marked uploaded,
 sorted oldest first.
 
 Takes a snapshot of the current directory's completed "uploaded" log files, sorts them,
 and then enumerates. Accordingly if changes are being made to the filesystem other
 than through this object, errors may arise.
 
 @param block   The block to call during enumeration.
 @param error   Any error detected during the enumeration
 @return Returns `YES`, if the enumeration was successful. `NO`, otherwise.
 */
- (BOOL)enumerateLogsAlreadyUploaded:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error;

/**
 Appends an object to the log file, which will be formatted with logFormatter.
 
 The default log formatter expects NSData; ask the logFormatter if it
 canAcceptLogObjectOfClass: to determine if it will accept this object.
 
 Note that the current log file is created and opened lazily when a request to
 log data is made. If an attempt is made to log data and there is no access due
 to file protection, the log is immediately rolled over and a new file created.
 
 @param object Should be an object of a class that is accepted by the logFormatter.
 @param error  Error output, if the append fails.
 @return Returns `YES`, if appending succeeds. `NO`, otherwise.
 */
- (BOOL)append:(id)object error:(NSError * __autoreleasing *)error;

/**
 Appends multiple objects to the log file.
 
 Formats and appends all the objects at once. May have efficiency
 and atomicity gains for error handling, compared to multiple calls to append:
 
 @param objects Array of objects of a class that is accepted by the logFormatter.
 @param error  Error output, if the append fails.
 @return Returns `YES`, if appending succeeds. `NO`, otherwise.
 */
- (BOOL)appendObjects:(NSArray *)objects error:(NSError * __ORK_NULLABLE __autoreleasing *)error;

/**
 Checks whether a file has been marked uploaded.
 
 @param url     URL to check.
 @return Returns `YES`, if the "uploaded" attribute has been set on the file and the file exists.
         `NO`, otherwise.
 */
- (BOOL)isFileUploadedAtURL:(NSURL *)url;

/**
 Marks or unmarks a file as uploaded.
 
 Marks a file uploaded using an extended attribute on the filesystem.
 This is intended for book-keeping use only, to track which files have already
 been attached to a pending upload. When the upload is sufficiently "complete",
 the file should be removed.
 
 @param uploaded    Whether to mark the file uploaded or non-uploaded
 @param url         URL to mark.
 @param error       Error that occurred, if operation fails.
 @return Returns `YES`, if adding or removing the attribute succeeded. NO, otherwise.
 */
- (BOOL)markFileUploaded:(BOOL)uploaded atURL:(NSURL *)url error:(NSError * __ORK_NULLABLE __autoreleasing *)error;

/**
 Removes files, but only if they are marked uploaded.
 
 If a file is in the list, but is no longer marked uploaded, the file
 is not removed. This permits unmarking files selectively if they could not be added
 to the archive, then calling -removeUploadedFiles:withError: to remove only
 the ones that are still marked uploaded.
 
 @param fileURLs    The array of files that need to be removed
 @param error       Error that occurred, if operation fails.
 @return Returns `YES`, if removing the files succeeded. NO, otherwise.
 */
- (BOOL)removeUploadedFiles:(NSArray *)fileURLs withError:(NSError * __ORK_NULLABLE __autoreleasing *)error;

/**
 Removes all files managed by this logger (i.e., with the logName prefix).
 
 @param error       Error that occurred, if operation fails.
 @return Returns `YES`, if removing the files succeeded. NO, otherwise.
 */
- (BOOL)removeAllFilesWithError:(NSError *__ORK_NULLABLE __autoreleasing *)error;


@end

/**
 The `ORKLogFormatter` is the base (default) log formatter, which appends data
 blindly to a log file.
 
 A log formatter is used by a data logger to format objects
 for output to the log, and to begin a new log file and end an existing log file.
 ORKLogFormatter accepts NSData and has neither a header nor a footer.
 
 A log formatter should ensure that the log is always in a valid state, so that
 even if the app is killed, the log is still readable.
 */
@interface ORKLogFormatter : NSObject

/**
 Whether this log formatter can serialize this type of object.
 
 @param c       The class of object to serialize.
 @return Returns `YES`, if this log formatter can serialize this object class.
 */
- (BOOL)canAcceptLogObjectOfClass:(Class)c;


/**
 Whether this log formatter can serialize this type of object.
 
 @param object       The object to serialize.
 @return Returns `YES`, if this log formatter can serialize this object.
 */
- (BOOL)canAcceptLogObject:(id)object;

/**
 Begins a new log file on this filehandle.
 
 For example, may write a header or "opening" stanza of a new log file.
 
 @param fileHandle      File handle to which to write.
 @param error           Error output, on failure.
 @return Returns `YES`, if the write succeeds.
 */
- (BOOL)beginLogWithFileHandle:(NSFileHandle *)fileHandle error:(NSError * __ORK_NULLABLE __autoreleasing *)error;

/**
 Appends an object to the log file.
 
 @param object          Object to write.
 @param fileHandle      File handle to which to write.
 @param error           Error output, on failure.
 @return Returns `YES`, if the write succeeds.
 */
- (BOOL)appendObject:(id)object fileHandle:(NSFileHandle *)fileHandle error:(NSError * __ORK_NULLABLE __autoreleasing *)error;

/**
 Appends multiple objects to the log file.
 
 @param objects         Objects to write.
 @param fileHandle      File handle to which to write.
 @param error           Error output, on failure.
 @return Returns `YES`, if the write succeeds.
 */
- (BOOL)appendObjects:(NSArray *)objects fileHandle:(NSFileHandle *)fileHandle error:(NSError * __ORK_NULLABLE __autoreleasing *)error;

@end

/**
 The `ORKJSONLogFormatter` class is a log formatter for producing JSON output.
 
 The JSON log formatter accepts `NSDictionary` objects for serialization.
 The JSON output is a dictionary with one key, "items",
 with contains the array of logged items. The log itself does not contain
 any timestamp information, so items themselves should include such fields
 if desired.
 */
ORK_CLASS_AVAILABLE
@interface ORKJSONLogFormatter : ORKLogFormatter

@end


@class ORKJSONDataLogger;
@class ORKDataLoggerManager;

/**
 Implement the `ORKDataLoggerManagerDelegate` protocol to receive notifications
 when the data loggers managed by a `ORKDataLoggerManager` reach a certain threshold
 of file size.
 */

ORK_CLASS_AVAILABLE
@protocol ORKDataLoggerManagerDelegate <NSObject>

/**
 This method is called by the data logger manager when the total size of files
 that are not marked uploaded has reached a threshold.
 
 @param dataLoggerManager       The manager that produced the notification.
 @param pendingUploadBytes      The number of bytes managed by all the loggers, which
            have not yet been marked "uploaded".
 */
- (void)dataLoggerManager:(ORKDataLoggerManager *)dataLoggerManager pendingUploadBytesReachedThreshold:(unsigned long long)pendingUploadBytes;

/**
 This method is called by the data logger manager when the total size of files
 managed by any of the loggers has reached a threshold.
 
 @param dataLoggerManager       The manager that produced the notification.
 @param totalBytes              The total number of bytes of all files managed.
 */
- (void)dataLoggerManager:(ORKDataLoggerManager *)dataLoggerManager totalBytesReachedThreshold:(unsigned long long)totalBytes;

@end

/**
 The `ORKDataLoggerManager` class is a manager for multiple `ORKDataLogger` instances,
 which tracks the total size of log files produced and can notify its delegate
 when their size reaches configurable thresholds.
 
 The `ORKDataLoggerManager` class is an internal component used by some `ORKRecorder`
 subclasses for writing data to disk during tasks.
 
 This manager can be used to organize the `ORKDataLogger` logs in a directory,
 and keep track of the total number of bytes stored on disk by each logger. The
 delegate can be informed if either the number of bytes pending upload, or the total
 number of bytes, exceeds configurable thresholds.
 
 The configuration of the loggers and their thresholds is persisted in a
 configuration file in the log directory.
 
 If the number of bytes pending exceeds the threshold, the natural action is to
 upload them. A block-based enumeration is provided for enumerating all the logs
 pending upload. Use `enumerateLogsNeedingUpload:error:` , and when a log has been
 processed for upload, mark it uploaded using the logger.
 
 When the upload succeeds (or at least is successfully queued), the uploaded files
 can be removed (across all the loggers) with `removeUploadedFiles:error:`
 
 If the total bytes exceeds the threshold, the natural action is to remove log
 files that have been marked uploaded, and then remove old log files until the
 threshold is no longer exceeded. Use `removeOldAndUploadedLogsToThreshold:error:`
 */
ORK_CLASS_AVAILABLE
@interface ORKDataLoggerManager : NSObject <ORKDataLoggerDelegate>

/**
 Designated initializer.
 
 @param directory       File URL to the directory where the data loggers should coexist.
 @param delegate        The delegate to receive notifications.
 */
- (instancetype)initWithDirectory:(NSURL *)directory delegate:(ORK_NULLABLE id<ORKDataLoggerManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/// Delegate.
@property (weak, ORK_NULLABLE) id<ORKDataLoggerManagerDelegate> delegate;

/// Threshold for delegate callback for total bytes not marked uploaded.
@property unsigned long long pendingUploadBytesThreshold;

/// Threshold for delegate callback for total bytes of completed logs.
@property unsigned long long totalBytesThreshold;

/// Total number of bytes of files not yet marked as pending upload.
@property unsigned long long pendingUploadBytes;

/// Total number of bytes for all the loggers.
@property unsigned long long totalBytes;

/**
 Add a data logger with a JSON log format, in the directory.
 
 Throws an exception if a logger already exists for that log name.
 
 @param logName     Log name prefix for the data logger
 @return Returns the `ORKDataLogger` added.
 */
- (ORKDataLogger *)addJSONDataLoggerForLogName:(NSString *)logName;

/**
 Add a data logger with a particular formatter, in the directory.
 
 @param logName     Log name prefix for the data logger
 @param formatter   The log formatter instance to use for this logger.
 @return Returns the `ORKDataLogger` added, or the existing one if one already existed for
 that logName.
 */
- (ORKDataLogger *)addDataLoggerForLogName:(NSString *)logName formatter:(ORKLogFormatter *)formatter;

/**
 Retrieve the already existing data logger for a log name.
 
 @param logName     Log name prefix for the data logger
 @return Returns the `ORKDataLogger` retrieved, or nil, if one already existed for that logName.
 */
- (ORK_NULLABLE ORKDataLogger *)dataLoggerForLogName:(NSString *)logName;

/**
 Remove a data logger.
 
 @param logger      Logger to remove.
 */
- (void)removeDataLogger:(ORKDataLogger *)logger;

/// Returns the set of log names of the data loggers managed by this object.
- (NSArray *)logNames;

/**
 Enumerate all the logs needing upload, across all data loggers, sorted oldest first.
 
 Fetches all the data loggers' logs needing upload, then sorts them
 oldest first.
 
 @param block       The block to call during enumeration.
 @param error       Error, on failure.
 @return Returns `YES`, if the enumeration succeeds.
 */
- (BOOL)enumerateLogsNeedingUpload:(void (^)(ORKDataLogger *dataLogger, NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error;

/**
 Unmark the set of uploaded files.
 
 Indicate that these files should no longer be marked uploaded (say, because
 the upload did not succeed).
 
 @param fileURLs     The array of file URLs that should no longer be marked uploaded.
 @param error       Error, on failure.
 @return Returns `YES`, if the operation succeeds.
 */
- (BOOL)unmarkUploadedFiles:(NSArray *)fileURLs error:(NSError * __ORK_NULLABLE __autoreleasing *)error;

/**
 Remove a set of uploaded files.
 
 Analogous to similar method on `ORKDataLogger`, but accepts an array of files
 which may relate to any of the data loggers. It is an error to pass a URL which would not
 belong to one of the loggers managed by this manager.
 
 @param fileURLs     The array of file URLs that should be removed.
 @param error       Error, on failure.
 @return Returns `YES`, if the operation succeeds.
 */
- (BOOL)removeUploadedFiles:(NSArray *)fileURLs error:(NSError * __ORK_NULLABLE __autoreleasing *)error;

/**
 Remove old and uploaded logs to bring total bytes down to a threshold.
 
 Removes uploaded logs first; then removes the oldest log files, across
 all of the data loggers, until the total usage falls below a threshold.
 
 @param bytes       The threshold down to which to remove old log files. File
                    removal will stop when the total bytes managed by all the data
                    loggers reaches this threshold.
 @param error       Error, on failure.
 @return Returns `YES`, if the operation succeeds.
 */
- (BOOL)removeOldAndUploadedLogsToThreshold:(unsigned long long)bytes error:(NSError * __ORK_NULLABLE __autoreleasing *)error;

@end


ORK_ASSUME_NONNULL_END

