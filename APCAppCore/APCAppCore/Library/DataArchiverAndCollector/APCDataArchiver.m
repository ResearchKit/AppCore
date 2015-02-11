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

NSString *const kQuestionTypeKey        = @"questionType";
NSString *const kUserInfoKey            = @"userInfo";
NSString *const kIdentifierKey          = @"identifier";
NSString *const kStartDateKey           = @"startDate";
NSString *const kEndDateKey             = @"endDate";
NSString *const kTaskRunKey             = @"taskRun";
NSString *const kItemKey                = @"item";

NSString *const kAppNameKey				= @"appName";
NSString *const kAppVersionKey			= @"appVersion";
NSString *const kPhoneInfoKey			= @"phoneInfo";
NSString *const kUploadTimeKey			= @"uploadTime";

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



/*********************************************************************************/
#pragma mark - Initialization
/*********************************************************************************/

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

- (instancetype) initWithTaskResult: (RKSTTaskResult*) taskResult
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
        [[NSFileManager defaultManager] createDirectoryAtPath:_tempOutputDirectory withIntermediateDirectories:YES attributes:nil error:&fileError];
        APCLogError2 (fileError);
    }
}



/*********************************************************************************/
#pragma mark - Task Results
/*********************************************************************************/

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
    rawTappingResults[kTappingSamplesKey] = sampleResults;


#warning Ron:  THIS IS NOT BEING USED AS INTENDED.  I renamed the method to reflect the intended use -- but this code is getting only part of the converted data.  I don't want to gratuitously make it "correct" because that might have lots of unintended side effects.

	NSDictionary *serializableData = [self generateSerializableDataFromSourceDictionary: rawTappingResults];
    [self writeResultDictionaryToArchive: serializableData];
}

- (void) addResultToArchive: (RKSTResult*) result
{
	NSMutableArray * propertyNames = [NSMutableArray array];

	/*
	 Get the names of all properties of our result's class
	 and all its superclasses.  Stop when we hit RKSTResult.
	 */
	Class klass = result.class;
	BOOL done = NO;
	NSArray *propertyNamesForOneClass = nil;

	while (klass != nil && ! done)
	{
		propertyNamesForOneClass = [self classPropsFor: klass];

		[propertyNames addObjectsFromArray: propertyNamesForOneClass];

		if (klass == [RKSTResult class])
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

- (NSDictionary *) generateSerializableDataFromSourceDictionary: (NSDictionary *) sourceDictionary
{
    static NSArray* array = nil;

	#warning Ron:  these hard-coded values seem to be the string equivalents of the some concept of a "question type," an integer, defined... somewhere else.  Where are those integers defined?  I think it'd help if these strings and those integers were defined in the same place.  And where is the "questionType" entry set to one of those integers?
    if (array == nil) {
        array = @[@"None", @"Scale", @"SingleChoice", @"MultipleChoice", @"Decimal",@"Integer", @"Boolean", @"Text", @"TimeOfDay", @"DateAndTime", @"Date", @"TimeInterval"];
    }

	NSMutableDictionary *somewhatCleanedUpSource = sourceDictionary.mutableCopy;


    //Replace questionType
    if (somewhatCleanedUpSource[kQuestionTypeKey]) {
        NSUInteger index = ((NSNumber*) somewhatCleanedUpSource[kQuestionTypeKey]).integerValue;

		#warning Ron:  here's where the question type is magically converted into one of the strings defined in this array called "array."
        if (index < array.count) {
            somewhatCleanedUpSource[kQuestionTypeKey] = array[index];
        }
    }
    
    //Remove userInfo if its empty
	#warning Ron:  should we also extract the item, see if it's a dictionary, and see if it's empty?
    if ([somewhatCleanedUpSource[kUserInfoKey] isEqual:[NSNull null]]) {
        [somewhatCleanedUpSource removeObjectForKey:kUserInfoKey];
    }
    
    //Replace identifier with item
	#warning Ron: why do this?  Who's consuming this, such that the word "item" is better than "identifier"?
	#warning Ron: and why modify the original, if we're about to make a copy anyway -- and we know we generated this dictionary on the line of code immediately preceding this method call?
    if (somewhatCleanedUpSource[kIdentifierKey]) {
        somewhatCleanedUpSource[kItemKey] =somewhatCleanedUpSource[kIdentifierKey];
        [somewhatCleanedUpSource removeObjectForKey:kIdentifierKey];
    }
    
    //Override dates with strings
	#warning Ron: why?  ...although the default formatter does seem to generate pretty, terse, and readable results: "2015-02-07 23:15:17 +0000".
    if ([somewhatCleanedUpSource[kStartDateKey] isKindOfClass:[NSDate class]]) {
        somewhatCleanedUpSource[kStartDateKey] = [NSString stringWithFormat:@"%@", somewhatCleanedUpSource[kStartDateKey]];
    }
    
    if ([somewhatCleanedUpSource[kEndDateKey] isKindOfClass:[NSDate class]]) {
        somewhatCleanedUpSource[kEndDateKey] = [NSString stringWithFormat:@"%@", somewhatCleanedUpSource[kEndDateKey]];
    }
    
    NSMutableDictionary * copyDictionary = [somewhatCleanedUpSource mutableCopy];

    [somewhatCleanedUpSource enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        // Delete NSCalendars.  By the time we serialize,
		// we'll have a date/time objects with time zones,
		// which is sufficient.
        if ([obj isKindOfClass:[NSCalendar class]])
		{
            [copyDictionary removeObjectForKey:key];
        }

		/*
		 If the thing in question can be serialized as-is,
		 leave it be.  Specifically:  if it's an array of
		 strings, numbers, nulls, or dictionaries/arrays
		 containing yet more primitives, include it as-is,
		 instead of stringifying it.
		 
		 The reason:  if we stringify these, they end up
		 with lots of gratuitous ()s, ""s, "\n"s, etc.
		 
		 The rules:
		 https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSJSONSerialization_Class/
		 */
		else if ([NSJSONSerialization isValidJSONObject: obj])
		{
			// Arrays and dictionaries containing nothing
			// but primitives, or more arrays/dictionaries
			// of primitives, will be fine.  Leave as-is.
		}

		else if ([obj isKindOfClass: [NSString class]])
		{
			// Strings will be serialized just fine.  Leave as-is.
		}

		else if ([obj isKindOfClass: [NSNumber class]] && [NSJSONSerialization isValidJSONObject: @[obj]])
		{
			// Numbers will be serialized just fine,
			// as long as they aren't NaN or infinity.
			// To check for that, I wrapped the number
			// in an array ( @[obj] ) and asked the
			// serializer to inspect it.
		}

		else
		{
			// No idea what it is.  Stringify it.
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
    [self.zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: url.path.lastPathComponent
                                                                compress:YES
                                                               dataBlock:^(NSError** error){ return [NSData dataWithContentsOfURL:url];}]];
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

+ (void) encryptZipFile: (NSString*) unencryptedPath encryptedPath:(NSString*) encryptedPath
{
    NSData * unencryptedZipData = [NSData dataWithContentsOfFile:unencryptedPath];
    
    NSError * encryptionError;
    NSData * encryptedZipData = RKSTCryptographicMessageSyntaxEnvelopedData(unencryptedZipData, [APCDataArchiver readPEM], RKEncryptionAlgorithmAES128CBC, &encryptionError);
    APCLogError2(encryptionError);
    
    NSError * fileWriteError;
    [encryptedZipData writeToFile:encryptedPath options:NSDataWritingAtomic error:&fileWriteError];
    APCLogError2(fileWriteError);
}

/*********************************************************************************/
#pragma mark - Helpers
/*********************************************************************************/
+ (NSData*) readPEM
{
    APCAppDelegate * appDelegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    NSString * path = [[NSBundle mainBundle] pathForResource:appDelegate.certificateFileName ofType:@"pem"];
    NSData * data = [NSData dataWithContentsOfFile:path];
    NSAssert(data != nil, @"Please add PEM file");
    return data;
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

@end
