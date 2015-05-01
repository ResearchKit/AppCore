// 
//  APCPassiveDataCollector.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
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
 
#import "APCPassiveDataCollector.h"
#import "APCAppCore.h"
#import "zipzap.h"
#import "APCDataVerificationClient.h"
#import "CMMotionActivity+Helper.h"

static NSString *const kCollectorFolder = @"collector";
static NSString *const kUploadFolder = @"upload";

static NSString *const kIdentifierKey = @"identifier";
static NSString *const kStartDateKey = @"startDate";
static NSString *const kEndDateKey = @"endDate";

static NSString *const kInfoFilename = @"info.json";
static NSString *const kCSVFilename  = @"data.csv";

@interface APCPassiveDataCollector () <APCDataTrackerDelegate>
@property (nonatomic, strong) NSMutableDictionary * registeredTrackers;
@property (nonatomic, strong) NSString * collectorsPath;
@property (nonatomic, readonly) NSString *collectorsUploadPath;
@end

@implementation APCPassiveDataCollector

/*********************************************************************************/
#pragma mark - Initializers & related methods
/*********************************************************************************/

- (instancetype)init
{
    self = [super init];
    if (self) {
        _registeredTrackers = [NSMutableDictionary dictionary];
        NSString * documentsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        _collectorsPath = [documentsDir stringByAppendingPathComponent:kCollectorFolder];
        [APCPassiveDataCollector createFolderIfDoesntExist:_collectorsPath];
        [APCPassiveDataCollector createFolderIfDoesntExist:[_collectorsPath stringByAppendingPathComponent:kUploadFolder]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecameActive) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) appBecameActive
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.registeredTrackers enumerateKeysAndObjectsUsingBlock:^(id __unused key, APCDataTracker * obj, BOOL * __unused stop) {
            [obj updateTracking];
        }];
    });
}

- (NSString *)collectorsUploadPath
{
    return [self.collectorsPath stringByAppendingPathComponent:kUploadFolder];
}

/*********************************************************************************/
#pragma mark - Adding tracker
/*********************************************************************************/

- (void) addTracker: (APCDataTracker *) tracker
{
    NSString *identifier = tracker.identifier;
    APCDataTracker *existingTracker = self.registeredTrackers [identifier];

    if (existingTracker)
    {
        NSString *message = [NSString stringWithFormat: @"Trying to install a [%@].  Found an existing one the same name, [%@].  We'll use that older one, instead of the new one.  Calling this an 'error' because we want to track when this happens, in case it leads to problems.", NSStringFromClass ([existingTracker class]), identifier];

        NSError *errorKindaSorta = [NSError errorWithDomain: @"PassiveDataCollector"
                                                       code: 1
                                                   userInfo: @{ NSLocalizedFailureReasonErrorKey: @"Duplicate Passive Data Collector",
                                                                NSLocalizedRecoverySuggestionErrorKey: message }];

        APCLogError2 (errorKindaSorta);

        tracker = existingTracker;
    }

    self.registeredTrackers [identifier] = tracker;
    tracker.delegate = self;
    [self loadOrCreateDataFiles:tracker];
    [tracker startTracking];
}

- (void) loadOrCreateDataFiles: (APCDataTracker*) tracker
{
    tracker.folder = [self.collectorsPath stringByAppendingPathComponent:tracker.identifier];
    //Create log files
    if (![[NSFileManager defaultManager] fileExistsAtPath:tracker.folder]) {
        NSError * folderCreationError;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:tracker.folder
                                       withIntermediateDirectories:YES
                                                        attributes:@{
                                                                        NSFileProtectionKey :
                                                                        NSFileProtectionCompleteUntilFirstUserAuthentication
                                                                     }
                                                             error:&folderCreationError]) {
            APCLogError2(folderCreationError);
        }
        else
        {
            [self resetDataFilesForTracker:tracker];
        }
    }
    
    tracker.infoDictionary = @{kIdentifierKey : tracker.identifier, kStartDateKey : [[NSDate date] toStringInISO8601Format]};
}

/*********************************************************************************/
#pragma mark - Flush and zip creation
/*********************************************************************************/

- (void)flush:(APCDataTracker*) tracker
{
    NSString *dataFilePath = [tracker.folder stringByAppendingPathComponent:kCSVFilename];

    NSError *flushError = nil;
    
    BOOL successfullyMoved = [APCDataArchiverAndUploader uploadFileAtPath:dataFilePath
                                                       withTaskIdentifier:tracker.identifier
                                                           andTaskRunUuid:[NSUUID UUID]
                                                           returningError:&flushError];
    
    if (!successfullyMoved) {
        APCLogError2(flushError);
    } else {
        [self resetDataFilesForTracker:tracker];
    }
}

/*********************************************************************************/
#pragma mark - APC Tracker Delegate
/*********************************************************************************/
- (void) APCDataTracker:(APCDataTracker *)tracker hasNewData:(NSArray *)dataArray
{
    [dataArray enumerateObjectsUsingBlock: ^(id obj, NSUInteger __unused idx, BOOL * __unused stop) {
        
        NSString * rowString = nil;
        NSString * csvFilePath = nil;
        NSArray  * arrayOfStuffToPrint = nil;
        
        if ([obj isKindOfClass: [CMMotionActivity class]])
        {
            /*
             This csvColumnValues property comes from our CMMotionActivity+Helper
             category. These values will be in the same order as the matching
             csvColumnNames.  Those names will be shoved into the outbound .csv
             file because they're returned by the -columnNames method of the
             incoming Tracker.
             */
            arrayOfStuffToPrint = ((CMMotionActivity *) obj).csvColumnValues;
        }

        else if ([obj isKindOfClass: [NSArray class]])
        {
            arrayOfStuffToPrint = obj;
        }

        else
        {
            // Should literally never happen.  Ahem.
            APCLogDebug (@"Got report for dataTracker object [%@], but I don't know how to handle a [%@].",
                         obj,
                         NSStringFromClass ([obj class]));
        }

        if (arrayOfStuffToPrint.count > 0)
        {
            rowString = [[arrayOfStuffToPrint componentsJoinedByString: @","] stringByAppendingString: @"\n"];
            csvFilePath = [tracker.folder stringByAppendingPathComponent: kCSVFilename];

            [APCPassiveDataCollector createOrAppendString: rowString toFile: csvFilePath];
        }
    }];

    [self checkIfDataNeedsToBeFlushed:tracker];
}

- (void) checkIfDataNeedsToBeFlushed:(APCDataTracker*) tracker
{
    NSString *csvFilePath = [tracker.folder stringByAppendingPathComponent:kCSVFilename];
    NSError *flushError = nil;
    NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:csvFilePath error:&flushError];
    NSDate *startDate = [self datefromDateString:tracker.infoDictionary[kStartDateKey]];
    
    if (!fileDictionary) {
        APCLogError2(flushError);
    } else {
        
        if (!startDate) {
            startDate = [NSDate date];
        }
        
        unsigned long long filesize = [fileDictionary fileSize];
        BOOL hasReachedFileSizeLimit = (filesize >= tracker.sizeThreshold);
        BOOL hasReachedStalenessInterval = ([[NSDate date] timeIntervalSinceDate:startDate] >= tracker.stalenessInterval);
        
        if (hasReachedFileSizeLimit || hasReachedStalenessInterval) {
            [self flush:tracker];
        }
    }
}

/*********************************************************************************/
#pragma mark - Helpers
/*********************************************************************************/

- (void) resetDataFilesForTracker: (APCDataTracker*) tracker
{
    APCLogEventWithData(kPassiveCollectorEvent, (@{@"Tracker":tracker.identifier, @"Status" : @"Reset"}));
    NSString * csvFilePath = [tracker.folder stringByAppendingPathComponent:kCSVFilename];
    NSString * infoFilePath = [tracker.folder stringByAppendingPathComponent:kInfoFilename];
    
    [APCPassiveDataCollector deleteFileIfExists:csvFilePath];
    [APCPassiveDataCollector deleteFileIfExists:infoFilePath];
    
    //Create data csv file
    NSString * rowString = [[[tracker columnNames] componentsJoinedByString:@","] stringByAppendingString:@"\n"];
    [APCPassiveDataCollector createOrAppendString:rowString toFile:csvFilePath];
}

+ (void) createOrAppendString: (NSString*) string toFile: (NSString*) path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[string dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
    }
    else
    {
        NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
        [fileHandler seekToEndOfFile];
        [fileHandler writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandler closeFile];
    }
}

+ (void) createOrReplaceString: (NSString*) string toFile: (NSString*) path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError * error;
        if (![string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
            APCLogError2(error);
        }
    }
    else
    {
        NSError * error;
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
            APCLogError2(error);
        }
        else
        {
            NSError * writeError;
            if (![string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
                APCLogError2(writeError);
            }
        }
    }
}

+ (void) createFolderIfDoesntExist: (NSString*) path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError * folderCreationError;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:YES
                                                        attributes:@{
                                                                     NSFileProtectionKey :
                                                                     NSFileProtectionCompleteUntilFirstUserAuthentication
                                                                     }
                                                             error:&folderCreationError]) {
            APCLogError2(folderCreationError);
        }
    }
}

+ (void) deleteFileIfExists: (NSString*) path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError * error;
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
            APCLogError2(error);
        }
    }
}

- (NSDate*) datefromDateString: (NSString*) string
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    return [dateFormat dateFromString:string];
}

@end
