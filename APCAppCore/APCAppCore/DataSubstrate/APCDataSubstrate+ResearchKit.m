// 
//  APCDataSubstrate+ResearchKit.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
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
        [SBBComponent(SBBUploadManager) uploadFileToBridge:url contentType:@"application/zip" completion:^(NSError *error) {
            APCLogError2 (error);
            if (completionBlock) {
                completionBlock(error);
            }
        }];
    }
    
}


@end
