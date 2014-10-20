//
//  SBBSurveyResponse.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyResponse.h instead.
//

#import <Foundation/Foundation.h>
#import "ModelObject.h"
#import "SBBBridgeObject.h"

#import "SBBSurvey.h"

@protocol _SBBSurveyResponse

@end

@interface _SBBSurveyResponse : SBBBridgeObject

@property (nonatomic, strong) NSArray* answers;

@property (nonatomic, strong) NSDate* completedOn;

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSDate* startedOn;

@property (nonatomic, strong) NSString* status;

@property (nonatomic, strong) SBBSurvey* survey;

@end
