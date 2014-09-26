
//
//  APCLocationTrackingHeartbeat.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 9/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCPassiveLocationTracking.h"

static NSString *passiveLocationTrackingIdentifier = @"com.ymedialabs.passiveLocationTracking";
static NSString *APCPassiveLocationTrackingFileName = @"APCPassiveLocationTracking.json";

@interface APCPassiveLocationTracking ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, strong) RKDataArchive *taskArchive;
@property (nonatomic, strong) NSURL *fileUrl;

@property (assign) BOOL deferringUpdates;
@property (assign) NSTimeInterval timeout;
@end

@implementation APCPassiveLocationTracking

-(instancetype)init
{
    self = [super init];
    
    if (self)
    {
        
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        if (status == kCLAuthorizationStatusNotDetermined) {
            
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [_locationManager requestAlwaysAuthorization];
            }
        }
    }
    
    return self;
}

- (void)startWithTimeInterval:(NSTimeInterval)timeout
{
    
    [self beginTask];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        self.locationManager = [[CLLocationManager alloc]init];
        [self.locationManager setDelegate:self];
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];

        //If no significant movement is being made let's pause tracking and do some work.
        
        if ([CLLocationManager deferredLocationUpdatesAvailable])
        {
            [self.locationManager allowDeferredLocationUpdatesUntilTraveled:(CLLocationDistance)0.0 timeout:(NSTimeInterval)timeout];
            self.timeout = timeout;
        }

        //If no significant movement is being made let's pause tracking and do some work.
        self.locationManager.pausesLocationUpdatesAutomatically = YES;
        [self.locationManager startUpdatingLocation];
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
    

    [self createFileWithName:APCPassiveLocationTrackingFileName];
}

- (void)createFileWithName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *manager = [NSFileManager defaultManager];

    // 1st, This funcion could allow you to create a file with initial contents.
    // 2nd, You could specify the attributes of values for the owner, group, and permissions.
    // Here we use nil, which means we use default values for these attibutes.
    // 3rd, it will return YES if NSFileManager create it successfully or it exists already.
    if ([manager createFileAtPath:filePath contents:nil attributes:nil]) {
        NSLog(@"Created the File Successfully.");

        //Set the filepath URL
        self.fileUrl = [[NSURL alloc] initFileURLWithPath:filePath];

        NSError *error;
        [self.taskArchive addFileWithURL:self.fileUrl contentType:@"json" metadata:nil error:&error];
        
        
    } else {
        NSLog(@"Failed to Create the File");

    }
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
    NSLog(@"didFinishDeferredUpdatesWithError %@ \n", error);
    
    self.deferringUpdates = NO;
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"locationManagerDidPauseLocationUpdates");
    
//TODO Upload passive data collection
    
    NSError *err = nil;
    NSURL *archiveFileURL = [self.taskArchive archiveURLWithError:&err];
    if (archiveFileURL)
    {
        NSURL *documents = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        NSURL *outputUrl = [documents URLByAppendingPathComponent:[archiveFileURL lastPathComponent]];
        
        // This is where you would queue the archive for upload. In this demo, we move it
        // to the documents directory, where you could copy it off using iTunes, for instance.
        [[NSFileManager defaultManager] moveItemAtURL:archiveFileURL toURL:outputUrl error:nil];
        
        NSLog(@"outputUrl= %@", outputUrl);
        
        // When done, clean up:
        self.taskArchive = nil;
        if (archiveFileURL)
        {
            [[NSFileManager defaultManager] removeItemAtURL:archiveFileURL error:nil];
        }
    }
}

- (void)updateArchiveDataWithLocationManager:(CLLocationManager *)manager {
    
    //TODO store this in parameters
    CLLocation *homeLocation = [[CLLocation alloc] initWithLatitude:37.335420 longitude: -122.012901];
    
    
    //Create distance in meters from home
    CLLocationDistance distanceFromHome = [homeLocation distanceFromLocation:manager.location];

    NSMutableDictionary *json = [NSMutableDictionary new];

    json[@"distanceFromHome"] = [NSNumber numberWithDouble:distanceFromHome];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:json
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    
    //TODO write to data archive
    NSLog(@"Data to update %@", data);
    
    NSError *error;
    [self.taskArchive addContentWithData:data
                                filename:[self.fileUrl path]
                             contentType:@"json"
                               timestamp:[NSDate date]
                                metadata:nil error:&error];
    
    if (error) {
        NSLog(@"Content not added");
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
   [self updateArchiveDataWithLocationManager:manager];
    
    // Defer updates until a certain amount of time has passed.
    if (!self.deferringUpdates) {

        [self.locationManager allowDeferredLocationUpdatesUntilTraveled:(CLLocationDistance)0
                                                           timeout:self.timeout];
        self.deferringUpdates = YES;
    }

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
