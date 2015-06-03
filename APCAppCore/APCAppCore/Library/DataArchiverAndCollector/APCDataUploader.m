//
//  APCDataUploader.m
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

#import "APCDataUploader.h"
#import "zipzap.h"
#import "APCLog.h"
#import "APCDataArchiver.h"
#import "APCUtilities.h"
#import "NSError+APCAdditions.h"
#import <BridgeSDK/BridgeSDK.h>
#import "APCConstants.h"

static NSString * kFileInfoNameKey                  = @"filename";
static NSString * kEncryptedDataFilename            = @"encrypted.dat";
static NSString * kUnencryptedArchiveFilename       = @"unencrypted.zip";
static NSString * kFileInfoTimeStampKey             = @"timestamp";
static NSString * kFileInfoContentTypeKey           = @"contentType";
static NSString * kTaskRunKey                       = @"taskRun";
static NSString * kFilesKey                         = @"files";
static NSString * kAppNameKey                       = @"appName";
static NSString * kAppVersionKey                    = @"appVersion";
static NSString * kPhoneInfoKey                     = @"phoneInfo";
static NSString * kItemKey                          = @"item";

@interface APCDataUploader ()

@property (nonatomic, strong) NSString *uploadReference;
@property (nonatomic, strong) ZZArchive * zipArchive;
@property (nonatomic, strong) NSMutableArray * zipEntries;
@property (nonatomic, strong) NSString *encryptedArchiveFilename;
@property (nonatomic, strong) NSMutableArray * filesList;
@property (nonatomic, strong) NSMutableDictionary * infoDict;

@end

@implementation APCDataUploader

//designated initializer
- (id)initWithUploadReference: (NSString *)ref
{
    self = [super init];
    if (self) {
        self.uploadReference = ref;
        [self createZipArchive];
    }
    
    return self;
}

#pragma mark - Zip

//create a new zip archive as a container for this upload
- (void)createZipArchive{
    
    NSURL *zipArchiveURL = [NSURL fileURLWithPath:[[self workingDirectoryPath] stringByAppendingPathComponent:kUnencryptedArchiveFilename]];
    
    self.zipEntries = [NSMutableArray array];
    self.filesList = [NSMutableArray array];
    self.infoDict = [NSMutableDictionary dictionary];
    NSError * error;
    
    self.zipArchive = [[ZZArchive alloc] initWithURL:zipArchiveURL
                                         options:@{ZZOpenOptionsCreateIfMissingKey : @YES}
                                           error:&error];
    if (!self.zipArchive) {
        APCLogError2(error);
    }
}

- (void)insertJSONDataIntoZipArchive:(NSData *)jsonData filename:(NSString *)filename
{
 
    if (jsonData !=nil) {
        NSString * fullFileName = [filename stringByAppendingPathExtension:@"json"];
        
        APCLogFilenameBeingArchived (fullFileName);
        
        id objectToInsert = [ZZArchiveEntry archiveEntryWithFileName: fullFileName
                                                            compress:YES
                                                           dataBlock:^(NSError** __unused error){ return jsonData;}];
        
        [self.zipEntries addObject: objectToInsert];
        
        if (objectToInsert) {
            [self.zipEntries addObject: objectToInsert];
            NSMutableDictionary * fileInfoEntry = [NSMutableDictionary dictionary];
            fileInfoEntry[kFileInfoNameKey] = fullFileName;
            fileInfoEntry[kFileInfoTimeStampKey] = [NSDate new];
            fileInfoEntry[kFileInfoContentTypeKey] = @"application/json";
            [self.filesList addObject:fileInfoEntry];
        }else{
            APCLogDebug(@"failed to insert %@ into archive", filename);
        }
    }
}

// Converts the dictionary into json and inserts into the archive using the given filename
- (void)insertIntoZipArchive:(NSDictionary *)dictionary filename: (NSString *)filename{
   
    NSError * serializationError;
    NSData * jsonData;
    if ([NSJSONSerialization isValidJSONObject:dictionary]) {
        
        jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&serializationError];
        if (!jsonData) {
            APCLogDebug(@"serialization error: %@", serializationError.message);
        }
        
    }else{
        APCLogDebug(@"%@ is not a valid JSON object, attempting to fix...", filename);
        APCDataArchiver *archiver = [[APCDataArchiver alloc]init];
        NSDictionary *newDictionary = [archiver generateSerializableDataFromSourceDictionary:dictionary];
        if ([NSJSONSerialization isValidJSONObject:newDictionary]) {
            [self insertIntoZipArchive:newDictionary filename:filename];
        }
    }
    
    if (jsonData !=nil) {
        
        [self insertJSONDataIntoZipArchive:jsonData filename:filename];
    }
    
}

//Compiles the final info.json file and inserts it into the zip archive.
- (BOOL)completeZip{
    
    BOOL success = NO;
    
    if (self.filesList.count) {
        [self.infoDict setObject:self.filesList forKey:kFilesKey];
        [self.infoDict setObject:[APCUtilities appName] forKey:kAppNameKey];
        [self.infoDict setObject:[APCUtilities appVersion] forKey:kAppVersionKey];
        [self.infoDict setObject:[APCUtilities phoneInfo] forKey:kPhoneInfoKey];
        [self.infoDict setObject:[NSUUID new].UUIDString forKey:kTaskRunKey];
        [self.infoDict setObject:self.uploadReference forKey:kItemKey];
        
        [self insertIntoZipArchive:self.infoDict filename:@"info"];
        
        NSError * error;
        if (![self.zipArchive updateEntries:self.zipEntries error:&error]) {
            APCLogError2(error);
        }else{
            success = YES;
            APCLogDebug(@"Outputting infoDict to console\n%@", self.infoDict);
        }
    }
    
    return success;
}

#pragma mark - Encryption

//Calls the APCDataArchiver to encrypt the zip file.
- (BOOL)encryptZip{
    
    self.encryptedArchiveFilename = [[self workingDirectoryPath] stringByAppendingPathComponent:kEncryptedDataFilename];
    
    BOOL success = NO;
    
    NSError *reachableError;
    if (![self.zipArchive.URL checkResourceIsReachableAndReturnError:&reachableError]) {
        APCLogDebug(@"resource is unreachable: %@", reachableError.message);
    }else{
        if ([APCDataArchiver encryptZipFile:[self.zipArchive.URL relativePath] encryptedPath:self.encryptedArchiveFilename]){
            success = YES;
        }else{
            APCLogDebug(@"Encryption of zip file failed, won't upload");
        }
    }
    
    return success;
}

#pragma mark - Upload

//sequentially and conditionally proceed through the encryption and upload process
- (void)uploadWithCompletion: (void(^)(void)) completion
{
    
    if ([self completeZip])
    {
        if ([self encryptZip]) {
            [self uploadEncryptedZipWithCompletion:completion];
            
        }else{
            APCLogDebug(@"Failed to encrypt zip");
        }
        
    }else{
        APCLogDebug(@"Failed to complete zip");
    }
    
}

//Wrapper around SBBUploadManager which calls the completion block on success.
- (void)uploadEncryptedZipWithCompletion: (void(^)(void)) completion{
    
    NSURL *encryptedZipURL = [NSURL fileURLWithPath:self.encryptedArchiveFilename];
    
    NSError *reachableError;
    if (![encryptedZipURL checkResourceIsReachableAndReturnError:&reachableError]) {
        APCLogDebug(@"resource is unreachable: %@", reachableError.message);
    }else{
        APCLogFilenameBeingUploaded (encryptedZipURL.absoluteString);
        
        __weak typeof(self) weakSelf = self;
        
        [SBBComponent(SBBUploadManager) uploadFileToBridge:encryptedZipURL contentType:@"application/zip" completion:^(NSError *error) {
            if (!error) {
                APCLogEventWithData(kNetworkEvent, (@{@"event_detail":[NSString stringWithFormat:@"APCDataUploader uploaded file: %@", self.encryptedArchiveFilename.lastPathComponent]}));
                
                if (completion){
                    completion();
                }
                
            }else{
                APCLogDebug(@"%@", error.message);
            }
            
            [weakSelf cleanUp];
            
        }];
    }
}

#pragma mark - File Management

//A sandbox in the temporary directory for this uploader to be cleaned up on completion.
- (NSString *)workingDirectoryPath {
    
    NSString *workingDirectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.uploadReference];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:workingDirectoryPath]) {
        NSError * fileError;
        BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:workingDirectoryPath withIntermediateDirectories:YES attributes:@{ NSFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication } error:&fileError];
        if (!created) {
            APCLogError2 (fileError);
        }
    }
    
    return workingDirectoryPath;
}

//delete the workingDirectoryPath
-(void)cleanUp{
    NSError *err;
    if (![[NSFileManager defaultManager] removeItemAtPath:[self workingDirectoryPath] error:&err]) {
        APCLogError2(err);
    }
}

@end
