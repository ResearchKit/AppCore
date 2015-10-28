// 
//  APCDataArchive.m
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

@import BridgeSDK;
#import "APCDataArchive.h"
#import "zipzap.h"
#import <objc/runtime.h>
#import "APCUtilities.h"
#import "ORKAnswerFormat+Helper.h"
#import "APCLog.h"
#import "NSDate+Helper.h"
#import "APCJSONSerializer.h"
#import "NSError+APCAdditions.h"
#import "APCConstants.h"

static NSString * kFileInfoNameKey                  = @"filename";
static NSString * kUnencryptedArchiveFilename       = @"unencrypted.zip";
static NSString * kFileInfoTimeStampKey             = @"timestamp";
static NSString * kFileInfoContentTypeKey           = @"contentType";
static NSString * kTaskRunKey                       = @"taskRun";
static NSString * kSurveyCreatedOnKey               = @"surveyCreatedOn";
static NSString * kSurveyGuidKey                    = @"surveyGuid";
static NSString * kSchemaRevisionKey                = @"schemaRevision";
static NSString * kFilesKey                         = @"files";
static NSString * kAppNameKey                       = @"appName";
static NSString * kAppVersionKey                    = @"appVersion";
static NSString * kPhoneInfoKey                     = @"phoneInfo";
static NSString * kItemKey                          = @"item";
static NSString * kJsonPathExtension                = @"json";
static NSString * kJsonInfoFilename                 = @"info.json";

@interface APCDataArchive ()

@property (nonatomic, strong) NSString *reference;
@property (nonatomic, strong) APCTask *task;
@property (nonatomic, strong) ZZArchive *zipArchive;
@property (nonatomic, strong) NSMutableArray *zipEntries;
@property (nonatomic, strong) NSMutableArray *filesList;
@property (nonatomic, strong) NSMutableDictionary *infoDict;

@end

@implementation APCDataArchive

//designated initializer
- (id)initWithReference: (NSString *)reference
{
    self = [super init];
    if (self) {
        _reference = reference;
        [self createArchive];
    }
    
    return self;
}

// designated initializer
- (id)initWithReference: (NSString *)reference task:(APCTask *)task
{
    self = [super init];
    if (self) {
        _reference = reference;
        _task = task;
        [self createArchive];
    }
    
    return self;
}

//create a new zip archive at the reference path
- (void)createArchive
{
    
    NSURL *zipArchiveURL = [NSURL fileURLWithPath:[[self workingDirectoryPath] stringByAppendingPathComponent:kUnencryptedArchiveFilename]];
    _unencryptedURL = zipArchiveURL;

    _zipEntries = [NSMutableArray array];
    _filesList = [NSMutableArray array];
    _infoDict = [NSMutableDictionary dictionary];
    NSError * error;
    
    _zipArchive = [[ZZArchive alloc] initWithURL:zipArchiveURL
                                             options:@{ZZOpenOptionsCreateIfMissingKey : @YES}
                                               error:&error];
    if (!_zipArchive) {
        APCLogError2(error);
    }
}

//A sandbox in the temporary directory for this archive to be cleaned up on completion.
- (NSString *)workingDirectoryPath
{
    
    NSString *workingDirectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.reference];
    if (![[NSFileManager defaultManager] fileExistsAtPath:workingDirectoryPath]) {
        NSError * fileError;
        BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:workingDirectoryPath withIntermediateDirectories:YES attributes:@{ NSFileProtectionKey : NSFileProtectionComplete } error:&fileError];
        if (!created) {
            workingDirectoryPath = nil;
            APCLogError2 (fileError);
        }
    }
    
    return workingDirectoryPath;
}

- (void)insertDataAtURLIntoArchive: (NSURL*) url fileName: (NSString *) filename
{
    NSData *dataToInsert = [NSData dataWithContentsOfURL:url];
    [self insertDataIntoArchive:dataToInsert filename:filename];
}

- (void)insertJSONDataIntoArchive:(NSData *)jsonData filename:(NSString *)filename
{
    if (jsonData !=nil) {
        [self insertDataIntoArchive:jsonData filename:filename];
    }
}

// Converts the dictionary into json and inserts into the archive using the given filename
- (void)insertIntoArchive:(NSDictionary *)dictionary filename: (NSString *)filename
{
    
    NSError * serializationError;
    NSData * jsonData;
    
    NSDictionary *newDictionary = [APCJSONSerializer serializableDictionaryFromSourceDictionary: dictionary];
    
    if (newDictionary) {
        
        jsonData = [NSJSONSerialization dataWithJSONObject:newDictionary options:NSJSONWritingPrettyPrinted error:&serializationError];
        
        if (jsonData !=nil) {
            [self insertDataIntoArchive:jsonData filename:filename];
        }else{
            APCLogError2(serializationError);
        }
    }
}

- (void)insertDataIntoArchive :(NSData *)data filename: (NSString *)filename
{
    [self.zipEntries addObject: [ZZArchiveEntry archiveEntryWithFileName: filename
                                                                compress:YES
                                                               dataBlock:^(NSError** error)
                                 {
                                     APCLogError2(*error);
                                     return data;
                                 }]];
    
    //add the fileInfoEntry
    NSString *extension = [filename pathExtension] ? : kJsonPathExtension;
    NSDictionary *fileInfoEntry = @{ kFileInfoNameKey: filename,
                                     kFileInfoTimeStampKey: [NSDate date].toStringInISO8601Format,
                                     kFileInfoContentTypeKey: [self contentTypeForFileExtension:extension] };
    
    [self.filesList addObject:fileInfoEntry];

}

//Compiles the final info.json file and inserts it into the zip archive.
-(void)completeArchiveWithErrorHandler:(void (^)(NSError *))errorHandler
{
    
    if (self.filesList.count) {
        [self.infoDict setObject:self.filesList forKey:kFilesKey];
        [self.infoDict setObject:[APCUtilities appName] forKey:kAppNameKey];
        [self.infoDict setObject:[APCUtilities appVersion] forKey:kAppVersionKey];
        [self.infoDict setObject:[APCUtilities phoneInfo] forKey:kPhoneInfoKey];
        [self.infoDict setObject:[NSUUID new].UUIDString forKey:kTaskRunKey];
        [self.infoDict setObject:self.reference forKey:kItemKey];
        if (self.task.taskSchemaRevision) {
            [self.infoDict setObject:self.task.taskSchemaRevision forKey:kSchemaRevisionKey];
        }
        if ([self.task.taskType isEqualToNumber:@(APCTaskTypeSurveyTask)]) {
            // Survey schema is better matched by created date and survey guid
            [self.infoDict setObject:self.task.taskVersionName forKey:kSurveyGuidKey];
            NSString *isoCreatedString = [self.task.taskVersionDate ISO8601String];
            [self.infoDict setObject:isoCreatedString forKey:kSurveyCreatedOnKey];
        }
        
        [self insertIntoArchive:self.infoDict filename:kJsonInfoFilename];
        
        NSError * error;
        if (![self.zipArchive updateEntries:self.zipEntries error:&error]) {
            APCLogError2(error);
        }
        
        errorHandler(error);
    }
}

//delete the workingDirectoryPath, and therefore its contents.
-(void)removeArchive
{
    NSError *err;
    if (![[NSFileManager defaultManager] removeItemAtPath:[self workingDirectoryPath] error:&err]) {
        NSAssert(false, @"failed to remove unencrypted archive at %@",[self workingDirectoryPath] );
        APCLogError2(err);
    }
}

#pragma mark - Helpers

- (NSString *)contentTypeForFileExtension: (NSString *)extension
{
    
    NSString *contentType;
    if ([extension isEqualToString:@"csv"]) {
        contentType = @"text/csv";
    }else if ([extension isEqualToString:@"m4a"]) {
        contentType = @"audio/mp4";
    }else {
        contentType = @"application/json";
    }
    
    return contentType;

}



@end
