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
        [[NSFileManager defaultManager] createDirectoryAtPath:_tempOutputDirectory withIntermediateDirectories:YES attributes:nil error:&fileError];
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
                [self addFileToArchive:fileResult.fileURL contentType:@"data" timeStamp:fileResult.endDate];
            }
            else if ([result isKindOfClass:[ORKTappingIntervalResult class]])
            {
                ORKTappingIntervalResult  *tappingResult = (ORKTappingIntervalResult *)result;
                [self addTappingResultsToArchive:tappingResult];
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

- (void) addFileToArchive: (NSURL*) fileURL contentType: (NSString*) contentType timeStamp: (NSDate*) date
{
    NSString * fileName = fileURL.lastPathComponent;
    [self writeURLToArchive:fileURL];
    [self addFileInfoEntryWithFileName:fileName timeStamp: date.toStringInISO8601Format contentType:contentType];
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

	NSDictionary *serializableData = [self generateSerializableDataFromSourceDictionary: rawTappingResults];
    [self writeResultDictionaryToArchive: serializableData];
}

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

- (NSDictionary *) generateSerializableDataFromSourceDictionary: (NSDictionary *) sourceDictionary
{
	NSMutableDictionary *serializableDictionary = [NSMutableDictionary new];

	/*
	 Walk through all content we're about to serialize,
	 decide if we want to keep it, convert it to something
	 safe, and add it to the outbound dictionary if desired.
	 */
	for (NSString *key in sourceDictionary.allKeys)
	{
		id value = sourceDictionary [key];


		//
		// Delete calendars.
		//

		if ([value isKindOfClass: [NSCalendar class]])
		{
			// Skip it.
		}

        
		//
		// Replace the key "identifier" with the key "item".
		//
		// Note:  several other parts of this file use kItemKey.
		//

		else if ([key isEqualToString: kIdentifierKey])
		{
			id itemToSerialize = [self safeSerializableItemFromItem: value];
			serializableDictionary [kItemKey] = itemToSerialize;
		}


		//
		// Find and include the names for RKQuestionTypes.
		//

		else if ([key isEqualToString: kQuestionTypeKey])
		{
			id valueToSerialize = nil;
			NSString* nameToSerialize = nil;

			NSNumber *questionType = [self safeSerializableQuestionTypeFromItem: value];

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

			serializableDictionary [kQuestionTypeKey] = valueToSerialize;
			serializableDictionary [kQuestionTypeNameKey] = nameToSerialize;
		}


		//
		// Include the userInfo dictionary if it has something in it.
		//

		else if ([key isEqualToString: kUserInfoKey])
		{
			NSDictionary *safeDictionary = [self safeAndUsefulSerializableDictionaryFromMaybeDictionary: value];

			if (safeDictionary)
			{
				serializableDictionary [kUserInfoKey] = safeDictionary;
			}

			else
			{
				// It's null, empty, or not a dictionary.  Skip it.
			}
		}


		//
		// Arrays of Integers and Booleans
		//

		/*
		 Very commonly, we have arrays of integers and Booleans
		 (as answers to multiple-choice questions, say).
		 However, much earlier in this process, they got converted
		 to strings.  This seems to be a core feature of ResearchKit.
		 But there's still value in them being numeric or Boolean
		 answers.  So if this is an array, try to convert each item
		 to an integer or Boolean.  If we can't, just call our master
		 -safe: method to make sure we can serialize it.
		 */
		else if ([value isKindOfClass: [NSArray class]])
		{
			NSArray *inputArray = value;
			NSMutableArray *outputArray = [NSMutableArray new];

			for (id item in inputArray)
			{
				id outputItem = [self safeSerializableIntOrBoolFromStringIfString: item];

				if (outputItem == nil)
				{
					outputItem = [self safeSerializableItemFromItem: item];
				}

				[outputArray addObject: outputItem];
			}

			serializableDictionary [key] = outputArray;
        }


        //
        // Make dates "ISO-8601 compliant."  Meaning, format
        // them like this:  2015-02-25T16:42:11+00:00
        //
        // Per Sage.
        // From http://en.wikipedia.org/wiki/ISO_8601.
        //
        else if ([value isKindOfClass: [NSDate class]])
        {
            NSDate *theDate = (NSDate *) value;
            NSString *sageFriendlyDate = theDate.toStringInISO8601Format;
            serializableDictionary [key] = sageFriendlyDate;
        }


		//
		// Everything Else
		//

		/*
		 If we get here:  we want to keep it, but don't have specific
		 rules for converting it.  Use our default serialization process:
		 include it as-is if the serializer recognizes it, or convert it
		 to a string if not.
		 */
		else
		{
			id itemToSerialize = [self safeSerializableItemFromItem: value];
			serializableDictionary [key] = itemToSerialize;
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
                                                                   dataBlock:^(NSError** __unused error){ return jsonData;}]];
    }
    else {
        APCLogError2(error);
    }
}

- (void) writeDataToArchive: (NSData*) data fileName: (NSString*) fileName
{
    [self.zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: fileName
                                                                compress:YES
                                                               dataBlock:^(NSError** __unused error){ return data;}]];
}

- (void) writeURLToArchive: (NSURL*) url
{
    [self.zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: url.path.lastPathComponent
                                                                compress:YES
                                                               dataBlock:^(NSError** __unused error){ return [NSData dataWithContentsOfURL:url];}]];
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

/**
 Try to convert the specified item to an NSNumber, specifically
 if it's a String that looks like a Boolean or an intenger.
 */
- (NSNumber *) safeSerializableIntOrBoolFromStringIfString: (id) item
{
	NSNumber *result = nil;

	if ([item isKindOfClass: [NSString class]])
	{
		NSString *itemAsString = item;

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
	}

	return result;
}

/**
 If this item is a Number, try to convert it to an RKQuestionType.
 */
- (NSNumber *) safeSerializableQuestionTypeFromItem: (id) item
{
	NSNumber* result = nil;

	if ([item isKindOfClass: [NSNumber class]]  && [NSJSONSerialization isValidJSONObject: @[item]])
	{
		NSNumber *questionTypeAsNumber = item;
		ORKQuestionType questionType = questionTypeAsNumber.integerValue;
		result = @(questionType);
	}

	return result;
}

/**
 If this is a Dictionary, and it has stuff in it, 
 keep it -- either as a Dictionary (if we can
 serialize it) or a string (if not).
 */
- (NSDictionary *) safeAndUsefulSerializableDictionaryFromMaybeDictionary: (id) maybeDictionary
{
	NSDictionary *result = nil;

	if (maybeDictionary != [NSNull null] &&
		[maybeDictionary isKindOfClass: [NSDictionary class]] &&
		((NSDictionary *) maybeDictionary).count > 0)
	{
		// Make sure the whole dictionary can be serialized.
		// If not, convert it to a string.
		result = [self safeSerializableItemFromItem: maybeDictionary];
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
	 NSJSONSerializer can only take an array or
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
