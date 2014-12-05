//
//  SBBDecimalConstraints.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBDecimalConstraints.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBSurveyConstraints.h"

@protocol _SBBDecimalConstraints

@end

@interface _SBBDecimalConstraints : SBBSurveyConstraints

@property (nonatomic, strong) NSNumber* maxValue;

@property (nonatomic, assign) double maxValueValue;

@property (nonatomic, strong) NSNumber* minValue;

@property (nonatomic, assign) double minValueValue;

@property (nonatomic, strong) NSNumber* step;

@property (nonatomic, assign) double stepValue;

@end
