// 
//  APCDisplacementTrackingCollector.m 
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
#import "APCDisplacementTrackingCollector.h"

@interface APCDisplacementTrackingCollector () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation  *baseTrackingLocation;
@property (nonatomic, strong) CLLocation  *mostRecentUpdatedLocation;
@property (nonatomic, assign) BOOL deferringUpdates;

@end


@implementation APCDisplacementTrackingCollector

- (instancetype)initWithIdentifier:(NSString*)identifier deferredUpdatesTimeout:(NSTimeInterval) __unused anUpdateTimeout
{
    APCLogDebug(@"Initalizing location tracker");
    
    self = [super initWithIdentifier:identifier dateAnchorName:nil launchDateAnchor:nil];
    
    if (self != nil)
    {
        _deferringUpdates = NO;
        
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
    _baseTrackingLocation       = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    _mostRecentUpdatedLocation  = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
}

- (void)start
{
    if ([CLLocationManager locationServicesEnabled])
    {
        if (!self.locationManager)
        {
            APCLogDebug(@"Start location tracking");
            
            self.locationManager            = [[CLLocationManager alloc] init];
            self.locationManager.delegate   = self;
            
            if ([CLLocationManager significantLocationChangeMonitoringAvailable] &&
                [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
            {
                APCLogDebug(@"Significant Location Change Monitoring is Available");
                
                [self.locationManager startMonitoringSignificantLocationChanges];
            }
        }
    }
}

- (void)stop
{
    if ([CLLocationManager locationServicesEnabled])
    {
        if ([CLLocationManager significantLocationChangeMonitoringAvailable])
        {
            [self.locationManager stopMonitoringSignificantLocationChanges];
        }
    }
}

/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/

- (void)updateArchiveDataWithLocationManager:(CLLocationManager*)manager withUpdateLocations:(NSArray*)locations
{
    //Send to delegate
    if ([self.delegate respondsToSelector:@selector(didReceiveUpdateWithLocationManager:withUpdateLocations:)])
    {
        [self.delegate didReceiveUpdateWithLocationManager:manager withUpdateLocations:locations];
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

- (void)locationManager:(CLLocationManager*) __unused manager didFinishDeferredUpdatesWithError:(NSError*) error
{
    if (error != nil)
    {
        APCLogError2(error);
    }
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

@end
