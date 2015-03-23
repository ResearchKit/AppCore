/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ORKDeviceMotionRecorder.h"
#import "ORKHelpers.h"
#import "ORKRecorder_Internal.h"
#import "ORKRecorder_Private.h"
#import "ORKDataLogger.h"
#import <CoreMotion/CoreMotion.h>
#import "CMDeviceMotion+ORKJSONDictionary.h"

@interface ORKDeviceMotionRecorder()
{
    ORKDataLogger *_logger;
}

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic) NSTimeInterval uptime;

@end


@implementation ORKDeviceMotionRecorder


- (instancetype)initWithFrequency:(double)frequency
                             step:(ORKStep *)step
                  outputDirectory:(NSURL *)outputDirectory
{
    self = [super initWithStep:step
               outputDirectory:(NSURL *)outputDirectory];
    if (self)
    {
        self.frequency = frequency;
        self.continuesInBackground = YES;
    }
    return self;
}


- (void)dealloc
{
    [_logger finishCurrentLog];
}

- (void)setFrequency:(double)frequency
{
    if (frequency <= 0)
    {
        _frequency = 1;
    }
    else
    {
        _frequency = frequency;
    }
}

- (void)start {
    
    [super start];
    
    if (! _logger) {
        NSError *err = nil;
        _logger = [self _makeJSONDataLoggerWithError:&err];
        if (! _logger) {
            [self finishRecordingWithError:err];
            return;
        }
    }
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0/_frequency;
    
    self.uptime = [NSProcessInfo processInfo].systemUptime;
    
    [self.motionManager stopDeviceMotionUpdates];
    
    [self.motionManager
     startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
     withHandler:^(CMDeviceMotion *data, NSError *error)
     {
         BOOL success = NO;
         if (data)
         {
             success = [_logger append:[data _ork_JSONDictionary] error:&error];
         }
         if (!success)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self finishRecordingWithError:error];
             });
         }
     }];
}


- (NSString *)_recorderType
{
    return @"deviceMotion";
}


- (void)stop {
    [self _doStopRecording];
    [_logger finishCurrentLog];
    
    NSError *error = nil;
    __block NSURL *fileUrl = nil;
    [_logger enumerateLogs:^(NSURL *logFileUrl, BOOL *stop) {
        fileUrl = logFileUrl;
    } error:&error];
    
    [self _reportFileResultWithFile:fileUrl error:error];
    
    [super stop];
}

- (void)_doStopRecording
{
    if (self.isRecording) {
        [self.motionManager stopDeviceMotionUpdates];
        self.motionManager = nil;
    }
}

- (void)finishRecordingWithError:(NSError *)error
{
    [self _doStopRecording];
    [super finishRecordingWithError:error];
}

- (BOOL)isRecording {
    return self.motionManager.deviceMotionActive;
}

- (NSString *)mimeType {
    return @"application/json";
}

- (void)_reset
{
    [super _reset];
    
    _logger = nil;
}

@end


@interface ORKDeviceMotionRecorderConfiguration()
@end


@implementation ORKDeviceMotionRecorderConfiguration

- (instancetype)initWithFrequency:(double)freq {
    self = [super _init];
    if (self) {
        _frequency = freq;
    }
    return self;
}

- (ORKRecorder *)recorderForStep:(ORKStep *)step outputDirectory:(NSURL *)outputDirectory
{
    return [[ORKDeviceMotionRecorder alloc] initWithFrequency:self.frequency
                                                        step:step
                                             outputDirectory:(NSURL *)outputDirectory];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        ORK_DECODE_DOUBLE(aDecoder, frequency);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, frequency);
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.frequency == castObject.frequency)) ;
}

- (ORKPermissionMask)requestedPermissionMask {
    return ORKPermissionCoreMotionAccelerometer;
}

@end
