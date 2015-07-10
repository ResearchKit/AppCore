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
#import "APCLog.h"
#import "NSError+APCAdditions.h"
#import "APCConstants.h"
#import "APCAppDelegate.h"
#import "APCDataVerificationDaemon.h"

@interface APCDataUploader ()
@property (strong, nonatomic) APCDataVerificationDaemon *verificationDaemon;
@end

@implementation APCDataUploader

- (id)init
{
    self = [super init];
    if (self) {
        SBBUploadManager *uploadManager = [SBBUploadManager defaultComponent];
        uploadManager.uploadDelegate = self;
        self.verificationDaemon = [[APCDataVerificationDaemon alloc] init];
    }
    
    return self;
}

+ (APCDataUploader *)sharedUploader
{
    APCAppDelegate *delegate = (APCAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.dataUploader;
}

-(void)uploadFileAtURL:(NSURL *)url withCompletion:(void (^)(NSError *))completion
{
    
    [SBBComponent(SBBUploadManager) uploadFileToBridge:url contentType:@"application/zip" completion:^(NSError *error) {
        if (!error) {
            APCLogEventWithData(kNetworkEvent, (@{@"event_detail":[NSString stringWithFormat:@"APCDataUploader uploaded file: %@", url.relativePath.lastPathComponent]}));
        }else {
            APCLogDebug(@"APCDataUploader error returned from SBBUploadManager: %@", error.message);
        }
        
        if (completion){
            completion(error);
        }
    }];
}

#pragma mark - SBBUploadManager delegate

//required delegate method
- (void)uploadManager:(SBBUploadManager *)__unused manager uploadOfFile:(NSString *)__unused file completedWithError:(NSError *) error
{
    APCLogError2(error);
}

- (void)uploadManager:(SBBUploadManager *)__unused manager uploadOfFile:(NSString *)__unused file completedWithVerificationURL:(NSURL *)url
{
    [self.verificationDaemon queueURL:url];
}

@end
