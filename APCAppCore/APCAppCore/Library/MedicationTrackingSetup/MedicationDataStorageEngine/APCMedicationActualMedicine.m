//
//  APCMedicationActualMedicine.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationActualMedicine.h"

@implementation APCMedicationActualMedicine

- (id) init
{
    self = [super init];

    if (self)
    {
        self.name = nil;
    }

    return self;
}

- (NSString *) description
{
    NSString *result = [NSString stringWithFormat: @"Medication { name: %@ }", self.name];

    return result;
}

@end
