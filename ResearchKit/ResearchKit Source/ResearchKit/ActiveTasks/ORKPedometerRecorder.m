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

#import "ORKPedometerRecorder.h"
#import "ORKDataLogger.h"
#import "CMPedometerData+ORKJSONDictionary.h"
#import "ORKRecorder_Internal.h"
#import "ORKRecorder_Private.h"

@interface ORKPedometerRecorder()
{
    ORKDataLogger *_logger;
    BOOL _isRecording;
}

@property (nonatomic, strong) CMPedometer *pedometer;
@property (nonatomic, strong) NSError *recordingError;

@end


@implementation ORKPedometerRecorder


- (instancetype)initWithStep:(ORKStep *)step
             outputDirectory:(NSURL *)outputDirectory
{
    self = [super initWithStep:step
               outputDirectory:(NSURL *)outputDirectory];
    if (self)
    {
        self.continuesInBackground = YES;
    }
    return self;
}


- (void)dealloc
{
    [_logger finishCurrentLog];
}



- (void)_updateStatisticsWithData:(CMPedometerData *)pedometerData {
    
    _lastUpdateDate = pedometerData.endDate;
    _totalNumberOfSteps = [pedometerData.numberOfSteps integerValue];
    if (pedometerData.distance) {
        _totalDistance = [pedometerData.distance doubleValue];
    } else {
        _totalDistance = -1;
    }
    
    id delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(pedometerRecorderDidUpdate:)]) {
        [delegate pedometerRecorderDidUpdate:self];
    }
}

- (void)start {
    
    [super start];
    
    _lastUpdateDate = nil;
    _totalNumberOfSteps = 0;
    _totalDistance = -1;
    
    if (! _logger) {
        NSError *err = nil;
        _logger = [self _makeJSONDataLoggerWithError:&err];
        if (! _logger) {
            [self finishRecordingWithError:err];
            return;
        }
    }
    
    if (! [CMPedometer isStepCountingAvailable])
    {
        [self finishRecordingWithError:[NSError errorWithDomain:NSCocoaErrorDomain
                                                           code:NSFeatureUnsupportedError
                                                       userInfo:@{@"recorder" : self}]];
        return;
    }
    
    self.pedometer = [[CMPedometer alloc] init];
    
    _isRecording = YES;
    __weak __typeof(self) weakSelf = self;
    [self.pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        
        BOOL success = NO;
        if (pedometerData)
        {
            success = [_logger append:[pedometerData _ork_JSONDictionary] error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                __typeof(self) strongSelf = weakSelf;
                [strongSelf _updateStatisticsWithData:pedometerData];
            });
        }
        if (!success || error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                __typeof(self) strongSelf = weakSelf;
                [strongSelf finishRecordingWithError:error];
            });
        }
    }];
}


- (NSString *)_recorderType
{
    return @"pedometer";
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
    if (_isRecording) {
        [self.pedometer stopPedometerUpdates];
        _isRecording = NO;
        self.pedometer = nil;
    }
}

- (void)finishRecordingWithError:(NSError *)error
{
    [self _doStopRecording];
    [super finishRecordingWithError:error];
}

- (BOOL)isRecording {
    return _isRecording;
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


@interface ORKPedometerRecorderConfiguration()
@end


@implementation ORKPedometerRecorderConfiguration

- (instancetype)init {
    self = [super _init];
    return self;
}

- (ORKRecorder *)recorderForStep:(ORKStep *)step outputDirectory:(NSURL *)outputDirectory
{
    return [[ORKPedometerRecorder alloc] initWithStep:step
                                     outputDirectory:outputDirectory];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}


- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    return (isParentSame) ;
}



- (ORKPermissionMask)requestedPermissionMask {
    return ORKPermissionCoreMotionActivity;
}

@end

