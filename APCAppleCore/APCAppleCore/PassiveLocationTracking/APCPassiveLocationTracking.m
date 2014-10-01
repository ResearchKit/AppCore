
//
//  APCLocationTrackingHeartbeat.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 9/24/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCAppleCore.h"
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

-(instancetype)initWithTimeInterval:(NSTimeInterval)timeout
{
    self = [super init];
    
    if (self)
    {
        
        _timeout = timeout;
        _deferringUpdates = YES;
    }
    
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)start
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
            [self.locationManager allowDeferredLocationUpdatesUntilTraveled:(CLLocationDistance)0.0 timeout:(NSTimeInterval)self.timeout];
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
    
    //Set the filepath URL
    self.fileUrl = [[NSURL alloc] initFileURLWithPath:filePath];
    
    NSError *error;
    [self.taskArchive addFileWithURL:self.fileUrl contentType:@"json" metadata:nil error:&error];
}


- (void)updateArchiveDataWithLocationManager:(CLLocationManager *)manager withUpdateLocations:(NSArray *)locations {
    
    NSLog(@"%@", manager.location);
    
    //TODO store this in parameters
    CLLocation *homeLocation = [[CLLocation alloc] initWithLatitude:37.335420 longitude: -122.012901];
    
    
    //Create distance in meters from home
    CLLocationDistance distanceFromHome = [homeLocation distanceFromLocation:manager.location];
    
    NSMutableDictionary *json = [NSMutableDictionary new];
    
    json[@"distanceFromHome"] = [NSNumber numberWithDouble:distanceFromHome];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    json[@"timestamp"] = dateString;
    /* Type used to represent a location accuracy level in meters. The lower the value in meters, the
     more physically precise the location is. A negative accuracy value indicates an invalid location. */
    json[@"verticalAccuracy"] = [NSNumber numberWithDouble:manager.location.verticalAccuracy];
    json[@"horizontalAccuracy"] = [NSNumber numberWithDouble:manager.location.horizontalAccuracy];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    
    NSError *error;
    [self.taskArchive addContentWithData:data
                                filename:APCPassiveLocationTrackingFileName
                             contentType:@"json"
                               timestamp:[NSDate date]
                                metadata:nil error:&error];
    
    if (error) {
        NSLog(@"Content not added");
        //TODO Handle error
    }
}


- (NSDictionary *)retreieveLocationMarkersFromLog
{
    
    //TODO Return any geocoordinate data that has not been uploaded
    return nil;
}

- (void)kickOffPassiveLocationUpdating:(NSNotification *)notification {
    [self start];
}



/*********************************************************************************/
#pragma mark -CLLocationManagerDelegate
/*********************************************************************************/
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    
    //TODO error handling
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    NSLog(@"didFinishDeferredUpdatesWithError %@ \n", error);
    
    self.deferringUpdates = NO;
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    //TODO After pausing there may be some work to do here.
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


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    // Defer updates until a certain amount of time has passed.
    if (!self.deferringUpdates) {
        
        [self updateArchiveDataWithLocationManager:manager withUpdateLocations:locations];

        [self.locationManager allowDeferredLocationUpdatesUntilTraveled:(CLLocationDistance)0
                                                           timeout:self.timeout];
        self.deferringUpdates = YES;
    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Asynchronous call failed");
    
    //TODO connection failed. What to do here.
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
