//
//  AppDelegate.m
//  StudyDemo
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <ResearchKit/ResearchKit_Private.h>
#import <HealthKit/HealthKit.h>
#import <CoreMotion/CoreMotion.h>


#ifndef TARGET_URL
#define TARGET_URL @"http://localhost:8080/api/upload"
#endif


NSString *const MainStudyIdentifier = @"com.apple.studyDemo.mainStudy";

@interface AppDelegate ()<RKStudyDelegate,RKDataLoggerManagerDelegate>
{
    NSString *_logDirectory;
    RKDataLoggerManager *_logManager;
}

@end

@implementation AppDelegate

-(BOOL)initializeStudiesOnStore:(RKStudyStore*)store
{
    NSError *error = nil;
    RKStudy *study = [store addStudyWithIdentifier:MainStudyIdentifier delegate:self error:&error];
    if (!study)
    {
        NSLog(@"Error creating study %@: %@", MainStudyIdentifier, error);
        return NO;
    }
    
    // NSData *identity = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"investigator" ofType:@"pem"]];
    
    HKQuantityType *quantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    RKHealthCollector *healthCollector = [study addHealthCollectorWithSampleType:quantityType unit:[HKUnit countUnit] startDate:nil error:&error];
    if (!healthCollector)
    {
        NSLog(@"Error creating health collector: %@", error);
        [store removeStudy:study error:nil];
        return NO;
    }
    
    HKQuantityType *quantityType2 = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    HKUnit *unit = [HKUnit unitFromString:@"mg/dL"];
    RKHealthCollector *glucoseCollector = [study addHealthCollectorWithSampleType:quantityType2 unit:unit startDate:nil error:&error];
    if (!glucoseCollector)
    {
        NSLog(@"Error creating glucose collector: %@", error);
        [store removeStudy:study error:nil];
        return NO;
    }
    
    HKCorrelationType *bpType = (HKCorrelationType *)[HKCorrelationType correlationTypeForIdentifier:HKCorrelationTypeIdentifierBloodPressure];
    RKHealthCorrelationCollector *bpCollector = [study addHealthCorrelationCollectorWithCorrelationType:bpType sampleTypes:@[[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic], [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic]] units:@[[HKUnit unitFromString:@"mmHg"], [HKUnit unitFromString:@"mmHg"]] startDate:nil error:&error];
    if (!bpCollector)
    {
        NSLog(@"Error creating BP collector: %@", error);
        [store removeStudy:study error:nil];
        return NO;
    }
    
    RKMotionActivityCollector *motionCollector = [study addMotionActivityCollectorWithStartDate:nil error:&error];
    if (!motionCollector)
    {
        NSLog(@"Error creating motion collector: %@", error);
        [store removeStudy:study error:nil];
        return NO;
    }
        
        
    return YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _logDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"ResearchKitLogs"]; // for now
    [[NSFileManager defaultManager] createDirectoryAtPath:_logDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    _logManager = [[RKDataLoggerManager alloc] initWithDirectory:[NSURL fileURLWithPath:_logDirectory] delegate:self];
    _logManager.pendingUploadBytesThreshold = 5 * 1024 * 1024; // 5 MB
    _logManager.totalBytesThreshold = 50 * 1024 * 1024; // 50 MB
    
    RKStudyStore *studyStore = [RKStudyStore sharedStudyStore];
    
    
    self.studyStore = studyStore;
    
#define CLEAR_OLD_STUDY 0
#if CLEAR_OLD_STUDY
    // Sometimes it's helpful to be able to clear an old study
    RKStudy *oldStudy = [studyStore studyWithIdentifier:MainStudyIdentifier];
    if (oldStudy)
    {
        // Remove the old study!
        [studyStore removeStudy:oldStudy error:nil];
    }
#endif
    
    // On launch, either create the study objects, or setup
    // delegates on the existing study objects.
    if (! [studyStore studyWithIdentifier:MainStudyIdentifier])
    {
        [self initializeStudiesOnStore:studyStore];
    }
    else
    {
        for (RKStudy *study in studyStore.studies)
        {
            [study setDelegate:self];
        }
    }
    
    // Resume data collection
    [studyStore resume];
    
        
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [[MainViewController alloc] initWithStudy:[studyStore studyWithIdentifier:MainStudyIdentifier]];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}



- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
}


// Generate a unique archive URL in the documents directory
- (NSURL *)_makeArchiveURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *zipPath = [[paths lastObject] stringByAppendingPathComponent:[[[NSUUID UUID] UUIDString] stringByAppendingString:@".zip"]];
    return [NSURL fileURLWithPath:zipPath];
}

- (void)_createArchiveForUpload
{
    // Wrap archive creation in a background task, so that the archive can be created
    // and queued, even if
    __block UIBackgroundTaskIdentifier taskIdentifier = UIBackgroundTaskInvalid;
    taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        taskIdentifier = UIBackgroundTaskInvalid;
    }];
    NSError *err = nil;
    NSArray *pendingFiles = nil;
    NSURL *archiveFile = [RKDataArchive makeArchiveFromDataLoggerManager:_logManager
                                                          itemIdentifier:@"com.apple.ResearchKit.collection"
                                                         studyIdentifier:MainStudyIdentifier
                                                          fileProtection:RKFileProtectionNone
                                                       maximumInputBytes:1024*1024*10
                                                            maximumFiles:0
                                                            pendingFiles:&pendingFiles
                                                                   error:&err];
   
    if (err)
    {
        NSLog(@"Error creating archive from log manager: %@", err);
        return;
    }
    
    NSURL *url = [self _makeArchiveURL];
    
    // TODO: upload the actual file. For demo purposes, just move it to the documents
    // directory so you can see it in iTunes.
    NSLog(@"Moving archive file to %@", [url path]);
    if (![[NSFileManager defaultManager] moveItemAtURL:archiveFile toURL:url error:&err])
    {
        // If the upload fails, unmark the files as uploaded.
        [_logManager unmarkUploadedFiles:pendingFiles error:NULL];
    }
    else
    {
        // If the upload enqueue succeeds, remove the files we know are pending
        [_logManager removeUploadedFiles:pendingFiles error:NULL];
    }
    
    if (taskIdentifier != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:taskIdentifier];
    }
}

- (void)dataLoggerManager:(RKDataLoggerManager*)manager pendingUploadBytesReachedThreshold:(unsigned long long)pendingUploadBytes
{
    NSLog(@"Pending bytes threshold reached");
    // Create the archive.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        while (manager.pendingUploadBytes >= manager.pendingUploadBytesThreshold)
        {
            [self _createArchiveForUpload];
        }
    });
}

- (void)dataLoggerManager:(RKDataLoggerManager*)manager totalBytesReachedThreshold:(unsigned long long)totalBytes
{
    NSLog(@"Total bytes threshold reached");
    // Throw out old files
    [manager removeOldAndUploadedLogsToThreshold:manager.totalBytesThreshold/2 error:nil];
}

#pragma mark RKStudyDelegate


- (BOOL)study:(RKStudy *)study healthCollector:(RKHealthCollector *)collector anchor:(NSNumber *)anchor didCollectObjects:(NSArray /* <HKSample> */ *)objects
{
    NSString *identifier = [[collector sampleType] identifier];
    RKDataLogger *logger = [_logManager dataLoggerForLogName:identifier];
    if (! logger)
    {
        logger = [_logManager addJSONDataLoggerForLogName:identifier];
        logger.fileProtectionMode = RKFileProtectionCompleteUnlessOpen;
    }
    BOOL success = [logger appendObjects:[collector serializableObjectsForObjects:objects] error:nil];
    NSLog(@"Health log (%d)", success);
    return success;
}

- (BOOL)study:(RKStudy *)study healthCorrelationCollector:(RKHealthCorrelationCollector *)collector anchor:(NSNumber *)anchor didCollectObjects:(NSArray /* <HKCorrelation> */ *)objects
{
    NSString *identifier = [[collector correlationType] identifier];
    RKDataLogger *logger = [_logManager dataLoggerForLogName:identifier];
    if (! logger)
    {
        logger = [_logManager addJSONDataLoggerForLogName:identifier];
        logger.fileProtectionMode = RKFileProtectionCompleteUnlessOpen;
    }
    BOOL success = [logger appendObjects:[collector serializableObjectsForObjects:objects] error:nil];
    NSLog(@"Health log (%d)", success);
    return success;
}

- (BOOL)study:(RKStudy *)study motionActivityCollector:(RKMotionActivityCollector *)collector startDate:(NSDate *)startDate didCollectObjects:(NSArray /* <CMMotionActivity> */ *)objects
{
    NSString *logName = @"RKMotionActivity";
    RKDataLogger *logger = [_logManager dataLoggerForLogName:logName];
    if (! logger)
    {
        logger = [_logManager addJSONDataLoggerForLogName:logName];
        logger.fileProtectionMode = RKFileProtectionCompleteUnlessOpen;
    }
    BOOL success = [logger appendObjects:[collector serializableObjectsForObjects:objects] error:nil];
    NSLog(@"Motion log (%d)", success);
    return success;
}


- (void)passiveCollectionDidFinishForStudy:(RKStudy *)study
{
    if (self.justJoined)
    {
        self.justJoined = NO;
        
        NSLog(@"First collection finished - queue an upload");
        // Create the archive.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self _createArchiveForUpload];
        });
    }
    

}

@end
