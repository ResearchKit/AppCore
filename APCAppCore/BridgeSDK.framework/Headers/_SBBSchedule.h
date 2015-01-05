//
//  SBBSchedule.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBSchedule.h instead.
//

#import <Foundation/Foundation.h>
#import "SBBBridgeObject.h"

@protocol _SBBSchedule

@end

@interface _SBBSchedule : SBBBridgeObject

@property (nonatomic, strong) NSArray* activities;

@property (nonatomic, strong) NSString* activityRef;

@property (nonatomic, strong) NSString* activityType;

@property (nonatomic, strong) NSString* cronTrigger;

@property (nonatomic, strong) NSDate* endsOn;

@property (nonatomic, strong) NSString* expires;

@property (nonatomic, strong) NSString* label;

@property (nonatomic, strong) NSString* scheduleType;

@property (nonatomic, strong) NSDate* startsOn;

@end
