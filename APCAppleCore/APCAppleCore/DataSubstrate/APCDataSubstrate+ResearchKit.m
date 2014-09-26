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

NSString *const MainStudyIdentifier                 = @"com.ymedialabs.passivedatacollection.mainStudy";

@implementation APCDataSubstrate (ResearchKit)

/*********************************************************************************/
#pragma mark - ResearchKit Subsystem
/*********************************************************************************/
- (void) setUpResearchStudy: (NSString*) studyIdentifier
{
    
    
    self.logDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"ResearchKitLogs"]; // for now
    [[NSFileManager defaultManager] createDirectoryAtPath:self.logDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    self.logManager = [[RKDataLoggerManager alloc] initWithDirectory:[NSURL fileURLWithPath:self.logDirectory] delegate:self];
    self.logManager.pendingUploadBytesThreshold = APCPendingUploadMegaBytesThreshold * APCMegabyteFileSize; // 5 MB
    self.logManager.totalBytesThreshold = APCTotalMegaBytesThreshold * APCMegabyteFileSize; // 50 MB
    
    self.studyStore = [RKStudyStore sharedStudyStore];
    NSError * error;
    if (![self.studyStore studyWithIdentifier:studyIdentifier]) {
        self.study = [self.studyStore addStudyWithIdentifier:studyIdentifier delegate:self error:&error];
    }
    [error handle];
    [self setUpCollectors];
    
    BOOL resuming = [self.studyStore resume];
    NSLog(resuming ? @"Yes" : @"No");
    
    if (resuming) {
        self.study = [self.studyStore studyWithIdentifier:MainStudyIdentifier];
        [self joinStudy];
    }
}

-(void)joinStudy
{
    NSError *err = nil;
    self.justJoined = YES;
    if (![self.study updateParticipating:YES withJoinDate:[NSDate date] error:&err])
    {
        NSLog(@"Could not join %@: %@", self.study, err);
    }
}


-(void)leaveStudy
{
    NSError *err = nil;
    self.justJoined = NO;
    if (![self.study updateParticipating:NO withJoinDate:nil error:&err])
    {
        NSLog(@"Could not leave %@: %@", self.study, err);
    }
}

#pragma mark - HealthKit Permissions

- (void) setUpCollectors
{
    
    // delegates on the existing study objects.
    if (! [self.studyStore studyWithIdentifier:MainStudyIdentifier])
    {
        [self initializeStudiesOnStore:self.studyStore];
    }
    else
    {
        for (RKStudy *study in self.studyStore.studies)
        {
            
            [study setDelegate:self];
        }
    }
}


-(BOOL)initializeStudiesOnStore:(RKStudyStore*)store
{
    NSError *error = nil;
    BOOL returnErrorFlag = YES;
    
    RKStudy *study = [store addStudyWithIdentifier:MainStudyIdentifier delegate:self error:&error];
    if (!study)
    {
        NSLog(@"Error creating study %@: %@", MainStudyIdentifier, error);
        returnErrorFlag = NO;
    }
    
    HKQuantityType *quantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    RKHealthCollector *healthCollector = [study addHealthCollectorWithSampleType:quantityType unit:[HKUnit countUnit] startDate:nil error:&error];
    if (!healthCollector)
    {
        NSLog(@"Error creating health collector: %@", error);
        [store removeStudy:study error:nil];
        returnErrorFlag = NO;
    }
    
    HKQuantityType *quantityType2 = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    HKUnit *unit = [HKUnit unitFromString:@"mg/dL"];
    RKHealthCollector *glucoseCollector = [study addHealthCollectorWithSampleType:quantityType2 unit:unit startDate:nil error:&error];
    
    if (!glucoseCollector)
    {
        NSLog(@"Error creating glucose collector: %@", error);
        [store removeStudy:study error:nil];
        returnErrorFlag = NO;
    }
    
    HKCorrelationType *bpType = (HKCorrelationType *)[HKCorrelationType correlationTypeForIdentifier:HKCorrelationTypeIdentifierBloodPressure];
    RKHealthCorrelationCollector *bpCollector = [study addHealthCorrelationCollectorWithCorrelationType:bpType sampleTypes:@[[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic], [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic]] units:@[[HKUnit unitFromString:@"mmHg"], [HKUnit unitFromString:@"mmHg"]] startDate:nil error:&error];
    if (!bpCollector)
    {
        NSLog(@"Error creating BP collector: %@", error);
        [store removeStudy:study error:nil];
        returnErrorFlag = NO;
    }
    
    RKMotionActivityCollector *motionCollector = [study addMotionActivityCollectorWithStartDate:nil error:&error];
    if (!motionCollector)
    {
        NSLog(@"Error creating motion collector: %@", error);
        [store removeStudy:study error:nil];
        returnErrorFlag = NO;
    }
    
    
    return YES;
}


/*********************************************************************************/
#pragma mark - Research Kit RKStudyDelegate
/*********************************************************************************/
- (BOOL)study:(RKStudy *)study healthCollector:(RKHealthCollector *)collector anchor:(NSNumber *)anchor didCollectObjects:(NSArray /* <HKSample> */ *)objects
{
    NSString *identifier = [[collector sampleType] identifier];
    
    RKDataLogger *logger = [self.logManager dataLoggerForLogName:identifier];
    if (! logger)
    {
        logger = [self.logManager addJSONDataLoggerForLogName:identifier];
        logger.fileProtectionMode = RKFileProtectionCompleteUnlessOpen;
    }
    BOOL success = [logger appendObjects:[collector serializableObjectsForObjects:objects] error:nil];
    NSLog(@"Health log (%d)", success);
    return success;
}


- (BOOL)study:(RKStudy *)study healthCorrelationCollector:(RKHealthCorrelationCollector *)collector anchor:(NSNumber *)anchor didCollectObjects:(NSArray /* <HKCorrelation> */ *)objects
{
    
    NSString *identifier = [[collector correlationType] identifier];
    RKDataLogger *logger = [self.logManager dataLoggerForLogName:identifier];
    if (! logger)
    {
        logger = [self.logManager addJSONDataLoggerForLogName:identifier];
        logger.fileProtectionMode = RKFileProtectionCompleteUnlessOpen;
    }
    
    
    BOOL success = [logger appendObjects:[collector serializableObjectsForObjects:objects] error:nil];
    NSLog(@"Health log (%d)", success);
    return success;
}


- (BOOL)study:(RKStudy *)study motionActivityCollector:(RKMotionActivityCollector *)collector startDate:(NSDate *)startDate didCollectObjects:(NSArray /* <CMMotionActivity> */ *)objects
{
    NSString *logName = @"RKMotionActivity";
    RKDataLogger *logger = [self.logManager dataLoggerForLogName:logName];
    if (! logger)
    {
        logger = [self.logManager addJSONDataLoggerForLogName:logName];
        logger.fileProtectionMode = RKFileProtectionCompleteUnlessOpen;
    }
    BOOL success = [logger appendObjects:[collector serializableObjectsForObjects:objects] error:nil];
    NSLog(@"Motion log (%d)", success);
    return success;
}


- (BOOL)passiveCollectionShouldBeginForStudy:(RKStudy *)study {
    
    return YES;
}


- (void)passiveCollectionDidFinishForStudy:(RKStudy *)study
{
    if (self.justJoined)
    {
        self.justJoined = NO;
        
        NSLog(@"First collection finished - queue an upload");
        // Create the archive.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self createArchiveForUpload];
        });
    }
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
    NSURL *archiveFile = [RKDataArchive makeArchiveFromDataLoggerManager:self.logManager
                                                          itemIdentifier:[[RKItemIdentifier alloc] initWithComponents:@[@"com",@"apple",@"ResearchKit",@"collection"]]
                                                         studyIdentifier:MainStudyIdentifier
                                                          fileProtection:RKFileProtectionNone
                                                       maximumInputBytes:APCDataLoggerManagerMaximumInputBytes * APCMegabyteFileSize
                                                            maximumFiles:APCDataLoggerManagerMaximumFiles
                                                            pendingFiles:&pendingFiles
                                                                   error:&error];
    
    if (error)
    {
        NSLog(@"Error creating archive from log manager: %@", error);
        return;
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
- (void)dataLoggerManager:(RKDataLoggerManager*)manager pendingUploadBytesReachedThreshold:(unsigned long long)pendingUploadBytes
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


- (void)dataLoggerManager:(RKDataLoggerManager*)manager totalBytesReachedThreshold:(unsigned long long)totalBytes
{
    
    NSLog(@"Total bytes threshold reached");
    // Throw out old files
    [manager removeOldAndUploadedLogsToThreshold:manager.totalBytesThreshold/2 error:nil];
}

#pragma mark - Network upload

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
