//
//  APCLocationTrackingHeartbeat.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 9/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCPassiveLocationTracking.h"

static NSString *passiveLocationTrackingIdentifier = @"com.ymedialabs.passiveLocationTracking";

@interface APCPassiveLocationTracking ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *lastKnownLocation;

@property (nonatomic, strong) RKDataArchive *taskArchive;
@end

@implementation APCPassiveLocationTracking

-(instancetype)initWithTimeInterval:(NSTimeInterval)timeout
{

    self = [super init];
    
    if (self)
    {
        
        if ([CLLocationManager locationServicesEnabled])
        {
            _locationManager = [[CLLocationManager alloc] init];

            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            
            [_locationManager setDelegate:self];
        }
    }
    
    return self;
}

- (void)start
{
    
    if ([CLLocationManager locationServicesEnabled])
    {
        [self.locationManager startUpdatingLocation];
        
    } else {
        NSLog(@"Location services disabled");
    }
}

- (void)stop
{
    
    if ([CLLocationManager locationServicesEnabled])
    {
        [self.locationManager stopUpdatingLocation];
        
    } else {
        NSLog(@"Location services disabled");
    }
}

/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/

- (void)beginTask
{
    if (self.taskArchive)
    {
        [self.taskArchive resetContent];
    }
    
    RKTask* task = [[RKTask alloc] initWithName:@"PassiveLocationTracking" identifier:@"passiveLocationTracking" steps:nil];
    
    self.taskArchive = [[RKDataArchive alloc] initWithItemIdentifier:[RKItemIdentifier itemIdentifierForTask:task]
                                                     studyIdentifier:passiveLocationTrackingIdentifier
                                                    taskInstanceUUID: [NSUUID UUID]
                                                       extraMetadata: nil
                                                      fileProtection:RKFileProtectionCompleteUnlessOpen];
}

- (NSDictionary *)retreieveLocationMarkersFromLog
{
    
    //TODO Return any geocoordinate data that has not been uploaded
    return nil;
}

/*********************************************************************************/
#pragma mark -CLLocationManagerDelegate
/*********************************************************************************/

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"didEnterRegion");
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"didExitRegion");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
}
- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    NSLog(@"didFinishDeferredUpdatesWithError");
    
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"locationManagerDidPauseLocationUpdates");
    
    
//TODO Upload passive data collection
    
//    NSError *err = nil;
//    NSURL *archiveFileURL = [self.taskArchive archiveURLWithError:&err];
//    if (archiveFileURL)
//    {
//        NSURL *documents = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
//        NSURL *outputUrl = [documents URLByAppendingPathComponent:[archiveFileURL lastPathComponent]];
//        
//        // This is where you would queue the archive for upload. In this demo, we move it
//        // to the documents directory, where you could copy it off using iTunes, for instance.
//        [[NSFileManager defaultManager] moveItemAtURL:archiveFileURL toURL:outputUrl error:nil];
//        
//        NSLog(@"outputUrl= %@", outputUrl);
//        
//        // When done, clean up:
//        self.taskArchive = nil;
//        if (archiveFileURL)
//        {
//            [[NSFileManager defaultManager] removeItemAtURL:archiveFileURL error:nil];
//        }
//    }
}

- (void)updateLog:(CLLocationManager *)manager {
    
    //Create time stamp
    NSTimeInterval currentTimeInMilliseconds = [[NSDate date]timeIntervalSince1970];
    
    //Create distance in meters from home
    CLLocationDistance distanceFromHome = [_lastKnownLocation distanceFromLocation:manager.location];

    NSMutableDictionary *json = [NSMutableDictionary new];

    json[@"timestamp"] = [NSNumber numberWithDouble:currentTimeInMilliseconds];
    json[@"distanceFromHome"] = [NSNumber numberWithDouble:distanceFromHome];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:json
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    
    //TODO write to data archive
    NSLog(@"Data to update %@", data);
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    
    [self updateLog:manager];
    
    _lastKnownLocation = manager.location;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Asynchronous call failed");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"CLLocation is working didUpdateToLocation: %@", newLocation);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion");
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    NSLog(@"locationManagerShouldDisplayHeadingCalibration");
    return YES;
}

/*********************************************************************************/
#pragma mark - Delegate Methods
/*********************************************************************************/

- (void) didFailToUpdateLocationWithError:(NSError *)error
{
    
    if ( [self.delegate respondsToSelector:@selector(passiveLocationTracking:didFailToUpdateLocationWithError:)] ) {
        
        [self.delegate passiveLocationTracking:self didFailToUpdateLocationWithError:error];
    }
}


- (void) didPauseLocationTracking:(CLLocationManager *)manager
{
    
    if ( [self.delegate respondsToSelector:@selector(passiveLocationTracking:didPauseLocationTracking:)] ) {
        
        [self.delegate passiveLocationTracking:self didPauseLocationTracking:manager];
    }
}


- (void) didResumeLocationTracking:(CLLocationManager *)manager
{
    
    if ( [self.delegate respondsToSelector:@selector(passiveLocationTracking:didResumeLocationTracking:)] ) {
        
        [self.delegate passiveLocationTracking:self didResumeLocationTracking:manager];
    }
}


- (void) didFailToUpdateLogWithError:(NSError *)error
{
    
    if ( [self.delegate respondsToSelector:@selector(passiveLocationTracking:didFailToUpdateLogWithError:)] ) {
        
        [self.delegate passiveLocationTracking:self didFailToUpdateLogWithError:error];
    }
}


- (void) didFailToDeleteLogWithError:(NSError *)error
{
    
    if ( [self.delegate respondsToSelector:@selector(passiveLocationTracking:didFailToDeleteLogWithError:)] ) {
        
        [self.delegate passiveLocationTracking:self didFailToDeleteLogWithError:error];
    }
}


- (void) didFailToUploadLogWithError:(NSError *)error
{
    
    if ( [self.delegate respondsToSelector:@selector(passiveLocationTracking:didFailToUploadLog:)] ) {
        
        [self.delegate passiveLocationTracking:self didFailToUploadLog:error];
    }
}


- (void) didFinishSavingLog:(NSURL *)fileURL
{
    
    if ( [self.delegate respondsToSelector:@selector(passiveLocationTracking:didFinishSavingLog:)] ) {
        
        [self.delegate passiveLocationTracking:self didFinishSavingLog:fileURL];
    }
}


@end
