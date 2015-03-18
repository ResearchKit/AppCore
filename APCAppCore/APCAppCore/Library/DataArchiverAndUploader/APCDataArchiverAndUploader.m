//
//  APCDataArchiverAndUploader.m
//  APCAppCore
//
//  Created by Ron Conescu on 3/4/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCDataArchiverAndUploader.h"
#import <BridgeSDK/BridgeSDK.h>
#import "ZZArchive.h"
#import "ZZArchiveEntry.h"
#import "APCLog.h"
#import "APCCMS.h"
#import "APCUtilities.h"
#import "NSOperationQueue+Helper.h"
#import "APCAppDelegate.h"
#import "APCJSONSerializer.h"
#import "APCDataVerificationClient.h"


/*
 Some new keys, some historical.  Working on pruning this list.
 */
static NSString * const kTaskRunKey                             = @"taskRun";
static NSString * const kAPCSerializedDataKey_PhoneInfo         = @"phoneInfo";
static NSString * const kAPCEncryptedZipFileName                = @"encrypted.zip";
static NSString * const kAPCUnencryptedZipFileName              = @"unencrypted.zip";
static NSString * const kAPCUploadQueueName                     = @"Generic zip-and-upload queue";
static NSString * const kAPCUploaderTrackerQueueName            = @"Queue tracking and untracking the archivers - basically, for performing thread-safe inter-thread communications";
static NSString * const kAPCNormalFileNameKey                   = @"item";          // not sure why these two things are used
static NSString * const kAPCAlternateFileNameKey                = @"identifier";    // as filenames.  Soon, we can change that.
static NSString * const kAPCNameOfIndexFile                     = @"info";
static NSString * const kAPCExtensionForJSONFiles               = @"json";
static NSString * const kAPCContentTypeForJSON                  = @"text/json";
static NSString * const kAPCPrivateKeyFileExtension             = @"pem";
static NSString * const kAPCUnknownFileNameFormatString         = @"UnknownFile_%d";


static NSString * const kAPCErrorDomainArchiveAndUpload         = @"DataArchiverAndUploader";
//static NSString * const kAPCErrorNone_Message                 = @"Everything worked!";
//static NSInteger  const kAPCErrorNone_Code                    = 0;
static NSString * const kAPCErrorDomainArchiveAndUpload_CantCreateZip_Message           = @"Can't create .zip file.";
static NSInteger  const kAPCErrorDomainArchiveAndUpload_CantCreateZip_Code              = 1;
static NSString * const kAPCErrorDomainArchiveAndUpload_CantReadUnencryptedFile_Message = @"Can't read unencrypted .zip file.";
static NSInteger  const kAPCErrorDomainArchiveAndUpload_CantReadUnencryptedFile_Code    = 2;


/**
 All zip-and-upload operations will use this and only this queue.
 This will ease debugging, as well as system load.
 */
static NSOperationQueue * generalPurposeUploadQueue = nil;

/**
 Pointers to objects waiting for responses from Sage.  After that,
 they'll do whatever cleanup is required after the upload, like
 deleting their working directories and calling back the calling
 methods.
 */
static NSMutableArray * uploadersWaitingForSageUploadToFinish = nil;
static NSOperationQueue * queueForTrackingUploaders = nil;



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
#pragma mark - Globals:  setting up and editing class and queues
// ---------------------------------------------------------

+ (void) initialize
{
    generalPurposeUploadQueue = [NSOperationQueue sequentialOperationQueueWithName: kAPCUploadQueueName];
    uploadersWaitingForSageUploadToFinish = [NSMutableArray new];
    queueForTrackingUploaders = [NSOperationQueue sequentialOperationQueueWithName: kAPCUploaderTrackerQueueName];
}

+ (void) uploadOneDictionary: (NSDictionary *) dictionary
{
    [generalPurposeUploadQueue addOperationWithBlock:^{

        APCDataArchiverAndUploader *archiverAndUploader = [[APCDataArchiverAndUploader alloc] initWithDictionariesToUpload: @[dictionary]];

        [archiverAndUploader go];

        NSLog(@"######### Your block has finished!  and uploadOne should have finished, like, years ago. ######");
    }];

    NSLog(@"######### +uploadOne has finished!  ...but your block should still be going. ######");
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
#pragma mark - The main method:  zip it and ship it
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
     aborting the first time we get an error.
     
     The last step is "start the upload."  If we get that far, we'll
     get a callback when the upload completes.  Otherwise, we report
     whatever error we got, clean up, and stop.
     */
    if (ok) ok = [self createWorkingDirectoryReturningError : & error];
    if (ok) ok = [self createZipArchiveReturningError       : & error];
    if (ok) ok = [self zipAllDictionariesReturningError     : & error];
    if (ok) ok = [self createManifestReturningError         : & error];
    if (ok) ok = [self saveToDiskReturningError             : & error];
    if (ok) ok = [self encryptZipFileReturningError         : & error];

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

- (BOOL) createWorkingDirectoryReturningError: (NSError **) error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempDirectory = NSTemporaryDirectory ();
    NSString *uniqueSubdirectoryName = [NSUUID UUID].UUIDString;
    NSString *workingDirectoryPath = [tempDirectory stringByAppendingPathComponent: uniqueSubdirectoryName];

    /*
     This should literally never happen; the UUID should
     guarantee uniqueness.  Still...
     */
    if ([fileManager fileExistsAtPath: workingDirectoryPath])
    {
        // report?
    }

    NSError * directoryCreationError = nil;
    BOOL ableToCreateWorkingDirectory = [fileManager createDirectoryAtPath: workingDirectoryPath
                                               withIntermediateDirectories: YES
                                                                attributes: nil
                                                                     error: & directoryCreationError];
    if (ableToCreateWorkingDirectory)
    {
        self.workingDirectoryPath   = workingDirectoryPath;
        self.unencryptedZipPath     = [workingDirectoryPath stringByAppendingPathComponent: kAPCUnencryptedZipFileName];
        self.encryptedZipPath       = [workingDirectoryPath stringByAppendingPathComponent: kAPCEncryptedZipFileName];
        self.unencryptedZipURL      = [NSURL fileURLWithPath: self.unencryptedZipPath];
        self.encryptedZipURL        = [NSURL fileURLWithPath: self.encryptedZipPath];
    }
    else
    {
        // Something broke.  We'll pass that error up to the main method.
    }

    *error = directoryCreationError;
    return (directoryCreationError == nil);
}



// ---------------------------------------------------------
#pragma mark - Step 2:  Create the empty .zip archive, in RAM only
// ---------------------------------------------------------

- (BOOL) createZipArchiveReturningError: (NSError **) errorToReturn
{
    NSError *errorCreatingArchive = nil;

    self.zipArchive = [[ZZArchive alloc] initWithURL: self.unencryptedZipURL
                                             options: @{ ZZOpenOptionsCreateIfMissingKey : @(YES) }
                                               error: & errorCreatingArchive];

    if (! self.zipArchive)
    {
        if (errorCreatingArchive == nil)
        {
            errorCreatingArchive = [NSError errorWithDomain: kAPCErrorDomainArchiveAndUpload
                                                       code: kAPCErrorDomainArchiveAndUpload_CantCreateZip_Code
                                                   userInfo: @{ NSLocalizedFailureReasonErrorKey: kAPCErrorDomainArchiveAndUpload_CantCreateZip_Message } ];
        }
    }

    *errorToReturn = errorCreatingArchive;
    return (errorCreatingArchive == nil);
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
- (BOOL) zipAllDictionariesReturningError: (NSError **) error
{
    NSError *localError = nil;

    for (NSDictionary *dictionary in self.dictionariesToUpload)
    {
        NSString *filename = [self filenameFromDictionary: dictionary];

        if (! [self insertIntoZipArchive: dictionary
                                filename: filename
                          returningError: & localError])
        {
            // Stop at the first error.
            break;
        }
    }

    *error = localError;
    return (localError == nil);
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
    NSString *filename = dictionary [kAPCNormalFileNameKey];

    if (filename == nil)
    {
        filename = dictionary [kAPCAlternateFileNameKey];
    }

    if (filename == nil)
    {
        self.countOfUnknownFileNames = self.countOfUnknownFileNames + 1;

        filename = [NSString stringWithFormat: kAPCUnknownFileNameFormatString, (int) self.countOfUnknownFileNames];
    }
    else
    {
        // We'll use the filename specified in the dictionary.
    }

    filename = [self cleanUpFilename: filename];

    return filename;
}

/**
 Replace spaces, hyphens, dots, underscores, or sequences of
 more than one of those things, with a single "_".
 */
- (NSString *) cleanUpFilename: (NSString *) filename
{
    NSString *newFilename = [filename stringByReplacingOccurrencesOfString: @"[_ .\\-]+"
                                                                withString: @"_"
                                                                   options: NSRegularExpressionSearch
                                                                     range: NSMakeRange (0, filename.length)];

    return newFilename;
}

- (BOOL) insertIntoZipArchive: (NSDictionary *) dictionary
                     filename: (NSString *) filename
               returningError: (NSError **) errorToReturn
{
    NSError *localError = nil;


    /*
     Get a serializable copy of our data.

     There should never be an error here.  Our
     -generateSerializableDataFromSourceDictionary: method, called
     above, stringifies everything it doesn't have a custom converter
     for, and uses NSJSONSerialization to validate everything it does.
     
     Ahem.  Famous last words, right?
     */
    NSDictionary *uploadableData = [APCJSONSerializer serializableDictionaryFromSourceDictionary: dictionary];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: uploadableData
                                                       options: NSJSONWritingPrettyPrinted
                                                         error: & localError];

    if (jsonData == nil)
    {
        // Something broke!  We'll set the output error below.
    }
    else
    {
        NSString * fullFileName = [filename stringByAppendingPathExtension: kAPCExtensionForJSONFiles];

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
                                         kAPCSerializedDataKey_FileInfoContentType: kAPCContentTypeForJSON };

        [self.fileInfoEntries addObject: fileInfoEntry];
    }

    *errorToReturn = localError;
    return (localError == nil);
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
- (BOOL) createManifestReturningError: (NSError **) error
{
    NSError *localError = nil;

    if (self.fileInfoEntries.count)
    {
        NSDictionary *zipArchiveManifest = @{ kAPCSerializedDataKey_Files      : self.fileInfoEntries,
                                              kAPCSerializedDataKey_AppName    : [APCUtilities appName],
                                              kAPCSerializedDataKey_AppVersion : [APCUtilities appVersion],
                                              kAPCSerializedDataKey_PhoneInfo  : [APCUtilities phoneInfo]
                                              };

        if (! [self insertIntoZipArchive: zipArchiveManifest
                                filename: kAPCNameOfIndexFile
                          returningError: & localError])
        {
            *error = localError;
        }
    }

    return (localError == nil);
}



// ---------------------------------------------------------
#pragma mark - Step 5:  Save to Disk
// ---------------------------------------------------------

- (BOOL) saveToDiskReturningError: (NSError **) error
{
    NSError *localError = nil;

    if ([self.zipArchive updateEntries: self.zipEntries
                                 error: & localError])
    {
        if ([self.zipArchive.URL checkResourceIsReachableAndReturnError: & localError])
        {
            // Everything worked!
        }
        else
        {
            // Something went wrong:  we thought we zipped it, but we couldn't
            // find it afterwards.  localError will contain the problem.
        }
    }
    else
    {
        // Something went wrong during save-to-disk.  localError will contain the problem.
    }

    *error = localError;
    return (localError == nil);
}



// ---------------------------------------------------------
#pragma mark - Step 6:  Encrypt
// ---------------------------------------------------------

- (BOOL) encryptZipFileReturningError: (NSError **) error
{
    NSError *localError = nil;
    NSString *unencryptedPath = self.zipArchive.URL.relativePath; // NOT self.zipArchive.URL.absoluteString !
    NSString *encryptedPath   = self.encryptedZipPath;

    NSData *unencryptedZipData = [NSData dataWithContentsOfFile: unencryptedPath];

    if (unencryptedZipData == nil)
    {
        localError = [NSError errorWithDomain: kAPCErrorDomainArchiveAndUpload
                                         code: kAPCErrorDomainArchiveAndUpload_CantReadUnencryptedFile_Code
                                     userInfo: @{ NSLocalizedFailureReasonErrorKey: kAPCErrorDomainArchiveAndUpload_CantReadUnencryptedFile_Message,
                                                  NSFilePathErrorKey: unencryptedPath
                                                  }];
    }

    else
    {
        APCAppDelegate * appDelegate = (APCAppDelegate*) UIApplication.sharedApplication.delegate;
        NSString *privateKeyFilePath = [[NSBundle mainBundle] pathForResource: appDelegate.certificateFileName
                                                                       ofType: kAPCPrivateKeyFileExtension];

        NSData *encryptedZipData = cmsEncrypt (unencryptedZipData, privateKeyFilePath, & localError);

        if (localError)
        {
            // report.
        }
        else
        {
            BOOL weZippedIt = [encryptedZipData writeToFile: encryptedPath
                                                    options: NSDataWritingAtomic
                                                      error: & localError];

            if (! weZippedIt)
            {
                // report.
            }
        }
    }

    if (! localError)
    {
        if ([self.encryptedZipURL checkResourceIsReachableAndReturnError: & localError])
        {
            // Something went wrong:  we thought we encrypted it,
            // but now we can't find it.  localError will contain
            // the error.
        }
        else
        {
            // As far as we know, everything worked!
        }
    }

    *error = localError;
    return (localError == nil);
}



// ---------------------------------------------------------
#pragma mark - Step 7:  Upload to Sage
// ---------------------------------------------------------

/**
 Ship it!
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




    APCLogFilenameBeingUploaded (self.encryptedZipPath);

    [SBBComponent(SBBUploadManager) uploadFileToBridge: self.encryptedZipURL
                                           contentType: kAPCContentTypeForJSON
                                            completion: ^(NSError *uploadError)
     {
         [self finalCleanupHandlingError: uploadError];
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
     */
    APCLogError2 (error);



    [self cleanUpAndDestroyWorkingDirectory];



    // Remove the last pointer to myself.  I should be freed
    // verrrry soon afterwards.
    [[self class] stopTrackingArchiver: self];
}

- (void) cleanUpAndDestroyWorkingDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    /*
     The last item in this list of stuff to trash is the working
     directory itself, which contains all the others.
     */
    NSArray *filesToDestroy = @[self.unencryptedZipPath,
                                self.encryptedZipPath,
                                self.workingDirectoryPath
                                ];

    for (NSString *path in filesToDestroy)
    {
        NSError *error = nil;

        if (! [fileManager removeItemAtPath: path error: &error])
        {
            APCLogError2 (error);
        }
    }
}

@end












