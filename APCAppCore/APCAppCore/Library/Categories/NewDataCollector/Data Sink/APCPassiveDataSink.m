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

static NSString *const  kCollectorFolder    = @"newCollector";
static NSString *const  kUploadFolder       = @"upload";
static NSString *const  kIdentifierKey      = @"identifier";
static NSString *const  kStartDateKey       = @"startDate";
static NSString *const  kEndDateKey         = @"endDate";
static NSString *const  kInfoFilename       = @"info.json";
static NSString *const  kCSVFilename        = @"data.csv";
static long long        kKBPerMB            = 1024;
static NSUInteger       kSecsPerMin         = 60;
static NSUInteger       kMinsPerHour        = 60;
static NSUInteger       kHoursPerDay        = 24;

@implementation APCPassiveDataSink

/*********************************************************************************/
#pragma mark - Abstract methods from delegate
/*********************************************************************************/
- (void)didReceiveUpdatedHealthkitSamplesFromCollector:(id)results withUnit:(HKUnit*)unit
{
    __weak typeof(self) weakSelf = self;
    
    NSArray* dataSamples = (NSArray*)results;
    
    [dataSamples enumerateObjectsUsingBlock: ^(id quantitySample, NSUInteger __unused idx, BOOL * __unused stop)
     {
         __typeof(self) strongSelf = weakSelf;
         
         [strongSelf processUpdatesFromCollector:quantitySample withUnit:unit];
     }];
}

- (void)didReceiveUpdatedValuesFromCollector:(NSArray*)quantitySamples
{
    __weak typeof(self) weakSelf = self;
    
    [quantitySamples enumerateObjectsUsingBlock: ^(id quantitySample, NSUInteger __unused idx, BOOL * __unused stop)
    {
        __typeof(self) strongSelf = weakSelf;
        
        [strongSelf processUpdatesFromCollector:quantitySample];
    }];
}

- (void)didReceiveUpdatedValueFromCollector:(id)result
{
    [self processUpdatesFromCollector:result];
}

- (void)didReceiveUpdateWithLocationManager:(CLLocationManager*) __unused manager withUpdateLocations:(NSArray*) __unused locations
{
    [self checkIfCSVStructureHasChanged];
}

/*********************************************************************************/
#pragma mark - Abstract methods
/*********************************************************************************/

- (void)processUpdatesFromCollector:(id)dataSamples withUnit:(HKUnit*)unit
{
    __weak typeof(self) weakSelf = self;
    
    [self.healthKitCollectorQueue addOperationWithBlock:^{
        
        __typeof(self) strongSelf = weakSelf;
        
        NSString *stringToWrite = [self transformQuantityCollectorData:dataSamples withUnit:unit];
        
        [APCPassiveDataSink createOrAppendString:stringToWrite
                                          toFile:[strongSelf.folder stringByAppendingPathComponent:kCSVFilename]];
        
        [strongSelf checkIfDataNeedsToBeFlushed];
    }];
}

- (void)processUpdatesFromCollector:(id)dataSamples
{
    __weak typeof(self) weakSelf = self;
    
    [self.healthKitCollectorQueue addOperationWithBlock:^{
    
        __typeof(self) strongSelf = weakSelf;
        
        NSString *stringToWrite = [self transformCollectorData:dataSamples];
        
        [APCPassiveDataSink createOrAppendString:stringToWrite
                                          toFile:[strongSelf.folder stringByAppendingPathComponent:kCSVFilename]];
        
        [strongSelf checkIfDataNeedsToBeFlushed];
    }];
}

- (NSString*)transformCollectorData:(id)dataSample
{
    return self.transformer(dataSample);
}

- (NSString*)transformQuantityCollectorData:(id)dataSample withUnit:(HKUnit*)unit
{
    return self.quantitytransformer(dataSample, unit);
}

- (instancetype)initWithIdentifier:(NSString*)identifier columnNames:(NSArray*)columnNames operationQueueName:(NSString*)operationQueueName dataProcessor:(APCCSVSerializer)transformer fileProtectionKey:(NSString *)fileProtectionKey
{
    self = [super init];
    
    if (self)
    {
        //Unique configuration for collector
        _identifier         = identifier;
        _columnNames        = columnNames;
        _transformer        = transformer;
        _fileProtectionKey  = fileProtectionKey;
        
        if (!self.healthKitCollectorQueue) {
            self.healthKitCollectorQueue = [NSOperationQueue sequentialOperationQueueWithName:operationQueueName];
        }
        
        [self checkIfCSVStructureHasChanged];
        
        //General configuration for file management
        NSString* documentsDir  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

        _collectorsPath         = [documentsDir stringByAppendingPathComponent:kCollectorFolder];
        
        [APCPassiveDataSink createFolderIfDoesntExist:_collectorsPath andProtectionValue:self.fileProtectionKey];
        [APCPassiveDataSink createFolderIfDoesntExist:[_collectorsPath stringByAppendingPathComponent:kUploadFolder]
                                   andProtectionValue:self.fileProtectionKey];
        
        [self loadOrCreateDataFiles];
    }
    
    return self;
}

- (instancetype)initWithQuantityIdentifier:(NSString*)identifier
                               columnNames:(NSArray*)columnNames
                        operationQueueName:(NSString*)operationQueueName
                             dataProcessor:(APCQuantityCSVSerializer)transformer
                         fileProtectionKey:(NSString*)fileProtectionKey
{
    self = [super init];
    
    if (self)
    {
        //Unique configuration for collector
        _identifier             = identifier;
        _columnNames            = columnNames;
        _quantitytransformer    = transformer;
        _fileProtectionKey  = fileProtectionKey;
        
        if (!self.healthKitCollectorQueue) {
            self.healthKitCollectorQueue = [NSOperationQueue sequentialOperationQueueWithName:operationQueueName];
        }
        
        [self checkIfCSVStructureHasChanged];
        
        //General configuration for file management
        NSString* documentsDir  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        
        _collectorsPath         = [documentsDir stringByAppendingPathComponent:kCollectorFolder];
        
        [APCPassiveDataSink createFolderIfDoesntExist:_collectorsPath andProtectionValue:self.fileProtectionKey];
        [APCPassiveDataSink createFolderIfDoesntExist:[_collectorsPath stringByAppendingPathComponent:kUploadFolder]
                                   andProtectionValue:self.fileProtectionKey];
        
        [self loadOrCreateDataFiles];
    }
    
    return self;
}

- (NSString*)collectorsUploadPath
{
    return [self.collectorsPath stringByAppendingPathComponent:kUploadFolder];
}

/*********************************************************************************/
#pragma mark - Adding tracker
/*********************************************************************************/

- (void) loadOrCreateDataFiles
{
    self.folder = [self.collectorsPath stringByAppendingPathComponent:self.identifier];
    
    NSString*       infoFilePath    = [self.folder stringByAppendingPathComponent:kInfoFilename];
    NSDictionary*   infoDictionary  = nil;

    //Create log files
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.folder])
    {
        NSError* folderCreationError = nil;
        
        if (![[NSFileManager defaultManager] createDirectoryAtPath:self.folder
                                       withIntermediateDirectories:YES
                                                        attributes:@{
                                                                     NSFileProtectionKey :
                                                                         self.fileProtectionKey
                                                                     }
                                                             error:&folderCreationError])
        {
            APCLogError2(folderCreationError);
        }
        else
        {
            [self resetDataFilesForTracker];
        }
    }
    
    NSData* dictData = [NSData dataWithContentsOfFile:infoFilePath];

    infoDictionary      = [NSDictionary dictionaryWithJSONString:[[NSString alloc] initWithData:dictData
                                                                                       encoding:NSUTF8StringEncoding]];
    self.infoDictionary = infoDictionary;
}

- (void) checkIfCSVStructureHasChanged
{
    NSString* csvFilePath = [self.folder stringByAppendingPathComponent:kCSVFilename];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:csvFilePath])
    {
        // read everything from text
        NSError*    fileContentsError   = nil;
        NSString*   fileContents        = [NSString stringWithContentsOfFile:csvFilePath
                                                                    encoding:NSUTF8StringEncoding
                                                                       error:&fileContentsError];
        
        if (fileContentsError)
        {
            APCLogError2(fileContentsError);
        }
        
        // first, separate by new line
        NSArray* dataSeparatedByNewLine = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        if (dataSeparatedByNewLine.count > 0)
        {
            NSString*   expectedColumn          = [dataSeparatedByNewLine objectAtIndex:0];
            NSArray*    oldColumnStructure      = [expectedColumn componentsSeparatedByString:@","];
            NSArray*    possibleNewStructure    = [NSArray arrayWithArray:self.columnNames];
            
            if (![oldColumnStructure isEqualToArray:possibleNewStructure] && dataSeparatedByNewLine.count == 1)
            {
                //If there isn't data then reset the file.
                [self resetDataFilesForTracker];
            }
            else
            {
                //If there's data then upload this data.
                [self flush];
            }
        }
        else
        {
            //If the file exists and there are no columns reset the file.
            [self resetDataFilesForTracker];
        }
    }
}

- (void)checkIfDataNeedsToBeFlushed
{
    //Check for size
    NSString*       csvFilePath         = [self.folder stringByAppendingPathComponent:kCSVFilename];
    NSError*        error               = nil;
    NSDictionary*   fileDictionary      = [[NSFileManager defaultManager] attributesOfItemAtPath:csvFilePath
                                                                                           error:&error];
    
    if (!fileDictionary)
    {
        if (error)
        {
            APCLogError2(error);
        }
    }
    else
    {
        unsigned long long filesize = [fileDictionary fileSize];
        
        if (filesize >= self.sizeThreshold)
        {
            [self flush];
        }
        else
        {
            //Check for start date
            NSDictionary*   dictionary          = self.infoDictionary;
            NSString*       startDateString     = dictionary[kStartDateKey];
            
            if (startDateString)
            {
                NSDate* startDate = [self datefromDateString:startDateString];

                if (startDate)
                {
                    if ([[NSDate date] timeIntervalSinceDate:startDate] >= self.stalenessInterval)
                    {
                        [self flush];
                    }
                }
            }
        }
    }
}

/*********************************************************************************/
#pragma mark - Flush and zip creation
/*********************************************************************************/
- (void)flush
{
    //  At this point the responsibility of the data is handed off to the uploadAndArchiver.
    BOOL success = [self uploadWithDataArchiverAndUploader];
    
    if (success)
    {
        //  Reset the data files
        [self resetDataFilesForTracker];
    }
}

- (BOOL)uploadWithDataArchiverAndUploader
{
    NSError*    error       = nil;
    NSString*   csvFilePath = [self.folder stringByAppendingPathComponent:kCSVFilename];

    BOOL success = [APCDataArchiverAndUploader uploadFileAtPath:csvFilePath
                                             withTaskIdentifier:self.identifier
                                                 andTaskRunUuid:nil
                                                 returningError:&error];
    
    //  If the data fails to be copied and uploaded the next time data is collected the uploader will try again.
    if (!success && error)
    {
        APCLogError2(error);
    }
    
    return success;
}

/*********************************************************************************/
#pragma mark - Helpers
/*********************************************************************************/

- (void)resetDataFilesForTracker
{
    id sinkIdentifier = self.identifier;
    
    if (sinkIdentifier == nil)
    {
        sinkIdentifier = [NSNull null];
    }
    
    APCLogEventWithData(kPassiveCollectorEvent, (@{@"Tracker":sinkIdentifier, @"Status" : @"Reset"}));
    
    NSString*       csvFilePath     = [self.folder stringByAppendingPathComponent:kCSVFilename];
    NSString*       infoFilePath    = [self.folder stringByAppendingPathComponent:kInfoFilename];
    NSDictionary*   infoDictionary  = nil;
    
    [APCPassiveDataSink deleteFileIfExists:csvFilePath];
    [APCPassiveDataSink deleteFileIfExists:infoFilePath];
    
    //Create info.json
    NSDate*     date          = [NSDate date];
    id          dateString    = [date toStringInISO8601Format];
    
    if (dateString == nil)
    {
        dateString = [NSNull null];
    }

    infoDictionary = @{
                       kIdentifierKey   : sinkIdentifier,
                       kStartDateKey    : dateString
                       };
    
    self.infoDictionary = infoDictionary;
    
    NSString*       infoJSON        = [infoDictionary JSONString];
    
    [APCPassiveDataSink createOrReplaceString:infoJSON toFile:infoFilePath];
    
    //Create data csv file
    NSString*       rowString       = [[[self columnNames] componentsJoinedByString:@","] stringByAppendingString:@"\n"];
    
    [APCPassiveDataSink createOrAppendString:rowString toFile:csvFilePath];
}

- (NSDate*)datefromDateString:(NSString*)string
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    return [dateFormat dateFromString:string];
}

+ (void)createOrAppendString:(NSString*)string toFile:(NSString*)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[string dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
    }
    else
    {
        NSFileHandle* fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:path];
        
        [fileHandler seekToEndOfFile];
        [fileHandler writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandler closeFile];
    }
}


+ (void)createOrReplaceString:(NSString*)string toFile:(NSString*)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSError* error = nil;
        
        if (![string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error])
        {
            if (error)
            {
                APCLogError2(error);
            }
        }
    }
    else
    {
        NSError* error = nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
        {
            if (error)
            {
                APCLogError2(error);
            }
        }
        else
        {
            NSError* writeError = nil;
            
            if (![string writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error])
            {
                if (writeError)
                {
                    APCLogError2(writeError);
                }
            }
        }
    }
}

+ (void)createFolderIfDoesntExist:(NSString*)path andProtectionValue:(NSString*)protectionValue
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSError* folderCreationError = nil;
        
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:YES
                                                        attributes:@{ NSFileProtectionKey : protectionValue}
                                                             error:&folderCreationError])
        {
            
            if (folderCreationError)
            {
                APCLogError2(folderCreationError);
            }
        }
    }
}

+ (void)deleteFileIfExists:(NSString*)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSError* error = nil;
        
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
        {
            if (error)
            {
                APCLogError2(error);
            }
        }
    }
}

- (unsigned long long)sizeThreshold
{
    if (_sizeThreshold == 0)
    {
        _sizeThreshold = 50 * kKBPerMB;
    }
    
    return _sizeThreshold;
}

- (NSTimeInterval)stalenessInterval
{
    if (_stalenessInterval == 0)
    {
        _stalenessInterval = 1 * kHoursPerDay * kMinsPerHour * kSecsPerMin;
    }
    
    return _stalenessInterval;
}


@end
