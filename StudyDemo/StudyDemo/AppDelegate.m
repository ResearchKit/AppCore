//
//  AppDelegate.m
//  StudyDemo
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <ResearchKit/ResearchKit.h>
#import <HealthKit/HealthKit.h>
#import <CoreMotion/CoreMotion.h>


#ifndef TARGET_URL
#define TARGET_URL @"http://localhost:8080/api/upload"
#endif


NSString *const MainStudyIdentifier = @"com.apple.studyDemo.mainStudy";

@interface AppDelegate ()<RKStudyStoreDelegate>
            

@end

@implementation AppDelegate

-(BOOL)initializeStudiesOnStore:(RKStudyStore*)store
{
    NSError *error = nil;
    RKStudy *study = [store addStudyWithIdentifier:MainStudyIdentifier error:&error];
    if (!study)
    {
        NSLog(@"Error creating study %@: %@", MainStudyIdentifier, error);
        return NO;
    }
    
    NSData *identity = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"investigator" ofType:@"pem"]];
    RKUploader *uploader = [study addUploaderWithEndpoint:[NSURL URLWithString:TARGET_URL] identity:identity archiveFormat:RKDataArchiveFormatZip error:&error];
    if (!uploader)
    {
        NSLog(@"Error creating uploader: %@", error);
        [store removeStudy:study error:nil];
        return NO;
    }
    
    HKQuantityType *quantityType = (HKQuantityType*)[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    RKHealthCollector *healthCollector = [study addHealthCollectorWithSampleType:quantityType unit:[HKUnit countUnit] startDate:nil error:&error];
    if (!healthCollector)
    {
        NSLog(@"Error creating health collector: %@", error);
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
    RKStudyStore *studyStore = [[RKStudyStore alloc] initWithIdentifier:[[NSBundle bundleForClass:[self class]] bundleIdentifier] delegate:self];
    
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
    
    // On first launch, configure the study
    if (! [studyStore studyWithIdentifier:MainStudyIdentifier])
    {
        [self initializeStudiesOnStore:studyStore];
    }
        
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [[MainViewController alloc] initWithStudy:[studyStore studyWithIdentifier:MainStudyIdentifier]];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Because in the current iteration, passive data collection is not fully automatic,
    // it may be helpful to try collecting data if the application is foregrounded.
    
    NSLog(@"Trying to collect data");
    for (RKStudy *study in self.studyStore.studies)
    {
        [study tryCollectingData];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    assert(self.studyStore);
    if ([self.studyStore handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler])
    {
        return;
    }
    
    // If reaching here, the identifier has not been consumed and is probably relevant to the app.
        
}


- (void)studyStore:(RKStudyStore *)studyStore willRestoreState:(NSDictionary *)dict
{
    NSLog(@"Restoring store with dict: %@", dict);
    // Can re-attach data collection blocks for collectors here
    for (RKCollector *collector in dict[RKStudyStoreRestoredCollectorsKey])
    {
        // do stuff with the collector
        // collector.dataHandler = xxx;
    }
        
}

@end
