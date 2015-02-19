//
//  APCMedicationModel.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationModel.h"

@implementation APCMedicationModel

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _medicationName        = NSLocalizedString(@"Unknown Medication", nil);
        _medicationLabelColor  = NSLocalizedString(@"Gray", nil);
        _frequencyAndDays   =    nil;
        _medicationDosageValue = [NSNumber numberWithInteger:0];
        _medicationDosageText  = @"0\u2008mg";
    }
    return  self;
}

@end
