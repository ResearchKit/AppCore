//
//  APCDataArchiverAndUploader.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
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


static BOOL       const K_DEBUG_INCLUDE_TESTING_MESSAGE         = YES;
static NSString * const kAPCUploaderThisIsATestMessage_Key      = @"THIS_IS_A_TEST";
static NSString * const kAPCUploaderThisIsATestMessage_Message  = @"Dear Sage folks:  This whole .zip file is a test, as we work on improving the health apps.  Please ignore.";
static NSString * const kAPCSerializedDataKey_PhoneInfo         = @"phoneInfo";
static NSString * const kAPCNormalFileNameKey                   = @"item";          // not sure why these two things are used
static NSString * const kAPCAlternateFileNameKey                = @"identifier";    // as filenames.  Soon, we can change that.
static NSString * const kAPCNameOfIndexFile                     = @"info";
static NSString * const kAPCUnknownFileNameFormatString         = @"UnknownFile_%d";

static NSString * const kAPCOperationQueueName_ArchiveAndUpload_General                     = @"ArchiveAndUpload: Generic zip-and-upload queue";
static NSString * const kAPCOperationQueueName_ArchiveAndUpload_ModifyingListOfArchivers    = @"ArchiveAndUpload: Queue for adding and removing archivers to a global list";



// ---------------------------------------------------------
#pragma mark - Error Codes and Strings (more constants)
// ---------------------------------------------------------

typedef enum : NSInteger
{
    APCErrorCode_Undetermined                               = -1,
    APCErrorCode_None                                       = 0,
    APCErrorCode_ArchiveAndUpload_NoErrors                  = 100,
    APCErrorCode_ArchiveAndUpload_CantCreateZipFile,
    APCErrorCode_ArchiveAndUpload_CantSerializeObject,
    APCErrorCode_ArchiveAndUpload_CantInsertZipEntry,
    APCErrorCode_ArchiveAndUpload_CantReadUnencryptedFile,
    APCErrorCode_ArchiveAndUpload_CantFindDocumentsFolder,
    APCErrorCode_ArchiveAndUpload_CantCreateArchiveFolder,
    APCErrorCode_ArchiveAndUpload_CantCreateUploadFolder,
    APCErrorCode_ArchiveAndUpload_CantCreateWorkingDirectory,
    APCErrorCode_ArchiveAndUpload_DontHaveAnyZippedFiles,
    APCErrorCode_ArchiveAndUpload_CantCreateManifest,
    APCErrorCode_ArchiveAndUpload_CantSaveUnencryptedFile,
    APCErrorCode_ArchiveAndUpload_CantFindUnencryptedFile,
    APCErrorCode_ArchiveAndUpload_CantEncryptFile,
    APCErrorCode_ArchiveAndUpload_CantSaveEncryptedFile,
    APCErrorCode_ArchiveAndUpload_CantFindEncryptedFile,
    APCErrorCode_ArchiveAndUpload_UploadFailed,
    APCErrorCode_ArchiveAndUpload_CantDeleteFileOrFolder,

} APCErrorCode;


static NSString * const kAPCError_CoreData_Domain                                           = @"kAPCError_CoreData_Domain";

static NSString * const kAPCError_ArchiveAndUpload_Domain                                   = @"kAPCError_ArchiveAndUpload_Domain";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateZipFile_Reason                 = @"Can't Create Archive in Memory";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateZipFile_Suggestion             = @"We couldn't create the new, placeholder .zip file in RAM.  (We haven't even gotten to the 'save to disk' part.)";
static NSString * const kAPCError_ArchiveAndUpload_CantSerializeObject_Reason               = @"Can't Serialize Object";
static NSString * const kAPCError_ArchiveAndUpload_CantSerializeObject_Suggestion           = @"We couldn't generate a JSON version of some piece of data.";
static NSString * const kAPCError_ArchiveAndUpload_CantInsertZipEntry_Reason                = @"Can't Insert Zip Entry";
static NSString * const kAPCError_ArchiveAndUpload_CantInsertZipEntry_Suggestion            = @"We couldn't add one of the .zippable items to the .zip file.";
static NSString * const kAPCError_ArchiveAndUpload_CantReadUnencryptedFile_Reason           = @"Can't Open Archive";
static NSString * const kAPCError_ArchiveAndUpload_CantReadUnencryptedFile_Suggestion       = @"Couldn't read the unencrypted .zip file we just tried to create.";
static NSString * const kAPCError_ArchiveAndUpload_CantFindDocumentsFolder_Reason           = @"Can't Find 'Documents' Folder";
static NSString * const kAPCError_ArchiveAndUpload_CantFindDocumentsFolder_Suggestion       = @"Couldn't find the user's 'documents' folder. This should never happen. Ahem.";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateArchiveFolder_Reason           = @"Can't create 'Archive' folder";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateArchiveFolder_Suggestion       = @"Couldn't create the folder for preparing our .zip files.";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateUploadFolder_Reason            = @"Can't create 'Upload' folder";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateUploadFolder_Suggestion        = @"Couldn't create the folder for saving files to be uploaded.";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateWorkingDirectory_Reason        = @"Can't Create Working Folder";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateWorkingDirectory_Suggestion    = @"Couldn't create a folder in which to make our .zip file.";
static NSString * const kAPCError_ArchiveAndUpload_DontHaveAnyZippedFiles_Reason            = @"Don't Have Files For Archive";
static NSString * const kAPCError_ArchiveAndUpload_DontHaveAnyZippedFiles_Suggestion        = @"Something went wrong. We don't seem to have any contents for this .zip file.";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateManifest_Reason                = @"Can't Create Manifest";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateManifest_Suggestion_Format     = @"Couldn't create the manifest file entry (%@.%@) in the .zip file.";
static NSString * const kAPCError_ArchiveAndUpload_CantSaveUnencryptedFile_Reason           = @"Can't Save Unencrypted File";
static NSString * const kAPCError_ArchiveAndUpload_CantSaveUnencryptedFile_Suggestion       = @"We couldn't save the unencrypted .zip file to disk.";
static NSString * const kAPCError_ArchiveAndUpload_CantFindUnencryptedFile_Reason           = @"Can't Find Unencrypted File";
static NSString * const kAPCError_ArchiveAndUpload_CantFindUnencryptedFile_Suggestion       = @"We couldn't find the unencrypted .zip file on disk (even though we seem to have successfully saved it...?).";
static NSString * const kAPCError_ArchiveAndUpload_CantEncryptFile_Reason                   = @"Can't Encrypt Zip File";
static NSString * const kAPCError_ArchiveAndUpload_CantEncryptFile_Suggestion               = @"We couldn't encrypt the .zip file we need to upload.";
static NSString * const kAPCError_ArchiveAndUpload_CantSaveEncryptedFile_Reason             = @"Can't Save Encrypted File";
static NSString * const kAPCError_ArchiveAndUpload_CantSaveEncryptedFile_Suggestion         = @"We couldn't save the encrypted .zip file to disk.";
static NSString * const kAPCError_ArchiveAndUpload_CantFindEncryptedFile_Reason             = @"Can't Find Encrypted File";
static NSString * const kAPCError_ArchiveAndUpload_CantFindEncryptedFile_Suggestion         = @"We couldn't find the encrypted .zip file on disk (even though we seem to have successfully encrypted it...?).";
static NSString * const kAPCError_ArchiveAndUpload_UploadFailed_Reason                      = @"Upload to Sage Failed";
static NSString * const kAPCError_ArchiveAndUpload_UploadFailed_Suggestion                  = @"We got an error when uploading to Sage.  See the nested error for details.";
static NSString * const kAPCError_ArchiveAndUpload_CantDeleteFileOrFolder_Reason            = @"Can't Delete File/Folder";
static NSString * const kAPCError_ArchiveAndUpload_CantDeleteFileOrFolder_Suggestion        = @"We couldn't delete a file/folder creating during the archiving process. See attached path and nested error, if any, for details.";



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

@property (nonatomic, assign) NSUInteger            countOfUnknownFileNames;
@end



@implementation APCDataArchiverAndUploader



// ---------------------------------------------------------
#pragma mark - Setting up class and queues
// ---------------------------------------------------------

/**
 Per Apple:  this method is called once per class, in a thread-safe
 way, the first time the class is sent a message.  That includes the
 "alloc" message, which means we can use this to set up stuff that
 applies to all objects (instances) of this class.
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

+ (void) uploadOneDictionary: (NSDictionary *) dictionary
{
    [queueForArchivingAndUploading addOperationWithBlock:^{

        APCDataArchiverAndUploader *archiverAndUploader = [[APCDataArchiverAndUploader alloc] initWithDictionariesToUpload: @[dictionary]];

        [archiverAndUploader go];
    }];
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
#pragma mark - Create one uploader
// ---------------------------------------------------------

- (id) init
{
    self = [super init];

    if (self)
    {
        _zipEntries                 = [NSMutableArray new];
        _fileInfoEntries            = [NSMutableArray new];
        _countOfUnknownFileNames    = 0;


        // This will be filled with stuff to ship.
        _dictionariesToUpload   = nil;


        // These will be set if we can successfully create a working directory.
        _workingDirectoryPath   = nil;
        _unencryptedZipPath     = nil;
        _encryptedZipPath       = nil;
        _unencryptedZipURL      = nil;
        _encryptedZipURL        = nil;


        /*
         Register with a static variable, so I don't
         get deleted while waiting for Sage to reply.
         I'll un-register myself in -finalCleanup.
         */
        [[self class] trackNewArchiver: self];
    }

    return self;
}

- (id) initWithDictionariesToUpload: (NSArray *) arrayOfDictionaries
{
    self = [self init];

    if (self)
    {
        _dictionariesToUpload = [NSArray arrayWithArray: arrayOfDictionaries];
    }

    return self;
}



// ---------------------------------------------------------
#pragma mark - The main method:  calls all other methods below.
// ---------------------------------------------------------

- (void) go
{
    NSError *error = nil;
    BOOL ok = YES;


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
    if (ok) {  ok = [self createZipArchiveInRamReturningError           : & error];  }
    if (ok) {  ok = [self zipAllDictionariesReturningError              : & error];  }
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
- (BOOL) createBaseFoldersDuringFirstRunReturningError: (NSError **) errorToReturn
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
            localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantFindDocumentsFolder
                                         domain: kAPCError_ArchiveAndUpload_Domain
                                  failureReason: kAPCError_ArchiveAndUpload_CantFindDocumentsFolder_Reason
                             recoverySuggestion: kAPCError_ArchiveAndUpload_CantFindDocumentsFolder_Suggestion];
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
                localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantCreateArchiveFolder
                                             domain: kAPCError_ArchiveAndUpload_Domain
                                      failureReason: kAPCError_ArchiveAndUpload_CantCreateArchiveFolder_Reason
                                 recoverySuggestion: kAPCError_ArchiveAndUpload_CantCreateArchiveFolder_Suggestion
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
                    localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantCreateUploadFolder
                                                 domain: kAPCError_ArchiveAndUpload_Domain
                                          failureReason: kAPCError_ArchiveAndUpload_CantCreateUploadFolder_Reason
                                     recoverySuggestion: kAPCError_ArchiveAndUpload_CantCreateUploadFolder_Suggestion
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

- (BOOL) createWorkingDirectoryReturningError: (NSError **) errorToReturn
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
        localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantCreateWorkingDirectory
                                     domain: kAPCError_ArchiveAndUpload_Domain
                              failureReason: kAPCError_ArchiveAndUpload_CantCreateWorkingDirectory_Reason
                         recoverySuggestion: kAPCError_ArchiveAndUpload_CantCreateWorkingDirectory_Suggestion
                                nestedError: directoryCreationError];
    }
    else
    {
        self.workingDirectoryPath   = workingDirectoryPath;
        self.unencryptedZipPath     = [workingDirectoryPath stringByAppendingPathComponent: kAPCFileName_UnencryptedZipFile];
        self.encryptedZipPath       = [workingDirectoryPath stringByAppendingPathComponent: kAPCFileName_EncryptedZipFile];
        self.unencryptedZipURL      = [NSURL fileURLWithPath: self.unencryptedZipPath];
        self.encryptedZipURL        = [NSURL fileURLWithPath: self.encryptedZipPath];
    }


    if (errorToReturn != nil)
    {
        *errorToReturn = localError;
    }

    return (ableToCreateWorkingFolder);
}



// ---------------------------------------------------------
#pragma mark - Step 2:  Create the empty .zip archive, in RAM only
// ---------------------------------------------------------

- (BOOL) createZipArchiveInRamReturningError: (NSError **) errorToReturn
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
        localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantCreateZipFile
                                     domain: kAPCError_ArchiveAndUpload_Domain
                              failureReason: kAPCError_ArchiveAndUpload_CantCreateZipFile_Reason
                         recoverySuggestion: kAPCError_ArchiveAndUpload_CantCreateZipFile_Suggestion
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

    return (ableToCreateZipArchive);
}



// ---------------------------------------------------------
#pragma mark - Step 3:  .zip everything
// ---------------------------------------------------------

/**
 Loop through the dictionaries we have to send, inserting
 each into our .zip file.  If we have trouble doing any
 of them, stop, and don't do the rest.  Because of how
 this whole file works -- everything aborts at the first
 sign of an error -- that means if we have trouble
 .zipping anything, we stop everything (by design).
 */
- (BOOL) zipAllDictionariesReturningError: (NSError **) errorToReturn
{
    /*
     Note:  unlike the other methods in this file, 
     we're defaulting to "it worked."  If any individual
     "insert" process fails, we'll change this to a "NO,"
     and stop.
     */
    BOOL ableToZipEverything = YES;
    NSError *localError = nil;
    NSError *errorFromZipInsertProcess = nil;

    for (NSDictionary *dictionary in self.dictionariesToUpload)
    {
        NSString *filename = [self filenameFromDictionary: dictionary];

        ableToZipEverything = [self insertIntoZipArchive: dictionary
                                                filename: filename
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
            localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantInsertZipEntry
                                         domain: kAPCError_ArchiveAndUpload_Domain
                                  failureReason: kAPCError_ArchiveAndUpload_CantInsertZipEntry_Reason
                             recoverySuggestion: kAPCError_ArchiveAndUpload_CantInsertZipEntry_Suggestion
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

    return (ableToZipEverything);
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

- (BOOL) insertIntoZipArchive: (NSDictionary *) dictionary
                     filename: (NSString *) filename
               returningError: (NSError **) errorToReturn
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

    if (K_DEBUG_INCLUDE_TESTING_MESSAGE)
    {
        NSMutableDictionary *temp = uploadableData.mutableCopy;
        temp [kAPCUploaderThisIsATestMessage_Key] = kAPCUploaderThisIsATestMessage_Message;
        uploadableData = temp;
    }

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
        localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantSerializeObject
                                     domain: kAPCError_ArchiveAndUpload_Domain
                              failureReason: kAPCError_ArchiveAndUpload_CantSerializeObject_Reason
                         recoverySuggestion: kAPCError_ArchiveAndUpload_CantSerializeObject_Suggestion
                                nestedError: errorSerializingTheData];
    }

    else
    {
        // If we get this far, we'll assume everything else is going to work.  (Good idea?)
        ableToInsertDictionaryIntoZipFile = YES;

        NSString * fullFileName = [filename stringByAppendingPathExtension: kAPCFileExtension_JSON];

        APCLogFilenameBeingArchived (fullFileName);

        ZZArchiveEntry *zipEntry = [ZZArchiveEntry archiveEntryWithFileName: fullFileName
                                                                   compress: YES
                                                                  dataBlock: ^(NSError** __unused callbackError)
                                    {
                                        return jsonData;
                                    }];

        [self.zipEntries addObject: zipEntry];

        NSDictionary *fileInfoEntry = @{ kAPCSerializedDataKey_FileInfoName: filename,
                                         kAPCSerializedDataKey_FileInfoTimeStamp: [NSDate date],
                                         kAPCSerializedDataKey_FileInfoContentType: kAPCContentType_JSON };

        [self.fileInfoEntries addObject: fileInfoEntry];
    }

    if (errorToReturn != nil)
    {
        *errorToReturn = localError;
    }

    return (ableToInsertDictionaryIntoZipFile);
}



// ---------------------------------------------------------
#pragma mark - Step 4:  Create a "manifest"
// ---------------------------------------------------------

/**
 In our world, we upload a bunch of files in a .zip file.
 Then we include an "info.json" file to describe that
 bunch of files.  This method generates that "info.json"
 file.
 */
- (BOOL) createManifestReturningError: (NSError **) errorToReturn
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
        localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_DontHaveAnyZippedFiles
                                     domain: kAPCError_ArchiveAndUpload_Domain
                              failureReason: kAPCError_ArchiveAndUpload_DontHaveAnyZippedFiles_Reason
                         recoverySuggestion: kAPCError_ArchiveAndUpload_DontHaveAnyZippedFiles_Suggestion];
    }
    else
    {
        NSDictionary *zipArchiveManifest = @{ kAPCSerializedDataKey_Files      : self.fileInfoEntries,
                                              kAPCSerializedDataKey_AppName    : appName,
                                              kAPCSerializedDataKey_AppVersion : appVersion,
                                              kAPCSerializedDataKey_PhoneInfo  : phoneInfo
                                              };

        NSError *errorCreatingManifest = nil;

        ableToCreateManifest = [self insertIntoZipArchive: zipArchiveManifest
                                                 filename: kAPCNameOfIndexFile
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
            NSString *errorMessage = [NSString stringWithFormat: kAPCError_ArchiveAndUpload_CantCreateManifest_Suggestion_Format,
                                      kAPCNameOfIndexFile,
                                      kAPCFileExtension_JSON];

            localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantCreateManifest
                                         domain: kAPCError_ArchiveAndUpload_Domain
                                  failureReason: kAPCError_ArchiveAndUpload_CantCreateManifest_Reason
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

    return (ableToCreateManifest);
}



// ---------------------------------------------------------
#pragma mark - Step 5:  Save to Disk
// ---------------------------------------------------------

- (BOOL) saveToDiskReturningError: (NSError **) errorToReturn
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
        localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantSaveUnencryptedFile
                                     domain: kAPCError_ArchiveAndUpload_Domain
                              failureReason: kAPCError_ArchiveAndUpload_CantSaveUnencryptedFile_Reason
                         recoverySuggestion: kAPCError_ArchiveAndUpload_CantSaveUnencryptedFile_Suggestion
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
            localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantFindUnencryptedFile
                                         domain: kAPCError_ArchiveAndUpload_Domain
                                  failureReason: kAPCError_ArchiveAndUpload_CantFindUnencryptedFile_Reason
                             recoverySuggestion: kAPCError_ArchiveAndUpload_CantFindUnencryptedFile_Suggestion
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

    return (ableToSaveToDisk);
}



// ---------------------------------------------------------
#pragma mark - Step 6:  Encrypt
// ---------------------------------------------------------

- (BOOL) encryptZipFileReturningError: (NSError **) errorToReturn
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
        localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantReadUnencryptedFile
                                     domain: kAPCError_ArchiveAndUpload_Domain
                              failureReason: kAPCError_ArchiveAndUpload_CantReadUnencryptedFile_Reason
                         recoverySuggestion: kAPCError_ArchiveAndUpload_CantReadUnencryptedFile_Suggestion
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
            localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantEncryptFile
                                         domain: kAPCError_ArchiveAndUpload_Domain
                                  failureReason: kAPCError_ArchiveAndUpload_CantEncryptFile_Reason
                             recoverySuggestion: kAPCError_ArchiveAndUpload_CantEncryptFile_Suggestion
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
                localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantSaveEncryptedFile
                                             domain: kAPCError_ArchiveAndUpload_Domain
                                      failureReason: kAPCError_ArchiveAndUpload_CantSaveEncryptedFile_Reason
                                 recoverySuggestion: kAPCError_ArchiveAndUpload_CantSaveEncryptedFile_Suggestion
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
                    localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantFindEncryptedFile
                                                 domain: kAPCError_ArchiveAndUpload_Domain
                                          failureReason: kAPCError_ArchiveAndUpload_CantFindEncryptedFile_Reason
                                     recoverySuggestion: kAPCError_ArchiveAndUpload_CantFindEncryptedFile_Suggestion
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

    return (successfullyEncrypted);
}



// ---------------------------------------------------------
#pragma mark - Step 7:  Upload to Sage
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
    #ifdef USE_DATA_VERIFICATION_CLIENT

        [APCDataVerificationClient uploadDataFromFileAtPath: self.unencryptedZipPath];
        
    #endif



    /*
     Log it to Flurry.
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
             localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_UploadFailed
                                          domain: kAPCError_ArchiveAndUpload_Domain
                                   failureReason: kAPCError_ArchiveAndUpload_UploadFailed_Reason
                              recoverySuggestion: kAPCError_ArchiveAndUpload_UploadFailed_Suggestion
                                     nestedError: uploadError];
         }

         [self finalCleanupHandlingError: localError];
     }];
}



// ---------------------------------------------------------
#pragma mark - Step 8:  Clean Up
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


    /*
     IMPORTANT!
     #warning Ron - To Do:  handle "we couldn't upload to Sage" errors.  (How?)

     Perhaps:

     if (error == couldn't upload to Sage)
     {
        queue some try-again concept
     }
     else
     {
        truly clean up
     }
     */


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
        NSError *errorDeletingFileOrDirectory = nil;

        BOOL itemDeleted = [fileManager removeItemAtPath: fileOrFolderPath
                                                   error: &errorDeletingFileOrDirectory];

        if (! itemDeleted)
        {
            // Last chance to report this problem.
            NSError * localError = [NSError errorWithCode: APCErrorCode_ArchiveAndUpload_CantDeleteFileOrFolder
                                                   domain: kAPCError_ArchiveAndUpload_Domain
                                            failureReason: kAPCError_ArchiveAndUpload_CantDeleteFileOrFolder_Reason
                                       recoverySuggestion: kAPCError_ArchiveAndUpload_CantDeleteFileOrFolder_Suggestion
                                          relatedFilePath: fileOrFolderPath
                                               relatedURL: nil
                                              nestedError: errorDeletingFileOrDirectory];

            APCLogError2 (localError);
        }
    }
}




// ---------------------------------------------------------
#pragma mark - Proposed Ideas (not yet implemented)
// ---------------------------------------------------------

/*
 See explanations in the header file.

 These empty method bodies are just to calm down the compiler warnings.
 */
+ (void) uploadResearchKitTaskResult: (id /* ORKTaskResult* */) __unused taskResult {}

+ (void)        uploadOneDictionary: (NSDictionary *) __unused dictionary
    encryptingContentsBeforeZipping: (BOOL)           __unused shouldEncryptContentsFirst {}

+ (void) uploadAirQualityData: (NSDictionary *) __unused airQualityStuff {}

+ (void) uploadDictionaries: (NSArray *)  __unused dictionaries
          withGroupFilename: (NSString *) __unused filename
    encryptingContentsFirst: (BOOL)       __unused shouldEncryptContentsFirst {}

@end












