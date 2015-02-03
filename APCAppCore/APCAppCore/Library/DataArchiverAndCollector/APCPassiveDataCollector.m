//
//  APCPassiveDataCollector.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCPassiveDataCollector.h"
#import "APCAppCore.h"
#import "zipzap.h"
#import "APCDataVerificationClient.h"

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
        [self.registeredTrackers enumerateKeysAndObjectsUsingBlock:^(id key, APCDataTracker * obj, BOOL *stop) {
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

- (void)addTracker:(APCDataTracker *)tracker
{
    NSAssert(self.registeredTrackers[tracker.identifier] == nil, @"Tracker with the same identifier already exists");
    self.registeredTrackers[tracker.identifier] = tracker;
    tracker.delegate = self;
    [self loadOrCreateDataFiles:tracker];
    [tracker startTracking];
}

- (void) loadOrCreateDataFiles: (APCDataTracker*) tracker
{
    tracker.folder = [self.collectorsPath stringByAppendingPathComponent:tracker.identifier];
    NSString * infoFilePath = [tracker.folder stringByAppendingPathComponent:kInfoFilename];
    NSDictionary * infoDictionary;
    //Create log files
    if (![[NSFileManager defaultManager] fileExistsAtPath:tracker.folder]) {
        NSError * folderCreationError;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:tracker.folder withIntermediateDirectories:YES attributes:nil error:&folderCreationError]) {
            APCLogError2(folderCreationError);
        }
        else
        {
            [self resetDataFilesForTracker:tracker];
        }
    }
    NSData* dictData = [NSData dataWithContentsOfFile:infoFilePath];
    infoDictionary = [NSDictionary dictionaryWithJSONString:[[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding]];
    tracker.infoDictionary = infoDictionary;
}

/*********************************************************************************/
#pragma mark - Flush and zip creation
/*********************************************************************************/

- (void)flush:(APCDataTracker*) tracker
{
    //Write the end date
    NSMutableDictionary * infoDictionary = [tracker.infoDictionary mutableCopy];
    infoDictionary[kEndDateKey] = [NSDate date].description;
    NSString * infoFilePath = [tracker.folder stringByAppendingPathComponent:kInfoFilename];
    [APCPassiveDataCollector createOrReplaceString:[infoDictionary JSONString] toFile:infoFilePath];
    
    [self createZipFile:tracker];
    [self resetDataFilesForTracker:tracker];
}

- (void) createZipFile:(APCDataTracker*) tracker
{
    NSError * error;
    NSString * unencryptedZipFileName = [NSString stringWithFormat:@"unencrypted_%@_%0.0f.zip",tracker.identifier, [[NSDate date] timeIntervalSinceReferenceDate]];
    NSString * encryptedZipFileName = [NSString stringWithFormat:@"encrypted_%@_%0.0f.zip",tracker.identifier, [[NSDate date] timeIntervalSinceReferenceDate]];
    NSString * unencryptedPath = [self.collectorsUploadPath stringByAppendingPathComponent:unencryptedZipFileName];
    NSString * encryptedPath = [self.collectorsUploadPath stringByAppendingPathComponent:encryptedZipFileName];
    
    ZZArchive * zipArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:unencryptedPath]
                                                    options:@{ZZOpenOptionsCreateIfMissingKey : @YES}
                                                      error:&error];
    APCLogError2(error);
    NSMutableArray * zipEntries = [NSMutableArray array];
    NSString * csvFilePath = [tracker.folder stringByAppendingPathComponent:kCSVFilename];
    NSString * infoFilePath = [tracker.folder stringByAppendingPathComponent:kInfoFilename];
    [zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: kCSVFilename
                                                                compress:YES
                                                          dataBlock:^(NSError** error){ return [NSData dataWithContentsOfFile:csvFilePath];}]];
    [zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: kInfoFilename
                                                           compress:YES
                                                          dataBlock:^(NSError** error){ return [NSData dataWithContentsOfFile:infoFilePath];}]];

    [zipArchive updateEntries:zipEntries error:&error];
    APCLogError2(error);
    
    [APCDataArchiver encryptZipFile:unencryptedPath encryptedPath:encryptedPath];
    APCLogDebug(@"Created zip file: %@", encryptedPath);
    
    if (![self shouldPreserveUnencryptedFiles]) {
        NSError * error;
        if (![[NSFileManager defaultManager] removeItemAtPath:unencryptedPath error:&error]) {
            APCLogError2(error);
        }
    }
    else
    {
#ifdef USE_DATA_VERIFICATION_CLIENT
        
        [APCDataVerificationClient uploadDataFromFileAtPath: unencryptedPath];
        
#endif
    }
    
    [((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataMonitor uploadZipFile:encryptedPath onCompletion:^(NSError *error) {
        if (!error) {
            NSError * deleteError;
            if (![[NSFileManager defaultManager] removeItemAtPath:encryptedPath error:&deleteError]) {
                APCLogError2(deleteError);
            }
        }
    }];
}

- (BOOL) shouldPreserveUnencryptedFiles
{
#ifdef USE_DATA_VERIFICATION_CLIENT
    return YES;
#else
    return NO;
#endif

}

/*********************************************************************************/
#pragma mark - APC Tracker Delegate
/*********************************************************************************/
- (void) APCDataTracker:(APCDataTracker *)tracker hasNewData:(NSArray *)dataArray
{
    [dataArray enumerateObjectsUsingBlock:^(NSArray * obj, NSUInteger idx, BOOL *stop) {
        NSString * rowString = [[obj componentsJoinedByString:@","] stringByAppendingString:@"\n"];
        NSString * csvFilePath = [tracker.folder stringByAppendingPathComponent:kCSVFilename];
        [APCPassiveDataCollector createOrAppendString:rowString toFile:csvFilePath];
    }];
    APCLogDebug(@"Results: %@", dataArray);
    [self checkIfDataNeedsToBeFlushed:tracker];
}

- (void) checkIfDataNeedsToBeFlushed:(APCDataTracker*) tracker
{
    //Check for size
    NSString * csvFilePath = [tracker.folder stringByAppendingPathComponent:kCSVFilename];
    NSError * error;
    NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:csvFilePath error:&error];
    APCLogError2(error);
    unsigned long long filesize = [fileDictionary fileSize];
    if (filesize >= tracker.sizeThreshold) {
        [self flush:tracker];
    }
    
    //Check for start date
    NSDictionary * dictionary = tracker.infoDictionary;
    NSString * startDateString = dictionary[kStartDateKey];
    NSDate * startDate = [self datefromDateString:startDateString];
    if ([[NSDate date] timeIntervalSinceDate:startDate] >= tracker.stalenessInterval) {
        [self flush:tracker];
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
    NSDictionary * infoDictionary;
    
    [APCPassiveDataCollector deleteFileIfExists:csvFilePath];
    [APCPassiveDataCollector deleteFileIfExists:infoFilePath];
    
    //Create info.json
    infoDictionary = @{kIdentifierKey : tracker.identifier, kStartDateKey : [NSDate date].description};
    NSString * infoJSON = [infoDictionary JSONString];
    [APCPassiveDataCollector createOrReplaceString:infoJSON toFile:infoFilePath];
    
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
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&folderCreationError]) {
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
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    return [dateFormat dateFromString:string];
}

@end