//
//  APCMedicationPossibleDosage.m
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
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
    NSString *result = [NSString stringWithFormat: @"PossibleDosage { name: %@, uniqueId: %d, amount: %@ }", self.name, self.uniqueId.intValue, self.amount];

    return result;
}

@end
