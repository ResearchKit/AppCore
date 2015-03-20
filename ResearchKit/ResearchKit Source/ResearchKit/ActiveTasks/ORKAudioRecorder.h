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

#import <ResearchKit/ORKRecorder.h>
#import <AVFoundation/AVFoundation.h>

ORK_ASSUME_NONNULL_BEGIN

/**
 * The ORKAudioRecorder uses the application's AVAudioSession to record audio.
 *
 * To ensure audio recording continues if a task enters the background,
 * add the "audio" tag to UIBackgroundModes in your application's Info.plist.
 */
ORK_CLASS_AVAILABLE
@interface ORKAudioRecorder : ORKRecorder

/**
 * Default audio format settings
 *
 * If no specific settings are specified, the audio configuration is
 * MPEG4 AAC, 2 channels, 16 bit, 44.1 kHz, AVAudioQualityMin.
 */
+ (NSDictionary *)defaultRecorderSettings;

/**
 * Audio format settings
 *
 * Settings for the recording session.
 * Passed to AVAudioRecorder's -initWithURL:settings:error:
 * For information on the settings available for an audio recorder, see "AV Foundation Audio Settings Constants".
 */
@property (nonatomic, copy, readonly, ORK_NULLABLE) NSDictionary *recorderSettings;

/**
 @param recorderSettings Settings for the recording session.
 @param step The step that requested this recording.
 @param outputDirectory The directory where the audio output should be stored.
 */
- (instancetype)initWithRecorderSettings:(NSDictionary *)recorderSettings
                                    step:(ORKStep *)step
                         outputDirectory:(NSURL *)outputDirectory NS_DESIGNATED_INITIALIZER;


/**
 Reference to the audio recorder being used.
 
 This is used in the audio task in order to display recorded volume in real time during the task.
 */
@property (nonatomic, strong, readonly, ORK_NULLABLE) AVAudioRecorder *audioRecorder;

@end

ORK_ASSUME_NONNULL_END
