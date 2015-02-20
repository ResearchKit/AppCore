//
//  APCMedicationPossibleDosage.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationPossibleDosage.h"

@implementation APCMedicationPossibleDosage

- (id) init
{
    self = [super init];

    if (self)
    {
        self.name = nil;
        self.amount = nil;
    }

    return self;
}

- (NSString *) description
{
    NSString *result = [NSString stringWithFormat: @"PossibleDosage { name: %@, amount: %@ }", self.name, self.amount];

    return result;
}

@end
