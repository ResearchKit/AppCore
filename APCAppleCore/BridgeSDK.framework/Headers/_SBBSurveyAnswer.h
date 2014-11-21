//
//  SBBSurveyAnswer.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyAnswer.h instead.
//

#import <Foundation/Foundation.h>
#import "ModelObject.h"
#import "SBBBridgeObject.h"

@protocol _SBBSurveyAnswer

@end

@interface _SBBSurveyAnswer : SBBBridgeObject

@property (nonatomic, strong) NSString* answer;

@property (nonatomic, strong) NSDate* answeredOn;

@property (nonatomic, strong) NSString* client;

@property (nonatomic, strong) NSNumber* declined;

@property (nonatomic, assign) BOOL declinedValue;

@property (nonatomic, strong) NSString* questionGuid;

@end
