//
//  APCPassiveDisplacementTrackingSink.m
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

#import "APCPassiveDisplacementTrackingDataUploader.h"
#import <CoreLocation/CoreLocation.h>

static  NSString* const kCollectorFolder                        = @"newCollector";
static  NSString* const kUploadFolder                           = @"upload";
static  NSString* const kIdentifierKey                          = @"identifier";
static  NSString* const kStartDateKey                           = @"startDate";
static  NSString* const kEndDateKey                             = @"endDate";
static  NSString* const kInfoFilename                           = @"info.json";
static  NSString* const kCSVFilename                            = @"data.csv";
static  NSString* const kLocationTimeStamp                      = @"timestamp";
static  NSString* const kLocationDistanceFromPreviousLocation   = @"distanceFromPreviousLocation";
static  NSString* const kLocationVerticalAccuracy               = @"verticalAccuracy";
static  NSString* const kLocationHorizontalAccuracy             = @"horizontalAccuracy";
static  NSString* const kLocationDistanceUnit                   = @"distanceUnit"; //Always meters
static  NSString* const kBaseTrackingFileName                   = @"baseTrackingLocation";
static  NSString* const kRecentLocationFileName                 = @"recentLocation";
static  NSString* const kLat                                    = @"lat";
static  NSString* const kLon                                    = @"lon";

@interface APCPassiveDisplacementTrackingDataUploader ()

@property (nonatomic, strong) CLLocation* baseTrackingLocation;
@property (nonatomic, strong) CLLocation* mostRecentUpdatedLocation;

@end

@implementation APCPassiveDisplacementTrackingDataUploader

@synthesize baseTrackingLocation = _baseTrackingLocation;
@synthesize mostRecentUpdatedLocation = _mostRecentUpdatedLocation;

- (NSArray*)locationDictionaryWithLocationManager:(CLLocationManager*)manager
                       distanceFromReferencePoint:(CLLocationDistance)distanceFromReferencePoint
                              andPreviousLocation:(CLLocation*)previousLocation
{
    NSString*   timestamp               = manager.location.timestamp.description;
    NSString*   distance                = [NSString stringWithFormat:@"%f", distanceFromReferencePoint];
    NSString*   unit                    = @"meters"; //Hardcoded as Core Locations uses only meters
    double      direction               = [previousLocation calculateDirectionFromLocation:manager.location];
    NSString*   directionUnit           = @"radians"; //Not a user facing constant
    
    //  A negative value of manager.location.speed indicates an invalid speed.
    NSString*   speed                   = nil;
    
    if (manager.location.speed >= 0)
    {
        double pace = manager.location.speed;
        speed = [NSString stringWithFormat:@"%f", pace];
    }
    else
    {
        speed = NSLocalizedString(@"invalid speed", nil);
    }

    NSString*   speedUnit               = @"meters/second"; //Not a user facing constant
    NSString*   floor                   = nil;
    
    //  A nil value of manager.location.floor indicates that this info is unavailable.
    if (manager.location.floor == nil)
    {
        floor = NSLocalizedString(@"not available", nil);
    }
    else
    {
        NSInteger level = manager.location.floor.level;
        floor = [NSString stringWithFormat:@"%ld", (long)level];
    }
    
    //  Altitude of the location can be positive (above sea level) or negative (below sea level).
    double      altitude                = manager.location.altitude;
    NSString*   altitudeUnit            = @"meters";
    NSString*   horizontalAccuracy      = [NSString stringWithFormat:@"%f", manager.location.horizontalAccuracy];
    NSString*   horizontalAccuracyUnit  = @"meters";
    NSString*   verticalAccuracy        = [NSString stringWithFormat:@"%f", manager.location.verticalAccuracy];
    NSString*   verticalAccuracyUnit    = @"meters";
    
    return  @[timestamp, distance, unit, @(direction), directionUnit, speed, speedUnit, floor, @(altitude), altitudeUnit, horizontalAccuracy, horizontalAccuracyUnit, verticalAccuracy, verticalAccuracyUnit];
}


- (void)didRecieveUpdateWithLocationManager:(CLLocationManager*)manager withUpdateLocations:(NSArray*)locations
{
    __weak typeof(self) weakSelf = self;
    
    [self.healthKitCollectorQueue addOperationWithBlock:^
    {
        __typeof(self)  strongSelf  = weakSelf;
        NSArray*        result      = nil;
        
        if ((self.baseTrackingLocation.coordinate.latitude == 0.0) && (self.baseTrackingLocation.coordinate.longitude == 0.0))
        {
            self.baseTrackingLocation = [locations firstObject];
            self.mostRecentUpdatedLocation = self.baseTrackingLocation;
            
            if ([locations count] >= 1)
            {
                CLLocationDistance  distanceFromReferencePoint = [self.baseTrackingLocation distanceFromLocation:manager.location];
                
                result = [self locationDictionaryWithLocationManager:manager
                                          distanceFromReferencePoint:distanceFromReferencePoint
                                                 andPreviousLocation:self.baseTrackingLocation];
            }
        }
        else
        {
            self.baseTrackingLocation = self.mostRecentUpdatedLocation;
            self.mostRecentUpdatedLocation = manager.location;
            
            CLLocationDistance  distanceFromReferencePoint = [self.baseTrackingLocation distanceFromLocation:manager.location];
            result = [self locationDictionaryWithLocationManager:manager
                                      distanceFromReferencePoint:distanceFromReferencePoint
                                             andPreviousLocation:self.baseTrackingLocation];
        }
        
        //Send to delegate
        if (result)
        {  
            NSString *stringToWrite = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
                                                                   result[0],
                                                                   result[1],
                                                                   result[2],
                                                                   result[3],
                                                                   result[4],
                                                                   result[5],
                                                                   result[6],
                                                                   result[7],
                                                                   result[8],
                                                                   result[9],
                                                                   result[10],
                                                                   result[11],
                                                                   result[12],
                                                                   result[13]];

            //Write to file
            [APCPassiveDataSink createOrAppendString:stringToWrite
                                              toFile:[strongSelf.folder stringByAppendingPathComponent:kCSVFilename]];
            
            [strongSelf checkIfDataNeedsToBeFlushed];
        }        
    }];
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

- (void)setBaseTrackingLocation:(CLLocation*)baseTrackingLocation
{
    _baseTrackingLocation = baseTrackingLocation;
    
    NSDictionary* dict = @{kLat : @(baseTrackingLocation.coordinate.latitude), kLon : @(baseTrackingLocation.coordinate.longitude)};
    
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
                NSError*    error       = nil;
                NSString*   jsonString  = [NSString stringWithContentsOfFile:[self baseTrackingFilePath]
                                                                    encoding:NSUTF8StringEncoding
                                                                       error:&error];
                if (error || !jsonString)
                {
                    APCLogError2(error);
                }
                else
                {
                    NSDictionary* dict      = nil;
                
                    dict                    = [NSDictionary dictionaryWithJSONString:jsonString];
                    _baseTrackingLocation   = [[CLLocation alloc] initWithLatitude:[dict[kLat] doubleValue]
                                                                         longitude:[dict[kLon] doubleValue]];
                }
            }
        }
    }
    
    return _baseTrackingLocation;
}

- (void)setMostRecentUpdatedLocation:(CLLocation*)mostRecentUpdatedLocation
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
                NSError*    error       = nil;
                NSString*   jsonString  = [NSString stringWithContentsOfFile:[self recentLocationFilePath]
                                                                    encoding:NSUTF8StringEncoding
                                                                       error:&error];
                
                if (error || !jsonString)
                {
                    APCLogError2(error);
                }
                else
                {
                    NSDictionary* dict      = nil;

                    dict                        = [NSDictionary dictionaryWithJSONString:jsonString];
                    _mostRecentUpdatedLocation  = [[CLLocation alloc] initWithLatitude:[dict[kLat] doubleValue]
                                                                             longitude:[dict[kLon] doubleValue]];
                }
            }
        }
    }
    
    return _mostRecentUpdatedLocation;
}

- (void)writeDictionary:(NSDictionary*)dict toPath:(NSString*)path
{
    NSString*   dataString = [dict JSONString];
    [APCPassiveDisplacementTrackingDataUploader createOrReplaceString:dataString toFile:path];
}


@end
