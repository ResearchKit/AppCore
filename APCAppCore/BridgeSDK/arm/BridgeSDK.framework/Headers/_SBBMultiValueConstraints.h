//
//  SBBMultiValueConstraints.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBMultiValueConstraints.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBSurveyConstraints.h"

@protocol _SBBMultiValueConstraints

@end

@interface _SBBMultiValueConstraints : SBBSurveyConstraints

@property (nonatomic, strong) NSNumber* allowMultiple;

@property (nonatomic, assign) BOOL allowMultipleValue;

@property (nonatomic, strong) NSNumber* allowOther;

@property (nonatomic, assign) BOOL allowOtherValue;

@property (nonatomic, strong) NSArray* enumeration;

@end
