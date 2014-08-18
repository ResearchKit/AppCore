//
//  RKAudioRecorder.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import "RKRecorder.h"

/**
 * @brief The RKAudioRecorder use AVAudioSession to record audio.
 * 
 * The audio configuration is MPEG4 AAC, 2 channels, 16 bit, 44.1 kHz, AVAudioQualityMin.
 */
@interface RKAudioRecorder : RKRecorder


@end

/**
 * @brief RKAudioRecorderConfiguration implements RKRecorderConfiguration and able to generate RKAudioRecorder instance.
 */
@interface RKAudioRecorderConfiguration: NSObject<RKRecorderConfiguration>

+ (instancetype)configuration;

@end