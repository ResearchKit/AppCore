//
//  APCDataArchiver.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCDataArchiver.h"
#import "APCAppCore.h"
#import "zipzap.h"
#import <objc/runtime.h>
#import "APCUtilities.h"
#import "ORKAnswerFormat+Helper.h"
#import "APCCMS.h"
#import "NSDate+Helper.h"

    //
    //    ORK Result Base Class property keys
    //
static NSString * const kIdentifierKey              = @"identifier";
static NSString * const kStartDateKey               = @"startDate";
static NSString * const kEndDateKey                 = @"endDate";
static NSString * const kUserInfoKey                = @"userInfo";
    //
    //    other important data item keys
    //
static NSString * const kQuestionTypeKey            = @"questionType";
static NSString * const kQuestionTypeNameKey        = @"questionTypeName";
static NSString * const kTaskRunKey                 = @"taskRun";
static NSString * const kItemKey                    = @"item";
static NSString * const kAppNameKey                 = @"appName";
static NSString * const kAppVersionKey              = @"appVersion";
static NSString * const kPhoneInfoKey               = @"phoneInfo";
static NSString * const kUploadTimeKey              = @"uploadTime";
static NSString * const kFilesKey                   = @"files";
static NSString * const kFileInfoNameKey            = @"filename";
static NSString * const kFileInfoTimeStampKey       = @"timestamp";
static NSString * const kFileInfoContentTypeKey     = @"contentType";

    //
    //    Interval Tapping Dictionary Keys
    //
static  NSString  *const  kTappingViewSizeKey                           = @"TappingViewSize";
static  NSString  *const  kButtonRectLeftKey                            = @"ButtonRectLeft";
static  NSString  *const  kButtonRectRightKey                           = @"ButtonRectRight";
static  NSString  *const  kTappingSamplesKey                            = @"TappingSamples";
static  NSString  *const  kTappedButtonIdKey                            = @"TappedButtonId";
static  NSString  *const  kTappedButtonNoneKey                          = @"TappedButtonNone";
static  NSString  *const  kTappedButtonLeftKey                          = @"TappedButtonLeft";
static  NSString  *const  kTappedButtonRightKey                         = @"TappedButtonRight";
static  NSString  *const  kTapTimeStampKey                              = @"TapTimeStamp";
static  NSString  *const  kTapCoordinateKey                             = @"TapCoordinate";
static  NSString  *const  kAPCTappingResultsFileName                    = @"tapping_results";

    //
    //    Spatial Span Memory Dictionary Keys — Summary
    //
static  NSString  *const  kSpatialSpanMemorySummaryNumberOfGamesKey     = @"MemoryGameNumberOfGames";
static  NSString  *const  kSpatialSpanMemorySummaryNumberOfFailuresKey  = @"MemoryGameNumberOfFailures";
static  NSString  *const  kSpatialSpanMemorySummaryOverallScoreKey      = @"MemoryGameOverallScore";
static  NSString  *const  kSpatialSpanMemorySummaryGameRecordsKey       = @"MemoryGameGameRecords";
static  NSString  *const  kSpatialSpanMemorySummaryFilenameKey          = @"MemoryGameResults";
    //
    //    Spatial Span Memory Dictionary Keys — Touch Samples
    //
static  NSString  *const  kSpatialSpanMemoryTouchSampleTimeStampKey     = @"MemoryGameTouchSampleTimestamp";
static  NSString  *const  kSpatialSpanMemoryTouchSampleTargetIndexKey   = @"MemoryGameTouchSampleTargetIndex";
static  NSString  *const  kSpatialSpanMemoryTouchSampleLocationKey      = @"MemoryGameTouchSampleLocation";
static  NSString  *const  kSpatialSpanMemoryTouchSampleIsCorrectKey     = @"MemoryGameTouchSampleIsCorrect";
    //
    //    Spatial Span Memory Dictionary Keys — Game Status
    //
static  NSString   *const  kSpatialSpanMemoryGameStatusKey              = @"MemoryGameStatus";
static  NSString   *const  kSpatialSpanMemoryGameStatusUnknownKey       = @"MemoryGameStatusUnknown";
static  NSString   *const  kSpatialSpanMemoryGameStatusSuccessKey       = @"MemoryGameStatusSuccess";
static  NSString   *const  kSpatialSpanMemoryGameStatusFailureKey       = @"MemoryGameStatusFailure";
static  NSString   *const  kSpatialSpanMemoryGameStatusTimeoutKey       = @"MemoryGameStatusTimeout";
    //
    //    Spatial Span Memory Dictionary Keys — Game Records
    //
static  NSString   *const  kSpatialSpanMemoryGameRecordSeedKey          = @"MemoryGameRecordSeed";
static  NSString   *const  kSpatialSpanMemoryGameRecordSequenceKey      = @"MemoryGameRecordSequence";
static  NSString   *const  kSpatialSpanMemoryGameRecordGameSizeKey      = @"MemoryGameRecordGameSize";
static  NSString   *const  kSpatialSpanMemoryGameRecordTargetRectsKey   = @"MemoryGameRecordTargetRects";
static  NSString   *const  kSpatialSpanMemoryGameRecordTouchSamplesKey  = @"MemoryGameRecordTouchSamples";
static  NSString   *const  kSpatialSpanMemoryGameRecordGameScoreKey     = @"MemoryGameRecordGameScore";


/**
 We'll eventually use something that makes more sense, here.
 At the moment, this is pretty common, so I don't want to break
 anything that's using this.
 */
static NSString * const kAPCFilenameIfCouldntIdentifyFileName = @"NoName";
static NSString * const kAPCFilenameExtensionJSON = @"json";
static NSArray * kAPCKnownJSONFilenamePrefixes = nil;


@interface APCDataArchiver ()

@property (nonatomic, strong) ZZArchive * zipArchive;
@property (nonatomic, strong) NSMutableDictionary * infoDict;
@property (nonatomic, strong) NSMutableArray * filesList;
@property (nonatomic, strong) NSMutableArray * zipEntries;
@property (nonatomic, strong) NSString * tempOutputDirectory;
@property (nonatomic, readonly) NSString * tempUnencryptedZipFilePath;
@property (nonatomic, readonly) NSString * tempEncryptedZipFilePath;

@end

@implementation APCDataArchiver



/*********************************************************************************/
#pragma mark - Initialization
/*********************************************************************************/

+ (void) initialize
{
    /**
     Specific known filenames, generated by ResearchKit, which
     we just happen to know are actually JSON files -- and so we can
     .zip them as such.
     
     ...um.  Some of these are several megabytes.  So -- do we
     *want* to suggest that they're "readable"?
     */
    kAPCKnownJSONFilenamePrefixes = @[
                                      @"accel_walking",
                                      @"deviceMotion_walking",
                                      @"pedometer_walking",
                                      @"accel_tapping",
                                      @"accel_fitness",
                                      ];
}

/**
 Designated initializer.
 The other -init methods all end up calling this one.
 */
- (instancetype) init
{
    self = [super init];

    if (self)
	{
        _infoDict = [NSMutableDictionary dictionary];
        _filesList = [NSMutableArray array];
        _zipEntries = [NSMutableArray array];
        _tempOutputDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
        [self createTempDirectoryIfDoesntExist];
        NSError * error;
        _zipArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:[self.tempOutputDirectory stringByAppendingPathComponent:@"unencrypted.zip"]]
                                                 options:@{ZZOpenOptionsCreateIfMissingKey : @YES}
                                                   error:&error];
        APCLogError2(error);
        
		/*
		 Make sure crackers (Bad Guys) don't know these features
		 exist, and (also) cannot use them, even by accident.
		 */
		#ifdef USE_DATA_VERIFICATION_CLIENT

			_preserveUnencryptedFile = NO;
			_unencryptedFilePath = nil;

		#endif
    }

    return self;
}

- (instancetype) initWithResults: (NSArray*) results
				  itemIdentifier: (NSString*) itemIdentifier
						 runUUID: (NSUUID*) runUUID
{
	self = [self init];

	if (self)
	{
		// Set up info Dictionary
		_infoDict [kTaskRunKey] = runUUID.UUIDString;
		_infoDict [kItemKey] = itemIdentifier;

		/*
		 These items are cached in APCUtilities after the
		 first time we call them.  They will always return
		 a safe, non-zero-length string (even if we had to
		 say, "I couldn't detect the requested info").
		 */
		_infoDict [kAppNameKey]		= [APCUtilities appName];
		_infoDict [kAppVersionKey]	= [APCUtilities appVersion];
		_infoDict [kPhoneInfoKey]	= [APCUtilities phoneInfo];

		[self processResults: results];
	}
	return self;
}

- (instancetype) initWithTaskResult: (ORKTaskResult*) taskResult
{
	return [self initWithResults:taskResult.results itemIdentifier:taskResult.identifier runUUID:taskResult.taskRunUUID];
}



/*********************************************************************************/
#pragma mark - Where are our .zip files?
/*********************************************************************************/

-(NSString *)tempUnencryptedZipFilePath {
    return [self.tempOutputDirectory stringByAppendingPathComponent:@"unencrypted.zip"];
}

-(NSString *)tempEncryptedZipFilePath {
    return [self.tempOutputDirectory stringByAppendingPathComponent:@"encrypted.zip"];
}

- (void)createTempDirectoryIfDoesntExist {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_tempOutputDirectory]) {
        NSError * fileError;
        [[NSFileManager defaultManager] createDirectoryAtPath:_tempOutputDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:@{
                                                                NSFileProtectionKey :
                                                                NSFileProtectionCompleteUntilFirstUserAuthentication
                                                                }
                                                        error:&fileError];
        APCLogError2 (fileError);
    }
}



/*********************************************************************************/
#pragma mark - Task Results
/*********************************************************************************/

- (void) processResults: (NSArray*) results
{
    [results enumerateObjectsUsingBlock:^(ORKStepResult *stepResult, NSUInteger __unused idx, BOOL * __unused stop) {
        [stepResult.results enumerateObjectsUsingBlock:^(ORKResult *result, NSUInteger __unused idx, BOOL *__unused stop) {
            //Update date if needed
            if (!result.startDate) {
                result.startDate = stepResult.startDate;
                result.endDate = stepResult.endDate;
            }
            
            if ([result isKindOfClass:[APCDataResult class]])
            {
                APCDataResult * dataResult = (APCDataResult*) result;
                NSString *fileName = dataResult.identifier?:(stepResult.identifier?:[NSUUID UUID].UUIDString);
                [self addDataToArchive:dataResult.data fileName:[fileName stringByAppendingString:@"_data"] contentType:@"data" timeStamp:dataResult.endDate];
            }

            else if ([result isKindOfClass:[ORKFileResult class]])
            {
                ORKFileResult * fileResult = (ORKFileResult*) result;

                NSString *betterFilename = [self friendlyFilenameForFile: fileResult];

                if ([betterFilename hasSuffix: kAPCFilenameExtensionJSON])
                {
                    [self addJSONFileToArchive: fileResult usingFileName: betterFilename];
                }
                else
                {
                    [self addGenericDataFileToArchive: fileResult];
                }
            }
            
            else if ([result isKindOfClass:[ORKTappingIntervalResult class]])
            {
                ORKTappingIntervalResult  *tappingResult = (ORKTappingIntervalResult *)result;
                [self addTappingResultsToArchive:tappingResult];
            }
            
            else if ([result isKindOfClass:[ORKSpatialSpanMemoryResult class]])
            {
                ORKSpatialSpanMemoryResult  *spatialSpanMemoryResult = (ORKSpatialSpanMemoryResult *)result;
                [self addSpatialSpanMemoryResultsToArchive:spatialSpanMemoryResult];
            }

            else if ([result isKindOfClass:[ORKQuestionResult class]])
            {
                [self addResultToArchive:result];
            }

            else
            {
                APCLogError(@"Result not processed for : %@", result.identifier);
            }
        }];
    }];
    
    [self finalizeZipFile];
}

- (void) addDataToArchive: (NSData*) data fileName: (NSString*) fileName contentType:(NSString*) contentType timeStamp: (NSDate*) date
{
    [self writeDataToArchive:data fileName:fileName];
    [self addFileInfoEntryWithFileName:fileName timeStamp: date.toStringInISO8601Format contentType:contentType];
}

- (void) addJSONFileToArchive: (ORKFileResult *) file usingFileName: (NSString *) fileName
{
    [self addFileToArchiveFromURL: file.fileURL
                    usingFileName: fileName
                      contentType: @"text/json"
                        timeStamp: file.endDate];
}

- (void) addGenericDataFileToArchive: (ORKFileResult *) file
{
    [self addFileToArchiveFromURL: file.fileURL
                    usingFileName: file.fileURL.lastPathComponent
                      contentType: @"data"      // Not sure why we're using this particular string.  At the moment, it's historical.
                        timeStamp: file.endDate];
}

- (void) addFileToArchiveFromURL: (NSURL*) fileURL
                   usingFileName: (NSString *) fileName
                     contentType: (NSString*) contentType
                       timeStamp: (NSDate*) date
{
    [self writeURLToArchive: fileURL
              usingFileName: fileName];

    [self addFileInfoEntryWithFileName: fileName
                             timeStamp: date.toStringInISO8601Format
                           contentType: contentType];
}

/**
 A catchall for any rules, tricks, or whatever that we
 can use to make outbound "black box" data files readable.
 */
- (NSString *) friendlyFilenameForFile: (ORKFileResult *) file
{
    BOOL isKnownJSONFilename = NO;
    NSString *defaultFileName = file.fileURL.lastPathComponent;
    NSString *currentFileName = defaultFileName;

    /*
     Is it JSON?

     If we happen to know this filename is JSON, 
     set a flag before we mangle (or unmangle)
     the name.
     */
    for (NSString *filenamePrefix in kAPCKnownJSONFilenamePrefixes)
    {
        if ([defaultFileName hasPrefix: filenamePrefix])
        {
            isKnownJSONFilename = YES;
            break;
        }
    }

    /*
     Strip trailing timestamps.

     Some of our filenames have timestamps, like:
     
            "blah_blah_blah-20150131050505"

     --meaning January 31, 2015, at 5:05:05 AM.  If we find one,
     strip off the timestamp.
     
     The timestamp is 14 characters, which is where the "14" in
     this next line of code comes from:  I'm searching for strings
     whose last 14 characters are digits ("\d").
     */
    NSString *timestampPattern = @"-\\d{14}";
    NSRange timestampRange = [currentFileName rangeOfString: timestampPattern
                                                    options: NSRegularExpressionSearch];

    if (timestampRange.location == currentFileName.length - timestampRange.length)
    {
        currentFileName = [currentFileName substringToIndex: timestampRange.location];
    }

    /*
     Replace spaces, hyphens, dots, underscores,
     or sequences of more than one of those things,
     with a single "_".
     */
    currentFileName = [currentFileName stringByReplacingOccurrencesOfString: @"[_ .\\-]+"
                                                                 withString: @"_"
                                                                    options: NSRegularExpressionSearch
                                                                      range: NSMakeRange (0, currentFileName.length)];

    /*
     Now that we've unmangled it, append the ".json", if
     appropriate.
     */
    if (isKnownJSONFilename)
    {
        currentFileName = [currentFileName stringByAppendingPathExtension: kAPCFilenameExtensionJSON];
    }

    return currentFileName;
}

/*********************************************************************************/
#pragma mark - Add Task-Specific Results — Interval Tapping
/*********************************************************************************/

- (void)addTappingResultsToArchive:(ORKTappingIntervalResult *)result
{
    NSMutableDictionary  *rawTappingResults = [NSMutableDictionary dictionary];

    NSString  *tappingViewSize = NSStringFromCGSize(result.stepViewSize);
    rawTappingResults[kTappingViewSizeKey] = tappingViewSize;
    
    rawTappingResults[kStartDateKey] = result.startDate;
    rawTappingResults[kEndDateKey]   = result.endDate;
    
    NSString  *leftButtonRect = NSStringFromCGRect(result.buttonRect1);
    rawTappingResults[kButtonRectLeftKey] = leftButtonRect;
    
    NSString  *rightButtonRect = NSStringFromCGRect(result.buttonRect2);
    rawTappingResults[kButtonRectRightKey] = rightButtonRect;
    
    NSArray  *samples = result.samples;
    NSMutableArray  *sampleResults = [NSMutableArray array];
    for (ORKTappingSample *sample  in  samples) {
        NSMutableDictionary  *aSampleDictionary = [NSMutableDictionary dictionary];
        
        aSampleDictionary[kTapTimeStampKey]     = @(sample.timestamp);
        
        aSampleDictionary[kTapCoordinateKey]   = NSStringFromCGPoint(sample.location);
        
        if (sample.buttonIdentifier == ORKTappingButtonIdentifierNone) {
            aSampleDictionary[kTappedButtonIdKey] = kTappedButtonNoneKey;
        } else if (sample.buttonIdentifier == ORKTappingButtonIdentifierLeft) {
            aSampleDictionary[kTappedButtonIdKey] = kTappedButtonLeftKey;
        } else if (sample.buttonIdentifier == ORKTappingButtonIdentifierRight) {
            aSampleDictionary[kTappedButtonIdKey] = kTappedButtonRightKey;
        }
        [sampleResults addObject:aSampleDictionary];
    }
    rawTappingResults[kTappingSamplesKey] = sampleResults;
    rawTappingResults[kItemKey] = kAPCTappingResultsFileName;

	NSDictionary *serializableData = [self generateSerializableDataFromSourceDictionary: rawTappingResults];
    [self writeResultDictionaryToArchive: serializableData];
    [self addFileInfoEntryWithDictionary: serializableData];
}

/*********************************************************************************/
#pragma mark - Add Task-Specific Results — Spatial Span Memory
/*********************************************************************************/

- (NSArray *)makeTouchSampleRecords:(NSArray *)touchSamples
{
    NSMutableArray  *samples = [NSMutableArray array];
    
    for (ORKSpatialSpanMemoryGameTouchSample  *sample  in  touchSamples) {
        
        NSMutableDictionary  *aTouchSample = [NSMutableDictionary dictionary];
            
        aTouchSample[kSpatialSpanMemoryTouchSampleTimeStampKey]   = @(sample.timestamp);
        aTouchSample[kSpatialSpanMemoryTouchSampleTargetIndexKey] = @(sample.targetIndex);
        aTouchSample[kSpatialSpanMemoryTouchSampleLocationKey]    = NSStringFromCGPoint(sample.location);
        aTouchSample[kSpatialSpanMemoryTouchSampleIsCorrectKey]   = @(sample.isCorrect);
        
        [samples addObject:aTouchSample];
    }
    return  samples;
}

- (NSArray *)makeTargetRectangleRecords:(NSArray *)targetRectangles
{
    NSMutableArray  *rectangles = [NSMutableArray array];
    
    for (NSValue  *value  in  targetRectangles) {
        CGRect  rectangle = [value CGRectValue];
        NSString  *stringified = NSStringFromCGRect(rectangle);
        [rectangles addObject:stringified];
    }
    return  rectangles;
}

- (void)addSpatialSpanMemoryResultsToArchive:(ORKSpatialSpanMemoryResult *)result
{
    
    NSString  *gameStatusKeys[] = { kSpatialSpanMemoryGameStatusUnknownKey, kSpatialSpanMemoryGameStatusSuccessKey, kSpatialSpanMemoryGameStatusFailureKey, kSpatialSpanMemoryGameStatusTimeoutKey };
    
    NSMutableDictionary  *memoryGameResults = [NSMutableDictionary dictionary];
    
        //
        //    ORK Result
        //
    memoryGameResults[kIdentifierKey] = result.identifier;
    memoryGameResults[kStartDateKey]  = result.startDate;
    memoryGameResults[kEndDateKey]    = result.endDate;
        //
        //    ORK ORKSpatialSpanMemoryResult
        //
    memoryGameResults[kSpatialSpanMemorySummaryNumberOfGamesKey]    = @(result.numberOfGames);
    memoryGameResults[kSpatialSpanMemorySummaryNumberOfFailuresKey] = @(result.numberOfFailures);
    memoryGameResults[kSpatialSpanMemorySummaryOverallScoreKey]     = @(result.score);
    
    memoryGameResults[kItemKey] = kSpatialSpanMemorySummaryFilenameKey;
    
        //
        //    Memory Game Records
        //
    NSMutableArray   *gameRecords = [NSMutableArray arrayWithCapacity:[result.gameRecords count]];
    
    for (ORKSpatialSpanMemoryGameRecord  *aRecord  in  result.gameRecords) {
        
        NSMutableDictionary  *aGameRecord = [NSMutableDictionary dictionary];
        
        aGameRecord[kSpatialSpanMemoryGameRecordSeedKey]      = @(aRecord.seed);
        aGameRecord[kSpatialSpanMemoryGameRecordGameSizeKey]  = @(aRecord.gameSize);
        aGameRecord[kSpatialSpanMemoryGameRecordGameScoreKey] = @(aRecord.score);
        aGameRecord[kSpatialSpanMemoryGameRecordSequenceKey]  = aRecord.sequence;
        aGameRecord[kSpatialSpanMemoryGameStatusKey]          = gameStatusKeys[aRecord.gameStatus];
        
        NSArray  *touchSamples = [self makeTouchSampleRecords:aRecord.touchSamples];
        aGameRecord[kSpatialSpanMemoryGameRecordTouchSamplesKey] = touchSamples;
        
        NSArray  *rectangles = [self makeTargetRectangleRecords:aRecord.targetRects];
        aGameRecord[kSpatialSpanMemoryGameRecordTargetRectsKey] = rectangles;
        
        [gameRecords addObject:aGameRecord];
    }
    memoryGameResults[kSpatialSpanMemorySummaryGameRecordsKey] = gameRecords;
    
    NSDictionary  *serializableData = [self generateSerializableDataFromSourceDictionary: memoryGameResults];
    [self writeResultDictionaryToArchive: serializableData];
    [self addFileInfoEntryWithDictionary: serializableData];
}

/*********************************************************************************/
#pragma mark - Add Result Archive
/*********************************************************************************/

- (void) addResultToArchive: (ORKResult*) result
{
	NSMutableArray * propertyNames = [NSMutableArray array];

	/*
	 Get the names of all properties of our result's class
	 and all its superclasses.  Stop when we hit ORKResult.
	 */
	Class klass = result.class;
	BOOL done = NO;
	NSArray *propertyNamesForOneClass = nil;

	while (klass != nil && ! done)
	{
		propertyNamesForOneClass = [self classPropsFor: klass];

		[propertyNames addObjectsFromArray: propertyNamesForOneClass];

		if (klass == [ORKResult class])
		{
			done = YES;
		}
		else
		{
			klass = [klass superclass];
		}
	}

    NSDictionary *propertiesToSave = [result dictionaryWithValuesForKeys: propertyNames];
	NSDictionary *serializableData = [self generateSerializableDataFromSourceDictionary: propertiesToSave];

    APCLogDebug(@"%@", serializableData);

    [self writeResultDictionaryToArchive: serializableData];
    [self addFileInfoEntryWithDictionary: serializableData];
}

- (void) writeResultDictionaryToArchive: (NSDictionary*) dictionary
{
    NSString * fileName = dictionary[kItemKey]?:kAPCFilenameIfCouldntIdentifyFileName;
    [self writeDictionaryToArchive:dictionary fileName:fileName];
}

- (void) writeDictionaryToArchive: (NSDictionary*) dictionary fileName: (NSString*) fileName
{
    NSError * error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (jsonData !=nil) {
        NSString * fullFileName = [fileName stringByAppendingPathExtension: kAPCFilenameExtensionJSON];

        APCLogFilenameBeingArchived (fullFileName);

        [self.zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: fullFileName
                                                                    compress:YES
                                                                   dataBlock:^(NSError** __unused error){ return jsonData;}]];
    }
    else {
        APCLogError2(error);
    }
}

- (void) writeDataToArchive: (NSData*) data fileName: (NSString*) fileName
{
    APCLogFilenameBeingArchived (fileName);

    [self.zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: fileName
                                                                compress:YES
                                                               dataBlock:^(NSError** __unused error){ return data;}]];
}

- (void) writeURLToArchive: (NSURL*) url usingFileName: (NSString *) fileName
{
    APCLogFilenameBeingArchived (fileName);

    [self.zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: fileName
                                                                compress:YES
                                                               dataBlock:^(NSError** __unused error){ return [NSData dataWithContentsOfURL:url];}]];
}

- (void) addFileInfoEntryWithDictionary: (NSDictionary*) dictionary
{
    NSString * fileName = dictionary[kItemKey]?:kAPCFilenameIfCouldntIdentifyFileName;
    NSString * fullFileName = [fileName stringByAppendingPathExtension: kAPCFilenameExtensionJSON];
    [self addFileInfoEntryWithFileName:fullFileName timeStamp:dictionary[kEndDateKey] contentType:@"application/json"];
}

- (void) addFileInfoEntryWithFileName: (NSString*) fileName timeStamp: (NSString*) dateString contentType: (NSString*) contentType
{
    NSMutableDictionary * fileInfoEntry = [NSMutableDictionary dictionary];
    fileInfoEntry[kFileInfoNameKey] = fileName;
    fileInfoEntry[kFileInfoTimeStampKey] = dateString;
    fileInfoEntry[kFileInfoContentTypeKey] = contentType;
    [self.filesList addObject:fileInfoEntry];
}

- (void) finalizeZipFile {
    
    if (self.filesList.count) {
        self.infoDict[kFilesKey] = self.filesList;
    }
    [self writeDictionaryToArchive:self.infoDict fileName:@"info"];
    
    NSError * error;
    [self.zipArchive updateEntries:self.zipEntries error:&error];
    APCLogError2(error);
}


/*********************************************************************************/
#pragma mark - Write Output File
/*********************************************************************************/
- (NSString*)writeToOutputDirectory:(NSString *)outputDirectory {
    
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:outputDirectory], @"Output Directory does not exist");
    
    [APCDataArchiver encryptZipFile:self.tempUnencryptedZipFilePath encryptedPath:self.tempEncryptedZipFilePath];
    
    NSString * newEncryptedPath = [outputDirectory stringByAppendingPathComponent:@"encrypted.zip"];

    NSError * moveError;
    if (![[NSFileManager defaultManager] moveItemAtPath:self.tempEncryptedZipFilePath toPath:newEncryptedPath error:&moveError]) {
        APCLogError2(moveError);
    }

	/*
	 Make sure crackers (Bad Guys) don't know these features
	 exist, and (also) cannot use them, even by accident.
	 */
#ifdef USE_DATA_VERIFICATION_CLIENT

	NSString * newUnEncryptedPath = [outputDirectory stringByAppendingPathComponent:@"unencrypted.zip"];

	if (self.preserveUnencryptedFile)
	{
		self.unencryptedFilePath = newUnEncryptedPath;

        if (![[NSFileManager defaultManager] moveItemAtPath:self.tempUnencryptedZipFilePath toPath:newUnEncryptedPath error:&moveError]) {
            APCLogError2(moveError);
        }
    }
    else

#endif

	{
        if (![[NSFileManager defaultManager] removeItemAtPath:self.tempUnencryptedZipFilePath error:&moveError]) {
            APCLogError2(moveError);
        }
        
    }
    return ([[NSFileManager defaultManager] fileExistsAtPath:newEncryptedPath])? @"encrypted.zip" : nil;
}

+ (BOOL) encryptZipFile: (NSString*) unencryptedPath encryptedPath:(NSString*) encryptedPath
{
    NSData * unencryptedZipData = [NSData dataWithContentsOfFile:unencryptedPath];
    
    NSError * encryptionError;
    NSData * encryptedZipData = cmsEncrypt(unencryptedZipData, [APCDataArchiver pemPath], &encryptionError);
    APCLogError2(encryptionError);

    return [encryptedZipData writeToFile:encryptedPath options:NSDataWritingAtomic error:nil];
}

/*********************************************************************************/
#pragma mark - Helpers
/*********************************************************************************/
+ (NSString*) pemPath
{
    APCAppDelegate * appDelegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    NSString * path = [[NSBundle mainBundle] pathForResource:appDelegate.certificateFileName ofType:@"pem"];
    return path;
}

- (NSArray *)classPropsFor:(Class)klass
{
    if (klass == NULL) {
        return nil;
    }
    
    NSMutableArray *results = [NSMutableArray array];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            [results addObject:propertyName];
        }
    }
    free(properties);
    
    return [NSArray arrayWithArray:results];
}



/*********************************************************************************/
#pragma mark - Converting Serializable Data
/*********************************************************************************/

/**
 The public API.  See comments in the header file.
 */
- (NSDictionary *) generateSerializableDataFromSourceDictionary: (NSDictionary *) sourceDictionary
{
    id result = [self generateSerializableObjectFromSourceObject: sourceDictionary
                                                atRecursionDepth: 0];

    return result;
}

/**
 @param recursionDepth:  How far down this recursive conversion stack
 we are.  One particular transformation only happens at the top level.
 Only -generateSerializableArray and -generateSerializableDictionary
 should modify this; all other methods should pass it through as-is.
 */
- (id) generateSerializableObjectFromSourceObject: (id) sourceObject
                                 atRecursionDepth: (NSUInteger) recursionDepth
{
    id result = nil;

    if ([sourceObject isKindOfClass: [NSArray class]])
    {
        result = [self generateSerializableArrayFromSourceArray: sourceObject
                                               atRecursionDepth: recursionDepth];
    }

    else if ([sourceObject isKindOfClass: [NSDictionary class]])
    {
        result = [self generateSerializableDictionaryFromSourceDictionary: sourceObject
                                                         atRecursionDepth: recursionDepth];
    }

    else
    {
        result = [self generateSerializableSimpleObjectFromSourceSimpleObject: sourceObject];
    }

    return result;
}

- (NSArray *) generateSerializableArrayFromSourceArray: (NSArray *) sourceArray
                                      atRecursionDepth: (NSUInteger) recursionDepth
{
    NSMutableArray *resultArray = [NSMutableArray new];

    for (id value in sourceArray)
    {
        id convertedValue = [self generateSerializableObjectFromSourceObject: value
                                                            atRecursionDepth: recursionDepth + 1];

        if (convertedValue != nil)
        {
            [resultArray addObject: convertedValue];
        }
    }

    return resultArray;
}

- (NSDictionary *) generateSerializableDictionaryFromSourceDictionary: (NSDictionary *) sourceDictionary
                                                     atRecursionDepth: (NSUInteger) recursionDepth
{
    NSMutableDictionary *resultDictionary = [NSMutableDictionary new];

    for (NSString *key in sourceDictionary)
    {
        id value = sourceDictionary [key];

        //
        // Find and include the names for RKQuestionTypes.
        //
        if ([key isEqualToString: kQuestionTypeKey])
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

            resultDictionary [kQuestionTypeKey] = valueToSerialize;
            resultDictionary [kQuestionTypeNameKey] = nameToSerialize;
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
            if (recursionDepth == 0 && [key isEqualToString: kIdentifierKey])
            {
                convertedKey = kItemKey;
            }
            else
            {
                // "else" nothing.  This applies to every other decision.
            }
            

            convertedValue = [self generateSerializableObjectFromSourceObject: value
                                                             atRecursionDepth: recursionDepth + 1];

            if (convertedValue != nil)
            {
                resultDictionary [convertedKey] = convertedValue;
            }
        }
    }

    return resultDictionary;
}

- (id) generateSerializableSimpleObjectFromSourceSimpleObject: (id) sourceObject
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
- (NSNumber *) extractIntOrBoolFromString: (NSString *) itemAsString
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
- (NSNumber *) extractRKQuestionTypeFromNSNumber: (NSNumber *) item
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
- (id) safeSerializableItemFromItem: (id) item
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
