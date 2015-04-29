// 
//  APCDataTracker.m 
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
 
#import "APCDataTracker.h"

long long kKBPerMB = 1024;
long long kBytesPerKB = 1024;

NSUInteger kSecsPerMin = 60;
NSUInteger kMinsPerHour = 60;
NSUInteger kHoursPerDay = 24;
NSUInteger kDaysPerWeek = 7;

@interface APCDataTracker ()
@property (nonatomic, strong) NSString * identifier;
@end

@implementation APCDataTracker

-(instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        NSAssert(identifier.length > 0, @"Valid identifier missing");
        _identifier = identifier;
    }
    return self;
}

/*********************************************************************************/
#pragma mark - Abstract Implementations
/*********************************************************************************/

- (unsigned long long)sizeThreshold
{
    if (_sizeThreshold == 0) {
        _sizeThreshold = 50 * kBytesPerKB;
    }
    return _sizeThreshold;
}

- (NSTimeInterval)stalenessInterval
{
    if (_stalenessInterval == 0) {
        _stalenessInterval = 1 * kHoursPerDay * kMinsPerHour * kSecsPerMin;
    }
    return _stalenessInterval;
}

- (NSArray*) columnNames
{
    NSAssert(NO, @"Column names missing");
    return nil;
}

- (void) startTracking
{
    //Abstract implementation
}

- (void) stopTracking
{
    //Abstract implementation
}

- (void) updateTracking
{
    //Abstract implementation
}

@end
