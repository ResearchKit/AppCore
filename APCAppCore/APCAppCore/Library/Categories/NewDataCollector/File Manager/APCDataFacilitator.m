//
//  APCFileManagerForCollector.m
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

#import "APCDataFacilitator.h"
#import "APCAppCore.h"
#import "zipzap.h"
#import "APCDataVerificationClient.h"
#import "CMMotionActivity+Helper.h"

static NSString *const kCollectorFolder = @"newCollector";
static NSString *const kUploadFolder = @"upload";

static NSString *const kIdentifierKey = @"identifier";
static NSString *const kStartDateKey = @"startDate";
static NSString *const kEndDateKey = @"endDate";

static NSString *const kInfoFilename = @"info.json";
static NSString *const kCSVFilename  = @"data.csv";

@interface APCDataFacilitator ()
@property (nonatomic, strong) NSMutableDictionary * registeredTrackers;
@property (nonatomic, strong) NSString * collectorsPath;
@property (nonatomic, readonly) NSString *collectorsUploadPath;

//Unique configuration for collector
@property (nonatomic, readonly) NSString*       identifier;
@property (nonatomic, strong)   NSDictionary*   infoDictionary;
@property (nonatomic, strong)   NSString*       folder;
@property (nonatomic)           NSTimeInterval  stalenessInterval;
@property (nonatomic) unsigned long long        sizeThreshold;
@property (nonatomic)           NSArray*        columnNames;

@end


@implementation APCDataFacilitator

/**********************************************************************/
#pragma mark - APCCollectorProtocol Delegate Methods
/**********************************************************************/

- (instancetype)initWithIdentifier:(NSString *)identifier andColumnNames:(NSArray *)columnNames
{
    self = [super init];
    if (self) {
        
        //Unique configuration for collector
        _identifier = identifier;
        _columnNames = columnNames;


        //General configuration for file management
        _registeredTrackers = [NSMutableDictionary dictionary];
        NSString * documentsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        _collectorsPath = [documentsDir stringByAppendingPathComponent:kCollectorFolder];
        [APCFileManagerUtility createFolderIfDoesntExist:_collectorsPath];
        [APCFileManagerUtility createFolderIfDoesntExist:[_collectorsPath stringByAppendingPathComponent:kUploadFolder]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecameActive) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
        
        [self loadOrCreateDataFiles];
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

- (void) loadOrCreateDataFiles
{
    self.folder = [self.collectorsPath stringByAppendingPathComponent:self.identifier];
    NSString * infoFilePath = [self.folder stringByAppendingPathComponent:kInfoFilename];
    NSDictionary * infoDictionary;
    //Create log files
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.folder]) {
        NSError * folderCreationError;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:self.folder
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
            [self resetDataFilesForTracker];
        }
    }
    NSData* dictData = [NSData dataWithContentsOfFile:infoFilePath];
    infoDictionary = [NSDictionary dictionaryWithJSONString:[[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding]];
    self.infoDictionary = infoDictionary;
}

- (void) didRecieveUpdatedValueFromCollector:(id)quantitySample {

//    [results enumerateObjectsUsingBlock: ^(id obj, NSUInteger __unused idx, BOOL * __unused stop) {
//        
//        NSString * rowString = nil;
//        NSString * csvFilePath = nil;
//        NSArray  * arrayOfStuffToPrint = nil;
//        
//        if ([obj isKindOfClass: [CMMotionActivity class]])
//        {
//            /*
//             This csvColumnValues property comes from our CMMotionActivity+Helper
//             category. These values will be in the same order as the matching
//             csvColumnNames.  Those names will be shoved into the outbound .csv
//             file because they're returned by the -columnNames method of the
//             incoming Tracker.
//             */
//            arrayOfStuffToPrint = ((CMMotionActivity *) obj).csvColumnValues;
//        }
//        
//        else if ([obj isKindOfClass: [NSArray class]])
//        {
//            arrayOfStuffToPrint = obj;
//        }
//        
//        else
//        {
//            // Should literally never happen.  Ahem.
//            APCLogDebug (@"Got report for dataTracker object [%@], but I don't know how to handle a [%@].",
//                         obj,
//                         NSStringFromClass ([obj class]));
//        }
//        
//        if (arrayOfStuffToPrint.count > 0)
//        {
//            rowString = [[arrayOfStuffToPrint componentsJoinedByString: @","] stringByAppendingString: @"\n"];
//            csvFilePath = [self.folder stringByAppendingPathComponent: kCSVFilename];
//            
//            [APCFileManagerUtility createOrAppendString: rowString toFile: csvFilePath];
//        }
//    }];
    
    
    NSString *dateTimeStamp = [[NSDate date] toStringInISO8601Format];
    NSString *healthKitType = nil;
    NSString *quantityValue = nil;
    
    if ([quantitySample isKindOfClass:[HKCategorySample class]]) {
        HKCategorySample *catSample = (HKCategorySample *)quantitySample;
        healthKitType = catSample.categoryType.identifier;
        quantityValue = [NSString stringWithFormat:@"%ld", (long)catSample.value];
        
        // Get the difference in seconds between the start and end date for the sample
        NSDateComponents *secondsSpentInBedOrAsleep = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond
                                                                                      fromDate:catSample.startDate
                                                                                        toDate:catSample.endDate
                                                                                       options:NSCalendarWrapComponents];
        if (catSample.value == HKCategoryValueSleepAnalysisInBed) {
            quantityValue = [NSString stringWithFormat:@"%ld,seconds in bed", secondsSpentInBedOrAsleep.second];
        } else if (catSample.value == HKCategoryValueSleepAnalysisAsleep) {
            quantityValue = [NSString stringWithFormat:@"%ld,seconds asleep", secondsSpentInBedOrAsleep.second];
        }
    } else {
        HKQuantitySample *qtySample = (HKQuantitySample *)quantitySample;
        healthKitType = qtySample.quantityType.identifier;
        quantityValue = [NSString stringWithFormat:@"%@", qtySample.quantity];
        quantityValue = [quantityValue stringByReplacingOccurrencesOfString:@" " withString:@","];
    }
    
    NSString *stringToWrite = [NSString stringWithFormat:@"%@,%@,%@\n", dateTimeStamp, healthKitType, quantityValue];
        
    [APCFileManagerUtility createOrAppendString:stringToWrite
                                           toFile:[self.folder stringByAppendingPathComponent:self.identifier]];

    
    [self checkIfDataNeedsToBeFlushed];
}

- (void) checkIfDataNeedsToBeFlushed
{
    //Check for size
    NSString * csvFilePath = [self.folder stringByAppendingPathComponent:kCSVFilename];
    NSError * error;
    NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:csvFilePath error:&error];
    APCLogError2(error);
    unsigned long long filesize = [fileDictionary fileSize];
    if (filesize >= self.sizeThreshold) {
        [self flush];
    }
    
    //Check for start date
    NSDictionary * dictionary = self.infoDictionary;
    NSString * startDateString = dictionary[kStartDateKey];
    NSDate * startDate = [self datefromDateString:startDateString];
    if ([[NSDate date] timeIntervalSinceDate:startDate] >= self.stalenessInterval) {
        [self flush];
    }
}
/**********************************************************************/



/*********************************************************************************/
#pragma mark - Flush and zip creation
/*********************************************************************************/

- (void)flush
{
    //Write the end date
    NSMutableDictionary * infoDictionary = [self.infoDictionary mutableCopy];
    infoDictionary[kEndDateKey]   = [[NSDate date] toStringInISO8601Format];
    infoDictionary[kStartDateKey] = [[self datefromDateString:infoDictionary[kStartDateKey]] toStringInISO8601Format];
    NSString * infoFilePath = [self.folder stringByAppendingPathComponent:kInfoFilename];
    
#warning This is temporary, please remove once the work on a better class is completed.
    NSError *fileAttributeError = nil;
    NSString *dataFilePath = [self.folder stringByAppendingPathComponent:kCSVFilename];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:dataFilePath
                                                                                    error:&fileAttributeError];
    NSString *fileTimeStamp = nil;
    
    if (!fileAttributes) {
        APCLogError2(fileAttributeError);
        fileTimeStamp = [[NSDate date] toStringInISO8601Format];
    } else {
        fileTimeStamp = [[fileAttributes fileModificationDate] toStringInISO8601Format];
    }
    
    infoDictionary[@"files"] = @[@{
                                     @"filename": kCSVFilename,
                                     @"timestamp": fileTimeStamp
                                     }
                                 ];
    infoDictionary[@"taskRun"] = [[NSUUID UUID] UUIDString];
    infoDictionary[@"metaData"] = @{
                                    @"appName": [APCUtilities appName],
                                    @"appVersion": [APCUtilities appVersion],
                                    @"device": [APCDeviceHardware platformString]
                                    };
    
    NSDictionary *sageBS = [APCJSONSerializer serializableDictionaryFromSourceDictionary:infoDictionary];
    
    [APCFileManagerUtility createOrReplaceString:[sageBS JSONString] toFile:infoFilePath];
    
    [self createZipFile];
    [self resetDataFilesForTracker];
}

- (void) createZipFile
{
    NSError * error;
    NSString * unencryptedZipFileName = [NSString stringWithFormat:@"unencrypted_%@_%0.0f.zip",self.identifier, [[NSDate date] timeIntervalSinceReferenceDate]];
    NSString * encryptedZipFileName = [NSString stringWithFormat:@"encrypted_%@_%0.0f.zip",self.identifier, [[NSDate date] timeIntervalSinceReferenceDate]];
    NSString * unencryptedPath = [self.collectorsUploadPath stringByAppendingPathComponent:unencryptedZipFileName];
    NSString * encryptedPath = [self.collectorsUploadPath stringByAppendingPathComponent:encryptedZipFileName];
    
    ZZArchive * zipArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:unencryptedPath]
                                                    options:@{ZZOpenOptionsCreateIfMissingKey : @YES}
                                                      error:&error];
    APCLogError2(error);
    NSMutableArray * zipEntries = [NSMutableArray array];
    NSString * csvFilePath = [self.folder stringByAppendingPathComponent:kCSVFilename];
    NSString * infoFilePath = [self.folder stringByAppendingPathComponent:kInfoFilename];
    
    APCLogFilenameBeingArchived (kCSVFilename);
    APCLogFilenameBeingArchived (kInfoFilename);
    
    [zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: kCSVFilename
                                                           compress:YES
                                                          dataBlock:^(NSError** __unused error){ return [NSData dataWithContentsOfFile:csvFilePath];}]];
    [zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: kInfoFilename
                                                           compress:YES
                                                          dataBlock:^(NSError** __unused error){ return [NSData dataWithContentsOfFile:infoFilePath];}]];
    
    [zipArchive updateEntries:zipEntries error:&error];
    APCLogError2(error);
    
    [APCDataArchiver encryptZipFile:unencryptedPath encryptedPath:encryptedPath];
    APCLogDebug(@"Created zip file: %@", encryptedPath);
    
#ifdef USE_DATA_VERIFICATION_CLIENT
    [APCDataVerificationClient uploadDataFromFileAtPath: unencryptedPath];
#else
    NSError * deleteError;
    if (![[NSFileManager defaultManager] removeItemAtPath:unencryptedPath error:&deleteError]) {
        APCLogError2(deleteError);
    }
#endif
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedPath]) {
        [((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataMonitor uploadZipFile:encryptedPath onCompletion:^(NSError *error) {
            if (!error) {
                NSError * deleteError;
                if (![[NSFileManager defaultManager] removeItemAtPath:encryptedPath error:&deleteError]) {
                    APCLogError2(deleteError);
                }
            }
        }];
    }
    
}


/*********************************************************************************/
#pragma mark - Helpers
/*********************************************************************************/

- (void) resetDataFilesForTracker
{
    APCLogEventWithData(kPassiveCollectorEvent, (@{@"Tracker":self.identifier, @"Status" : @"Reset"}));
    NSString * csvFilePath = [self.folder stringByAppendingPathComponent:kCSVFilename];
    NSString * infoFilePath = [self.folder stringByAppendingPathComponent:kInfoFilename];
    NSDictionary * infoDictionary;
    
    [APCFileManagerUtility deleteFileIfExists:csvFilePath];
    [APCFileManagerUtility deleteFileIfExists:infoFilePath];
    
    //Create info.json
    infoDictionary = @{kIdentifierKey : self.identifier, kStartDateKey : [NSDate date].description};
    NSString * infoJSON = [infoDictionary JSONString];
    [APCFileManagerUtility createOrReplaceString:infoJSON toFile:infoFilePath];
    
    //Create data csv file
    NSString * rowString = [[[self columnNames] componentsJoinedByString:@","] stringByAppendingString:@"\n"];
    [APCFileManagerUtility createOrAppendString:rowString toFile:csvFilePath];
}


- (NSDate*) datefromDateString: (NSString*) string
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    return [dateFormat dateFromString:string];
}



@end
