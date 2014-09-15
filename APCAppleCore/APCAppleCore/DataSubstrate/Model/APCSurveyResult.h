//
//  APCSurveyResult.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/12/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "APCResult.h"

@class APCQuestionResult;

@interface APCSurveyResult : APCResult

@property (nonatomic, retain) NSSet *surveyResults;
@end

@interface APCSurveyResult (CoreDataGeneratedAccessors)

- (void)addSurveyResultsObject:(APCQuestionResult *)value;
- (void)removeSurveyResultsObject:(APCQuestionResult *)value;
- (void)addSurveyResults:(NSSet *)values;
- (void)removeSurveyResults:(NSSet *)values;

@end
