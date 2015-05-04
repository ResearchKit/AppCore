// 
//  APCDataSubstrate+ResearchKit.m 
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
 
#import "APCDataSubstrate+ResearchKit.h"
#import "APCAppCore.h"

#import <ResearchKit/ResearchKit.h>
#import <CoreMotion/CoreMotion.h>
#import <MobileCoreServices/MobileCoreServices.h>

//Constants being used configuring the log manager
//static NSInteger const APCFileAllocationBlockSize = 1024;
//static NSInteger const APCMegabyteFileSize = APCFileAllocationBlockSize * APCFileAllocationBlockSize;
//static NSInteger const APCPendingUploadMegaBytesThreshold = 0.5;

//Constants being used for creating the archive from the data logger manager
//static NSInteger const APCTotalMegaBytesThreshold = 5;
//static NSInteger const APCDataLoggerManagerMaximumInputBytes = 10;
//static NSInteger const APCDataLoggerManagerMaximumFiles = 0;

@implementation APCDataSubstrate (ResearchKit)

/*********************************************************************************/
#pragma mark - ResearchKit Subsystem
/*********************************************************************************/
// Generate a unique archive URL in the documents directory

/*********************************************************************************/
#pragma mark - Bridge Call
/*********************************************************************************/

- (BOOL) serverDisabled
{
#if DEVELOPMENT
    return YES;
#else
    return ((APCAppDelegate*)[UIApplication sharedApplication].delegate).dataSubstrate.parameters.bypassServer;
#endif
}

- (void) uploadFileToBridge:(NSURL *)url onCompletion:(void (^)(NSError *))completionBlock
{
    if ([self serverDisabled]) {
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    else
    {
        NSAssert(url, @"URL Missing");

        APCLogFilenameBeingUploaded (url.absoluteString);

        [SBBComponent(SBBUploadManager) uploadFileToBridge:url contentType:@"application/zip" completion:^(NSError *error) {
            APCLogError2 (error);
            if (completionBlock) {
                completionBlock(error);
            }
        }];
    }
    
}


@end
