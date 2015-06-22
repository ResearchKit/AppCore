//
//  CLLocation+APCAdditions.m
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

#import "CLLocation+APCAdditions.h"

static double DegreesToRadians(double degrees) {return degrees * M_PI / 180;};
static double RadiansToDegrees(double radians) {return radians * 180/M_PI;};

@implementation CLLocation (APCAdditions)

- (double)bearingToLocation:(CLLocation*)destinationLocation
{
    double lat1             = DegreesToRadians(self.coordinate.latitude);
    double lon1             = DegreesToRadians(self.coordinate.longitude);
    double lat2             = DegreesToRadians(destinationLocation.coordinate.latitude);
    double lon2             = DegreesToRadians(destinationLocation.coordinate.longitude);
    double dLon             = lon2 - lon1;
    double y                = sin(dLon) * cos(lat2);
    double x                = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double radiansBearing   = atan2(y, x);
    
    return RadiansToDegrees(radiansBearing);
}

- (double)calculateDirectionFromLocation:(CLLocation*)destinationLocation
{
    double lat1             = DegreesToRadians(self.coordinate.latitude);
    double lon1             = DegreesToRadians(self.coordinate.longitude);
    double lat2             = DegreesToRadians(destinationLocation.coordinate.latitude);
    double lon2             = DegreesToRadians(destinationLocation.coordinate.longitude);
    double latDeltaSquared  = lat2 - lat1;
    double lonDeltaSquared  = lon2 - lon1;
    
    return atan2(latDeltaSquared, lonDeltaSquared);
}

@end
