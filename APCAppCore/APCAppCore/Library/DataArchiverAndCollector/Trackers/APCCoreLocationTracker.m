// 
//  APCPassiveLocationTracking.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCAppCore.h"
#import "APCCoreLocationTracker.h"

static CLLocationDistance kAllowDistanceFilterAmount         = 500.0;        //  metres

static  NSString  *kLocationTimeStamp                    = @"timestamp";
static  NSString  *kLocationDistanceFromHomeLocation     = @"distanceFromHomeLocation";
static  NSString  *kLocationDistanceFromPreviousLocation = @"distanceFromPreviousLocation";
static  NSString  *kLocationVerticalAccuracy             = @"verticalAccuracy";
static  NSString  *kLocationHorizontalAccuracy           = @"horizontalAccuracy";
static  NSString  *kLocationDistanceUnit                 = @"distanceUnit"; //Always meters

static NSString *kBaseTrackingFileName = @"baseTrackingLocation";
static NSString *kRecentLocationFileName = @"recentLocation";

static NSString *kLat = @"lat";
static NSString *kLon = @"lon";

@interface APCCoreLocationTracker () <CLLocationManagerDelegate>
{
    CLLocation * _baseTrackingLocation;
    CLLocation * _mostRecentUpdatedLocation;
}

@property (strong, nonatomic) CLLocationManager *locationManager;

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

- (instancetype)initWithIdentifier:(NSString *)identifier deferredUpdatesTimeout:(NSTimeInterval)anUpdateTimeout andHomeLocationStatus:(APCPassiveLocationTrackingHomeLocation)aHomeLocationStatus
{
    self = [super initWithIdentifier:identifier];
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

- (void)startTracking
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
            [self.locationManager allowDeferredLocationUpdatesUntilTraveled:kAllowDistanceFilterAmount timeout:self.deferredUpdatesTimeout];
        }
    }
}

- (void)stopTracking
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

- (NSArray *)columnNames
{
    NSArray * retValue;
    if (self.homeLocationStatus == APCPassiveLocationTrackingHomeLocationAvailable) {
        retValue = @[kLocationTimeStamp, kLocationDistanceFromHomeLocation, kLocationDistanceUnit, kLocationHorizontalAccuracy, kLocationVerticalAccuracy];
    }
    else
    {
        retValue = @[kLocationTimeStamp, kLocationDistanceFromPreviousLocation, kLocationDistanceUnit, kLocationHorizontalAccuracy, kLocationVerticalAccuracy];
    }
    return retValue;
}

/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/

- (NSArray *)locationDictionaryWithLocationManager:(CLLocationManager *)manager andDistanceFromReferencePoint:(CLLocationDistance)distanceFromReferencePoint
{
    
    NSString * timestamp = manager.location.timestamp.description;
    NSString * distance = [NSString stringWithFormat:@"%f", distanceFromReferencePoint];
    NSString * unit = @"meters"; //Hardcoded as Core Locations uses only meters
    NSString * horizontalAccuracy = [NSString stringWithFormat:@"%f", manager.location.horizontalAccuracy];
    NSString * verticalAccuracy = [NSString stringWithFormat:@"%f", manager.location.verticalAccuracy];
 
    return  @[timestamp, distance, unit, horizontalAccuracy, verticalAccuracy];
}

- (void)updateArchiveDataWithLocationManager:(CLLocationManager *)manager withUpdateLocations:(NSArray *)locations
{
    NSArray  *result = nil;
    
    if (self.homeLocationStatus == APCPassiveLocationTrackingHomeLocationAvailable) {
        CLLocationDistance  distanceFromReferencePoint = [self.baseTrackingLocation distanceFromLocation:manager.location];
        result = [self locationDictionaryWithLocationManager:manager andDistanceFromReferencePoint:distanceFromReferencePoint];
    }
    else
    {
        if ((self.baseTrackingLocation.coordinate.latitude == 0.0) && (self.baseTrackingLocation.coordinate.longitude == 0.0)) {
            self.baseTrackingLocation = [locations firstObject];
            self.mostRecentUpdatedLocation = self.baseTrackingLocation;
            if ([locations count] >= 1) {
                CLLocationDistance  distanceFromReferencePoint = [self.baseTrackingLocation distanceFromLocation:manager.location];
                result = [self locationDictionaryWithLocationManager:manager andDistanceFromReferencePoint:distanceFromReferencePoint];
            }
        } else {
            self.baseTrackingLocation = self.mostRecentUpdatedLocation;
            self.mostRecentUpdatedLocation = manager.location;
            CLLocationDistance  distanceFromReferencePoint = [self.baseTrackingLocation distanceFromLocation:manager.location];
            result = [self locationDictionaryWithLocationManager:manager andDistanceFromReferencePoint:distanceFromReferencePoint];
        }
    }
    
    //Send to delegate
    if (result) {
        [self.delegate APCDataTracker:self hasNewData:@[result]];
    }

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

/*********************************************************************************/
#pragma mark - Base Tracking Location & Recent Updated Location
/*********************************************************************************/
- (NSString *)baseTrackingFilePath
{
    return [self.folder stringByAppendingPathComponent:kBaseTrackingFileName];
}
- (NSString *)recentLocationFilePath
{
    return [self.folder stringByAppendingPathComponent:kRecentLocationFileName];
}

- (void)setBaseTrackingLocation:(CLLocation *)baseTrackingLocation
{
    _baseTrackingLocation = baseTrackingLocation;
    NSDictionary * dict = @{kLat : @(baseTrackingLocation.coordinate.latitude), kLon : @(baseTrackingLocation.coordinate.longitude)};
    [self writeDictionary:dict toPath:[self baseTrackingFilePath]];
}

- (CLLocation *)baseTrackingLocation
{
    if (!_baseTrackingLocation) {
        if (self.folder) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:[self baseTrackingFilePath]]) {
                NSError * error;
                NSString * jsonString = [NSString stringWithContentsOfFile:[self baseTrackingFilePath] encoding:NSUTF8StringEncoding error:&error];
                APCLogError2(error);
                NSDictionary * dict;
                if (jsonString) {
                    dict = [NSDictionary dictionaryWithJSONString:jsonString];
                    _baseTrackingLocation = [[CLLocation alloc] initWithLatitude:[dict[kLat] doubleValue] longitude:[dict[kLon] doubleValue]];
                }
            }
        }
    }
    return _baseTrackingLocation;
}

- (void)setMostRecentUpdatedLocation:(CLLocation *)mostRecentUpdatedLocation
{
    _mostRecentUpdatedLocation = mostRecentUpdatedLocation;
    NSDictionary * dict = @{kLat : @(mostRecentUpdatedLocation.coordinate.latitude), kLon : @(mostRecentUpdatedLocation.coordinate.longitude)};
    [self writeDictionary:dict toPath:[self recentLocationFilePath]];
}

- (CLLocation *)mostRecentUpdatedLocation
{
    if (!_mostRecentUpdatedLocation) {
        if (self.folder) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:[self recentLocationFilePath]]) {
                NSError * error;
                NSString * jsonString = [NSString stringWithContentsOfFile:[self recentLocationFilePath] encoding:NSUTF8StringEncoding error:&error];
                APCLogError2(error);
                NSDictionary * dict;
                if (jsonString) {
                    dict = [NSDictionary dictionaryWithJSONString:jsonString];
                    _mostRecentUpdatedLocation = [[CLLocation alloc] initWithLatitude:[dict[kLat] doubleValue] longitude:[dict[kLon] doubleValue]];
                }
            }
        }
    }
    return _mostRecentUpdatedLocation;
}

- (void) writeDictionary: (NSDictionary*) dict toPath:(NSString*) path
{
    NSString * dataString = [dict JSONString];
    [APCPassiveDataCollector createOrReplaceString:dataString toFile:path];
}

@end