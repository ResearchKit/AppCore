//
//  RKAudioRecorder.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/RKRecorder.h>

/**
 * @brief The RKAudioRecorder use AVAudioSession to record audio.
 *
 * To ensure audio recording continues if a task enters the background, the
 * application should add the "audio" tag to UIBackgroundModes in its Info.plist.
 */
@interface RKAudioRecorder : RKRecorder

/**
 * @brief Default audio format settings
 *
 * If no specific settings are specified, the audio configuration is
 * MPEG4 AAC, 2 channels, 16 bit, 44.1 kHz, AVAudioQualityMin.
 */
+ (NSDictionary *)defaultRecorderSettings;

/**
 * @brief Audio format settings
 *
 * Settings for the recording session.
 * Passed to AVAudioRecorder's -initWithURL:settings:error:
 * For information on the settings available for an audio recorder, see "AV Foundation Audio Settings Constants".
 */
@property (nonatomic, copy, readonly) NSDictionary *recorderSettings;

/**
 * @brief Designated initializer
 * @param recorderSettings Settings for the recording session.
 */
- (instancetype)initWithRecorderSettings:(NSDictionary *)recorderSettings step:(RKStep*)step taskInstanceUUID:(NSUUID*)taskInstanceUUID;


@end

/**
 * @brief RKAudioRecorderConfiguration implements RKRecorderConfiguration and able to generate RKAudioRecorder instance.
 */
@interface RKAudioRecorderConfiguration: NSObject<RKRecorderConfiguration>

/**
 * @brief Audio format settings
 * 
 * Settings for the recording session.
 * Passed to AVAudioRecorder's -initWithURL:settings:error:
 * For information on the settings available for an audio recorder, see "AV Foundation Audio Settings Constants".
 */
@property (nonatomic, readonly) NSDictionary *recorderSettings;

/**
 * @brief Designated initializer
 * @param recorderSettings Settings for the recording session.
 * @note For information on the settings available for an audio recorder, see "AV Foundation Audio Settings Constants".
 */
- (instancetype)initWithRecorderSettings:(NSDictionary *)recorderSettings;

@end
