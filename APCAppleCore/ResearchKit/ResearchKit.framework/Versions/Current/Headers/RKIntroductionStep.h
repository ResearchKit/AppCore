//
//  RKIntroductionStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

/**
 * @brief An introduction step is to summarize the study to be presented, motivate a participant to complete the task.
 */
@interface RKIntroductionStep : RKStep

/**
 * @brief The title content.
 */
@property (nonatomic, copy) NSString* titleText;

/**
 * @brief The description content.
 */
@property (nonatomic, copy) NSString* descriptionText;

@end
