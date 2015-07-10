//
//  APCDataEncryptor.m
//  APCAppCore
//
// Copyright (c) 2015 Apple, Inc. All rights reserved.
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

#import "APCDataEncryptor.h"
#import "APCLog.h"
#import "APCCMS.h"
#import "APCAppDelegate.h"

static NSString * kEncryptedDataFilename            = @"encrypted.zip";

@interface APCDataEncryptor ()

@property (nonatomic, strong) NSString *workingDirectoryName;

@end

@implementation APCDataEncryptor

- (id) init
{
    self = [super init];
    
    if (self) {
        _workingDirectoryName = [NSUUID UUID].UUIDString;
    }
    
    return self;
}

-(void)encryptFileAtURL:(NSURL *)url withCompletion:(void (^)(NSURL *url, NSError *error))completion
{
    NSError * encryptionError = nil;
    NSData * unencryptedZipData = [NSData dataWithContentsOfFile:url.relativePath];
    NSData * encryptedZipData = cmsEncrypt(unencryptedZipData, [APCDataEncryptor pemPath], &encryptionError);
    
    if (encryptedZipData) {
        NSString *encryptedPath = [[self workingDirectoryPath] stringByAppendingPathComponent:kEncryptedDataFilename];
        
        if ([encryptedZipData writeToFile:encryptedPath options:NSDataWritingAtomic error:&encryptionError]) {
            url = [[NSURL alloc] initFileURLWithPath:encryptedPath];
        }
    }
    
    if (completion) {
        completion(url, encryptionError);
    }
}

+ (NSData *)encryptData:(NSData *)data withCertificateAtPath:(NSString *)path
{
    NSData *jsonData;
    
    if (path) {
        jsonData = cmsEncrypt(data, path, nil);
    }
    
    return  jsonData;
    
}

#pragma mark - helpers

+ (NSString*) pemPath
{
    APCAppDelegate * appDelegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    NSString * path = [[NSBundle mainBundle] pathForResource:appDelegate.certificateFileName ofType:@"pem"];
    return path;
}

- (NSString *)workingDirectoryPath
{
    
    NSString *workingDirectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.workingDirectoryName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:workingDirectoryPath]) {
        NSError * fileError;
        BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:workingDirectoryPath withIntermediateDirectories:YES attributes:@{ NSFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication } error:&fileError];
        if (!created) {
            APCLogError2 (fileError);
        }
    }
    
    return workingDirectoryPath;
}

-(void)removeDirectory
{
    NSError *err;
    if (![[NSFileManager defaultManager] removeItemAtPath:[self workingDirectoryPath] error:&err]) {
        NSAssert(false, @"failed to remove encryptor working directory at %@",[self workingDirectoryPath] );
    }
}

@end
