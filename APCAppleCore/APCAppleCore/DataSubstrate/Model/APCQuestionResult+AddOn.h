//
//  APCQuestionResult+AddOn.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/12/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCQuestionResult.h"
#import <ResearchKit/ResearchKit.h>

@interface APCQuestionResult (AddOn)

@property (nonatomic, readonly) RKSurveyQuestionType questionType;
@property (nonatomic, readonly) NSObject * answer;

@end
