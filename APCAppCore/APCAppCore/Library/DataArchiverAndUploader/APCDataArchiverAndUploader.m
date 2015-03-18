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
#import "ORKAnswerFormat+Helper.h"
#import "NSDate+Helper.h"

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


/*
 Imported (stolen, duplicated) from APCDataArchiver.
 Working on normalizing that.
 */
static NSString * const kAPCSerializedDataKey_QuestionType            = @"questionType";
static NSString * const kAPCSerializedDataKey_QuestionTypeName        = @"questionTypeName";
static NSString * const kAPCSerializedDataKey_UserInfo                = @"userInfo";
static NSString * const kAPCSerializedDataKey_Identifier              = @"identifier";
static NSString * const kAPCSerializedDataKey_Item                    = @"item";
static NSString * const kAPCSerializedDataKey_Files                   = @"files";
static NSString * const kAPCSerializedDataKey_AppName                 = @"appName";
static NSString * const kAPCSerializedDataKey_AppVersion              = @"appVersion";
static NSString * const kAPCSerializedDataKey_FileInfoName            = @"filename";
static NSString * const kAPCSerializedDataKey_FileInfoTimeStamp       = @"timestamp";
static NSString * const kAPCSerializedDataKey_FileInfoContentType     = @"contentType";


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
@property (nonatomic, strong) NSString              * encryptedArchiveFilename;
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

            [newStyleArchiver insertIntoZipArchive: dictionary filename: filename];
            [newStyleArchiver packAndShip];
        }
    }];
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
    NSDictionary *uploadableData = [[self class] serializableDictionaryFromSourceDictionary: dictionary];

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
        NSString *archivePath   = self.zipArchive.URL.absoluteString;
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
                          encryptedPath: self.encryptedArchiveFilename
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
                                     userInfo: @{ NSLocalizedFailureReasonErrorKey: kAPCErrorDomainArchiveAndUpload_CantReadUnencryptedFile_Message }];
    }

    else
    {
        APCAppDelegate * appDelegate = (APCAppDelegate*) UIApplication.sharedApplication.delegate;
        NSString *privateKeyFilePath = [[NSBundle mainBundle] pathForResource: appDelegate.certificateFileName
                                                                       ofType: kAPCPrivateKeyFileExtension];

        NSData *encryptedZipData = cmsEncrypt (unencryptedZipData, privateKeyFilePath, & localError);

        if (error)
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
                                self.encryptedArchiveFilename,
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



// ---------------------------------------------------------
#pragma mark - Converting Serializable Data
// ---------------------------------------------------------

/*
 The methods below are all class methods, because they're currently
 being used by at least 2 other classes.  I hope we can come
 up with a way of doing that more cleanly -- subclassing, or
 a utility class, or whatever.
 */

/**
 The public API.  See comments in the header file.
 */
+ (NSDictionary *) serializableDictionaryFromSourceDictionary: (NSDictionary *) sourceDictionary
{
    NSDictionary *result = [self serializableDictionaryFromSourceDictionary: sourceDictionary
                                                           atRecursionDepth: 0];

    return result;
}

/**
 @param recursionDepth:  How far down this recursive conversion stack
 we are.  One particular transformation only happens at the top level.
 Only -generateSerializableArray and -generateSerializableDictionary
 should modify this; all other methods should pass it through as-is.
 */
+ (id) serializableObjectFromSourceObject: (id) sourceObject
                         atRecursionDepth: (NSUInteger) recursionDepth
{
    id result = nil;

    if ([sourceObject isKindOfClass: [NSArray class]])
    {
        result = [self serializableArrayFromSourceArray: sourceObject
                                       atRecursionDepth: recursionDepth];
    }

    else if ([sourceObject isKindOfClass: [NSDictionary class]])
    {
        result = [self serializableDictionaryFromSourceDictionary: sourceObject
                                                 atRecursionDepth: recursionDepth];
    }

    else
    {
        result = [self serializableSimpleObjectFromSourceSimpleObject: sourceObject];
    }

    return result;
}

+ (NSArray *) serializableArrayFromSourceArray: (NSArray *) sourceArray
                              atRecursionDepth: (NSUInteger) recursionDepth
{
    NSMutableArray *resultArray = [NSMutableArray new];

    for (id value in sourceArray)
    {
        id convertedValue = [self serializableObjectFromSourceObject: value
                                                    atRecursionDepth: recursionDepth + 1];

        if (convertedValue != nil)
        {
            [resultArray addObject: convertedValue];
        }
    }

    return resultArray;
}

+ (NSDictionary *) serializableDictionaryFromSourceDictionary: (NSDictionary *) sourceDictionary
                                             atRecursionDepth: (NSUInteger) recursionDepth
{
    NSMutableDictionary *resultDictionary = [NSMutableDictionary new];

    for (NSString *key in sourceDictionary)
    {
        id value = sourceDictionary [key];

        //
        // Find and include the names for RKQuestionTypes.
        //
        if ([key isEqualToString: kAPCSerializedDataKey_QuestionType])
        {
            id valueToSerialize = nil;
            NSString* nameToSerialize = nil;

            NSNumber *questionType = [self extractRKQuestionTypeFromNSNumber: value];

            if (questionType != nil)
            {
                valueToSerialize = questionType;
                nameToSerialize = NSStringFromRKQuestionType (questionType.integerValue);
            }
            else
            {
                valueToSerialize = [self safeSerializableItemFromItem: value];
                nameToSerialize = RKQuestionTypeUnknownAsString;
            }

            resultDictionary [kAPCSerializedDataKey_QuestionType] = valueToSerialize;
            resultDictionary [kAPCSerializedDataKey_QuestionTypeName] = nameToSerialize;
        }

        //
        // Treat other keys and values normally...
        //
        else
        {
            id convertedKey = key;
            id convertedValue = nil;


            //
            // ...with one exception:  at the top level only, convert
            // the key "identifier" to the key "item".
            //
            // Not sure why.  (It's historical.)  Still investigating.
            // Discovered so far:
            // -  this is used for the outbound filename
            // -  ?
            // -  ?
            //
            if (recursionDepth == 0 && [key isEqualToString: kAPCSerializedDataKey_Identifier])
            {
                convertedKey = kAPCSerializedDataKey_Item;
            }
            else
            {
                // "else" nothing.  This applies to every other decision.
            }


            convertedValue = [self serializableObjectFromSourceObject: value
                                                     atRecursionDepth: recursionDepth + 1];

            if (convertedValue != nil)
            {
                resultDictionary [convertedKey] = convertedValue;
            }
        }
    }

    return resultDictionary;
}

+ (id) serializableSimpleObjectFromSourceSimpleObject: (id) sourceObject
{
    id result = nil;

    /*
     Delete calendars.
     */
    if ([sourceObject isKindOfClass: [NSCalendar class]])
    {
        // Return nil.  This tells the calling method to omit this item.
    }

    /*
     Make dates "ISO-8601 compliant."  Meaning, format
     them like this:

     2015-02-25T16:42:11+00:00

     Per Sage.  I got the rules from:  http://en.wikipedia.org/wiki/ISO_8601
     */
    else if ([sourceObject isKindOfClass: [NSDate class]])
    {
        NSDate *theDate = (NSDate *) sourceObject;
        NSString *sageFriendlyDate = theDate.toStringInISO8601Format;
        result = sageFriendlyDate;
    }

    /*
     Extract strings from UUIDs.
     */
    else if ([sourceObject isKindOfClass: [NSUUID class]])
    {
        NSUUID *uuid = (NSUUID *) sourceObject;
        NSString *uuidString = uuid.UUIDString;
        result = uuidString;
    }

    /*
     Convert stringified ints and bools to their real values

     Very commonly, we have strings that actually contains integers or
     Booleans -- as answers to multiple-choice questions, say. However,
     much earlier in this process, they got converted to strings. This
     seems to be a core feature of ResearchKit. But there's still value
     in them being numeric or Boolean answers. So try to convert each
     item to an integer or Boolean. If we can't, just call our master
     -safe: method to make sure we can serialize it.
     */
    else if ([sourceObject isKindOfClass: [NSString class]])
    {
        result = [self extractIntOrBoolFromString: sourceObject];

        if (result == nil)
        {
            result = sourceObject;
        }
        else
        {
            // Accept the object we got from -extractIntOrBoolFromString.
        }
    }


    /*
     Everything Else

     If we get here:  we want to keep it, but don't have specific
     rules for converting it.  Use our default serialization process:
     include it as-is if the serializer recognizes it, or convert it
     to a string if not.
     */
    else
    {
        result = [self safeSerializableItemFromItem: sourceObject];
    }


    /*
     Whew.
     */
    return result;
}

/**
 Try to convert the specified item to an NSNumber, specifically
 if it's a String that looks like a Boolean or an intenger.
 */
+ (NSNumber *) extractIntOrBoolFromString: (NSString *) itemAsString
{
    NSNumber *result = nil;

    if (itemAsString.length > 0)
    {
        if ([itemAsString compare: @"no" options: NSCaseInsensitiveSearch] == NSOrderedSame ||
            [itemAsString compare: @"false" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            result = @(NO);
        }

        else if ([itemAsString compare: @"yes" options: NSCaseInsensitiveSearch] == NSOrderedSame ||
                 [itemAsString compare: @"true" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            result = @(YES);
        }

        else
        {
            NSInteger itemAsInt = itemAsString.integerValue;
            NSString *verificationString = [NSString stringWithFormat: @"%d", (int) itemAsInt];

            // Here, we use -isValidJSONObject: to make sure the int isn't
            // NaN or infinity.  According to the JSON rules, those will
            // break the serializer.
            if ([verificationString isEqualToString: itemAsString] && [NSJSONSerialization isValidJSONObject: @[verificationString]])
            {
                result = @(itemAsInt);
            }

            else
            {
                // It was NaN or infinity.  Therefore, we can't convert it
                // to a safe or serializable value.  Ignore it.
            }
        }
    }

    return result;
}

/**
 If this item is a Number, try to convert it to an RKQuestionType.
 */
+ (NSNumber *) extractRKQuestionTypeFromNSNumber: (NSNumber *) item
{
    NSNumber* result = nil;

    if ([NSJSONSerialization isValidJSONObject: @[item]])
    {
        ORKQuestionType questionType = item.integerValue;
        result = @(questionType);
    }

    return result;
}

/**
 If we can serialize the specified item, return it.
 Otherwise, converts it to a string and returns the
 string.

 Things we can serialize are strings, numbers, NSNulls,
 and arrays or dictionaries of those things (potentially
 infinitely deep).  Numbers are OK as long as they're not
 NaN or infinity.

 Note that the REAL rules say we should call this method:

 [NSJSONSerialization isValidJSONObject:]

 instead of using, like, our brains, or other logic.
 Which means (I guess) that Apple reserves the right to
 decide what can and cannot be serialized, as they
 upgrade NSJSONSerializer.

 Details:
 https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSJSONSerialization_Class/
 */
+ (id) safeSerializableItemFromItem: (id) item
{
    id result = nil;

    /*
     -isValidJSONObject: can only take an array or
     dictionary at its top level.  So wrap this item
     in an array.
     */
    NSArray *itemToEvaluate = @[item];
    
    if ([NSJSONSerialization isValidJSONObject: itemToEvaluate])
    {
        result = item;
    }
    else
    {
        result = [NSString stringWithFormat: @"%@", item];
    }
    
    return result;
}

@end












