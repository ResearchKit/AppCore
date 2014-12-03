//
//  APCTask+Bridge.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 10/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <APCAppCore/APCAppCore.h>

@interface APCTask (Bridge)

+ (void) refreshSurveys;
- (void) loadSurveyOnCompletion: (void (^)(NSError * error)) completionBlock;
+ (RKSTOrderedTask*) rkTaskFromSBBSurvey: (SBBSurvey*) survey;
@end
