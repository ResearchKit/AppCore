//
//  APCFileManagerUtility.m
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

#import "APCFileManagerUtility.h"
#import "APCAppCore.h"

@implementation APCFileManagerUtility

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
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:YES
                                                        attributes:@{
                                                                     NSFileProtectionKey :
                                                                         NSFileProtectionCompleteUntilFirstUserAuthentication
                                                                     }
                                                             error:&folderCreationError]) {
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
