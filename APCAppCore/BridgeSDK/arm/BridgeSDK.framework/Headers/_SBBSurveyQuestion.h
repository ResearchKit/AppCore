//
//  SBBSurveyQuestion.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurveyQuestion.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBSurveyElement.h"

#import "SBBSurveyConstraints.h"

@protocol _SBBSurveyQuestion

@end

@interface _SBBSurveyQuestion : SBBSurveyElement

@property (nonatomic, strong) SBBSurveyConstraints* constraints;

@property (nonatomic, strong) NSString* uiHint;

@end
