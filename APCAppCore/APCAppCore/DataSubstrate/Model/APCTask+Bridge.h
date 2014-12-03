//
//  APCTask+Bridge.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 10/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <APCAppleCore/APCAppleCore.h>

@interface APCTask (Bridge)

+ (void) refreshSurveys;
- (void) loadSurveyOnCompletion: (void (^)(NSError * error)) completionBlock;
+ (RKSTOrderedTask*) rkTaskFromSBBSurvey: (SBBSurvey*) survey;
@end
