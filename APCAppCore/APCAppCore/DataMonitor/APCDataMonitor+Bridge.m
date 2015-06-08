// 
//  APCDataMonitor+Bridge.m 
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
 
#import "APCDataMonitor+Bridge.h"
#import "APCAppCore.h"

NSString *const kFirstTimeRefreshToday = @"FirstTimeRefreshToday";

@implementation APCDataMonitor (Bridge)

- (void) refreshFromBridgeOnCompletion: (APCDataMonitorResponseHandler) completionBlock
{
    if (self.dataSubstrate.currentUser.isConsented)
    {
        __weak typeof(self) weakSelf = self;

        [[APCScheduler defaultScheduler] fetchTasksAndSchedulesFromServerAndThenUseThisQueue: [NSOperationQueue mainQueue]
                                                                            toDoThisWhenDone: ^(NSError *errorFromServerFetch)
         {
             if (errorFromServerFetch)
             {
                 [weakSelf finishRefreshCommandPassingError: errorFromServerFetch
                                          toCompletionBlock: completionBlock];
             }
             else
             {
                 [APCTask refreshSurveysOnCompletion: ^(NSError *errorFromRefreshingSurveys) {

                     [weakSelf finishRefreshCommandPassingError: errorFromRefreshingSurveys
                                              toCompletionBlock: completionBlock];

                 }];
             }
         }];
    }
}

- (void) finishRefreshCommandPassingError: (NSError *) error
                        toCompletionBlock: (APCDataMonitorResponseHandler) completionBlock
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        if (completionBlock)
        {
            completionBlock (error);
        }

        [[NSNotificationCenter defaultCenter] postNotificationName: APCUpdateActivityNotification
                                                            object: self
                                                          userInfo: nil];
    }];
}

- (void) batchUploadDataToBridgeOnCompletion: (void (^)(NSError * error)) completionBlock
{
    if (self.dataSubstrate.currentUser.isConsented && !self.batchUploadingInProgress) {
        self.batchUploadingInProgress = YES;
        NSManagedObjectContext * context = self.dataSubstrate.persistentContext;
        [context performBlock:^{
            NSFetchRequest * request = [APCResult request];
            request.predicate = [NSPredicate predicateWithFormat:@"uploaded == nil || uploaded == %@", @(NO)];
            NSError * error;
            NSArray * unUploadedResults = [context executeFetchRequest:request error:&error];
            for (APCResult * result in unUploadedResults) {
                [result uploadToBridgeOnCompletion:^(NSError *error) {
                    APCLogError2 (error);
                }];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.batchUploadingInProgress = NO;
                if (completionBlock) {
                    completionBlock(error);
                }
            });
        }];
    }
}

- (void) uploadZipFile:(NSString*) path onCompletion: (void (^)(NSError * error)) completionBlock
{
    NSParameterAssert(path);

    APCLogFilenameBeingUploaded (path);

    [SBBComponent(SBBUploadManager) uploadFileToBridge:[NSURL fileURLWithPath:path] contentType:@"application/zip" completion:^(NSError *error) {
        if (!error) {
            APCLogEventWithData(kNetworkEvent, (@{@"event_detail":[NSString stringWithFormat:@"Uploaded Passive Collector File: %@", path.lastPathComponent]}));
        }
        if (completionBlock) {
            completionBlock(error);
        }
    }];
    
}

@end
