//
//  APCPassiveDataSink.m
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

#import "APCPassiveDataSink.h"
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

static long long kKBPerMB = 1024;
static long long kBytesPerKB = 1024;

static NSUInteger kSecsPerMin = 60;
static NSUInteger kMinsPerHour = 60;
static NSUInteger kHoursPerDay = 24;
static NSUInteger kDaysPerWeek = 7;

@interface APCPassiveHealthKitQuantityDataSink ()


@end

@implementation APCPassiveDataSink

/*********************************************************************************/
#pragma mark - Abstract methods from delegate
/*********************************************************************************/
- (void) didRecieveUpdatedValuesFromCollector:(id) __unused results
{
    /* abstract implementation */
}

- (void) didRecieveUpdatedValueFromCollector:(id) __unused result
{
    /* abstract implementation */
}

/*********************************************************************************/
#pragma mark - Abstract methods
/*********************************************************************************/

- (void)processUpdatesFromCollector:(id) __unused quantitySample {
    
    [self checkIfCSVStructureHasChanged];
}

- (instancetype)initWithIdentifier:(NSString *)identifier andColumnNames:(NSArray *)columnNames
{
    self = [super init];
    if (self) {
        
        //Unique configuration for collector
        _identifier = identifier;
        _columnNames = columnNames;
        
        if (!self.healthKitCollectorQueue) {
            self.healthKitCollectorQueue = [NSOperationQueue sequentialOperationQueueWithName:@"HealthKit Data Collector"];
        }
        
        //General configuration for file management
        _registeredTrackers = [NSMutableDictionary dictionary];
        NSString * documentsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        _collectorsPath = [documentsDir stringByAppendingPathComponent:kCollectorFolder];
        [APCPassiveHealthKitQuantityDataSink createFolderIfDoesntExist:_collectorsPath];
        [APCPassiveHealthKitQuantityDataSink createFolderIfDoesntExist:[_collectorsPath stringByAppendingPathComponent:kUploadFolder]];
        
        [self loadOrCreateDataFiles];
    }
    return self;
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

- (void) checkIfCSVStructureHasChanged
{
    [self.healthKitCollectorQueue addOperationWithBlock:^{
        
        NSString * csvFilePath = [self.folder stringByAppendingPathComponent:kCSVFilename];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:csvFilePath])
        {
            // read everything from text
            NSString* fileContents =
            [NSString stringWithContentsOfFile:csvFilePath
                                      encoding:NSUTF8StringEncoding error:nil];
            
            // first, separate by new line
            NSArray* dataSeparatedByNewLine =
            [fileContents componentsSeparatedByCharactersInSet:
             [NSCharacterSet newlineCharacterSet]];
            
            if (dataSeparatedByNewLine.count > 0)
            {
                NSString* expectedColumn =
                [dataSeparatedByNewLine objectAtIndex:0];
                
                NSArray *items = [expectedColumn componentsSeparatedByString:@","];
                
                if (![items isEqualToArray:self.columnNames] && dataSeparatedByNewLine.count > 1)
                {
                    //If there's data then upload this data.
                    [self flush];
                    [self resetDataFilesForTracker];
                }
                else if (![items isEqualToArray:self.columnNames] && dataSeparatedByNewLine.count == 1)
                {
                    //If there isn't data then reset the file.
                    [self resetDataFilesForTracker];
                }
            }
            else
            {
                //If the file exists and there are no columns reset the file.
                [self resetDataFilesForTracker];
            }
        }
        
    }];
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
    
    NSString *startDate = infoDictionary[kStartDateKey];
    
    if (startDate == nil)
    {
        startDate = [NSDate date].description;
    }
    
    NSDate *dateFromStartDate = [self datefromDateString:startDate.description];
    
    infoDictionary[kStartDateKey] = [dateFromStartDate toStringInISO8601Format];
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
    
    [APCPassiveHealthKitQuantityDataSink createOrReplaceString:[sageBS JSONString] toFile:infoFilePath];
    
    [self uploadWithDataArchiverAndUploader];
    [self resetDataFilesForTracker];
}

- (void) uploadWithDataArchiverAndUploader
{
    NSError* error = nil;
    
    NSString* csvFilePath = [self.folder stringByAppendingPathComponent:kCSVFilename];
    [APCDataArchiverAndUploader uploadFileAtPath:csvFilePath returningError:&error];
    
    if (error)
    {
        APCLogError2(error);
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
    
    [APCPassiveDataSink deleteFileIfExists:csvFilePath];
    [APCPassiveDataSink deleteFileIfExists:infoFilePath];
    
    //Create info.json
    infoDictionary = @{kIdentifierKey : self.identifier, kStartDateKey : [NSDate date].description};
    NSString * infoJSON = [infoDictionary JSONString];
    [APCPassiveHealthKitQuantityDataSink createOrReplaceString:infoJSON toFile:infoFilePath];
    
    //Create data csv file
    NSString * rowString = [[[self columnNames] componentsJoinedByString:@","] stringByAppendingString:@"\n"];
    [APCPassiveHealthKitQuantityDataSink createOrAppendString:rowString toFile:csvFilePath];
}


- (NSDate*) datefromDateString: (NSString*) string
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    return [dateFormat dateFromString:string];
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

- (unsigned long long)sizeThreshold
{
    if (_sizeThreshold == 0) {
        _sizeThreshold = 1 * kKBPerMB * kBytesPerKB;
    }
    return _sizeThreshold;
}

- (NSTimeInterval)stalenessInterval
{
    if (_stalenessInterval == 0) {
        _stalenessInterval = 1 * kDaysPerWeek * kHoursPerDay * kMinsPerHour * kSecsPerMin;
    }
    return _stalenessInterval;
}


@end
