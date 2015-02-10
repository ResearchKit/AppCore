// 
//  APCTask+Bridge.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <APCAppCore/APCAppCore.h>

@interface APCTask (Bridge)

+ (void) refreshSurveysOnCompletion: (void (^)(NSError * error)) completionBlock;
- (void) loadSurveyOnCompletion: (void (^)(NSError * error)) completionBlock;
+ (RKSTOrderedTask*) rkTaskFromSBBSurvey: (SBBSurvey*) survey;
@end
