//
//  SBBStringConstraints.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBStringConstraints.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBSurveyConstraints.h"

@protocol _SBBStringConstraints

@end

@interface _SBBStringConstraints : SBBSurveyConstraints

@property (nonatomic, strong) NSNumber* maxLength;

@property (nonatomic, assign) int64_t maxLengthValue;

@property (nonatomic, strong) NSNumber* minLength;

@property (nonatomic, assign) int64_t minLengthValue;

@property (nonatomic, strong) NSString* pattern;

@end
