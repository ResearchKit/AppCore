//
//  SBBDateTimeConstraints.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBDateTimeConstraints.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBSurveyConstraints.h"

@protocol _SBBDateTimeConstraints

@end

@interface _SBBDateTimeConstraints : SBBSurveyConstraints

@property (nonatomic, strong) NSNumber* allowFuture;

@property (nonatomic, assign) BOOL allowFutureValue;

@property (nonatomic, strong) NSDate* earliestValue;

@property (nonatomic, strong) NSDate* latestValue;

@end
