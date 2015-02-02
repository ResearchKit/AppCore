//
//  APCPassiveDataCollector.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCPassiveDataCollector.h"
#import "APCAppCore.h"

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _registeredTrackers = [NSMutableDictionary dictionary];
        NSString * documentsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        _collectorsPath = [documentsDir stringByAppendingPathComponent:kCollectorFolder];
        [APCPassiveDataCollector createFolderIfDoesntExist:_collectorsPath];
        [APCPassiveDataCollector createFolderIfDoesntExist:[_collectorsPath stringByAppendingPathComponent:kUploadFolder]];
    }
    return self;
}

- (NSString *)collectorsUploadPath
{
    return [self.collectorsPath stringByAppendingPathComponent:kUploadFolder];
}

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
    //Load log files
    else
    {
        NSData* dictData = [NSData dataWithContentsOfFile:infoFilePath];
        infoDictionary = [NSDictionary dictionaryWithJSONString:[[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding]];
    }
    tracker.infoDictionary = infoDictionary;
}

- (void)flush:(NSString *)trackerIdentifier
{
    
}

/*********************************************************************************/
#pragma mark - APC Tracker Delegate
/*********************************************************************************/
- (void) APCDataTracker:(APCDataTracker *)tracker hasNewData:(NSArray *)dataArray
{
    //Write array to CSV file
    //Verify if the the data need to be flushed
}

/*********************************************************************************/
#pragma mark - Helpers
/*********************************************************************************/

- (void) resetDataFilesForTracker: (APCDataTracker*) tracker
{
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

@end
