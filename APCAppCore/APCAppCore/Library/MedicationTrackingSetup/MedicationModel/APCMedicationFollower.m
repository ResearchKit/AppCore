//
//  APCMedicationFollower.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationFollower.h"
#import "APCMedicationModel.h"

@implementation APCMedicationFollower

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _medicationName        = @"Unknown Medication";
        _numberOfDosesPrescribed = [NSNumber numberWithInteger:0];
        _numberOfDosesTaken  = [NSNumber numberWithInteger:0];
    }
    return  self;
}

@end
