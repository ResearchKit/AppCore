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
#import "RKSTAnswerFormat+Helper.h"

NSString *const kQuestionTypeKey        = @"questionType";
NSString *const kQuestionTypeNameKey    = @"questionTypeName";
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
	NSMutableDictionary *serializableDictionary = [NSMutableDictionary new];

	/*
	 Walk through all content we're about to serialize,
	 convert it to something safe, and add to the outbound
	 dictionary if desired.
	 */
	for (NSString *key in sourceDictionary.allKeys)
	{
		id value = sourceDictionary [key];


		// - - - - - - - - - - - - - -
		// Keys we like:  convert values to safe values
		// - - - - - - - - - - - - - -

		/*
		 QuestionType:

		 If we have a QuestionType, convert it to a human-readable name,
		 and put both the name and the value into the resulting dictionary.
		 This will let Sage (and us) switch() on the value, but debug it
		 using the name.
		 
		 If the questionType field doesn't contain a number, just pass
		 the value through as-is...  if it's legal JSON.  If not,
		 stringify it.  Either way, mark it as "unknown."  (This is
		 probably a programming error, though.)
		 */
		if ([key isEqualToString: kQuestionTypeKey])
		{
			NSString *questionTypeAsString = nil;
			id itemToSerialize = nil;

			// Make sure it's a legal number, not NaN or infinity,
			// or else it can't be serialized.
			if ([value isKindOfClass: [NSNumber class]]  && [NSJSONSerialization isValidJSONObject: @[value]])
			{
				NSNumber *questionTypeAsNumber = value;
				RKQuestionType questionType = questionTypeAsNumber.integerValue;
				questionTypeAsString = NSStringFromRKQuestionType (questionType);
				itemToSerialize = value;
			}

			else
			{
				questionTypeAsString = RKQuestionTypeUnknown;

				if ([NSJSONSerialization isValidJSONObject: @[value]])
				{
					// Don't know what it is (or why it's in the "question
					// type" field), but it's JSON-friendly.  Leave it as-is.
					itemToSerialize = value;
				}

				else
				{
					itemToSerialize = [NSString stringWithFormat: @"%@", value];
				}
			}

			serializableDictionary [kQuestionTypeKey] = itemToSerialize;
			serializableDictionary [kQuestionTypeNameKey] = questionTypeAsString;
		}

		/*
		 UserInfo:

		 Only copy the userInfo dictionary if it has something in it.
		 
		 If it contains non-JSON-friendly content, we'll stringify it.
		 (If that happens, it may be a programming error, though.)
		 */
		else if ([key isEqualToString: kUserInfoKey])
		{
			if (value != [NSNull null] &&
				[value isKindOfClass: [NSDictionary class]] &&
				((NSDictionary *) value).count > 0)
			{
				id itemToSerialize = nil;
				NSDictionary *userInfo = value;

				if ([NSJSONSerialization isValidJSONObject: userInfo])
				{
					itemToSerialize = userInfo;
				}
				else
				{
					itemToSerialize = [NSString stringWithFormat: @"%@", userInfo];
				}

				serializableDictionary [kUserInfoKey] = itemToSerialize;
			}

			else
			{
				// It's null, or an empty dictionary.  Ignore it --
				// omit it from the list of stuff to serialize.
			}
		}

		/*
		 Question Identifier:

		 Replace the key "identifier" with "item".
		 */
		#warning Ron: why do this?  Who's consuming this, such that the word "item" is better than "identifier"?
		else if ([key isEqualToString: kIdentifierKey])
		{
			id itemToSerialize = nil;

			if ([NSJSONSerialization isValidJSONObject: @[value]])
			{
				itemToSerialize = value;
			}
			else
			{
				itemToSerialize = [NSString stringWithFormat: @"%@", value];
			}

			serializableDictionary [kItemKey] = itemToSerialize;
		}

		

		// - - - - - - - - - - - - - -
		// Values to delete
		// - - - - - - - - - - - - - -
		
		/*
		 Delete calendars.  Meaning:  if we see one, ignore it.
		 
		 We'll serialize Dates to a string that contains the time
		 zone, so we don't need the Calendars.
		 */
		else if ([value isKindOfClass: [NSCalendar class]])
		{
			// Nothing to do.
		}



		// - - - - - - - - - - - - - -
		// Values the serializer can convert natively
		// - - - - - - - - - - - - - -
		
		/*
		 Arrays, dictionaries, strings, numbers, and nulls.

		 If the thing in question can be serialized as-is,
		 leave it be.  Specifically: 
		 
		 -	if it's an array of strings, numbers, nulls, or
			dictionaries/arrays containing yet more primitives,
			include it as-is, instead of stringifying it.  Why?
			Because if we stringify these, the strings end up
			with lots of gratuitous ()s, ""s, "\n"s, etc.

		 -	if it's a string or an NSNull, it's fine.
		 
		 -	if it's a number, and it's not NaN or infinity,
			it's fine.  Since the serializer can tell us
			about that, we'll just ask the serializer.
		 
		 We can check for all those situations by simply taking
		 the value, wrapping it in an array, and asking the
		 serializer to validate it.

		 The rules:
		 https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSJSONSerialization_Class/
		 */
		else if ([NSJSONSerialization isValidJSONObject: @[value]])

		{
			serializableDictionary [key] = value;
		}


		// - - - - - - - - - - - - - -
		// Everything else:  values we want to keep, but don't know how to convert
		// - - - - - - - - - - - - - -
		
		/*
		 If we get here:  we've deleted stuff we wanted to delete,
		 and converted stuff we wanted to convert.  Anything else
		 is data we do indeed like, but we don't know how to deal
		 with it, and the serializer didn't know, either.  So...
		 convert it to a string.
		 
		 This includes NSDates, by the way.  Their default
		 stringifier works fine.
		 */
		else
		{
			NSString *valueToSerialize = [NSString stringWithFormat: @"%@", value];
			serializableDictionary [key] = valueToSerialize;
		}
	}

	/*
	 Whew.  Done.  Return an immutable copy, just on the principle of encapsulation.
	 */
	return [NSDictionary dictionaryWithDictionary: serializableDictionary];
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
