//
//  SBBSurveyQuestion.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyQuestion.h instead.
//

#import <Foundation/Foundation.h>
#import "ModelObject.h"
#import "SBBBridgeObject.h"

#import "SBBSurveyConstraints.h"

@protocol _SBBSurveyQuestion

@end

@interface _SBBSurveyQuestion : SBBBridgeObject

@property (nonatomic, strong) SBBSurveyConstraints* constraints;

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSString* identifier;

@property (nonatomic, strong) NSString* prompt;

@property (nonatomic, strong) NSString* uiHint;

@end
