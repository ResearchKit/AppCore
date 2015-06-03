// 
//  APCCoreLocationTracker.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 

#import "APCAppCore.h"
#import "APCCoreLocationTracker.h"


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

@property (nonatomic, assign) BOOL deferringUpdates;
@end


@implementation APCCoreLocationTracker

- (instancetype)initWithIdentifier:(NSString*)identifier
            deferredUpdatesTimeout:(NSTimeInterval) __unused anUpdateTimeout
             andHomeLocationStatus:(APCPassiveLocationTrackingHomeLocation)aHomeLocationStatus
{
    APCLogDebug(@"Initalizing location tracker");
    self = [super initWithIdentifier:identifier];
    if (self != nil)
    {
        _homeLocationStatus     = aHomeLocationStatus;
        _deferringUpdates       = NO;
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
    if (_homeLocationStatus == APCPassiveLocationTrackingHomeLocationAvailable)
    {
        APCUser  *user = ((APCAppDelegate *)[UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
        CLLocationDegrees homeLocationLatitude  = [user.homeLocationLat doubleValue];
        CLLocationDegrees homeLocationLongitude = [user.homeLocationLong doubleValue];
        _baseTrackingLocation = [[CLLocation alloc] initWithLatitude:homeLocationLatitude longitude:homeLocationLongitude];
    }
    else
    {
        _baseTrackingLocation       = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
        _mostRecentUpdatedLocation  = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    }
}

- (void)startTracking
{
    if ([CLLocationManager locationServicesEnabled] == YES)
    {
        APCLogDebug(@"Start location tracking");
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;

        if ([CLLocationManager significantLocationChangeMonitoringAvailable] == YES &&
            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
        {
            APCLogDebug(@"Significant Location Change Monitoring is Available");
            [self.locationManager startMonitoringSignificantLocationChanges];
        }
    }
}

- (void)stopTracking
{
    if ([CLLocationManager locationServicesEnabled] == YES)
    {
        if ([CLLocationManager significantLocationChangeMonitoringAvailable] == YES)
        {
            [self.locationManager stopMonitoringSignificantLocationChanges];
        }
    }
}

- (NSArray*)columnNames
{
    NSArray* retValue;
    if (self.homeLocationStatus == APCPassiveLocationTrackingHomeLocationAvailable)
    {
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

- (NSArray*)locationDictionaryWithLocationManager:(CLLocationManager*)manager
                    andDistanceFromReferencePoint:(CLLocationDistance)distanceFromReferencePoint
{
    
    NSString*   timestamp          = manager.location.timestamp.description;
    NSString*   distance           = [NSString stringWithFormat:@"%f", distanceFromReferencePoint];
    NSString*   unit               = @"meters"; //Hardcoded as Core Locations uses only meters
    NSString*   horizontalAccuracy = [NSString stringWithFormat:@"%f", manager.location.horizontalAccuracy];
    NSString*   verticalAccuracy   = [NSString stringWithFormat:@"%f", manager.location.verticalAccuracy];
 
    return  @[timestamp, distance, unit, horizontalAccuracy, verticalAccuracy];
}

- (void)updateArchiveDataWithLocationManager:(CLLocationManager *)manager withUpdateLocations:(NSArray *)locations
{
    NSArray  *result = nil;
        
    if (self.homeLocationStatus == APCPassiveLocationTrackingHomeLocationAvailable)
    {
        CLLocationDistance  distanceFromReferencePoint = [self.baseTrackingLocation distanceFromLocation:manager.location];
        result = [self locationDictionaryWithLocationManager:manager andDistanceFromReferencePoint:distanceFromReferencePoint];
    }
    else
    {
        if ((self.baseTrackingLocation.coordinate.latitude == 0.0) && (self.baseTrackingLocation.coordinate.longitude == 0.0))
        {
            self.baseTrackingLocation = [locations firstObject];
            self.mostRecentUpdatedLocation = self.baseTrackingLocation;
            if ([locations count] >= 1)
            {
                CLLocationDistance  distanceFromReferencePoint = [self.baseTrackingLocation distanceFromLocation:manager.location];
                result = [self locationDictionaryWithLocationManager:manager andDistanceFromReferencePoint:distanceFromReferencePoint];
            }
        }
        else
        {
            self.baseTrackingLocation = self.mostRecentUpdatedLocation;
            self.mostRecentUpdatedLocation = manager.location;
            CLLocationDistance  distanceFromReferencePoint = [self.baseTrackingLocation distanceFromLocation:manager.location];
            result = [self locationDictionaryWithLocationManager:manager andDistanceFromReferencePoint:distanceFromReferencePoint];
        }
    }
    
    //Send to delegate
    if (result)
    {
        [self.delegate APCDataTracker:self hasNewData:@[result]];
    }
}

/*********************************************************************************/
#pragma mark -CLLocationManagerDelegate
/*********************************************************************************/

- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError*)error
{
    APCLogError2(error);
    
    switch(error.code)
    {
        case kCLErrorNetwork:
        {
            //  Possible network connection issue (eg, in airplane mode)
            break;
        }
            
        case kCLErrorDenied:
        {
            //  The user has denied use of location
            [manager stopUpdatingLocation];
            //  The app delegate should be notified so that other components (eg, Profile) could
            //  better reflect the state of location services.
            break;
        }

        default:
        {
            //  Unknown issue
            break;
        }
    }
}

- (void)              locationManager:(CLLocationManager*) __unused manager
    didFinishDeferredUpdatesWithError:(NSError*) error
{
    if (error != nil)
    {
        APCLogError2(error);
    }
}

#pragma mark TODO  After pausing there may be some work to do here

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager*) __unused manager
{
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager*) __unused manager
{
    APCLogDebug(@"locationManagerDidPauseLocationUpdates");
}


- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray*)locations
{
    APCLogDebug(@"locationManager didUpdateLocations at %@", [NSDate date]);
    [self updateArchiveDataWithLocationManager:manager withUpdateLocations:locations];
}

/*********************************************************************************/
#pragma mark - Base Tracking Location & Recent Updated Location
/*********************************************************************************/
- (NSString*)baseTrackingFilePath
{
    return [self.folder stringByAppendingPathComponent:kBaseTrackingFileName];
}

- (NSString*)recentLocationFilePath
{
    return [self.folder stringByAppendingPathComponent:kRecentLocationFileName];
}

- (void)setBaseTrackingLocation:(CLLocation *)baseTrackingLocation
{
    _baseTrackingLocation = baseTrackingLocation;
    NSDictionary * dict = @{kLat : @(baseTrackingLocation.coordinate.latitude), kLon : @(baseTrackingLocation.coordinate.longitude)};
    [self writeDictionary:dict toPath:[self baseTrackingFilePath]];
}

- (CLLocation*)baseTrackingLocation
{
    if (!_baseTrackingLocation)
    {
        if (self.folder)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:[self baseTrackingFilePath]])
            {
                NSError*    error;
                NSString*   jsonString = [NSString stringWithContentsOfFile:[self baseTrackingFilePath] encoding:NSUTF8StringEncoding error:&error];
                APCLogError2(error);
                NSDictionary* dict;
                
                if (jsonString)
                {
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

- (CLLocation*)mostRecentUpdatedLocation
{
    if (!_mostRecentUpdatedLocation)
    {
        if (self.folder)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:[self recentLocationFilePath]])
            {
                NSError*    error;
                NSString*   jsonString = [NSString stringWithContentsOfFile:[self recentLocationFilePath] encoding:NSUTF8StringEncoding error:&error];
                APCLogError2(error);
                NSDictionary * dict;
                if (jsonString)
                {
                    dict = [NSDictionary dictionaryWithJSONString:jsonString];
                    _mostRecentUpdatedLocation = [[CLLocation alloc] initWithLatitude:[dict[kLat] doubleValue] longitude:[dict[kLon] doubleValue]];
                }
            }
        }
    }
    
    return _mostRecentUpdatedLocation;
}

- (void)writeDictionary:(NSDictionary*)dict toPath:(NSString*)path
{
    NSString*   dataString = [dict JSONString];
    [APCPassiveDataCollector createOrReplaceString:dataString toFile:path];
}

@end
