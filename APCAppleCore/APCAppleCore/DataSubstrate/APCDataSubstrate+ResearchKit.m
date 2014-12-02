//
//  APCDataSubstrate+ResearchKit.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 8/26/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCDataSubstrate+ResearchKit.h"
#import "APCAppleCore.h"
#import <ResearchKit/ResearchKit.h>

#import <CoreMotion/CoreMotion.h>
#import <MobileCoreServices/MobileCoreServices.h>

//Constants being used configuring the log manager
static NSInteger const APCFileAllocationBlockSize = 1024;
static NSInteger const APCMegabyteFileSize = APCFileAllocationBlockSize * APCFileAllocationBlockSize;
static NSInteger const APCPendingUploadMegaBytesThreshold = 5;

//Constants being used for creating the archive from the data logger manager
static NSInteger const APCTotalMegaBytesThreshold = 50;
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
    self.logManager.pendingUploadBytesThreshold = APCPendingUploadMegaBytesThreshold * APCMegabyteFileSize; // 5 MB
    self.logManager.totalBytesThreshold = APCTotalMegaBytesThreshold * APCMegabyteFileSize; // 50 MB
    
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
    [self.delegate setUpCollectors];
    
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
    NSLog(@"Health log (%d)", success);
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
    NSLog(@"Health log (%d)", success);
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
    NSLog(@"Motion log (%d)", success);
    return success;
}


- (BOOL)passiveCollectionShouldBeginForStudy:(RKSTStudy *)study {
    
    return YES;
}


- (void)passiveCollectionDidFinishForStudy:(RKSTStudy *)study
{
    
    NSLog(@"First collection finished - queue an upload");
    // Create the archive.
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
    // Wrap archive creation in a background task, so that the archive can be created
    // and queued, even if
    __block UIBackgroundTaskIdentifier taskIdentifier = UIBackgroundTaskInvalid;
    taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        taskIdentifier = UIBackgroundTaskInvalid;
    }];
    
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
        //TODO error handling for creating a data archive
        NSLog(@"Error creating archive from log manager: %@", error);
        
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
        
        //TODO using debug endpoint
        [self uploadFile:[url path]];
        if (taskIdentifier != UIBackgroundTaskInvalid)
        {
            [[UIApplication sharedApplication] endBackgroundTask:taskIdentifier];
        }
    }
}

/*********************************************************************************/
#pragma mark - Research Kit RKDataManagerDelegate
/*********************************************************************************/
- (void)dataLoggerManager:(RKSTDataLoggerManager*)manager pendingUploadBytesReachedThreshold:(unsigned long long)pendingUploadBytes
{
    NSLog(@"Pending bytes threshold reached");
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
    // Throw out old files
    [manager removeOldAndUploadedLogsToThreshold:manager.totalBytesThreshold/2 error:nil];
}

/*********************************************************************************/
#pragma mark - Network upload debug-only end point
/*********************************************************************************/

- (void) uploadFile: (NSString*) path
{
    NSURL * url = [NSURL URLWithString:@"http://127.0.0.1:4567/api/v1/upload/passive_data_collection"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = [self boundaryString];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    NSData *data = [self createBodyWithBoundary:boundary data:fileData filename:[path lastPathComponent]];
    
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            //NSAssert(!error, @"%s: uploadTaskWithRequest error: %@", __FUNCTION__, error);
        }
        // parse and interpret the response `NSData` however is appropriate for your app
    }];
    [task resume];
}

- (NSString *)boundaryString
{
    // generate boundary string
    //
    // adapted from http://developer.apple.com/library/ios/#samplecode/SimpleURLConnections
    
    CFUUIDRef  uuid;
    NSString  *uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    assert(uuidStr != NULL);
    
    CFRelease(uuid);
    
    return [NSString stringWithFormat:@"Boundary-%@", uuidStr];
}

- (NSString *)mimeTypeForPath:(NSString *)path
{
    // get a mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);
    CFRelease(UTI);
    
    return mimetype;
}

- (NSData *) createBodyWithBoundary:(NSString *)boundary data:(NSData*)data filename:(NSString *)filename
{
    NSMutableData *body = [NSMutableData data];
    
    if (data) {
        //only send these methods when transferring data as well as username and password
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filedata\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", [self mimeTypeForPath:filename]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return body;
}


@end
