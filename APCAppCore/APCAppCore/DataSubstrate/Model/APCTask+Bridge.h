// 
//  APCTask+Bridge.h 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//   Copyright (c) 2014 Apple Inc. All rights reserved.
// 
 
#import <APCAppCore/APCAppCore.h>

@interface APCTask (Bridge)

+ (void) refreshSurveysOnCompletion: (void (^)(NSError * error)) completionBlock;
- (void) loadSurveyOnCompletion: (void (^)(NSError * error)) completionBlock;
+ (ORKOrderedTask*) rkTaskFromSBBSurvey: (SBBSurvey*) survey;
@end
