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


// For now, #import the reigning DataArchiver class, to use
// its generateSerializableData method.  However, I suspect
// we'll eventually move that method to this class,
// and make that class a subclass of this one, or something
// like that.
#import "APCDataArchiver.h"


/*
 Some new keys, some historical.  Working on pruning this list.
 */
static NSString * const kAQILastChecked                         = @"AQILastChecked";
static NSString * const kLatitudeKey                            = @"latitude";
static NSString * const kLongitudeKey                           = @"longitude";
static NSString * const kLifemapURL                             = @"https://alerts.lifemap-solutions.com";
static NSString * const kAlertGetJson                           = @"/alert/get_aqi.json";
static NSString * const klifemapCertificateFilename             = @"lifemap-solutions";
static NSString * const kTaskRunKey                             = @"taskRun";
static NSString * const kAPCSerializedDataKey_PhoneInfo         = @"phoneInfo";
static NSString * const kAPCEncryptedZipFileName                = @"encrypted.zip";
static NSString * const kAPCUnencryptedZipFileName              = @"unencrypted.zip";
static NSString * const kAPCUploadQueueName                     = @"Generic zip-and-upload queue";
static NSString * const kAPCHistoricalKeyForFilenameToUpload    = @"item";
static NSString * const kAPCNameOfIndexFile                     = @"info";
static NSString * const kAPCExtensionForJSONFiles               = @"json";
static NSString * const kAPCContentTypeForJSON                  = @"text/json";
static NSString * const kAPCPrivateKeyFileExtension             = @"pem";


static NSString * const kAPCErrorDomainArchiveAndUpload                         = @"DataArchiverAndUploader";
//static NSString * const kAPCErrorNone_Message                   = @"Everything worked!";
//static NSInteger  const kAPCErrorNone_Code                      = 0;
static NSString * const kAPCErrorDomainArchiveAndUpload_CantCreateZip_Message           = @"Can't create .zip file.";
static NSInteger  const kAPCErrorDomainArchiveAndUpload_CantCreateZip_Code              = 1;
static NSString * const kAPCErrorDomainArchiveAndUpload_CantReadUnencryptedFile_Message = @"Can't read unencrypted .zip file.";
static NSInteger  const kAPCErrorDomainArchiveAndUpload_CantReadUnencryptedFile_Code    = 2;


/**
 All zip-and-upload operations will use this and only this queue.
 This will ease debugging, as well as system load.
 */
static NSOperationQueue * generalPurposeUploadQueue = nil;



@interface APCDataArchiverAndUploader ()
@property (nonatomic, strong) ZZArchive             * zipArchive;
@property (nonatomic, strong) NSMutableArray        * zipEntries;
@property (nonatomic, strong) NSURL                 * zipArchiveURL;
@property (nonatomic, strong) NSString              * tempOutputDirectory;
@property (nonatomic, strong) NSMutableArray        * fileInfoEntries;
@property (nonatomic, strong) NSString              * workingDirectory;
@property (nonatomic, strong) NSString              * unencryptedZipPath;
@property (nonatomic, strong) NSString              * encryptedZipPath;
@property (nonatomic, strong) NSURL                 * unencryptedZipURL;
@property (nonatomic, strong) NSURL                 * encryptedZipURL;
@end



@implementation APCDataArchiverAndUploader

+ (void) initialize
{
    generalPurposeUploadQueue = [NSOperationQueue sequentialOperationQueueWithName: kAPCUploadQueueName];
}

+ (void) uploadOneDictionaryAsFile: (NSDictionary *) dictionary
{
    [generalPurposeUploadQueue addOperationWithBlock:^{

        APCDataArchiverAndUploader *newStyleArchiver = [APCDataArchiverAndUploader new];

        NSError *errorCreatingEmptyArchive = nil;

        if (! [newStyleArchiver createZipArchiveReturningError: &errorCreatingEmptyArchive])
        {
            APCLogError2 (errorCreatingEmptyArchive);
        }
        else
        {
            NSString *filename = dictionary [kAPCHistoricalKeyForFilenameToUpload];

            if (filename == nil)
            {
                // Report, or handle it.
            }
            else
            {
                // we'll use the filename specified in the dictionary.
            }

            [newStyleArchiver insertIntoZipArchive: dictionary filename: filename];
            [newStyleArchiver packAndShip];
        }

        NSLog(@"######### Your block has finished!  and uploadOne should have finished, like, years ago. ######");

    }];

    NSLog(@"######### +uploadOne has finished!  ...but your block should still be going. ######");
}

- (id) init
{
    self = [super init];

    if (self)
    {
        //
        // Create a working directory.
        //
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *tempDirectory = NSTemporaryDirectory ();
        NSString *uniqueSubdirectoryName = [NSUUID UUID].UUIDString;
        _workingDirectory = [tempDirectory stringByAppendingPathComponent: uniqueSubdirectoryName];

        /*
         This should literally never happen; the UUID should
         guarantee uniqueness.  Still...
         */
        if ([fileManager fileExistsAtPath: _workingDirectory])
        {
            // report.
        }

        NSError * directoryCreationError = nil;
        BOOL ableToCreateWorkingDirectory = [fileManager createDirectoryAtPath: _workingDirectory
                                                   withIntermediateDirectories: YES
                                                                    attributes: nil
                                                                         error: & directoryCreationError];
        if (ableToCreateWorkingDirectory)
        {
            // it worked
        }
        else
        {
            // handle the error
        }

        _unencryptedZipPath = [_workingDirectory stringByAppendingPathComponent: kAPCUnencryptedZipFileName];
        _encryptedZipPath   = [_workingDirectory stringByAppendingPathComponent: kAPCEncryptedZipFileName];
        _unencryptedZipURL  = [NSURL fileURLWithPath: _unencryptedZipPath];
        _encryptedZipURL    = [NSURL fileURLWithPath: _encryptedZipPath];

        _zipEntries         = [NSMutableArray new];
        _fileInfoEntries    = [NSMutableArray new];
    }

    return self;
}

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


- (void) insertIntoZipArchive: (NSDictionary *) dictionary
                     filename: (NSString *) filename
{
    NSDictionary *uploadableData = [APCJSONSerializer serializableDictionaryFromSourceDictionary: dictionary];

    /*
     There should never be an error here.  Our
     -generateSerializableDataFromSourceDictionary: method, called
     above, stringifies everything it doesn't have a custom converter
     for, and uses NSJSONSerialization to validate everything it does.
     
     Ahem.  Famous last words, right?
     */
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: uploadableData
                                                       options: NSJSONWritingPrettyPrinted
                                                         error: & error];

    if (jsonData == nil)
    {
        APCLogError2 (error);
    }

    else
    {
        NSString * fullFileName = [filename stringByAppendingPathExtension: kAPCExtensionForJSONFiles];

        APCLogFilenameBeingArchived (fullFileName);

        ZZArchiveEntry *zipEntry = [ZZArchiveEntry archiveEntryWithFileName: fullFileName
                                                                   compress: YES
                                                                  dataBlock: ^(NSError** __unused error)
                                    {
                                        return jsonData;
                                    }];

        [self.zipEntries addObject: zipEntry];

        NSDictionary *fileInfoEntry = @{ kAPCSerializedDataKey_FileInfoName: filename,
                                         kAPCSerializedDataKey_FileInfoTimeStamp: [NSDate date],
                                         kAPCSerializedDataKey_FileInfoContentType: kAPCContentTypeForJSON };

        [self.fileInfoEntries addObject: fileInfoEntry];
    }
}

- (void) packAndShip
{
    if (self.fileInfoEntries.count)
    {
        NSError *error          = nil;
        NSString *archivePath   = self.zipArchive.URL.relativePath; // self.zipArchive.URL.absoluteString;
        BOOL weCalledSage       = NO;

        NSDictionary *zipArchiveManifest = @{ kAPCSerializedDataKey_Files      : self.fileInfoEntries,
                                              kAPCSerializedDataKey_AppName    : [APCUtilities appName],
                                              kAPCSerializedDataKey_AppVersion : [APCUtilities appVersion],
                                              kAPCSerializedDataKey_PhoneInfo  : [APCUtilities phoneInfo]
                                              };

        [self insertIntoZipArchive: zipArchiveManifest
                          filename: kAPCNameOfIndexFile];

        /*
         Ok.  The next set of if/else statements cascades:
         Each "if" statement actually does a real piece of effort.
         If one succeeds, the next one will run.  If it
         fails, it'll report an error, and none of the rest
         of them will run.  If everything works, by the end,
         we'll actually call Sage and upload the encrypted file.
         Otherwise, we'll report the earliest error, clean
         up, and bug out.
         */
        if (! [self.zipArchive updateEntries: self.zipEntries
                                       error: & error])
        {
            APCLogError2 (error);
        }

        else if (! [self.zipArchive.URL checkResourceIsReachableAndReturnError: & error])
        {
            APCLogError2 (error);
        }

        else if (! [self encryptZipFile: archivePath
                          encryptedPath: self.encryptedZipPath
                         returningError: & error])
        {
            APCLogError2 (error);
        }

        else if (! [self.encryptedZipURL checkResourceIsReachableAndReturnError: & error])
        {
            APCLogError2 (error);
        }

        else
        {
            weCalledSage = YES;

            APCLogFilenameBeingUploaded (self.encryptedZipURL.absoluteString);

            [SBBComponent(SBBUploadManager) uploadFileToBridge: self.encryptedZipURL
                                                   contentType: kAPCContentTypeForJSON
                                                    completion: ^(NSError *uploadError)
             {
                 if (uploadError)
                 {
                     APCLogError2 (uploadError);
                 }

                 [self finalCleanup];
             }];
        }

        /*
         If we didn't run the Sage call, clean up now.  Otherwise, we'll
         clean up when we get back from the Sage call, asynchronously.
         */
        if (! weCalledSage)
        {
            [self finalCleanup];
        }
    }
}

- (BOOL) encryptZipFile: (NSString *) unencryptedPath
          encryptedPath: (NSString *) encryptedPath
         returningError: (NSError **) error
{
    NSError *localError = nil;

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

    *error = localError;
    return (localError == nil);
}

- (void) finalCleanup
{
    [self cleanUpAndDestroyWorkingDirectory];

    // Call the user back?
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
                                self.workingDirectory
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












