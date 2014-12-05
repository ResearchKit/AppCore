// 
//  APCDataSubstrate+ResearchKit.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCDataSubstrate+ResearchKit.h"
#import "APCAppCore.h"
#import <ResearchKit/ResearchKit.h>

#import <CoreMotion/CoreMotion.h>
#import <MobileCoreServices/MobileCoreServices.h>

//Constants being used configuring the log manager
static NSInteger const APCFileAllocationBlockSize = 1024;
static NSInteger const APCMegabyteFileSize = APCFileAllocationBlockSize * APCFileAllocationBlockSize;
static NSInteger const APCPendingUploadMegaBytesThreshold = 0.5;

//Constants being used for creating the archive from the data logger manager
static NSInteger const APCTotalMegaBytesThreshold = 5;
static NSInteger const APCDataLoggerManagerMaximumInputBytes = 10;
static NSInteger const APCDataLoggerManagerMaximumFiles = 0;

@implementation APCDataSubstrate (ResearchKit)

/*********************************************************************************/
#pragma mark - ResearchKit Subsystem
/*********************************************************************************/
- (void) setUpResearchStudy: (NSString*) studyIdentifier
{
    self.logDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"ResearchKitLogs"]; // for now
    [[NSFileManager defaultManager] createDirectoryAtPath:self.logDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    self.logManager = [[RKSTDataLoggerManager alloc] initWithDirectory:[NSURL fileURLWithPath:self.logDirectory] delegate:self];
    self.logManager.pendingUploadBytesThreshold = APCPendingUploadMegaBytesThreshold * APCMegabyteFileSize; // 0.5 MB
    self.logManager.totalBytesThreshold = APCTotalMegaBytesThreshold * APCMegabyteFileSize; // 5 MB
    
    self.studyStore = [RKSTStudyStore sharedStudyStore];
    NSError * error;
    if (![self.studyStore studyWithIdentifier:studyIdentifier]) {
        self.study = [self.studyStore addStudyWithIdentifier:studyIdentifier delegate:self error:&error];
    }
    else
    {
        self.study =[self.studyStore studyWithIdentifier:studyIdentifier];
    }
    [error handle];
    [self.studyStore resume];
}


-(void)joinStudy
{
    NSError *err = nil;

    if (![self.study updateParticipating:YES withJoinDate:[NSDate date] error:&err])
    {
        [err handle];
    }
}


-(void)leaveStudy
{
    NSError *err = nil;

    if (![self.study updateParticipating:NO withJoinDate:nil error:&err])
    {
        [err handle];
    }
}

/*********************************************************************************/
#pragma mark - Research Kit RKSTStudyDelegate
/*********************************************************************************/
- (BOOL)study:(RKSTStudy *)study healthCollector:(RKSTHealthCollector *)collector anchor:(NSNumber *)anchor didCollectObjects:(NSArray /* <HKSample> */ *)objects
{
    NSString *identifier = [[collector sampleType] identifier];
    
    RKSTDataLogger *logger = [self.logManager dataLoggerForLogName:identifier];
    if (! logger)
    {
        logger = [self.logManager addJSONDataLoggerForLogName:identifier];
        logger.fileProtectionMode = RKFileProtectionCompleteUnlessOpen;
    }
    BOOL success = [logger appendObjects:[collector serializableObjectsForObjects:objects] error:nil];
    return success;
}


- (BOOL)study:(RKSTStudy *)study healthCorrelationCollector:(RKSTHealthCorrelationCollector *)collector anchor:(NSNumber *)anchor didCollectObjects:(NSArray /* <HKCorrelation> */ *)objects
{
    NSString *identifier = [[collector correlationType] identifier];
    RKSTDataLogger *logger = [self.logManager dataLoggerForLogName:identifier];
    if (! logger)
    {
        logger = [self.logManager addJSONDataLoggerForLogName:identifier];
        logger.fileProtectionMode = RKFileProtectionCompleteUnlessOpen;
    }

    BOOL success = [logger appendObjects:[collector serializableObjectsForObjects:objects] error:nil];
    return success;
}


- (BOOL)study:(RKSTStudy *)study motionActivityCollector:(RKSTMotionActivityCollector *)collector startDate:(NSDate *)startDate didCollectObjects:(NSArray /* <CMMotionActivity> */ *)objects
{
    NSString *logName = @"RKMotionActivity";
    RKSTDataLogger *logger = [self.logManager dataLoggerForLogName:logName];
    if (! logger)
    {
        logger = [self.logManager addJSONDataLoggerForLogName:logName];
        logger.fileProtectionMode = RKFileProtectionCompleteUnlessOpen;
    }
    BOOL success = [logger appendObjects:[collector serializableObjectsForObjects:objects] error:nil];
    return success;
}


- (BOOL)passiveCollectionShouldBeginForStudy:(RKSTStudy *)study {
    
    return YES;
}

- (void)passiveCollectionDidFinishForStudy:(RKSTStudy *)study
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self createArchiveForUpload];
    });
}

// Generate a unique archive URL in the documents directory
- (NSURL *)makeArchiveURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *zipPath = [[paths lastObject] stringByAppendingPathComponent:[[[NSUUID UUID] UUIDString] stringByAppendingString:@".zip"]];
    return [NSURL fileURLWithPath:zipPath];
}

- (void)createArchiveForUpload
{
    NSError *error = nil;
    NSArray *pendingFiles = nil;
    //TODO: Check itemIdentifier
    NSURL *archiveFile = [RKSTDataArchive makeArchiveFromDataLoggerManager:self.logManager
                                                          itemIdentifier:@"com.ymedialabs.researchkit.collection"
                                                         studyIdentifier:self.study.studyIdentifier
                                                          fileProtection:RKFileProtectionNone
                                                       maximumInputBytes:APCDataLoggerManagerMaximumInputBytes * APCMegabyteFileSize
                                                            maximumFiles:APCDataLoggerManagerMaximumFiles
                                                            pendingFiles:&pendingFiles
                                                                   error:&error];
    
    if (error)
    {
        [error handle];
        
    } else {
        
        NSURL *url = [self makeArchiveURL];
        
        NSError *fileManagerError = nil;
        // directory so you can see it in iTunes.
        NSLog(@"Moving archive file to %@", [url path]);
        if (![[NSFileManager defaultManager] moveItemAtURL:archiveFile toURL:url error:&fileManagerError])
        {
            NSLog(@"Error moving file %@", fileManagerError);
            
            // If the upload fails, unmark the files as uploaded.
            [self.logManager unmarkUploadedFiles:pendingFiles error:NULL];
        }
        else
        {
            // If the upload enqueue succeeds, remove the files we know are pending
            [self.logManager removeUploadedFiles:pendingFiles error:NULL];
            
            //TODO remove this: temporarily storing this path for email upload
            [[NSUserDefaults standardUserDefaults] setObject:[url path] forKey:@"passiveArchiveFile"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [self uploadFileToBridge:url onCompletion:NULL];
    }
}

/*********************************************************************************/
#pragma mark - Research Kit RKDataManagerDelegate
/*********************************************************************************/
- (void)dataLoggerManager:(RKSTDataLoggerManager*)manager pendingUploadBytesReachedThreshold:(unsigned long long)pendingUploadBytes
{
    // Create the archive.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        while (manager.pendingUploadBytes >= manager.pendingUploadBytesThreshold)
        {
            [self createArchiveForUpload];
        }
    });
}

- (void)dataLoggerManager:(RKSTDataLoggerManager*)manager totalBytesReachedThreshold:(unsigned long long)totalBytes
{
    
    NSLog(@"Total bytes threshold reached");
    [manager removeOldAndUploadedLogsToThreshold:manager.totalBytesThreshold/2 error:nil];
}

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
            [error handle];
            if (completionBlock) {
                completionBlock(error);
            }
        }];
    }
    
}


@end
