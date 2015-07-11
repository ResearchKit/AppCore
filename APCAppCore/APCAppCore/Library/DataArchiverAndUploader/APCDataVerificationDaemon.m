//
//  APCDataVerificationDaemon.m
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

#import "APCDataVerificationDaemon.h"
#import <BridgeSDK/BridgeSDK.h>
#import "APCDataVerificationClient.h"
#import "APCLog.h"

static const NSUInteger kCallDelay = 5;

//Inner class
@interface APCTimestampedURL : NSObject
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSDate *timestamp;
@end

@implementation APCTimestampedURL

- (id)initWithURL: (NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;
        _timestamp = [NSDate new];
    }
    
    return self;
}

@end


@interface APCDataVerificationDaemon ()

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray*queue;
@end


@implementation APCDataVerificationDaemon

- (id) init
{
    self = [super init];
    
    if (self) {
        
        _queue = [NSMutableArray new];
        _timer = [NSTimer scheduledTimerWithTimeInterval:kCallDelay
                                                  target:self
                                                selector:@selector(checkForResponsesOnTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    }
    
    return self;
}

-(void)queueURL:(NSURL *)url
{
    APCTimestampedURL *timestampedURL = [[APCTimestampedURL alloc] initWithURL:url];
    [self.queue addObject:timestampedURL];
}

- (void)checkForResponsesOnTimer: (NSTimer *)__unused timer
{
    if (self.queue.count > 0) {
        APCTimestampedURL *tURL = [self.queue objectAtIndex:0];
        NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:tURL.timestamp];
        __weak typeof(self) weakSelf = self;
        if (interval >= kCallDelay) {
            [self.queue removeObjectAtIndex:0];
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf callURL:tURL.url];
            });
        }
    }
}

- (void)callURL: (NSURL *)url
{
    SBBNetworkManager *sharedManager = [SBBNetworkManager defaultComponent];
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [[SBBAuthManager defaultComponent] addAuthHeaderToHeaders:headers];
    
    [sharedManager get:url.absoluteString headers:headers parameters:@{@"study":gSBBAppStudy} completion:^(NSURLSessionDataTask *__unused task, id responseObject, NSError *error) {
        if (responseObject) {
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            NSString *responseString = [NSString stringWithFormat:@"\nAPCDataVerificationDaemon verified upload of uploadID: %@. Status : %@\n", [responseDictionary objectForKey:@"id"], [responseDictionary objectForKey:@"status"]];
            APCLogDebug(responseString);
            APCLogDebug(@"more info: %@", responseObject);
            
        }else{
            APCLogError2(error);
        }
    }];
}

@end
