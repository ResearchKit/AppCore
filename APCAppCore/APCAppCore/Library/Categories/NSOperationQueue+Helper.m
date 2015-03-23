// 
//  NSOperationQueue+Helper.m 
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
 
#import "NSOperationQueue+Helper.h"




/**
 Priorities.  These correspond directly to Apple's queue
 priorities; I'm just making them more readable, in terminology
 we're used to.
 */
typedef enum : NSUInteger {

    /** Same priority as stuff on the main queue.  Be verrrrrrry
     wary of using this.  You'll compete with the main queue --
     user animations and whatnot. */
    APCOperationQueuePriorityHighest,

    /**
     Pretty important stuff.  More important than average,
     not as important as user animations.
     */
    APCOperationQueuePriorityHigh,

    /** Designed by Apple for doing user stuff in the background. */
    APCOperationQueuePriorityMedium,

    /** Designed for doing truly background tasks, like
     downloading a large file:  it could take "forever"
     anyway, so a few extra milliseconds (or maybe even
     seconds) won't hurt. */
    APCOperationQueuePriorityLow

} APCOperationQueuePriority;




@implementation NSOperationQueue (Helper)

+ (instancetype) sequentialOperationQueueWithName: (NSString *) name
{
    return [self sequentialOperationQueueWithName: name
                                         priority: APCOperationQueuePriorityMedium];
}

+ (instancetype) sequentialOperationQueueWithName: (NSString *) name
                                         priority: (APCOperationQueuePriority) priority
{
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.name = name;
    queue.maxConcurrentOperationCount = 1;

    NSOperationQualityOfService underlyingPriority = NSOperationQualityOfServiceBackground;

    switch (priority)
    {
        case APCOperationQueuePriorityHighest:
            underlyingPriority = NSOperationQualityOfServiceUserInteractive;
            break;

        case APCOperationQueuePriorityHigh:
            underlyingPriority = NSOperationQualityOfServiceUserInitiated;
            break;

        default:
        case APCOperationQueuePriorityMedium:
            underlyingPriority = NSOperationQualityOfServiceUtility;
            break;

        case APCOperationQueuePriorityLow:
            underlyingPriority = NSOperationQualityOfServiceBackground;
            break;
    }

    queue.qualityOfService = underlyingPriority;
    return queue;
}

@end
