//
//  APCMedicationPossibleDosage.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationUltraSimpleSelfInflator.h"

@interface APCMedicationPossibleDosage : APCMedicationUltraSimpleSelfInflator

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *amount;

@end
