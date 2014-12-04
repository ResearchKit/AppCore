// 
//  APCPassiveLocationTracking.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCAppCore.h"
#import "APCPassiveLocationTracking.h"

static NSString *kPassiveLocationTrackingIdentifier = @"com.ymedialabs.passiveLocationTracking";
static NSString *kAPCPassiveLocationTrackingFileName = @"APCPassiveLocationTracking.json";
static CLLocationDistance kAllowDeferredLocationUpdatesUntilTraveled = 5.0;
@interface APCPassiveLocationTracking ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, strong) RKSTDataArchive *taskArchive;
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
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        self.locationManager = [[CLLocationManager alloc]init];
        [self.locationManager setDelegate:self];
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];

        //If no significant movement is being made let's pause tracking and do some work.
        
        if ([CLLocationManager deferredLocationUpdatesAvailable])
        {
            [self.locationManager allowDeferredLocationUpdatesUntilTraveled:kAllowDeferredLocationUpdatesUntilTraveled timeout:self.timeout];
        }

        //TODO I really think is going to be reliable but I don't know how to trigger it properly.
        //If no significant movement is being made let's pause tracking and do some work.
//        self.locationManager.pausesLocationUpdatesAutomatically = YES;
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

//TODO This is potentially going to be used but because of the way we're collecting data now we're not.
//- (void)beginTask
//{
//    if (self.taskArchive)
//    {
//        [self.taskArchive resetContent];
//    }
//    
//    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithName:@"PassiveLocationTracking" identifier:@"passiveLocationTracking" steps:nil];
//    
//    self.taskArchive = [[RKSTDataArchive alloc] initWithItemIdentifier:[RKItemIdentifier itemIdentifierForTask:task]
//                                                     studyIdentifier:passiveLocationTrackingIdentifier
//                                                    taskInstanceUUID: [NSUUID UUID]
//                                                       extraMetadata: nil
//                                                      fileProtection:RKFileProtectionCompleteUnlessOpen];
//    
//
//    [self createFileWithName:APCPassiveLocationTrackingFileName];
//}
//
//- (void)createFileWithName:(NSString *)fileName
//{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
//    
//    //Set the filepath URL
//    self.fileUrl = [[NSURL alloc] initFileURLWithPath:filePath];
//    
//    NSError *error;
//    [self.taskArchive addFileWithURL:self.fileUrl contentType:@"json" metadata:nil error:&error];
//}

// Generate a unique archive URL in the documents directory
- (NSURL *)makeArchiveURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *zipPath = [[paths lastObject] stringByAppendingPathComponent:[[[NSUUID UUID] UUIDString] stringByAppendingString:@".zip"]];
    
    
    return [NSURL fileURLWithPath:zipPath];
}


- (void)updateArchiveDataWithLocationManager:(CLLocationManager *)manager withUpdateLocations:(NSArray *)locations {
    
    //TODO store this in parameters
    CLLocation *homeLocation = [[CLLocation alloc] initWithLatitude:37.335420 longitude: -122.012901];
    
    
    //Create distance in meters from home
    CLLocationDistance distanceFromHome = [homeLocation distanceFromLocation:manager.location];
    
    NSMutableDictionary *locationJson = [NSMutableDictionary new];
    
    locationJson[@"distanceFromHome"] = [NSNumber numberWithDouble:distanceFromHome];
    
    double dateInterval = [manager.location.timestamp timeIntervalSince1970];
    
    locationJson[@"timestamp"] = [NSNumber numberWithDouble: dateInterval];
    
    /* Type used to represent a location accuracy level in meters. The lower the value in meters, the
     more physically precise the location is. A negative accuracy value indicates an invalid location. */
    locationJson[@"verticalAccuracy"] = [NSNumber numberWithDouble:manager.location.verticalAccuracy];
    locationJson[@"horizontalAccuracy"] = [NSNumber numberWithDouble:manager.location.horizontalAccuracy];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:locationJson options:0 error:nil];
    
    if (self.taskArchive)
    {
        [self.taskArchive resetContent];
    }
    
    RKSTOrderedTask* task = [[RKSTOrderedTask alloc] initWithIdentifier:@"passiveLocationTracking" steps:nil];
    
    //TODO: Check the identifier below
    self.taskArchive = [[RKSTDataArchive alloc] initWithItemIdentifier:task.identifier
                                                     studyIdentifier:kPassiveLocationTrackingIdentifier
                                                    taskRunUUID: [NSUUID UUID]
                                                       extraMetadata: nil
                                                      fileProtection:RKFileProtectionCompleteUnlessOpen];
    
    NSError *addFileError = nil;
    [self.taskArchive addFileWithURL:[self makeArchiveURL] contentType:@"json" metadata:nil error:&addFileError];

    NSError *error;
    [self.taskArchive addContentWithData:data
                                filename:kAPCPassiveLocationTrackingFileName
                             contentType:@"json"
                               timestamp:[NSDate date]
                                metadata:nil error:&error];
    
    if (error) {
        NSLog(@"Content not added");
        //TODO Handle error
    } else
    {
        NSError *err = nil;
    
        NSURL *archiveFileURL = [self.taskArchive archiveURLWithError:&err];
        
        if (err) {
            NSLog(@"Error");
        } else if (archiveFileURL)
        {
            NSURL *documents = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
            NSURL *outputUrl = [documents URLByAppendingPathComponent:[archiveFileURL lastPathComponent]];
            
            // This is where you would queue the archive for upload. In this demo, we move it
            // to the documents directory, where you could copy it off using iTunes, for instance.
            [[NSFileManager defaultManager] moveItemAtURL:archiveFileURL toURL:outputUrl error:nil];
            
            //TODO this is here because it's convenient.
            //NSLog(@"passive location data outputUrl= %@", outputUrl);
            
            // When done, clean up:
            self.taskArchive = nil;
            
            if (archiveFileURL)
            {
                [[NSFileManager defaultManager] removeItemAtURL:archiveFileURL error:nil];
            }
        }
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
    
    if (error) {
        NSLog(@"didFinishDeferredUpdatesWithError %@ \n", error);
    }
    
    self.deferringUpdates = NO;
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    //TODO After pausing there may be some work to do here.
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"locationManagerDidPauseLocationUpdates");
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
