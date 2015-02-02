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

NSString *const kQuestionTypeKey        = @"questionType";
NSString *const kUserInfoKey            = @"userInfo";
NSString *const kIdentifierKey          = @"identifier";
NSString *const kStartDateKey           = @"startDate";
NSString *const kEndDateKey             = @"endDate";
NSString *const kTaskRunKey             = @"taskRun";
NSString *const kItemKey                = @"item";

NSString *const kFilesKey               = @"files";

NSString *const kFileInfoNameKey        = @"filename";
NSString *const kFileInfoTimeStampKey   = @"timestamp";
NSString *const kFileInfoContentTypeKey = @"contentType";

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

- (instancetype)init {
    self = [super init];
    if (self) {
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

-(NSString *)tempUnencryptedZipFilePath {
    return [self.tempOutputDirectory stringByAppendingPathComponent:@"unencrypted.zip"];
}

-(NSString *)tempEncryptedZipFilePath {
    return [self.tempOutputDirectory stringByAppendingPathComponent:@"encrypted.zip"];
}

- (void)createTempDirectoryIfDoesntExist {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_tempOutputDirectory]) {
        NSError * fileError;
        [[NSFileManager defaultManager] createDirectoryAtPath:_tempOutputDirectory withIntermediateDirectories:YES attributes:nil error:&fileError];
        APCLogError2 (fileError);
    }
}


/*********************************************************************************/
#pragma mark - Task Results
/*********************************************************************************/
//Convenience Initializer
- (instancetype) initWithTaskResult: (RKSTTaskResult*) taskResult {
    return [self initWithResults:taskResult.results itemIdentifier:taskResult.identifier runUUID:taskResult.taskRunUUID];
}

- (instancetype)initWithResults: (NSArray*) results itemIdentifier: (NSString*) itemIdentifier runUUID: (NSUUID*) runUUID {
    self = [self init];
    if (self) {
        //Set up info Dictionary
        _infoDict[kTaskRunKey] = runUUID.UUIDString;
        _infoDict[kItemKey] = itemIdentifier;
        [self processResults:results];
    }
    return self;
}

- (void) processResults: (NSArray*) results
{

    [results enumerateObjectsUsingBlock:^(RKSTStepResult *stepResult, NSUInteger idx, BOOL *stop) {
        [stepResult.results enumerateObjectsUsingBlock:^(RKSTResult *result, NSUInteger idx, BOOL *stop) {
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
            else if ([result isKindOfClass:[RKSTFileResult class]])
            {
                RKSTFileResult * fileResult = (RKSTFileResult*) result;
                [self addFileToArchive:fileResult.fileURL contentType:@"data" timeStamp:fileResult.endDate];
            }
            else if ([result isKindOfClass:[RKSTTappingIntervalResult class]])
            {
                RKSTTappingIntervalResult  *tappingResult = (RKSTTappingIntervalResult *)result;
                [self addTappingResultsToArchive:tappingResult];
            }
            else if ([result isKindOfClass:[RKSTQuestionResult class]])
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
    [self addFileInfoEntryWithFileName:fileName timeStamp:[NSString stringWithFormat:@"%@", date] contentType:contentType];
}

- (void) addFileToArchive: (NSURL*) fileURL contentType: (NSString*) contentType timeStamp: (NSDate*) date
{
    NSString * fileName = fileURL.lastPathComponent;
    [self writeURLToArchive:fileURL];
    [self addFileInfoEntryWithFileName:fileName timeStamp:[NSString stringWithFormat:@"%@", date] contentType:contentType];
}

static  NSString  *kTappingViewSizeKey       = @"TappingViewSize";
static  NSString  *kButtonRectLeftKey        = @"ButtonRectLeft";
static  NSString  *kButtonRectRightKey       = @"ButtonRectRight";

static  NSString  *kTappingSamplesKey        = @"TappingSamples";
static      NSString  *kTappedButtonIdKey    = @"TappedButtonId";
static      NSString  *kTappedButtonNoneKey  = @"TappedButtonNone";
static      NSString  *kTappedButtonLeftKey  = @"TappedButtonLeft";
static      NSString  *kTappedButtonRightKey = @"TappedButtonRight";
static      NSString  *kTapTimeStampKey      = @"TapTimeStamp";
static      NSString  *kTapCoordinateKey     = @"TapCoordinate";

/*********************************************************************************/
#pragma mark - Add Result Archive
/*********************************************************************************/

- (void)addTappingResultsToArchive:(RKSTTappingIntervalResult *)result
{
    NSMutableDictionary  *dictionary = [NSMutableDictionary dictionary];
    
    NSString  *tappingViewSize = NSStringFromCGSize(result.stepViewSize);
    dictionary[kTappingViewSizeKey] = tappingViewSize;
    
    dictionary[kStartDateKey] = result.startDate;
    dictionary[kEndDateKey]   = result.endDate;
    
    NSString  *leftButtonRect = NSStringFromCGRect(result.buttonRect1);
    dictionary[kButtonRectLeftKey] = leftButtonRect;
    
    NSString  *rightButtonRect = NSStringFromCGRect(result.buttonRect2);
    dictionary[kButtonRectRightKey] = rightButtonRect;
    
    NSArray  *samples = result.samples;
    NSMutableArray  *sampleResults = [NSMutableArray array];
    for (RKSTTappingSample *sample  in  samples) {
        NSMutableDictionary  *aSampleDictionary = [NSMutableDictionary dictionary];
        
        aSampleDictionary[kTapTimeStampKey]     = @(sample.timestamp);
        
        aSampleDictionary[kTapCoordinateKey]   = NSStringFromCGPoint(sample.location);
        
        if (sample.buttonIdentifier == RKTappingButtonIdentifierNone) {
            aSampleDictionary[kTappedButtonIdKey] = kTappedButtonNoneKey;
        } else if (sample.buttonIdentifier == RKTappingButtonIdentifierLeft) {
            aSampleDictionary[kTappedButtonIdKey] = kTappedButtonLeftKey;
        } else if (sample.buttonIdentifier == RKTappingButtonIdentifierRight) {
            aSampleDictionary[kTappedButtonIdKey] = kTappedButtonRightKey;
        }
        [sampleResults addObject:aSampleDictionary];
    }
    dictionary[kTappingSamplesKey] = sampleResults;
    [self processDictionary:dictionary];
    [self writeResultDictionaryToArchive:dictionary];
}

- (void) addResultToArchive: (RKSTResult*) result {
    NSMutableArray * properties = [NSMutableArray array];
    [properties addObjectsFromArray:[APCDataArchiver classPropsFor:[RKSTResult class]]];
    if (result.superclass != [RKSTResult class]) {
        [properties addObjectsFromArray:[APCDataArchiver classPropsFor:result.superclass]];
    }
    [properties addObjectsFromArray:[APCDataArchiver classPropsFor:result.class]];
    NSMutableDictionary * dictionary = [[result dictionaryWithValuesForKeys:properties] mutableCopy];
    dictionary = [self processDictionary:dictionary];
    APCLogDebug(@"%@", dictionary);
    [self writeResultDictionaryToArchive:dictionary];
    [self addFileInfoEntryWithDictionary:dictionary];
}

- (NSMutableDictionary*) processDictionary :(NSMutableDictionary*) mutableDictionary {
    static NSArray* array = nil;
    if (array == nil) {
        array = @[@"None", @"Scale", @"SingleChoice", @"MultipleChoice", @"Decimal",@"Integer", @"Boolean", @"Text", @"TimeOfDay", @"DateAndTime", @"Date", @"TimeInterval"];
    }
    //Replace questionType
    if (mutableDictionary[kQuestionTypeKey]) {
        NSUInteger index = ((NSNumber*) mutableDictionary[kQuestionTypeKey]).integerValue;
        if (index < array.count) {
            mutableDictionary[kQuestionTypeKey] = array[index];
        }
    }
    
    //Remove userInfo if its empty
    if ([mutableDictionary[kUserInfoKey] isEqual:[NSNull null]]) {
        [mutableDictionary removeObjectForKey:kUserInfoKey];
    }
    
    //Replace identifier with item
    if (mutableDictionary[kIdentifierKey]) {
        mutableDictionary[kItemKey] =mutableDictionary[kIdentifierKey];
        [mutableDictionary removeObjectForKey:kIdentifierKey];
    }
    
        //Override dates with strings
    if ([mutableDictionary[kStartDateKey] isKindOfClass:[NSDate class]]) {
        mutableDictionary[kStartDateKey] = [NSString stringWithFormat:@"%@", mutableDictionary[kStartDateKey]];
    }
    
    if ([mutableDictionary[kEndDateKey] isKindOfClass:[NSDate class]]) {
        mutableDictionary[kEndDateKey] = [NSString stringWithFormat:@"%@", mutableDictionary[kEndDateKey]];
    }
    
    //Replace any other type of objects with its string equivalents
    NSMutableDictionary * copyDictionary = [mutableDictionary mutableCopy];
    [mutableDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //Removing NSCalendar objects if they are present
        if ([obj isKindOfClass:[NSCalendar class]]) {
            [copyDictionary removeObjectForKey:key];
        }
        //Otherwise call description on the objects to get string
        else if (!([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]])) {
            copyDictionary[key] = [NSString stringWithFormat:@"%@", obj];
        }
    }];
    
    return copyDictionary;
}

- (void) writeResultDictionaryToArchive: (NSDictionary*) dictionary
{
    NSString * fileName = dictionary[kItemKey]?:@"NoName";
    [self writeDictionaryToArchive:dictionary fileName:fileName];
}

- (void) writeDictionaryToArchive: (NSDictionary*) dictionary fileName: (NSString*) fileName
{
    NSError * error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (jsonData !=nil) {
        NSString * fullFileName = [fileName stringByAppendingPathExtension:@"json"];
        [self.zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: fullFileName
                                                                    compress:YES
                                                                   dataBlock:^(NSError** error){ return jsonData;}]];
    }
    else {
        APCLogError2(error);
    }
}

- (void) writeDataToArchive: (NSData*) data fileName: (NSString*) fileName
{
    [self.zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: fileName
                                                                compress:YES
                                                               dataBlock:^(NSError** error){ return data;}]];
}

- (void) writeURLToArchive: (NSURL*) url
{
    
}

- (void) addFileInfoEntryWithDictionary: (NSDictionary*) dictionary
{
    NSString * fileName = dictionary[kItemKey]?:@"NoName";
    NSString * fullFileName = [fileName stringByAppendingPathExtension:@"json"];
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
    
    [self encryptZipFile];
    
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

- (void) encryptZipFile {
    NSData * unencryptedZipData = [NSData dataWithContentsOfFile:self.tempUnencryptedZipFilePath];
    
    NSError * encryptionError;
    NSData * encryptedZipData = RKSTCryptographicMessageSyntaxEnvelopedData(unencryptedZipData, [self readPEM], RKEncryptionAlgorithmAES128CBC, &encryptionError);
    APCLogError2(encryptionError);
    
    NSError * fileWriteError;
    [encryptedZipData writeToFile:self.tempEncryptedZipFilePath options:NSDataWritingAtomic error:&fileWriteError];
    APCLogError2(fileWriteError);
}

/*********************************************************************************/
#pragma mark - Helpers
/*********************************************************************************/
- (NSData*) readPEM
{
    APCAppDelegate * appDelegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    NSString * path = [[NSBundle mainBundle] pathForResource:appDelegate.certificateFileName ofType:@"pem"];
    NSData * data = [NSData dataWithContentsOfFile:path];
    NSAssert(data != nil, @"Please add PEM file");
    return data;
}

+ (NSArray *)classPropsFor:(Class)klass
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

@end
