// 
//  APCPassiveLocationTracking.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCAppCore.h"
#import "APCCoreLocationTracker.h"

static NSString *kPassiveLocationTrackingIdentifier = @"com.ymedialabs.passiveLocationTracking";
static NSString *kAPCPassiveLocationTrackingFileName = @"APCPassiveLocationTracking.json";

static CLLocationDistance kAllowDistanceFilterAmount         = 500.0;        //  metres

static  NSString  *kPassiveLocationTrackingTaskIdentifier    = @"passiveLocationTracking";

static  NSString  *kLocationJsonDistanceFromHomeLocation     = @"distanceFromHomeLocation";
static  NSString  *kLocationJsonDistanceFromPreviousLocation = @"distanceFromPreviousLocation";
static  NSString  *kLocationJsonTimeStamp                    = @"timestamp";
static  NSString  *kLocationJsonDateStamp                    = @"datestamp";
static  NSString  *kLocationJsonVerticalAccuracy             = @"verticalAccuracy";
static  NSString  *kLocationJsonHorizontalAccuracy           = @"horizontalAccuracy";

@interface APCCoreLocationTracker ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, strong) NSString         *documentsDirectoryPath;
@property (nonatomic, strong) NSURL            *fileUrl;

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

@implementation APCCoreLocationTracker

- (instancetype)initWithDeferredUpdatesTimeout:(NSTimeInterval)anUpdateTimeout andHomeLocationStatus:(APCPassiveLocationTrackingHomeLocation)aHomeLocationStatus
{
    self = [super init];
    
    if (self != nil) {
        _deferredUpdatesTimeout = anUpdateTimeout;
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
            [self.locationManager stopMonitoringSignificantLocationChanges];
        }
    }
}

/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/

    //
    //    generate a unique archive URL in the documents directory
    //

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
//        NSData *data = [NSJSONSerialization dataWithJSONObject:locationJson options:0 error:nil];
//        
////        if (self.taskArchive != nil) {
////            [self.taskArchive resetContent];
////        }
//        RKSTOrderedTask  *task = [[RKSTOrderedTask alloc] initWithIdentifier:kPassiveLocationTrackingTaskIdentifier steps:nil];
        
#pragma mark TODO  Check the identifier below

//        self.taskArchive = [[RKSTDataArchive alloc] initWithItemIdentifier:task.identifier
//                                                         studyIdentifier:kPassiveLocationTrackingIdentifier
//                                                        taskRunUUID: [NSUUID UUID]
//                                                           extraMetadata: nil
//                                                          fileProtection:RKFileProtectionCompleteUnlessOpen];
        
//        NSError  *addFileError = nil;
//        [self.taskArchive addFileWithURL:[self makeArchiveURL] contentType:@"json" metadata:nil error:&addFileError];

        NSError  *error = nil;
//        [self.taskArchive addContentWithData:data
//                                    filename:kAPCPassiveLocationTrackingFileName
//                                 contentType:@"json"
//                                   timestamp:[NSDate date]
//                                    metadata:nil error:&error];
        
        if (error != nil) {
            APCLogError2(error);
        } else {
            NSError  *err = nil;
            NSURL  *archiveFileURL = nil;//[self.taskArchive archiveURLWithError:&err];
            
            if (err != nil) {
                APCLogError2(err);
            } else if (archiveFileURL != nil) {
                NSString  *outputFilePath = [self makeDocumentsDirectoryPath];
                NSURL  *outputFileURL = [NSURL fileURLWithPath:outputFilePath];
                NSURL  *outputUrl = [outputFileURL URLByAppendingPathComponent:[archiveFileURL lastPathComponent]];
                
                // This is where you would queue the archive for upload. In this demo, we move it
                // to the documents directory, where you could copy it off using iTunes, for instance.
                [[NSFileManager defaultManager] moveItemAtURL:archiveFileURL toURL:outputUrl error:nil];

#pragma mark TODO  This is here because it's convenient

                    //NSLog(@"passive location data outputUrl= %@", outputUrl);
                
                // When done, clean up:
//                self.taskArchive = nil;
                
//                if (archiveFileURL != nil) {
//                    [[NSFileManager defaultManager] removeItemAtURL:archiveFileURL error:nil];
//                }
            }
        }
    }
}

#pragma mark TODO  Return any geocoordinate data that has not been uploaded

- (NSDictionary *)retreieveLocationMarkersFromLog
{
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
}

#pragma mark TODO  After pausing there may be some work to do here

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    APCLogDebug(@"locationManagerDidPauseLocationUpdates");
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    APCLogDebug(@"locationManager didUpdateLocations DeferredUpdatesTimeout = %.2f", self.deferredUpdatesTimeout);
    [self updateArchiveDataWithLocationManager:manager withUpdateLocations:locations];
}

#pragma mark TODO  Connection failed. What to do here

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    APCLogError(@"Asynchronous call failed with error %@", error);
}

/*********************************************************************************/
#pragma mark - Delegate Methods
/*********************************************************************************/

- (void) didFailToUpdateLocationWithError:(NSError *)error
{
    
    if ( [self.heartBeatDelegate respondsToSelector:@selector(passiveLocationTracking:didFailToUpdateLocationWithError:)] ) {
        
        [self.heartBeatDelegate passiveLocationTracking:self didFailToUpdateLocationWithError:error];
    }
}


- (void) didPauseLocationTracking:(CLLocationManager *)manager
{
    
    if ( [self.heartBeatDelegate respondsToSelector:@selector(passiveLocationTracking:didPauseLocationTracking:)] ) {
        
        [self.heartBeatDelegate passiveLocationTracking:self didPauseLocationTracking:manager];
    }
}


- (void) didResumeLocationTracking:(CLLocationManager *)manager
{
    
    if ( [self.heartBeatDelegate respondsToSelector:@selector(passiveLocationTracking:didResumeLocationTracking:)] ) {
        
        [self.heartBeatDelegate passiveLocationTracking:self didResumeLocationTracking:manager];
    }
}


- (void) didFailToUpdateLogWithError:(NSError *)error
{
    
    if ( [self.heartBeatDelegate respondsToSelector:@selector(passiveLocationTracking:didFailToUpdateLogWithError:)] ) {
        
        [self.heartBeatDelegate passiveLocationTracking:self didFailToUpdateLogWithError:error];
    }
}


- (void) didFailToDeleteLogWithError:(NSError *)error
{
    
    if ( [self.heartBeatDelegate respondsToSelector:@selector(passiveLocationTracking:didFailToDeleteLogWithError:)] ) {
        
        [self.heartBeatDelegate passiveLocationTracking:self didFailToDeleteLogWithError:error];
    }
}


- (void) didFailToUploadLogWithError:(NSError *)error
{
    
    if ( [self.heartBeatDelegate respondsToSelector:@selector(passiveLocationTracking:didFailToUploadLog:)] ) {
        
        [self.heartBeatDelegate passiveLocationTracking:self didFailToUploadLog:error];
    }
}


- (void) didFinishSavingLog:(NSURL *)fileURL
{
    
    if ( [self.heartBeatDelegate respondsToSelector:@selector(passiveLocationTracking:didFinishSavingLog:)] ) {
        
        [self.heartBeatDelegate passiveLocationTracking:self didFinishSavingLog:fileURL];
    }
}


@end
