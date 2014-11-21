//
//  SBBDateConstraints.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBDateConstraints.h instead.
//

#import <Foundation/Foundation.h>
#import "ModelObject.h"
#import "SBBSurveyConstraints.h"

@protocol _SBBDateConstraints

@end

@interface _SBBDateConstraints : SBBSurveyConstraints

@property (nonatomic, strong) NSNumber* allowFuture;

@property (nonatomic, assign) BOOL allowFutureValue;

@property (nonatomic, strong) NSDate* earliestValue;

@property (nonatomic, strong) NSDate* latestValue;

@end
