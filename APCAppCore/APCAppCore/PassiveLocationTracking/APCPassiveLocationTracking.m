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

//static CLLocationDistance kAllowDeferredLocationUpdatesUntilTraveled = 500.0;        //  metres
static CLLocationDistance kAllowDistanceFilterAmount                 = 500.0;        //  metres

static  NSString  *kPassiveLocationTrackingTaskIdentifier    = @"passiveLocationTracking";

static  NSString  *kLocationJsonDistanceFromHomeLocation     = @"distanceFromHomeLocation";
static  NSString  *kLocationJsonDistanceFromPreviousLocation = @"distanceFromPreviousLocation";
static  NSString  *kLocationJsonTimeStamp                    = @"timestamp";
static  NSString  *kLocationJsonDateStamp                    = @"datestamp";
static  NSString  *kLocationJsonVerticalAccuracy             = @"verticalAccuracy";
static  NSString  *kLocationJsonHorizontalAccuracy           = @"horizontalAccuracy";

@interface APCPassiveLocationTracking ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, strong) RKSTDataArchive  *taskArchive;
@property (nonatomic, strong) NSString         *documentsDirectoryPath;
@property (nonatomic, strong) NSURL            *fileUrl;

//@property (nonatomic, assign) BOOL              deferringUpdates;
@property (nonatomic, assign) NSTimeInterval    deferredUpdatesTimeout;

    //
    //    determines whether there is a user's home location
    //        APCPassiveLocationTrackingHomeLocationAvailable  or
    //        APCPassiveLocationTrackingHomeLocationUnavailable
    //
@property (nonatomic, assign) APCPassiveLocationTrackingHomeLocation  homeLocationStatus;

    //
    //    when there is a user's home location, baseTrackingLocation
    //        maintains the position of the user's home location
    //
    //    when there is not a user's home location, baseTrackingLocation
    //        maintains the position of the most recent but one recorded location
    //
@property (nonatomic, strong) CLLocation  *baseTrackingLocation;

    //
    //    used in the case where there is not a user's home location,
    //        this records the most recent location update
    //
@property (nonatomic, strong) CLLocation  *mostRecentUpdatedLocation;

@end

@implementation APCPassiveLocationTracking

- (instancetype)initWithDeferredUpdatesTimeout:(NSTimeInterval)anUpdateTimeout andHomeLocationStatus:(APCPassiveLocationTrackingHomeLocation)aHomeLocationStatus
{
    self = [super init];
    
    if (self != nil) {
        _deferredUpdatesTimeout = anUpdateTimeout;
//        _deferringUpdates = YES;
        _homeLocationStatus = aHomeLocationStatus;
        [self setupInitialLocationParameters];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupInitialLocationParameters
{
    if (_homeLocationStatus == APCPassiveLocationTrackingHomeLocationAvailable) {
        APCUser  *user = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
        CLLocationDegrees homeLocationLatitude  = [user.homeLocationLat doubleValue];
        CLLocationDegrees homeLocationLongitude = [user.homeLocationLong doubleValue];
        _baseTrackingLocation = [[CLLocation alloc] initWithLatitude:homeLocationLatitude longitude:homeLocationLongitude];
    } else {
        _baseTrackingLocation       = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
        _mostRecentUpdatedLocation  = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    }
}

- (void)start
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        self.locationManager.distanceFilter = kAllowDistanceFilterAmount;

//        self.locationManager.pausesLocationUpdatesAutomatically = YES;
        if ([CLLocationManager significantLocationChangeMonitoringAvailable] == NO) {
            [self.locationManager startUpdatingLocation];
        } else {
            [self.locationManager startMonitoringSignificantLocationChanges];
        }
    }
}


- (void)stop
{
    if ([CLLocationManager locationServicesEnabled] == NO) {
        APCLogDebug(@"Location services disabled");
    } else {
        if ([CLLocationManager significantLocationChangeMonitoringAvailable] == NO) {
            [self.locationManager stopUpdatingLocation];
        } else {
//            [self.locationManager stopUpdatingLocation];
            [self.locationManager stopMonitoringSignificantLocationChanges];
        }
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

- (NSString *)makeDocumentsDirectoryPath
{
    NSString  *documentsPath = nil;
    
    if (self.documentsDirectoryPath != nil) {
        documentsPath = self.documentsDirectoryPath;
    } else {
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [paths lastObject];
        if ([[NSFileManager defaultManager] fileExistsAtPath:documentsPath] == NO) {
            NSError  *fileError;
            [[NSFileManager defaultManager] createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:&fileError];
            APCLogError2(fileError);
        }
        self.documentsDirectoryPath = documentsPath;
    }
    return  self.documentsDirectoryPath;
}

- (NSURL *)makeArchiveURL
{
    NSString  *documentsPath = [self makeDocumentsDirectoryPath];
    NSString  *zipFilePath = [documentsPath stringByAppendingPathComponent:[[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"zip"]];
    NSURL  *zipFileUrl = [NSURL fileURLWithPath:zipFilePath];
    return  zipFileUrl;
}

- (NSDictionary *)locationDictionaryWithLocationManager:(CLLocationManager *)manager andDistanceFromReferencePoint:(CLLocationDistance)distanceFromReferencePoint
{
    NSLog(@"locationDictionaryWithLocationManager called");
    NSDictionary  *locationDictionary = nil;
    NSDateFormatter  *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    NSTimeInterval  timestamp = [manager.location.timestamp timeIntervalSince1970];
    NSDate  *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString  *formatted = [formatter stringFromDate:date];
    if (self.homeLocationStatus == APCPassiveLocationTrackingHomeLocationAvailable) {
        locationDictionary = @{
                              kLocationJsonDistanceFromHomeLocation : [NSNumber numberWithDouble:distanceFromReferencePoint],
                              kLocationJsonTimeStamp                : [NSNumber numberWithDouble:[manager.location.timestamp timeIntervalSince1970]],
                              kLocationJsonDateStamp                : formatted,
                              kLocationJsonHorizontalAccuracy       : [NSNumber numberWithDouble:manager.location.horizontalAccuracy],
                              kLocationJsonVerticalAccuracy         : [NSNumber numberWithDouble:manager.location.verticalAccuracy],
                            };
    } else {
        locationDictionary = @{
                               kLocationJsonDistanceFromPreviousLocation : [NSNumber numberWithDouble:distanceFromReferencePoint],
                               kLocationJsonTimeStamp                    : [NSNumber numberWithDouble:[manager.location.timestamp timeIntervalSince1970]],
                               kLocationJsonDateStamp                    : formatted,
                               kLocationJsonHorizontalAccuracy           : [NSNumber numberWithDouble:manager.location.horizontalAccuracy],
                               kLocationJsonVerticalAccuracy             : [NSNumber numberWithDouble:manager.location.verticalAccuracy],
                               };
    }
    return  locationDictionary;
}

- (void)updateArchiveDataWithLocationManager:(CLLocationManager *)manager withUpdateLocations:(NSArray *)locations
{
    NSDictionary  *locationJson = nil;
    
    if (self.homeLocationStatus == APCPassiveLocationTrackingHomeLocationAvailable) {
        CLLocationDistance  distanceFromReferencePoint = [self.baseTrackingLocation distanceFromLocation:manager.location];
        locationJson = [self locationDictionaryWithLocationManager:manager andDistanceFromReferencePoint:distanceFromReferencePoint];
    } else {
        if ((self.baseTrackingLocation.coordinate.latitude == 0.0) && (self.baseTrackingLocation.coordinate.longitude == 0.0)) {
            self.baseTrackingLocation = [locations firstObject];
            if ([locations count] > 1) {
                CLLocationDistance  distanceFromReferencePoint = [self.baseTrackingLocation distanceFromLocation:manager.location];
                locationJson = [self locationDictionaryWithLocationManager:manager andDistanceFromReferencePoint:distanceFromReferencePoint];
            }
        } else {
            self.baseTrackingLocation = self.mostRecentUpdatedLocation;
            self.mostRecentUpdatedLocation = manager.location;
            CLLocationDistance  distanceFromReferencePoint = [self.baseTrackingLocation distanceFromLocation:manager.location];
            locationJson = [self locationDictionaryWithLocationManager:manager andDistanceFromReferencePoint:distanceFromReferencePoint];
        }
    }
    if (locationJson != nil) {
        NSLog(@"locationJson exists = %@", locationJson);
        NSData *data = [NSJSONSerialization dataWithJSONObject:locationJson options:0 error:nil];
        
        if (self.taskArchive != nil) {
            [self.taskArchive resetContent];
        }
        RKSTOrderedTask  *task = [[RKSTOrderedTask alloc] initWithIdentifier:kPassiveLocationTrackingTaskIdentifier steps:nil];
        
        //TODO: Check the identifier below
        self.taskArchive = [[RKSTDataArchive alloc] initWithItemIdentifier:task.identifier
                                                         studyIdentifier:kPassiveLocationTrackingIdentifier
                                                        taskRunUUID: [NSUUID UUID]
                                                           extraMetadata: nil
                                                          fileProtection:RKFileProtectionCompleteUnlessOpen];
        
        NSError  *addFileError = nil;
        [self.taskArchive addFileWithURL:[self makeArchiveURL] contentType:@"json" metadata:nil error:&addFileError];

        NSError  *error = nil;
        [self.taskArchive addContentWithData:data
                                    filename:kAPCPassiveLocationTrackingFileName
                                 contentType:@"json"
                                   timestamp:[NSDate date]
                                    metadata:nil error:&error];
        
        if (error != nil) {
            APCLogError2(error);
        } else {
            NSError  *err = nil;
            NSURL  *archiveFileURL = [self.taskArchive archiveURLWithError:&err];
            
            if (err != nil) {
                APCLogError2(err);
            } else if (archiveFileURL != nil) {
                NSString  *outputFilePath = [self makeDocumentsDirectoryPath];
                NSURL  *outputFileURL = [NSURL fileURLWithPath:outputFilePath];
                NSURL  *outputUrl = [outputFileURL URLByAppendingPathComponent:[archiveFileURL lastPathComponent]];
                
                // This is where you would queue the archive for upload. In this demo, we move it
                // to the documents directory, where you could copy it off using iTunes, for instance.
                [[NSFileManager defaultManager] moveItemAtURL:archiveFileURL toURL:outputUrl error:nil];
                
                //TODO this is here because it's convenient.
                //NSLog(@"passive location data outputUrl= %@", outputUrl);
                
                // When done, clean up:
                self.taskArchive = nil;
                
                if (archiveFileURL != nil) {
                    [[NSFileManager defaultManager] removeItemAtURL:archiveFileURL error:nil];
                }
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

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    APCLogError2(error);
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    if (error != nil) {
        APCLogError(@"didFinishDeferredUpdatesWithError %@ \n", error);
    }
//    self.deferringUpdates = NO;
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    //TODO After pausing there may be some work to do here.
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    APCLogDebug(@"locationManagerDidPauseLocationUpdates");
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    APCLogDebug(@"locationManager didUpdateLocations DeferredUpdatesTimeout = %.2f", self.deferredUpdatesTimeout);
    // Defer updates until a certain amount of time has passed.
//    if (self.deferringUpdates == NO) {
    
        [self updateArchiveDataWithLocationManager:manager withUpdateLocations:locations];

//        [self.locationManager allowDeferredLocationUpdatesUntilTraveled:(CLLocationDistance)0
//                                                           timeout:self.deferredUpdatesTimeout];
//        self.deferringUpdates = YES;
//    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    APCLogError(@"Asynchronous call failed with error %@", error);
    
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
