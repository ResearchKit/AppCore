//
//  SBBSurvey.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSurvey.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

@protocol _SBBSurvey

@end

@interface _SBBSurvey : SBBBridgeObject

@property (nonatomic, strong) NSDate* createdOn;

@property (nonatomic, strong) NSArray* elements;

//YML EDIT - START
@property (nonatomic, strong) NSArray* questions;
//YML EDIT - END

@property (nonatomic, strong) NSString* guid;

@property (nonatomic, strong) NSString* identifier;

@property (nonatomic, strong) NSDate* modifiedOn;

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSNumber* published;

@property (nonatomic, assign) BOOL publishedValue;

@property (nonatomic, strong) NSNumber* version;

@property (nonatomic, assign) double versionValue;

@end
