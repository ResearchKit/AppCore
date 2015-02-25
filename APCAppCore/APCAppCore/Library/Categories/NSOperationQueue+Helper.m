//
//  NSOperationQueue+Helper.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
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
