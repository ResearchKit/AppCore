//
//  SBBIntegerConstraints.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBIntegerConstraints.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBSurveyConstraints.h"

@protocol _SBBIntegerConstraints

@end

@interface _SBBIntegerConstraints : SBBSurveyConstraints

@property (nonatomic, strong) NSNumber* maxValue;

@property (nonatomic, assign) int64_t maxValueValue;

@property (nonatomic, strong) NSNumber* minValue;

@property (nonatomic, assign) int64_t minValueValue;

@property (nonatomic, strong) NSNumber* step;

@property (nonatomic, assign) int64_t stepValue;

@property (nonatomic, strong) NSString* unit;

@end
