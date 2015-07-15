//
// APCDataArchiverAndUploader.m
// AppCore
//
// Copyright (c) 2015 Apple, Inc. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "APCDataArchiverAndUploader.h"
#import <BridgeSDK/BridgeSDK.h>
#import "APCAppDelegate.h"
#import "APCCMS.h"
#import "APCDataVerificationClient.h"
#import "APCJSONSerializer.h"
#import "APCLog.h"
#import "APCUtilities.h"
#import "NSError+APCAdditions.h"
#import "NSFileManager+Helper.h"
#import "NSOperationQueue+Helper.h"
#import "ZZArchive.h"
#import "ZZArchiveEntry.h"



// ---------------------------------------------------------
#pragma mark - Constants
// ---------------------------------------------------------

static NSString * const kAPCSerializedDataKey_PhoneInfo         = @"phoneInfo";
static NSString * const kAPCNormalFileNameKey                   = @"item";          // not sure why these two things are used
static NSString * const kAPCAlternateFileNameKey                = @"identifier";    // as filenames.  Soon, we can change that.
static NSString * const kAPCNameOfIndexFile                     = @"info";
static NSString * const kAPCUnknownFileNameFormatString         = @"UnknownFile_%d";
static NSString * const kAPCPrivateFolderOfUploadableFiles      = @"filesToUpload";

static NSString * const kAPCOperationQueueName_ArchiveAndUpload_General                     = @"ArchiveAndUpload: Generic zip-and-upload queue";
static NSString * const kAPCOperationQueueName_ArchiveAndUpload_ModifyingListOfArchivers    = @"ArchiveAndUpload: Queue for adding and removing archivers to a global list";



// ---------------------------------------------------------
#pragma mark - Error Codes and Strings (more constants)
// ---------------------------------------------------------


/*
 These all end in "_Code" so they'll be easy to spot
 in the context menus, when we type "kError..." and see
 a bunch of related items.  These will appear next to
 their matching strings, defined below.
 */
typedef enum : NSInteger
{
    kErrorArchiveAndUploadFirstErrorCode = 100,
    kErrorCantCreateArchiveFolder_Code,
    kErrorCantCreateManifest_Code,
    kErrorCantCreatePrivateFolder_Code,
    kErrorCantCreateTempFolder_Code,
    kErrorCantCreateUploadFolder_Code,
    kErrorCantCreateWorkingDirectory_Code,
    kErrorCantCreateZipFile_Code,
    kErrorCantDeleteFileOrFolder_Code,
    kErrorCantEncryptFile_Code,
    kErrorCantFindDocumentsFolder_Code,
    kErrorCantFindEncryptedFile_Code,
    kErrorCantFindRequestedUploadableFile_Code,
    kErrorCantFindUnencryptedFile_Code,
    kErrorCantInsertZipEntry_Code,
    kErrorCantMoveRequestedUploadableFileToPrivateFolder_Code,
    kErrorCantMoveRequestedUploadableFileToTempFolder_Code,
    kErrorCantReadRequestedUploadableFile_Code,
    kErrorCantReadUnencryptedFile_Code,
    kErrorCantSaveEncryptedFile_Code,
    kErrorCantSaveUnencryptedFile_Code,
    kErrorCantSerializeObject_Code,
    kErrorDontHaveAnyZippedFiles_Code,
    kErrorHaveDuplicateUploadableFilenames_Code,
    kErrorInvalidTaskIdentifier_Code,
    kErrorInvalidTaskRunUuid_Code,
    kErrorUploadFailed_Code,

} APCErrorCode;


static NSString * const kArchiveAndUploadErrorDomain                    = @"ArchiveAndUpload";

static NSString * const kErrorCantCreateArchiveFolder_Reason            = @"Can't create 'Archive' folder";
static NSString * const kErrorCantCreateArchiveFolder_Suggestion        = @"Couldn't create the folder for preparing our .zip files.";
static NSString * const kErrorCantCreateManifest_Reason                 = @"Can't Create Manifest";
static NSString * const kErrorCantCreateManifest_SuggestionFormat       = @"Couldn't create the manifest file entry (%@.%@) in the .zip file.";
static NSString * const kErrorCantCreateUploadFolder_Reason             = @"Can't create 'Upload' folder";
static NSString * const kErrorCantCreateUploadFolder_Suggestion         = @"Couldn't create the folder for saving files to be uploaded.";
static NSString * const kErrorCantCreateWorkingDirectory_Reason         = @"Can't Create Working Folder";
static NSString * const kErrorCantCreateWorkingDirectory_Suggestion     = @"Couldn't create a folder in which to make our .zip file.";
static NSString * const kErrorCantCreateZipFile_Reason                  = @"Can't Create Archive in Memory";
static NSString * const kErrorCantCreateZipFile_Suggestion              = @"We couldn't create the new, placeholder .zip file in RAM.  (We haven't even gotten to the 'save to disk' part.)";
static NSString * const kErrorCantDeleteFileOrFolder_Reason             = @"Can't Delete File/Folder";
static NSString * const kErrorCantDeleteFileOrFolder_Suggestion         = @"We couldn't delete a file/folder creating during the archiving process. See attached path and nested error, if any, for details.";
static NSString * const kErrorCantEncryptFile_Reason                    = @"Can't Encrypt Zip File";
static NSString * const kErrorCantEncryptFile_Suggestion                = @"We couldn't encrypt the .zip file we need to upload.";
static NSString * const kErrorCantFindDocumentsFolder_Reason            = @"Can't Find 'Documents' Folder";
static NSString * const kErrorCantFindDocumentsFolder_Suggestion        = @"Couldn't find the user's 'documents' folder. This should never happen. Ahem.";
static NSString * const kErrorCantFindEncryptedFile_Reason              = @"Can't Find Encrypted File";
static NSString * const kErrorCantFindEncryptedFile_Suggestion          = @"We couldn't find the encrypted .zip file on disk (even though we seem to have successfully encrypted it...?).";
static NSString * const kErrorCantFindUnencryptedFile_Reason            = @"Can't Find Unencrypted File";
static NSString * const kErrorCantFindUnencryptedFile_Suggestion        = @"We couldn't find the unencrypted .zip file on disk (even though we seem to have successfully saved it...?).";
static NSString * const kErrorCantInsertZipEntry_Reason                 = @"Can't Insert Zip Entry";
static NSString * const kErrorCantInsertZipEntry_Suggestion             = @"We couldn't add one of the .zippable items to the .zip file.";
static NSString * const kErrorCantReadUnencryptedFile_Reason            = @"Can't Open Archive";
static NSString * const kErrorCantReadUnencryptedFile_Suggestion        = @"Couldn't read the unencrypted .zip file we just tried to create.";
static NSString * const kErrorCantSaveEncryptedFile_Reason              = @"Can't Save Encrypted File";
static NSString * const kErrorCantSaveEncryptedFile_Suggestion          = @"We couldn't save the encrypted .zip file to disk.";
static NSString * const kErrorCantSaveUnencryptedFile_Reason            = @"Can't Save Unencrypted File";
static NSString * const kErrorCantSaveUnencryptedFile_Suggestion        = @"We couldn't save the unencrypted .zip file to disk.";
static NSString * const kErrorCantSerializeObject_Reason                = @"Can't Serialize Object";
static NSString * const kErrorCantSerializeObject_Suggestion            = @"We couldn't generate a JSON version of some piece of data.";
static NSString * const kErrorDontHaveAnyZippedFiles_Reason             = @"Don't Have Files For Archive";
static NSString * const kErrorDontHaveAnyZippedFiles_Suggestion         = @"Something went wrong. We don't seem to have any contents for this .zip file.";
static NSString * const kErrorInvalidTaskIdentifier_Reason              = @"Invalid Task Identifier";
static NSString * const kErrorInvalidTaskIdentifier_SuggestionFormat    = @"The task identifier you specified [%@] does not appear to be valid.  Please check the source code for the current requirements for this field.";
static NSString * const kErrorInvalidTaskRunUuid_Reason                 = @"Invalid Task Run ID";
static NSString * const kErrorInvalidTaskRunUuid_SuggestionFormat       = @"The 'task run ID' you specified [%@] doesn't appear to be valid.  Please check the source code for the current requirements for this field.";
static NSString * const kErrorUploadFailed_Reason                       = @"Upload to Sage Failed";
static NSString * const kErrorUploadFailed_Suggestion                   = @"We got an error when uploading to Sage.  See the nested error for details.";


/*
 File-moving errors.  These are separate merely because the
 constant names are longer, and they don't line up as well.
 */
static NSString * const kErrorCantCreatePrivateFolder_Reason                            = @"Can't Create Private Folder";
static NSString * const kErrorCantCreatePrivateFolder_Suggestion                        = @"We couldn't create a private folder to hold the uploadable files.";
static NSString * const kErrorCantCreateTempFolder_Reason                               = @"Can't Create Temp Folder";
static NSString * const kErrorCantCreateTempFolder_Suggestion                           = @"We couldn't create a temporary folder to hold the uploadable files.";
static NSString * const kErrorCantFindRequestedUploadableFile_Reason                    = @"Can't Find Specified File";
static NSString * const kErrorCantFindRequestedUploadableFile_Suggestion                = @"We couldn't find one of the files you asked us to upload.";
static NSString * const kErrorCantMoveRequestedUploadableFileToPrivateFolder_Reason     = @"Can't Move Specified File";
static NSString * const kErrorCantMoveRequestedUploadableFileToPrivateFolder_Suggestion = @"We couldn't move one of the files from the temp directory to a private directory.";
static NSString * const kErrorCantMoveRequestedUploadableFileToTempFolder_Reason        = @"Can't Move Specified File";
static NSString * const kErrorCantMoveRequestedUploadableFileToTempFolder_Suggestion    = @"We couldn't move one of the files to a temporary directory.";
static NSString * const kErrorCantReadRequestedUploadableFile_Reason                    = @"Can't Open Specified File";
static NSString * const kErrorCantReadRequestedUploadableFile_Suggestion                = @"We couldn't open one of the files you asked us to upload.";
static NSString * const kErrorHaveDuplicateUploadableFilenames_Reason                   = @"Duplicate Uploadable Filenames";
static NSString * const kErrorHaveDuplicateUploadableFilenames_Suggestion               = @"Some of the filenames you specified for uploading are duplicates. The attached path shows the first duplicated name. Please upload only unique filenames in any one batch. (We can remove this restriction if needed.)";



// ---------------------------------------------------------
#pragma mark - Global (class) variables
// ---------------------------------------------------------

/**
 These are effectively constants, although we have
 to retrieve them at runtime.
 */
static NSString *appName    = nil;
static NSString *appVersion = nil;
static NSString *phoneInfo  = nil;

/**
 All zip-and-upload operations will use this and only this queue.
 This will ease debugging, as well as system load.
 */
static NSOperationQueue * queueForArchivingAndUploading = nil;

/**
 Pointers to objects waiting for responses from Sage.  After that,
 they'll do whatever cleanup is required after the upload, like
 deleting their working directories and calling back the calling
 methods.
 */
static NSMutableArray * uploadersWaitingForSageUploadToFinish = nil;
static NSOperationQueue * queueForTrackingUploaders = nil;

/**
 These will be set the first time we archive anything
 during a given run of the app.
 */
static BOOL uploadFoldersHaveBeenCreated = NO;
static NSString *folderPathContainingAllOtherFolders = nil;
static NSString *folderPathForArchiveOperations = nil;
static NSString *folderPathForUploadOperations = nil;



// ---------------------------------------------------------
#pragma mark - Private Properties
// ---------------------------------------------------------


@interface APCDataArchiverAndUploader ()
@property (nonatomic, strong) NSArray               * dictionariesToUpload;

/**
 Name for the task being uploaded.  Needs to be a legal
 C-style variable name.  I think.  Specification in progress.
 */
@property (nonatomic, strong) NSString              * taskIdentifier;

/**
 Unique ID for this particular run of the task identified
 with taskIdentifier.  I think.  Specification in progress.
 */
@property (nonatomic, strong) NSUUID                * taskRunUuid;

@property (nonatomic, strong) ZZArchive             * zipArchive;
@property (nonatomic, strong) NSMutableArray        * zipEntries;
@property (nonatomic, strong) NSURL                 * zipArchiveURL;
@property (nonatomic, strong) NSString              * tempOutputDirectory;
@property (nonatomic, strong) NSMutableArray        * fileInfoEntries;
@property (nonatomic, strong) NSString              * workingDirectoryPath;
@property (nonatomic, strong) NSString              * unencryptedZipPath;
@property (nonatomic, strong) NSString              * encryptedZipPath;
@property (nonatomic, strong) NSURL                 * unencryptedZipURL;
@property (nonatomic, strong) NSURL                 * encryptedZipURL;

// Files we've been asked to upload, and their folders,
// throughout our view of their lifecycle.  Tracking
// all these because we have to clean them all up:
@property (nonatomic, strong) NSArray               * sourceFilePathsToUpload;              // raw paths from the calling method
@property (nonatomic, strong) NSString              * pathToTempFolderOfFilesToUpload;      // someplace safe to put 'em (in the user's temp directory)
@property (nonatomic, strong) NSArray               * tempFilePathsToUpload;                // their paths after we put 'em there
@property (nonatomic, strong) NSString              * pathToPrivateFolderOfFilesToUpload;   // once we're rolling, a private place to put 'em, owned by this uploader object
@property (nonatomic, strong) NSArray               * privateFilePathsToUpload;             // their paths once we put 'em there

@property (nonatomic, assign) NSUInteger            countOfUnknownFileNames;

@property (nonatomic, strong) NSOperationQueue      *callbackQueue;
@property (nonatomic, strong) UploaderCallbackWhenCompleted uploaderCompletionCallback;

@end



@implementation APCDataArchiverAndUploader



// ---------------------------------------------------------
#pragma mark - Setting up class and queues
// ---------------------------------------------------------

/**
 By definition, this method is called once per class, in a thread-safe
 way, the first time the class is sent a message -- basically, the first
 time we refer to the class.  That means we can use this to set up stuff
 that applies to all objects (instances) of this class.

 Documentation:  See +initialize in the NSObject Class Reference.  Currently, that's here:
 https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSObject_Class/index.html#//apple_ref/occ/clm/NSObject/initialize
 */
+ (void) initialize
{
    uploadersWaitingForSageUploadToFinish = [NSMutableArray new];
    queueForArchivingAndUploading = [NSOperationQueue sequentialOperationQueueWithName: kAPCOperationQueueName_ArchiveAndUpload_General];
    queueForTrackingUploaders     = [NSOperationQueue sequentialOperationQueueWithName: kAPCOperationQueueName_ArchiveAndUpload_ModifyingListOfArchivers];

    appName     = [APCUtilities appName];
    appVersion  = [APCUtilities appVersion];
    phoneInfo   = [APCUtilities phoneInfo];
}

+ (void) trackNewArchiver: (APCDataArchiverAndUploader *) archiver
{
    [queueForTrackingUploaders addOperationWithBlock: ^{
        [uploadersWaitingForSageUploadToFinish addObject: archiver];
    }];
}

+ (void) stopTrackingArchiver: (APCDataArchiverAndUploader *) archiver
{
    [queueForTrackingUploaders addOperationWithBlock: ^{
        [uploadersWaitingForSageUploadToFinish removeObject: archiver];
    }];
}



// ---------------------------------------------------------
#pragma mark - The public API
// ---------------------------------------------------------

+ (void) uploadDictionary: (NSDictionary *) dictionary
       withTaskIdentifier: (NSString *) taskIdentifier
           andTaskRunUUID: (NSUUID *) taskRunUUID
          completionQueue: (NSOperationQueue *) completionQueue
           withCompletion: (UploaderCallbackWhenCompleted) completion
{
    APCDataArchiverAndUploader *archiverAndUploader = [[APCDataArchiverAndUploader alloc] initWithDictionariesToUpload: @[dictionary]
                                                                                                        taskIdentifier: taskIdentifier
                                                                                                           taskRunUUID: taskRunUUID
                                                                                                       completionQueue: completionQueue
                                                                                                        withCompletion: completion];
    
    [self startOneUploadWithUploader: archiverAndUploader];
    
}


+ (void) uploadDictionary: (NSDictionary *) dictionary
       withTaskIdentifier: (NSString *) taskIdentifier
           andTaskRunUuid: (NSUUID *) taskRunUuid
{
    APCDataArchiverAndUploader *archiverAndUploader = [[APCDataArchiverAndUploader alloc] initWithDictionariesToUpload: @[dictionary]
                                                                                                        taskIdentifier: taskIdentifier
                                                                                                           taskRunUuid: taskRunUuid];

    [self startOneUploadWithUploader: archiverAndUploader];
}


+ (BOOL) uploadFileAtPath: (NSString *) path
       withTaskIdentifier: (NSString *) taskIdentifier
           andTaskRunUuid: (NSUUID *) taskRunUuid
           returningError: (NSError * __autoreleasing *) errorToReturn
{
    BOOL result = [self uploadFilesAtPaths: @[path]
                        withTaskIdentifier: taskIdentifier
                            andTaskRunUuid: taskRunUuid
                            returningError: errorToReturn];

    return result;
}

+ (BOOL) uploadFilesAtPaths: (NSArray *) paths
         withTaskIdentifier: (NSString *) taskIdentifier
             andTaskRunUuid: (NSUUID *) taskRunUuid
             returningError: (NSError * __autoreleasing *) errorToReturn
{
    APCDataArchiverAndUploader *archiverAndUploader = [[APCDataArchiverAndUploader alloc] initWithFilePathsToUpload: paths
                                                                                                     taskIdentifier: taskIdentifier
                                                                                                        taskRunUuid: taskRunUuid];

    // Before we start the upload:  try to move the files to
    // a safe location we control.  Then the uploader will take
    // full ownership of it once it's created its working
    // directory.  If we *can't* get to the files, abort now
    // and say why.
    NSError *errorMovingFiles = nil;

    BOOL ableToMoveFile = [archiverAndUploader moveUploadableFilesToSafeLocationReturningError: & errorMovingFiles];

    if (! ableToMoveFile)
    {
        APCLogError2 (errorMovingFiles);
    }
    else
    {
        // This is the upload itself.
        [self startOneUploadWithUploader: archiverAndUploader];
    }

    if (errorToReturn != nil)
    {
        *errorToReturn = errorMovingFiles;
    }

    return ableToMoveFile;
}

+ (void) startOneUploadWithUploader: (APCDataArchiverAndUploader *) uploader
{
    [queueForArchivingAndUploading addOperationWithBlock: ^{
        [uploader go];
    }];
}



// ---------------------------------------------------------
#pragma mark - Create one uploader
// ---------------------------------------------------------

- (id) init
{
    self = [self initWithTaskIdentifier: nil
                         andTaskRunUuid: nil];

    return self;
}

- (id) initWithTaskIdentifier: (NSString *) taskIdentifier
               andTaskRunUuid: (NSUUID *) taskRunUuid
{
    self = [super init];

    if (self)
    {
        _taskIdentifier                     = taskIdentifier;
        _taskRunUuid                        = taskRunUuid;
        _zipEntries                         = [NSMutableArray new];
        _fileInfoEntries                    = [NSMutableArray new];
        _countOfUnknownFileNames            = 0;
        _dictionariesToUpload               = nil;
        _workingDirectoryPath               = nil;
        _unencryptedZipPath                 = nil;
        _encryptedZipPath                   = nil;
        _unencryptedZipURL                  = nil;
        _encryptedZipURL                    = nil;

        // Files we've been asked to upload, and their folders,
        // throughout our view of their lifecycle:
        _sourceFilePathsToUpload            = nil;
        _pathToTempFolderOfFilesToUpload    = nil;
        _tempFilePathsToUpload              = nil;
        _pathToPrivateFolderOfFilesToUpload = nil;
        _privateFilePathsToUpload           = nil;
        
        // Callback properties
        _uploaderCompletionCallback         = nil;
        _callbackQueue                      = nil;
    }

    return self;
}

- (id) initWithDictionariesToUpload: (NSArray *) arrayOfDictionaries
                     taskIdentifier: (NSString *) taskIdentifier
                        taskRunUUID: (NSUUID *) taskRunUUID
                    completionQueue: (NSOperationQueue *) completionQueue
                     withCompletion: (UploaderCallbackWhenCompleted) completion
{
    self = [self initWithTaskIdentifier: taskIdentifier
                         andTaskRunUuid: taskRunUUID];

    if (self)
    {
        _dictionariesToUpload = [NSArray arrayWithArray: arrayOfDictionaries];
        _callbackQueue = completionQueue;
        _uploaderCompletionCallback = completion;
    }

    return self;
}

- (id) initWithDictionariesToUpload: (NSArray *) arrayOfDictionaries
                     taskIdentifier: (NSString *) taskIdentifier
                        taskRunUuid: (NSUUID *) taskRunUuid
{
    self = [self initWithTaskIdentifier: taskIdentifier
                         andTaskRunUuid: taskRunUuid];
    
    if (self)
    {
        _dictionariesToUpload = [NSArray arrayWithArray: arrayOfDictionaries];
    }
    
    return self;
}

- (id) initWithFilePathsToUpload: (NSArray *) arrayOfFilePaths
                  taskIdentifier: (NSString *) taskIdentifier
                     taskRunUuid: (NSUUID *) taskRunUuid
{
    self = [self initWithTaskIdentifier: taskIdentifier
                         andTaskRunUuid: taskRunUuid];

    if (self)
    {
        _sourceFilePathsToUpload = [NSArray arrayWithArray: arrayOfFilePaths];
    }

    return self;
}



// ---------------------------------------------------------
#pragma mark - Preparation:  moving files to a location we control, while still on the calling thread
// ---------------------------------------------------------

- (BOOL) moveUploadableFilesToSafeLocationReturningError: (NSError * __autoreleasing *) errorToReturn
{
    BOOL itWorked = NO;
    NSError *errorMovingFiles = nil;
    NSMutableArray *filesIHaventMovedYet = [NSMutableArray arrayWithArray: self.sourceFilePathsToUpload];
    NSMutableArray *filesIWasAbleToMove  = [NSMutableArray new];


    // If we have an error, we'll report any files we weren't able to move,
    // so the calling method can delete them (or whatever).
    NSDictionary *userInfoDictionaryForError = @{ kAPCArchiveAndUpload_FilesWeDidntTouchErrorKey : filesIHaventMovedYet };


    // Make sure we have unique filenames, because, for now, we're
    // going to stick them all in the same directory.
    //
    // Also, for this next section:  default to itWorked = YES.
    // We'll set it to NO if we find a duplicate name.
    itWorked = YES;
    NSMutableArray *filenames = [NSMutableArray new];


    for (NSString *path in self.sourceFilePathsToUpload)
    {
        NSString *filename = path.lastPathComponent;
        BOOL alreadyExists = [filenames containsObject: filename];

        /*
         TESTING
         
         Please leave this block of test code here.  It helps
         verify that we're handling each possible error correctly.

                alreadyExists = YES;
         */

        if (alreadyExists)
        {
            errorMovingFiles = [NSError errorWithCode: kErrorHaveDuplicateUploadableFilenames_Code
                                               domain: kArchiveAndUploadErrorDomain
                                        failureReason: kErrorHaveDuplicateUploadableFilenames_Reason
                                   recoverySuggestion: kErrorHaveDuplicateUploadableFilenames_Suggestion
                                      relatedFilePath: path
                                           relatedURL: nil
                                          nestedError: nil
                                        otherUserInfo: userInfoDictionaryForError];

            itWorked = NO;
            break;
        }

        else
        {
            [filenames addObject: filename];
        }
    }

    if (! itWorked)
    {
        // We've already calculated the error.  Nothing else to do.
    }

    else
    {
        NSError *errorCreatingTempFolder     = nil;
        NSFileManager *fileManager           = [NSFileManager defaultManager];
        self.pathToTempFolderOfFilesToUpload = [APCUtilities pathToTemporaryDirectoryAddingUuid: YES];

        itWorked = [fileManager createAPCFolderAtPath: self.pathToTempFolderOfFilesToUpload
                                       returningError: & errorCreatingTempFolder];

        /*
         TESTING
         
         Please leave this block of test code here.  It helps
         verify that we're handling each possible error correctly.

                itWorked = NO;
                errorCreatingTempFolder = [NSError errorWithDomain: @"fake underlying error creating temp folder" code: 2 userInfo: nil];
         */

        if (! itWorked)
        {
            errorMovingFiles = [NSError errorWithCode: kErrorCantCreateTempFolder_Code
                                               domain: kArchiveAndUploadErrorDomain
                                        failureReason: kErrorCantCreateTempFolder_Reason
                                   recoverySuggestion: kErrorCantCreateTempFolder_Suggestion
                                      relatedFilePath: self.pathToTempFolderOfFilesToUpload
                                           relatedURL: nil
                                          nestedError: errorCreatingTempFolder
                                        otherUserInfo: userInfoDictionaryForError];
        }

        else
        {
            NSError *errorMovingOneFile = nil;

            for (NSString *sourcePath in self.sourceFilePathsToUpload)
            {
                NSString *filename = sourcePath.lastPathComponent;
                NSString *destinationPath = [self.pathToTempFolderOfFilesToUpload stringByAppendingPathComponent: filename];

                itWorked = [fileManager moveItemAtPath: sourcePath
                                                toPath: destinationPath
                                                 error: & errorMovingOneFile];

                /*
                 TESTING
                 
                 Please leave this block of test code here.  It helps
                 verify that we're handling each possible error correctly.

                        if ([self.sourceFilePathsToUpload indexOfObject: sourcePath] == 1)
                        {
                            itWorked = NO;
                            errorMovingOneFile = [NSError errorWithDomain: @"fake underlying error moving a file" code: 2 userInfo: nil];
                        }
                 */

                if (! itWorked)
                {
                    errorMovingFiles = [NSError errorWithCode: kErrorCantMoveRequestedUploadableFileToTempFolder_Code
                                                       domain: kArchiveAndUploadErrorDomain
                                                failureReason: kErrorCantMoveRequestedUploadableFileToTempFolder_Reason
                                           recoverySuggestion: kErrorCantMoveRequestedUploadableFileToTempFolder_Suggestion
                                              relatedFilePath: sourcePath
                                                   relatedURL: nil
                                                  nestedError: errorMovingOneFile
                                                otherUserInfo: userInfoDictionaryForError];
                    break;
                }
                
                else
                {
                    [filesIHaventMovedYet removeObject: sourcePath];
                    [filesIWasAbleToMove addObject: destinationPath];
                }
            }
        }
    }

    // Whether or not this worked *completely*, track any files we
    // moved, because we're now responsible for deleting them.
    self.tempFilePathsToUpload = [NSMutableArray arrayWithArray: filesIWasAbleToMove];

    if (! itWorked)
    {
        // And, now, try to delete those files.  We bought 'em, we own 'em.
        // This is an exception to our normal cleanup process.  Normally, we'll
        // clean up at the bottom of this class, after all the uploading is done.
        // In this method, though, if we have an error, we will, by definition,
        // never start the upload, so we have to clean up now.
        if (filesIWasAbleToMove.count)
        {
            for (NSString *filePath in filesIWasAbleToMove)
            {
                [self trashFileOrFolderAtPath: filePath];
            }

            [self trashFileOrFolderAtPath: self.pathToTempFolderOfFilesToUpload];
            self.pathToTempFolderOfFilesToUpload = nil;
        }
    }

    if (errorToReturn != nil)
    {
        *errorToReturn = errorMovingFiles;
    }

    return itWorked;
}




// ---------------------------------------------------------
#pragma mark - The main method:  calls all other methods below.
// ---------------------------------------------------------

- (void) go
{
    NSError *error = nil;
    BOOL ok = YES;


    /*
     Register with a static variable, so I don't get deleted
     while waiting for Sage to reply.  I'll un-register myself
     in -finalCleanup.
     */
    [[self class] trackNewArchiver: self];


    /*
     Here's how this works:

     Each line of code below does some mildly (or seriously) complex
     step in this zip-and-send process.  If it works, it returns
     YES, and its error is nil.  If it fails, it returns NO, and sets
     its error to something useful.
     
     So this pile of "if" statements means:  do each of those steps,
     aborting the moment we get an error.
     
     The last step is "start the upload."  If we get that far, we'll
     get a callback when the upload completes.  Otherwise, we report
     whatever error we got, clean up, and stop.
     
     Most of these steps work the same way, internally:  a cascading
     series of sub-steps which error out as fast as possible.
     */
    if (ok) {  ok = [self createBaseFoldersDuringFirstRunReturningError : & error];  }
    if (ok) {  ok = [self createWorkingDirectoryReturningError          : & error];  }
    if (ok) {  ok = [self moveFilesToWorkingDirectoryReturningError     : & error];  }
    if (ok) {  ok = [self createZipArchiveInRamReturningError           : & error];  }
    if (ok) {  ok = [self zipAllDictionariesReturningError              : & error];  }
    if (ok) {  ok = [self zipAllRequestedFilePathsReturningError        : & error];  }
    if (ok) {  ok = [self createManifestReturningError                  : & error];  }
    if (ok) {  ok = [self saveToDiskReturningError                      : & error];  }
    if (ok) {  ok = [self encryptZipFileReturningError                  : & error];  }

    if (ok)
    {
        // Wow!  Everything worked.  Ship it.  We'll get a callback
        // when done, which then calls -finalCleanup.
        [self beginTheUpload];
    }
    else
    {
        // Boo.  Something broke.  Report and clean up.
        [self finalCleanupHandlingError: error];
    }
}



// ---------------------------------------------------------
#pragma mark - Step 1:  Create a working directory
// ---------------------------------------------------------

/**
 This method creates our base working directories the first time
 the archiver runs.  They should persist across the lifetime of
 the app.  For that matter, they should persist across runs of
 the app, since the folders have constant names.

 @return  YES if the folders were created, or if they already
          existed.  NO if unable to create any of the base folders.

 @param   errorToReturn   Will be filled with the earliest error
                          encountered, if any.  Will be set to nil
                          if no errors were encountered.
 */
- (BOOL) createBaseFoldersDuringFirstRunReturningError: (NSError * __autoreleasing *) errorToReturn
{
    NSError *localError = nil;

    /*
     We need to thread-synchronize access to this
     "uploadFoldersHaveBeenCreated" variable.  That's accomplished
     by the fact that every method in this file runs on a single
     operationQueue which only allows one operation at a time.
     */
    if (! uploadFoldersHaveBeenCreated)
    {
        NSString *documentsFolder = [APCUtilities pathToUserDocumentsFolder];

        if (! documentsFolder)
        {
            localError = [NSError errorWithCode: kErrorCantFindDocumentsFolder_Code
                                         domain: kArchiveAndUploadErrorDomain
                                  failureReason: kErrorCantFindDocumentsFolder_Reason
                             recoverySuggestion: kErrorCantFindDocumentsFolder_Suggestion];
        }

        else
        {
            NSFileManager *fileManager           = NSFileManager.defaultManager;
            NSString *containerFolder            = [documentsFolder stringByAppendingPathComponent: kAPCFolderName_ArchiveAndUpload_TopLevelFolder];
            NSString *folderForArchiving         = [containerFolder stringByAppendingPathComponent: kAPCFolderName_ArchiveAndUpload_Archiving];
            NSString *folderForUploading         = [containerFolder stringByAppendingPathComponent: kAPCFolderName_ArchiveAndUpload_Uploading];
            NSError  *errorCreatingArchiveFolder = nil;

            BOOL folderCreated = [fileManager createAPCFolderAtPath: folderForArchiving
                                                     returningError: & errorCreatingArchiveFolder];


            /*
             TESTING
             
             Please leave this block of test code here.  It helps
             verify that we're handling each possible error correctly.

                    folderCreated = NO;
                    errorCreatingArchiveFolder = [NSError errorWithDomain: @"fake underlying error creating archive folder" code: 2 userInfo: nil];
             */


            if (! folderCreated)
            {
                localError = [NSError errorWithCode: kErrorCantCreateArchiveFolder_Code
                                             domain: kArchiveAndUploadErrorDomain
                                      failureReason: kErrorCantCreateArchiveFolder_Reason
                                 recoverySuggestion: kErrorCantCreateArchiveFolder_Suggestion
                                    relatedFilePath: folderForArchiving
                                         relatedURL: nil
                                        nestedError: errorCreatingArchiveFolder];
            }

            else
            {
                NSError *errorCreatingUploadFolder = nil;

                folderCreated = [fileManager createAPCFolderAtPath: folderForUploading
                                                    returningError: & errorCreatingUploadFolder];

                /*
                 TESTING

                 Please leave this block of test code here.  It helps
                 verify that we're handling each possible error correctly.

                        folderCreated = NO;
                        errorCreatingUploadFolder = [NSError errorWithDomain: @"fake underlying error creating upload folder" code: 2 userInfo: nil];
                 */

                if (! folderCreated)
                {
                    localError = [NSError errorWithCode: kErrorCantCreateUploadFolder_Code
                                                 domain: kArchiveAndUploadErrorDomain
                                          failureReason: kErrorCantCreateUploadFolder_Reason
                                     recoverySuggestion: kErrorCantCreateUploadFolder_Suggestion
                                        relatedFilePath: folderForUploading
                                             relatedURL: nil
                                            nestedError: errorCreatingUploadFolder];
                }
                else
                {
                    uploadFoldersHaveBeenCreated        = folderCreated;
                    folderPathContainingAllOtherFolders = containerFolder;
                    folderPathForArchiveOperations      = folderForArchiving;
                    folderPathForUploadOperations       = folderForUploading;
                }
            }
        }
    }

    if (errorToReturn != nil)
    {
        *errorToReturn = localError;
    }

    return uploadFoldersHaveBeenCreated;
}

- (BOOL) createWorkingDirectoryReturningError: (NSError * __autoreleasing *) errorToReturn
{
    BOOL ableToCreateWorkingFolder = NO;
    NSError *localError = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *uniqueSubdirectoryName = [NSUUID UUID].UUIDString;
    NSString *workingDirectoryPath = [folderPathForArchiveOperations stringByAppendingPathComponent: uniqueSubdirectoryName];

    /*
     This should literally never happen; the UUID should
     guarantee uniqueness.  Still...
     */
    if ([fileManager fileExistsAtPath: workingDirectoryPath])
    {
        // report?
    }

    NSError * directoryCreationError = nil;

    ableToCreateWorkingFolder = [fileManager createAPCFolderAtPath: workingDirectoryPath
                                                    returningError: & directoryCreationError];

    /*
     TESTING

     Please leave this block of test code here.  It helps
     verify that we're handling each possible error correctly.

            ableToCreateWorkingFolder = NO;
            directoryCreationError = [NSError errorWithDomain: @"fake underlying error creating working directory" code: 12 userInfo: nil];
     */

    if (! ableToCreateWorkingFolder)
    {
        localError = [NSError errorWithCode: kErrorCantCreateWorkingDirectory_Code
                                     domain: kArchiveAndUploadErrorDomain
                              failureReason: kErrorCantCreateWorkingDirectory_Reason
                         recoverySuggestion: kErrorCantCreateWorkingDirectory_Suggestion
                                nestedError: directoryCreationError];
    }
    else
    {
        self.workingDirectoryPath               = workingDirectoryPath;
        self.pathToPrivateFolderOfFilesToUpload = [workingDirectoryPath stringByAppendingPathComponent: kAPCPrivateFolderOfUploadableFiles];
        self.unencryptedZipPath                 = [workingDirectoryPath stringByAppendingPathComponent: kAPCFileName_UnencryptedZipFile];
        self.encryptedZipPath                   = [workingDirectoryPath stringByAppendingPathComponent: kAPCFileName_EncryptedZipFile];
        self.unencryptedZipURL                  = [NSURL fileURLWithPath: self.unencryptedZipPath];
        self.encryptedZipURL                    = [NSURL fileURLWithPath: self.encryptedZipPath];
    }


    if (errorToReturn != nil)
    {
        *errorToReturn = localError;
    }

    return ableToCreateWorkingFolder;
}

/**
 This takes the files we put into a temp directory during
 + moveUploadableFilesToSafeLocationReturningError:
 and puts them into the uploader-specific working directory we
 just made.
 */
- (BOOL) moveFilesToWorkingDirectoryReturningError: (NSError * __autoreleasing *) errorToReturn
{
    BOOL itWorked                       = NO;
    NSError *errorMovingFiles           = nil;
    NSError *errorCreatingPrivateFolder = nil;
    NSFileManager *fileManager          = [NSFileManager defaultManager];
    NSMutableArray *newArrayOfFilePaths = [NSMutableArray new];
    NSString *pathToPrivateFolder       = self.pathToPrivateFolderOfFilesToUpload;

    itWorked = [fileManager createAPCFolderAtPath: pathToPrivateFolder
                                   returningError: & errorCreatingPrivateFolder];

    /*
     TESTING

     Please leave this block of test code here.  It helps
     verify that we're handling each possible error correctly.

            itWorked = NO;
            errorCreatingPrivateFolder = [NSError errorWithDomain: @"fake underlying error creating private upload folder" code: 12 userInfo: nil];
     */

    if (! itWorked)
    {
        errorMovingFiles = [NSError errorWithCode: kErrorCantCreatePrivateFolder_Code
                                           domain: kArchiveAndUploadErrorDomain
                                    failureReason: kErrorCantCreatePrivateFolder_Reason
                               recoverySuggestion: kErrorCantCreatePrivateFolder_Suggestion
                                  relatedFilePath: pathToPrivateFolder
                                       relatedURL: nil
                                      nestedError: errorCreatingPrivateFolder];
    }

    else
    {
        NSError *errorMovingOneFile = nil;

        for (NSString *sourcePath in self.tempFilePathsToUpload)
        {
            NSString *filename = sourcePath.lastPathComponent;
            NSString *destinationPath = [pathToPrivateFolder stringByAppendingPathComponent: filename];

            itWorked = [fileManager moveItemAtPath: sourcePath
                                            toPath: destinationPath
                                             error: & errorMovingOneFile];

            /*
             TESTING

             Please leave this block of test code here.  It helps
             verify that we're handling each possible error correctly.

                    itWorked = NO;
                    errorMovingOneFile = [NSError errorWithDomain: @"fake underlying error moving one file to private upload area" code: 12 userInfo: nil];
             */

            if (! itWorked)
            {
                errorMovingFiles = [NSError errorWithCode: kErrorCantMoveRequestedUploadableFileToPrivateFolder_Code
                                                   domain: kArchiveAndUploadErrorDomain
                                            failureReason: kErrorCantMoveRequestedUploadableFileToPrivateFolder_Reason
                                       recoverySuggestion: kErrorCantMoveRequestedUploadableFileToPrivateFolder_Suggestion
                                          relatedFilePath: sourcePath
                                               relatedURL: nil
                                              nestedError: errorMovingOneFile];
                break;
            }

            else
            {
                [newArrayOfFilePaths addObject: destinationPath];
            }
        }
    }

    if (itWorked)
    {
        self.privateFilePathsToUpload = newArrayOfFilePaths;
    }

    if (errorToReturn != nil)
    {
        *errorToReturn = errorMovingFiles;
    }
    
    return itWorked;
}



// ---------------------------------------------------------
#pragma mark - Step 2:  Create the empty .zip archive, in RAM only
// ---------------------------------------------------------

- (BOOL) createZipArchiveInRamReturningError: (NSError * __autoreleasing *) errorToReturn
{
    BOOL ableToCreateZipArchive = NO;
    NSError *localError = nil;
    NSError *errorCreatingArchive = nil;

    self.zipArchive = [[ZZArchive alloc] initWithURL: self.unencryptedZipURL
                                             options: @{ ZZOpenOptionsCreateIfMissingKey : @(YES) }
                                               error: & errorCreatingArchive];

    /*
     TESTING

     Please leave this block of test code here.  It helps
     verify that we're handling each possible error correctly.

            self.zipArchive = nil;
            errorCreatingArchive = [NSError errorWithDomain: @"fake underlying error creating .zip file" code: 12 userInfo: nil];
     */

    if (! self.zipArchive)
    {
        localError = [NSError errorWithCode: kErrorCantCreateZipFile_Code
                                     domain: kArchiveAndUploadErrorDomain
                              failureReason: kErrorCantCreateZipFile_Reason
                         recoverySuggestion: kErrorCantCreateZipFile_Suggestion
                                nestedError: errorCreatingArchive];
    }
    else
    {
        ableToCreateZipArchive = YES;
    }


    if (errorToReturn != nil)
    {
        *errorToReturn = localError;
    }

    return ableToCreateZipArchive;
}



// ---------------------------------------------------------
#pragma mark - Step 3:  .zip dictionaries
// ---------------------------------------------------------

/**
 Loop through the dictionaries we have to send, inserting
 each into our .zip file.  If we have trouble doing any
 of them, stop, and don't do the rest.  Because of how
 this whole file works -- everything aborts at the first
 sign of an error -- that means if we have trouble
 .zipping anything, we stop everything (by design).
 */
- (BOOL) zipAllDictionariesReturningError: (NSError * __autoreleasing *) errorToReturn
{
    /*
     Note:  unlike most other methods in this file, the result
     value in this method defaults to "it worked."  If any sub-step
     fails, we'll change this to a "NO," and stop.
     */
    BOOL ableToZipEverything = YES;
    NSError *localError = nil;
    NSError *errorFromZipInsertProcess = nil;

    for (NSDictionary *dictionary in self.dictionariesToUpload)
    {
        NSString *filename = [self filenameFromDictionary: dictionary];

        ableToZipEverything = [self insertDictionary: dictionary
                          intoZipArchiveWithFilename: filename
                                      returningError: & errorFromZipInsertProcess];

        /*
         TESTING

         Please leave this block of test code here.  It helps
         verify that we're handling each possible error correctly.

                 ableToZipEverything = NO;
                 errorFromZipInsertProcess = [NSError errorWithDomain: @"fake underlying error inserting entry into .zip file" code: 12 userInfo: nil];
         */


        if (! ableToZipEverything)
        {
            // Something broke.  Stop looping, and report.
            localError = [NSError errorWithCode: kErrorCantInsertZipEntry_Code
                                         domain: kArchiveAndUploadErrorDomain
                                  failureReason: kErrorCantInsertZipEntry_Reason
                             recoverySuggestion: kErrorCantInsertZipEntry_Suggestion
                                    nestedError: errorFromZipInsertProcess];
            break;
        }
        else
        {
            // Yay!  Keep going, inserting the next item.
        }
    }

    if (errorToReturn != nil)
    {
        *errorToReturn = localError;
    }

    return ableToZipEverything;
}

/**
 Represents an old convention in this project:  the dictionary
 we're about to .zip must contain one entry with the name of that
 file.  Here, we'll try to extract it.  If we can't find it,
 no problem (kind of); we'll make one up.  At worst case, we'll
 have a .zip file with a bunch of files like "untitled_1.json", 
 "untitled_2.json", etc.
 */
- (NSString *) filenameFromDictionary: (NSDictionary *) dictionary
{
    //
    // Try to extract a filename from the dictionary.
    //
    NSString *filename = dictionary [kAPCNormalFileNameKey];

    if (filename == nil)
    {
        filename = dictionary [kAPCAlternateFileNameKey];
    }

    //
    // If that didn't work, use the next "unnamed_file" filename.
    //
    if (filename == nil)
    {
        self.countOfUnknownFileNames = self.countOfUnknownFileNames + 1;

        filename = [NSString stringWithFormat: kAPCUnknownFileNameFormatString, (int) self.countOfUnknownFileNames];
    }
    else
    {
        // We'll use the filename specified in the dictionary.
    }

    //
    // Normalize the filename:  remove extra "."s, spaces, etc.
    // (Not sure this is a good idea.)
    //
    //    filename = [self cleanUpFilename: filename];

    return filename;
}

//
// Please leave this commented-out method.  The code works; I'm
// just not sure we're going to keep it.
//
//    /**
//     Replace spaces, hyphens, dots, underscores, or sequences of
//     more than one of those things, with a single "_".
//
//     (Not sure this is a good idea.)
//
//     */
//    - (NSString *) cleanUpFilename: (NSString *) filename
//    {
//        NSString *newFilename = [filename stringByReplacingOccurrencesOfString: @"[_ .\\-]+"
//                                                                    withString: @"_"
//                                                                       options: NSRegularExpressionSearch
//                                                                         range: NSMakeRange (0, filename.length)];
//
//        return newFilename;
//    }
//

- (BOOL)      insertDictionary: (NSDictionary *) dictionary
    intoZipArchiveWithFilename: (NSString *) filename
                returningError: (NSError * __autoreleasing *) errorToReturn
{
    BOOL ableToInsertDictionaryIntoZipFile = NO;
    NSError *localError = nil;


    /*
     Get a serializable copy of our data -- specifically, one
     that can be converted to JSON by NSJSONSerialization.

     There should never (ahem) be an error here.  Our
     -serializableDictionaryFromSourceDictionary: method stringifies
     everything it doesn't have a custom converter for, and uses
     NSJSONSerialization to validate everything it does.
     */
    NSDictionary *uploadableData = [APCJSONSerializer serializableDictionaryFromSourceDictionary: dictionary];

    NSError *errorSerializingTheData = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: uploadableData
                                                       options: NSJSONWritingPrettyPrinted
                                                         error: & errorSerializingTheData];

    /*
     TESTING

     Please leave this block of test code here.  It helps
     verify that we're handling each possible error correctly.

            jsonData = nil;
            errorSerializingTheData = [NSError errorWithDomain: @"fake underlying error serializing some data" code: 12 userInfo: nil];
     */


    if (jsonData == nil)
    {
        localError = [NSError errorWithCode: kErrorCantSerializeObject_Code
                                     domain: kArchiveAndUploadErrorDomain
                              failureReason: kErrorCantSerializeObject_Reason
                         recoverySuggestion: kErrorCantSerializeObject_Suggestion
                                nestedError: errorSerializingTheData];
    }

    else
    {
        /*
         If we get here, assume everything else is going to work.
         (Ahem.)

         TODO:  Look for ways that errors might be generated by the
         method calls in this block of code.  As of this writing,
         they look safe -- but that really suggests we're missing
         a place where an NSError *should* have been returned.
         */
        ableToInsertDictionaryIntoZipFile = YES;


        NSString * fullFileName = [filename stringByAppendingPathExtension: kAPCFileExtension_JSON];

        APCLogFilenameBeingArchived (fullFileName);

        ZZArchiveEntry *zipEntry = [ZZArchiveEntry archiveEntryWithFileName: fullFileName
                                                                   compress: YES
                                                                  dataBlock: ^(NSError * __autoreleasing * __unused callbackError)
                                    {
                                        return jsonData;
                                    }];

        [self.zipEntries addObject: zipEntry];

        NSDictionary *fileInfoEntry = @{ kAPCSerializedDataKey_FileInfoName: fullFileName,
                                         kAPCSerializedDataKey_FileInfoTimeStamp: [NSDate date],
                                         kAPCSerializedDataKey_FileInfoContentType: kAPCContentType_JSON };

        [self.fileInfoEntries addObject: fileInfoEntry];
    }

    if (errorToReturn != nil)
    {
        *errorToReturn = localError;
    }

    return ableToInsertDictionaryIntoZipFile;
}



// ---------------------------------------------------------
#pragma mark - Step 4:  .zip files
// ---------------------------------------------------------

/**
 Loop through the files we were asked to upload, inserting
 each into our .zip file.  If we have trouble doing any
 of them, stop, and don't do the rest.  Because of how
 this whole file works -- everything aborts at the first
 sign of an error -- that means if we have trouble
 .zipping anything, we stop everything (by design).
 */
- (BOOL) zipAllRequestedFilePathsReturningError: (NSError * __autoreleasing *) errorToReturn
{
    /*
     Note:  unlike most other methods in this file, the result
     value in this method defaults to "it worked."  If any sub-step
     fails, we'll change this to a "NO," and stop.
     */
    BOOL ableToZipEverything = YES;
    NSError *localError = nil;
    NSError *errorFromZipInsertProcess = nil;

    for (NSString *path in self.privateFilePathsToUpload)
    {
        ableToZipEverything = [self insertFileAtPath: path
                        intoZipArchiveReturningError: & errorFromZipInsertProcess];

        /*
         TESTING

         Please leave this block of test code here.  It helps
         verify that we're handling each possible error correctly.

                 ableToZipEverything = NO;
                 errorFromZipInsertProcess = [NSError errorWithDomain: @"fake underlying error inserting entry into .zip file" code: 12 userInfo: nil];
         */


        if (! ableToZipEverything)
        {
            // Something broke.  Stop looping, and report.
            localError = [NSError errorWithCode: kErrorCantInsertZipEntry_Code
                                         domain: kArchiveAndUploadErrorDomain
                                  failureReason: kErrorCantInsertZipEntry_Reason
                             recoverySuggestion: kErrorCantInsertZipEntry_Suggestion
                                    nestedError: errorFromZipInsertProcess];
            break;
        }
        else
        {
            // Yay!  Keep going, inserting the next item.
        }
    }

    if (errorToReturn != nil)
    {
        *errorToReturn = localError;
    }

    return ableToZipEverything;
}

- (BOOL)        insertFileAtPath: (NSString *) path
    intoZipArchiveReturningError: (NSError * __autoreleasing *) errorToReturn
{
    BOOL ableToInsertRequestedFileIntoZipFile = NO;
    NSError *localError = nil;


    /*
     Try to find the requested file.
     */
    BOOL ableToFindFile = [[NSFileManager defaultManager] fileExistsAtPath: path];


    /*
     TESTING

     Please leave this block of test code here.  It helps
     verify that we're handling each possible error correctly.

            ableToFindFile = NO;
     */

    if (! ableToFindFile)
    {
        // Can't find one of the requestd files.  Stop looping, and report.
        localError = [NSError errorWithCode: kErrorCantFindRequestedUploadableFile_Code
                                     domain: kArchiveAndUploadErrorDomain
                              failureReason: kErrorCantFindRequestedUploadableFile_Reason
                         recoverySuggestion: kErrorCantFindRequestedUploadableFile_Suggestion
                            relatedFilePath: path
                                 relatedURL: nil
                                nestedError: nil];
    }

    else
    {
        NSError *errorReadingFile = nil;
        NSData *dataFromThatFile = [NSData dataWithContentsOfFile: path
                                                          options: NSDataReadingMappedIfSafe
                                                            error: &errorReadingFile];

        /*
         TESTING

         Please leave this block of test code here.  It helps
         verify that we're handling each possible error correctly.

                 dataFromThatFile = nil;
                 errorReadingFile = [NSError errorWithDomain: @"fake underlying error reading data from file" code: 12 userInfo: nil];
         */


        if (dataFromThatFile == nil)
        {
            localError = [NSError errorWithCode: kErrorCantReadRequestedUploadableFile_Code
                                         domain: kArchiveAndUploadErrorDomain
                                  failureReason: kErrorCantReadRequestedUploadableFile_Reason
                             recoverySuggestion: kErrorCantReadRequestedUploadableFile_Suggestion
                                relatedFilePath: path
                                     relatedURL: nil
                                    nestedError: errorReadingFile];
        }

        else
        {
            /*
             If we get here, assume everything else is going to work.
             (Ahem.)

             TODO:  Look for ways that errors might be generated by the
             method calls in this block of code.  As of this writing,
             they look safe -- but that really suggests we're missing
             a place where an NSError *should* have been returned.
             */
            ableToInsertRequestedFileIntoZipFile = YES;

            
            APCLogFilenameBeingArchived (path);

            NSString *filename = path.lastPathComponent;
            NSString *contentType = [self contentTypeForFileAtPath: path];

            /*
             TODO:  Explore using the stream-based ZZArchiveEntry method,
             so we don't have to slurp the whole file into RAM.
             */
            ZZArchiveEntry *zipEntry = [ZZArchiveEntry archiveEntryWithFileName: filename
                                                                       compress: YES
                                                                      dataBlock: ^(NSError * __autoreleasing * __unused callbackError)
                                        {
                                            return dataFromThatFile;
                                        }];

            [self.zipEntries addObject: zipEntry];

            NSDictionary *fileInfoEntry = @{ kAPCSerializedDataKey_FileInfoName: filename,
                                             kAPCSerializedDataKey_FileInfoTimeStamp: [NSDate date],
                                             kAPCSerializedDataKey_FileInfoContentType: contentType };

            [self.fileInfoEntries addObject: fileInfoEntry];
        }
    }
    
    if (errorToReturn != nil)
    {
        *errorToReturn = localError;
    }
    
    return ableToInsertRequestedFileIntoZipFile;
}

- (NSString *) contentTypeForFileAtPath: (NSString *) path
{
    NSString *extension = path.pathExtension.lowercaseString;

    NSString *contentType = kAPCContentType_UnknownData;

    if      ([extension isEqualToString: kAPCFileExtension_CommaSeparatedValues])   { contentType = kAPCContentType_CommaSeparatedValues; }
    else if ([extension isEqualToString: kAPCFileExtension_JSON])                   { contentType = kAPCContentType_JSON; }
    else if ([extension isEqualToString: kAPCFileExtension_MPEG4Audio])             { contentType = kAPCContentType_MPEG4Audio; }
    else if ([extension isEqualToString: kAPCFileExtension_PlainText])              { contentType = kAPCContentType_PlainText; }
    else if ([extension isEqualToString: kAPCFileExtension_PlainTextShort])         { contentType = kAPCContentType_PlainText; }
    else                                                                            { contentType = kAPCContentType_UnknownData; }

    return contentType;
}



// ---------------------------------------------------------
#pragma mark - Step 5:  Create a "manifest"
// ---------------------------------------------------------

/**
 In our world, we upload a bunch of files in a .zip file.
 Then we include an "info.json" file to describe that
 bunch of files.  This method generates that "info.json"
 file.
 */
- (BOOL) createManifestReturningError: (NSError * __autoreleasing *) errorToReturn
{
    BOOL ableToCreateManifest = NO;
    NSError *localError = nil;

    /*
     TESTING

     Please leave this block of test code here.  It helps
     verify that we're handling each possible error correctly.

             self.fileInfoEntries = nil;
     */


    if (self.fileInfoEntries.count == 0)
    {
        localError = [NSError errorWithCode: kErrorDontHaveAnyZippedFiles_Code
                                     domain: kArchiveAndUploadErrorDomain
                              failureReason: kErrorDontHaveAnyZippedFiles_Reason
                         recoverySuggestion: kErrorDontHaveAnyZippedFiles_Suggestion];
    }
    else
    {
        // These two values should never be nil.  But if they
        // are, ship them anyway, so that Sage can catch them
        // and ask us about them.  The programmer who wrote this
        // call to the uploader will then, appropriately, provide
        // those values.
        id taskIdentifier = self.taskIdentifier ?: [NSNull null];
        id taskRunUuid    = self.taskRunUuid    ?: [NSNull null];

        NSDictionary *zipArchiveManifest = @{ kAPCSerializedDataKey_Files       : self.fileInfoEntries,
                                              kAPCSerializedDataKey_Item        : taskIdentifier,
                                              kAPCSerializedDataKey_TaskRun     : taskRunUuid,
                                              kAPCSerializedDataKey_AppName     : appName,
                                              kAPCSerializedDataKey_AppVersion  : appVersion,
                                              kAPCSerializedDataKey_PhoneInfo   : phoneInfo
                                              };

        NSError *errorCreatingManifest = nil;

        ableToCreateManifest = [self insertDictionary: zipArchiveManifest
                           intoZipArchiveWithFilename: kAPCNameOfIndexFile
                                       returningError: & errorCreatingManifest];


        /*
         TESTING

         Please leave this block of test code here.  It helps
         verify that we're handling each possible error correctly.

                ableToCreateManifest = NO;
                errorCreatingManifest = [NSError errorWithDomain: @"fake underlying error creating manifest file entry" code: 12 userInfo: nil];
         */


        if (! ableToCreateManifest)
        {
            NSString *errorMessage = [NSString stringWithFormat: kErrorCantCreateManifest_SuggestionFormat,
                                      kAPCNameOfIndexFile,
                                      kAPCFileExtension_JSON];

            localError = [NSError errorWithCode: kErrorCantCreateManifest_Code
                                         domain: kArchiveAndUploadErrorDomain
                                  failureReason: kErrorCantCreateManifest_Reason
                             recoverySuggestion: errorMessage
                                    nestedError: errorCreatingManifest];
        }
        else
        {
            // Yay!  It worked.
            // ableToCreateManifest is already set correctly.
        }
    }

    if (errorToReturn != nil)
    {
        *errorToReturn = localError;
    }

    return ableToCreateManifest;
}



// ---------------------------------------------------------
#pragma mark - Step 6:  Save to Disk
// ---------------------------------------------------------

- (BOOL) saveToDiskReturningError: (NSError * __autoreleasing *) errorToReturn
{
    BOOL ableToSaveToDisk = NO;
    NSError *localError = nil;
    NSError *errorSavingToDisk = nil;

    ableToSaveToDisk = [self.zipArchive updateEntries: self.zipEntries
                                                error: & errorSavingToDisk];

    /*
     TESTING

     Please leave this block of test code here.  It helps
     verify that we're handling each possible error correctly.

            ableToSaveToDisk = NO;
            errorSavingToDisk = [NSError errorWithDomain: @"fake underlying error saving .zip file" code: 12 userInfo: nil];
     */


    if (! ableToSaveToDisk)
    {
        localError = [NSError errorWithCode: kErrorCantSaveUnencryptedFile_Code
                                     domain: kArchiveAndUploadErrorDomain
                              failureReason: kErrorCantSaveUnencryptedFile_Reason
                         recoverySuggestion: kErrorCantSaveUnencryptedFile_Suggestion
                                nestedError: errorSavingToDisk];
    }

    else
    {
        NSError *errorFindingSavedFileOnDisk = nil;

        ableToSaveToDisk = [self.zipArchive.URL checkResourceIsReachableAndReturnError: & errorFindingSavedFileOnDisk];


        /*
         TESTING

         Please leave this block of test code here.  It helps
         verify that we're handling each possible error correctly.

                 ableToSaveToDisk = NO;
                 errorFindingSavedFileOnDisk = [NSError errorWithDomain: @"fake underlying error finding .zipped file" code: 12 userInfo: nil];
         */


        if (! ableToSaveToDisk)
        {
            // Something went wrong:  we thought we zipped it, but we couldn't
            // find it afterwards.
            localError = [NSError errorWithCode: kErrorCantFindUnencryptedFile_Code
                                         domain: kArchiveAndUploadErrorDomain
                                  failureReason: kErrorCantFindUnencryptedFile_Reason
                             recoverySuggestion: kErrorCantFindUnencryptedFile_Suggestion
                                    nestedError: errorFindingSavedFileOnDisk];
        }
        else
        {
            // Hooray!
            // ableToSaveToDisk is already set correctly.
        }
    }

    if (errorToReturn != nil)
    {
        *errorToReturn = localError;
    }

    return ableToSaveToDisk;
}



// ---------------------------------------------------------
#pragma mark - Step 7:  Encrypt
// ---------------------------------------------------------

- (BOOL) encryptZipFileReturningError: (NSError * __autoreleasing *) errorToReturn
{
    BOOL successfullyEncrypted  = NO;
    NSError *localError         = nil;
    NSString *unencryptedPath   = self.zipArchive.URL.relativePath;   // NOT self.zipArchive.URL.absoluteString !  Don't know why, though.
    NSString *encryptedPath     = self.encryptedZipPath;

    /*
     Look at the structure of this next, big "if" statement.

     Every step says:
     - try something
     - if it fails, create an error
     - otherwise, try the next part
     
     Here we go.
     */


    NSError *errorReadingDisk = nil;
    NSData *unencryptedZipData = [NSData dataWithContentsOfFile: unencryptedPath
                                                        options: 0
                                                          error: & errorReadingDisk];

    /*
     TESTING

     Please leave this block of test code here.  It helps
     verify that we're handling each possible error correctly.

            unencryptedZipData = nil;
            errorReadingDisk = [NSError errorWithDomain: @"fake underlying error reading .zip file from disk" code: 12 userInfo: nil];
     */

    if (unencryptedZipData == nil)
    {
        localError = [NSError errorWithCode: kErrorCantReadUnencryptedFile_Code
                                     domain: kArchiveAndUploadErrorDomain
                              failureReason: kErrorCantReadUnencryptedFile_Reason
                         recoverySuggestion: kErrorCantReadUnencryptedFile_Suggestion
                            relatedFilePath: unencryptedPath
                                 relatedURL: self.zipArchive.URL
                                nestedError: errorReadingDisk];
    }
    else
    {
        APCAppDelegate * appDelegate = (APCAppDelegate*) UIApplication.sharedApplication.delegate;
        NSString *privateKeyFilePath = [[NSBundle mainBundle] pathForResource: appDelegate.certificateFileName
                                                                       ofType: kAPCFileExtension_PrivateKey];

        NSError *encryptionError = nil;
        NSData *encryptedZipData = cmsEncrypt (unencryptedZipData, privateKeyFilePath, & encryptionError);


        /*
         TESTING

         Please leave this block of test code here.  It helps
         verify that we're handling each possible error correctly.

                 encryptedZipData = nil;
                 encryptionError = [NSError errorWithDomain: @"fake underlying error encrypting .zip file" code: 12 userInfo: nil];
         */

        if (! encryptedZipData)
        {
            localError = [NSError errorWithCode: kErrorCantEncryptFile_Code
                                         domain: kArchiveAndUploadErrorDomain
                                  failureReason: kErrorCantEncryptFile_Reason
                             recoverySuggestion: kErrorCantEncryptFile_Suggestion
                                    nestedError: encryptionError];
        }

        else
        {
            NSError *errorSavingToDisk = nil;
            BOOL weSavedIt = [encryptedZipData writeToFile: encryptedPath
                                                    options: NSDataWritingAtomic
                                                      error: & errorSavingToDisk];

            /*
             TESTING

             Please leave this block of test code here.  It helps
             verify that we're handling each possible error correctly.

                     weSavedIt = NO;
                     errorSavingToDisk = [NSError errorWithDomain: @"fake underlying error saving encrypted .zip file to disk" code: 12 userInfo: nil];
             */

            if (! weSavedIt)
            {
                localError = [NSError errorWithCode: kErrorCantSaveEncryptedFile_Code
                                             domain: kArchiveAndUploadErrorDomain
                                      failureReason: kErrorCantSaveEncryptedFile_Reason
                                 recoverySuggestion: kErrorCantSaveEncryptedFile_Suggestion
                                        nestedError: errorSavingToDisk];
            }

            else
            {
                NSError *errorReachingZippedFile = nil;
                BOOL itsReallyThere = [self.encryptedZipURL checkResourceIsReachableAndReturnError: & errorReachingZippedFile];

                /*
                 TESTING

                 Please leave this block of test code here.  It helps
                 verify that we're handling each possible error correctly.

                         itsReallyThere = NO;
                         errorReachingZippedFile = [NSError errorWithDomain: @"fake underlying error locating encrypted .zip file on disk" code: 12 userInfo: nil];
                 */

                if (! itsReallyThere)
                {
                    localError = [NSError errorWithCode: kErrorCantFindEncryptedFile_Code
                                                 domain: kArchiveAndUploadErrorDomain
                                          failureReason: kErrorCantFindEncryptedFile_Reason
                                     recoverySuggestion: kErrorCantFindEncryptedFile_Suggestion
                                            nestedError: errorReachingZippedFile];
                }

                else
                {
                    // Hooray!  We're done.
                    successfullyEncrypted = YES;
                }
            }
        }
    }

    if (errorToReturn != nil)
    {
        *errorToReturn = localError;
    }

    return successfullyEncrypted;
}



// ---------------------------------------------------------
#pragma mark - Step 8:  Upload to Sage
// ---------------------------------------------------------

/**
 Ship it!

 Note that this method uses "self" completely safely.
 This "self" object has been shoved into a static array
 until we hear back from Sage.
 */
- (void) beginTheUpload
{
    /*
     In our special debug-ish mode, copy the unencrypted
     file to our local data-verification server.
     
     Do this before sending to Sage, so we can actually be
     sure to send it to the local server before deleting it
     (which happens in the callback from Sage).

     We're #if-ing it to make sure this code isn't accessible
     to Bad Guys in production.  Even if the code isn't called,
     if it's in RAM at all, it can be exploited.
     */
    #ifdef USE_DATA_VERIFICATION_SERVER

        [APCDataVerificationClient uploadDataFromFileAtPath: self.unencryptedZipPath];
        
    #endif



    /*
     Log it.
     */
    APCLogFilenameBeingUploaded (self.encryptedZipPath);


    /*
     Ship it.

     Note that if the app goes to the background,
     this response from Bridge *should wake the app*,
     and we need to write code to handle that response,
     somewhere in AppDelegate.  (...TBD?)
     */
    [SBBComponent(SBBUploadManager) uploadFileToBridge: self.encryptedZipURL
                                           contentType: kAPCContentType_JSON
                                            completion: ^(NSError *uploadError)
     {
         NSError * localError = nil;

        /*
         TESTING

         Please leave this block of test code here.  It helps
         verify that we're handling each possible error correctly.

                 uploadError = [NSError errorWithDomain: @"fake underlying error uploading file to the server" code: 12 userInfo: nil];
         */

         if (uploadError != nil)
         {
             localError = [NSError errorWithCode: kErrorUploadFailed_Code
                                          domain: kArchiveAndUploadErrorDomain
                                   failureReason: kErrorUploadFailed_Reason
                              recoverySuggestion: kErrorUploadFailed_Suggestion
                                     nestedError: uploadError];
         }

         [self finalCleanupHandlingError: localError];
     }];
}



// ---------------------------------------------------------
#pragma mark - Step 9:  Clean Up
// ---------------------------------------------------------

/**
 For better or worse, we're done.  Report any errors,
 clean up, report to the user (um, eventually?), and
 delete myself.
 */
- (void) finalCleanupHandlingError: (NSError *) error
{
    /*
     This should be the only place in this file where we
     print any errors.  Everything else errors out as
     fast as possible and falls through to here.
     
     In addition, this error should be a "normalized"
     error -- it should be one of our custom-crafted
     errors, optionally containing an original error
     which generated it.
     */
    if (error != nil)
    {
        APCLogError2 (error);
    }
    
    __weak typeof(self) weakSelf = self;
    
    if (self.uploaderCompletionCallback)
    {
        if (self.callbackQueue)
        {
            [self.callbackQueue addOperationWithBlock:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.uploaderCompletionCallback(error);
            }];
        }
        else
        {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.uploaderCompletionCallback(error);
        }
    }

    [self cleanUpAndDestroyWorkingDirectory];


    // Remove the last pointer to myself.  I should be freed
    // verrrry soon afterwards.
    [[self class] stopTrackingArchiver: self];
}

/**
 Trash all files we created, and then trash the working
 directory itself.
 */
- (void) cleanUpAndDestroyWorkingDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullFilePath = nil;

    NSArray *files = [fileManager contentsOfDirectoryAtPath: self.pathToTempFolderOfFilesToUpload error: nil];

    for (NSString *filePath in files)
    {
        fullFilePath = [self.pathToTempFolderOfFilesToUpload stringByAppendingPathComponent: filePath];
        [self trashFileOrFolderAtPath: fullFilePath];
    }
    
    files = [fileManager contentsOfDirectoryAtPath: self.pathToPrivateFolderOfFilesToUpload error: nil];

    for (NSString *filePath in files)
    {
        fullFilePath = [self.pathToPrivateFolderOfFilesToUpload stringByAppendingPathComponent: filePath];
        [self trashFileOrFolderAtPath: fullFilePath];
    }
    
    [self trashFileOrFolderAtPath: self.pathToTempFolderOfFilesToUpload];
    [self trashFileOrFolderAtPath: self.pathToPrivateFolderOfFilesToUpload];
    [self trashFileOrFolderAtPath: self.unencryptedZipPath];
    [self trashFileOrFolderAtPath: self.encryptedZipPath];
    [self trashFileOrFolderAtPath: self.workingDirectoryPath];
}

/**
 Deletes the specified file/folder if it's non-nil and
 actually exists.
 
 This method is specifically designed to check for "nil"
 paths, so I can wantonly call "delete" on everything I
 MIGHT have created, without checking to see whether I 
 actually DID create it.
 */
- (void) trashFileOrFolderAtPath: (NSString *) fileOrFolderPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (fileOrFolderPath != nil && [fileManager fileExistsAtPath: fileOrFolderPath])
    {
        /*
         Please leave this commented-out debugging command here.
         It's a reminder that we need to delete every file and
         folder we create.

                APCLogDebug (@"Cleaning up: removing file or folder at path [%@]...", fileOrFolderPath);
         */

        NSError *errorDeletingFileOrDirectory = nil;

        BOOL itemDeleted = [fileManager removeItemAtPath: fileOrFolderPath
                                                   error: &errorDeletingFileOrDirectory];

        if (! itemDeleted)
        {
            // Last chance to report this problem.
            NSError * localError = [NSError errorWithCode: kErrorCantDeleteFileOrFolder_Code
                                                   domain: kArchiveAndUploadErrorDomain
                                            failureReason: kErrorCantDeleteFileOrFolder_Reason
                                       recoverySuggestion: kErrorCantDeleteFileOrFolder_Suggestion
                                          relatedFilePath: fileOrFolderPath
                                               relatedURL: nil
                                              nestedError: errorDeletingFileOrDirectory];

            APCLogError2 (localError);
        }
    }
}


@end












