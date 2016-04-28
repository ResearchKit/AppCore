//
//  APCTaskResultArchiver.m
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

#import "APCTaskResultArchiver.h"
#import "APCAppDelegate.h"
#import "APCLog.h"
#import "APCDataArchive.h"
#import "APCTask.h"
#import "APCDataResult.h"
#import "APCJSONSerializer.h"
#import "ORKFileResult+Filename.h"

#import <objc/runtime.h>

NSString * const kJSONExtension = @"json";
NSString * const APCDefaultTranslationFilename = @"FilenameTranslation";

//
//    ORK Result Base Class property keys
//
static NSString * const kIdentifierKey              = @"identifier";
static NSString * const kStartDateKey               = @"startDate";
static NSString * const kEndDateKey                 = @"endDate";
static NSString * const kUserInfoKey                = @"userInfo";
static NSString * const kAnswerKey                  = @"answer";

//
//    General-Use Dictionary Keys
//
static  NSString  *const  kItemKey                  = @"item";
//
//    Interval Tapping Dictionary Keys
//
static  NSString  *const  kTappingViewSizeKey       = @"TappingViewSize";
static  NSString  *const  kButtonRectLeftKey        = @"ButtonRectLeft";
static  NSString  *const  kButtonRectRightKey       = @"ButtonRectRight";
static  NSString  *const  kTappingSamplesKey        = @"TappingSamples";
static  NSString  *const  kTappedButtonIdKey        = @"TappedButtonId";
static  NSString  *const  kTappedButtonNoneKey      = @"TappedButtonNone";
static  NSString  *const  kTappedButtonLeftKey      = @"TappedButtonLeft";
static  NSString  *const  kTappedButtonRightKey     = @"TappedButtonRight";
static  NSString  *const  kTapTimeStampKey          = @"TapTimeStamp";
static  NSString  *const  kTapCoordinateKey         = @"TapCoordinate";
//
//    Spatial Span Memory Dictionary Keys — Game Status
//
static  NSString   *const  kSpatialSpanMemoryGameStatusKey              = @"MemoryGameStatus";
static  NSString   *const  kSpatialSpanMemoryGameStatusUnknownKey       = @"MemoryGameStatusUnknown";
static  NSString   *const  kSpatialSpanMemoryGameStatusSuccessKey       = @"MemoryGameStatusSuccess";
static  NSString   *const  kSpatialSpanMemoryGameStatusFailureKey       = @"MemoryGameStatusFailure";
static  NSString   *const  kSpatialSpanMemoryGameStatusTimeoutKey       = @"MemoryGameStatusTimeout";
//
//    Spatial Span Memory Dictionary Keys — Summary
//
static  NSString  *const  kSpatialSpanMemorySummaryNumberOfGamesKey     = @"MemoryGameNumberOfGames";
static  NSString  *const  kSpatialSpanMemorySummaryNumberOfFailuresKey  = @"MemoryGameNumberOfFailures";
static  NSString  *const  kSpatialSpanMemorySummaryOverallScoreKey      = @"MemoryGameOverallScore";
static  NSString  *const  kSpatialSpanMemorySummaryGameRecordsKey       = @"MemoryGameGameRecords";
static  NSString  *const  kSpatialSpanMemorySummaryFilenameKey          = @"MemoryGameResults.json";
//
//    Spatial Span Memory Dictionary Keys — Game Records
//
static  NSString   *const  kSpatialSpanMemoryGameRecordSeedKey          = @"MemoryGameRecordSeed";
static  NSString   *const  kSpatialSpanMemoryGameRecordSequenceKey      = @"MemoryGameRecordSequence";
static  NSString   *const  kSpatialSpanMemoryGameRecordGameSizeKey      = @"MemoryGameRecordGameSize";
static  NSString   *const  kSpatialSpanMemoryGameRecordTargetRectsKey   = @"MemoryGameRecordTargetRects";
static  NSString   *const  kSpatialSpanMemoryGameRecordTouchSamplesKey  = @"MemoryGameRecordTouchSamples";
static  NSString   *const  kSpatialSpanMemoryGameRecordGameScoreKey     = @"MemoryGameRecordGameScore";
//
//    Spatial Span Memory Dictionary Keys — Touch Samples
//
static  NSString  *const  kSpatialSpanMemoryTouchSampleTimeStampKey     = @"MemoryGameTouchSampleTimestamp";
static  NSString  *const  kSpatialSpanMemoryTouchSampleTargetIndexKey   = @"MemoryGameTouchSampleTargetIndex";
static  NSString  *const  kSpatialSpanMemoryTouchSampleLocationKey      = @"MemoryGameTouchSampleLocation";
static  NSString  *const  kSpatialSpanMemoryTouchSampleIsCorrectKey     = @"MemoryGameTouchSampleIsCorrect";

@interface APCTaskResultArchiver ()

@property (nonatomic, strong) NSMutableSet *filenames;

@end

@implementation APCTaskResultArchiver

- (void)appendArchive:(APCDataArchive*)archive withTaskResult:(ORKTaskResult *)result
{
    // Track filenames. Occasionally RK spit out 2 files with the same name which causes trouble on the backend
    // if the archive has 2 files named the same. See BRIDGE-789.
    self.filenames = [NSMutableSet new];
    
    //add dictionaries or json data to the archive, calling completeArchive when done
    for (ORKStepResult *stepResult in result.results) {
        [stepResult.results enumerateObjectsUsingBlock:^(ORKResult *result, NSUInteger __unused idx, BOOL *__unused stop) {
            
            //Update date if needed
            if (!result.startDate) {
                result.startDate = stepResult.startDate;
                result.endDate = stepResult.endDate;
            }
            
            if (![self appendArchive:archive withResult:result forStepResult:stepResult])
            {
                APCLogError(@"Result not processed for : %@", result.identifier);
            }
        }];
    }
    
    self.filenames = nil;
}

- (BOOL)appendArchive:(APCDataArchive*)archive withResult:(ORKResult *)result forStepResult:(ORKStepResult*)stepResult
{
    BOOL success = NO;
    
    if ([result isKindOfClass:[APCDataResult class]])
    {
        APCDataResult * dataResult = (APCDataResult*) result;
        success = [self appendArchive:archive withJSONDataResult:dataResult forStepResult:stepResult];
    }
    
    else if ([result isKindOfClass:[ORKFileResult class]])
    {
        ORKFileResult * fileResult = (ORKFileResult*) result;
        success = [self appendArchive:archive withFileResult:fileResult forStepResult:stepResult];
    }
    
    else if ([result isKindOfClass:[ORKTappingIntervalResult class]])
    {
        ORKTappingIntervalResult  *tappingResult = (ORKTappingIntervalResult *)result;
        success = [self appendArchive:archive withTappingResult:tappingResult];
    }
    
    else if ([result isKindOfClass:[ORKSpatialSpanMemoryResult class]])
    {
        ORKSpatialSpanMemoryResult  *spatialSpanMemoryResult = (ORKSpatialSpanMemoryResult *)result;
        success = [self appendArchive:archive withSpatialSpanMemoryResult:spatialSpanMemoryResult];
    }
    
    else if ([result isKindOfClass:[ORKQuestionResult class]])
    {
        ORKQuestionResult *questionResult = (ORKQuestionResult*)result;
        success = [self appendArchive:archive withQuestionResult:questionResult];
    }
    
    return success;
}


/*********************************************************************************/
#pragma mark - Add Task-Specific Results — File
/*********************************************************************************/

- (BOOL)appendArchive:(APCDataArchive *)archive withJSONDataResult:(APCDataResult*)dataResult forStepResult:(ORKStepResult*)stepResult
{
    dataResult.identifier = dataResult.identifier ? : (stepResult.identifier ? : [NSUUID UUID].UUIDString);
    NSString *fileName = [dataResult.identifier stringByAppendingString:@"_data"];
    [archive insertJSONDataIntoArchive:dataResult.data filename:fileName];
    return YES;
}


/*********************************************************************************/
#pragma mark - Add Task-Specific Results — File
/*********************************************************************************/

- (BOOL)appendArchive:(APCDataArchive *)archive withFileResult:(ORKFileResult*)fileResult forStepResult:(ORKStepResult*)stepResult
{
    NSString *translatedFilename = [self filenameForFileResultIdentifier:fileResult.identifier stepIdentifier:stepResult.identifier extension:nil];
    if (fileResult.fileURL && ![self.filenames containsObject:translatedFilename]) {
        [self.filenames addObject:translatedFilename];
        [archive insertDataAtURLIntoArchive:fileResult.fileURL fileName:translatedFilename];
    }
    return YES;
}


/*********************************************************************************/
#pragma mark - Add Task-Specific Results — Tapping
/*********************************************************************************/

- (BOOL)appendArchive:(APCDataArchive *)archive withTappingResult:(ORKTappingIntervalResult *)result
{
    NSString *result_filename = [self filenameForFileResultIdentifier:result.identifier
                                                       stepIdentifier:nil
                                                            extension:@"json"];
    
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
    rawTappingResults[kItemKey] = result_filename;
    
    NSDictionary *serializableData = [APCJSONSerializer serializableDictionaryFromSourceDictionary: rawTappingResults];
    
    [archive insertDictionaryIntoArchive:serializableData filename:result_filename];
    return YES;
}


/*********************************************************************************/
#pragma mark - Add Task-Specific Results — Spatial Span Memory
/*********************************************************************************/

- (BOOL)appendArchive:(APCDataArchive *)archive withSpatialSpanMemoryResult:(ORKSpatialSpanMemoryResult *)result
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
    NSString *result_filename = [self filenameForFileResultIdentifier:result.identifier
                                                       stepIdentifier:nil
                                                            extension:@"json"];
    memoryGameResults[kItemKey] = result_filename;
    
    NSDictionary  *serializableData = [APCJSONSerializer serializableDictionaryFromSourceDictionary: memoryGameResults];

    [archive insertDictionaryIntoArchive:serializableData filename:result_filename];
    return YES;
}

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


/*********************************************************************************/
#pragma mark - Add Task-Specific Results — Question Survey
/*********************************************************************************/

- (BOOL)appendArchive:(APCDataArchive *)archive withQuestionResult: (ORKQuestionResult*) result
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
    
    // Almost all of the time we want dates to be serialized as ISO 8601 per sage bridge request
    // However, in the instance of question result with ORKQuestionTypeDate type, we want to use
    // a specific date format per sage bridge documentation
    NSDictionary* dateFormatterForKeys = nil;
    if (result.questionType == ORKQuestionTypeDate) {
        dateFormatterForKeys = @{ kAnswerKey: ORKResultDateFormatter() };
    }
    
    NSDictionary *propertiesToSave = [result dictionaryWithValuesForKeys: propertyNames];
    APCJSONSerializer* jsonSerializer = [[APCJSONSerializer alloc] initWithDateFormatterForKeys:dateFormatterForKeys];
    NSDictionary *serializableDictionary = [jsonSerializer serializableDictionaryFromSourceDictionary:propertiesToSave];
    
    APCLogDebug(@"%@", serializableDictionary);
    
    NSString *filename = [self filenameForFileResultIdentifier:result.identifier
                                                stepIdentifier:nil
                                                     extension:@"json"];
    
    [archive insertDictionaryIntoArchive:serializableDictionary filename:filename];
    return YES;
}


/*********************************************************************************/
#pragma mark - Utilities
/*********************************************************************************/

- (NSDictionary *)filenameTranslationDictionary
{
    if (_filenameTranslationDictionary == nil) {
        NSString *path = [[APCAppDelegate sharedAppDelegate] pathForResource:APCDefaultTranslationFilename ofType:kJSONExtension];
        [self setFilenameTranslationDictionaryWithJSONFileAtPath:path];
    }
    return _filenameTranslationDictionary;
}

- (void)setFilenameTranslationDictionaryWithJSONFileAtPath:(NSString * _Nonnull)filePath
{
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    if (JSONString != nil) {
        NSError *parseError;
        _filenameTranslationDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding]
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&parseError];
        if (parseError) {
            APCLogDebug(@"%@", parseError);
        }
    }
    if (_filenameTranslationDictionary == nil) {
        _filenameTranslationDictionary = @{};
    }
}

- (NSString *)filenameForResult:(ORKResult*)result stepResult:(ORKStepResult *)stepResult
{
    if ([result isKindOfClass:[APCDataResult class]])
    {
        result.identifier = result.identifier ?: (stepResult.identifier ?: [NSUUID UUID].UUIDString);
        return [result.identifier stringByAppendingString:@"_data"];
    }
    else if ([result isKindOfClass:[ORKFileResult class]])
    {
        return [self filenameForFileResultIdentifier:result.identifier stepIdentifier:stepResult.identifier extension:nil];
    }
    else
    {
        return [self filenameForFileResultIdentifier:result.identifier stepIdentifier:nil extension:@"json"];
    }
}

- (NSString *)filenameForFileResultIdentifier: (NSString * _Nullable )fileResultIdentifier stepIdentifier: (NSString * _Nullable)stepIdentifier extension:(NSString * _Nullable)extension
{
    fileResultIdentifier = [ORKFileResult rawFilenameForFileResultIdentifier:fileResultIdentifier stepIdentifier:stepIdentifier];

    NSDictionary *translationDictionary = self.filenameTranslationDictionary;
    NSString *translatedFilename = [translationDictionary objectForKey:fileResultIdentifier];
    
    if (translatedFilename == nil) {
        if (extension != nil) {
            translatedFilename = [NSString stringWithFormat:@"%@.%@", fileResultIdentifier, extension];
        }
        else {
            translatedFilename = fileResultIdentifier;
        }
    }
    
    return translatedFilename;
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
