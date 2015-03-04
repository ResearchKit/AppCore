//
//  ORKQuestionResult+APCHelper.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@interface ORKQuestionResult (APCHelper)

- (id) consolidatedAnswer;
- (BOOL) validForApplyingRule;

@end
