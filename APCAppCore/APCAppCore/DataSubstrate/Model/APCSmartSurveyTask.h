//
//  APCSmartSurveyTask.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ResearchKit.h>

@class SBBSurvey;
@interface APCSmartSurveyTask : NSObject <ORKTask>

@property (nonatomic, copy, readonly) NSString * identifier;

-(instancetype)initWithIdentifier: (NSString*) identifier survey:(SBBSurvey *)survey;


@end
