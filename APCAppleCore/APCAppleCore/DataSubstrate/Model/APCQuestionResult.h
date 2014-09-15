//
//  APCQuestionResult.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 9/12/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "APCResult.h"

@class APCSurveyResult;

@interface APCQuestionResult : APCResult

@property (nonatomic, retain) NSNumber * questionTypeStore;
@property (nonatomic, retain) NSString * stringAnswer;
@property (nonatomic, retain) NSNumber * integerAnswer;
@property (nonatomic, retain) NSNumber * floatAnswer;
@property (nonatomic, retain) APCSurveyResult *survey;

@end
