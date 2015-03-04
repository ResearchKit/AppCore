//
//  APCMedicationLozenge.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APCMedicationWeeklySchedule;
@class APCMedicationDosageTaken;

@interface APCMedicationLozenge : NSObject

@property (nonatomic, strong) APCMedicationWeeklySchedule *schedule;
@property (nonatomic, assign) NSNumber *dosesTakenSoFar;
@property (nonatomic, assign) NSNumber *maxNumberOfDoses;
@property (nonatomic, strong) NSNumber *zeroBasedDayOfTheWeek;
@property (readonly) BOOL isComplete;

+ (instancetype) lozengeWithSchedule: (APCMedicationWeeklySchedule *) schedule
                        dayOfTheWeek: (NSNumber *) zeroBasedDayOfTheWeek
                    maxNumberOfDoses: (NSNumber *) maxNumberOfDoses;

/**
 Records the fact that the user clicked an "I took a dose" button.
 Saves that fact to disk, in the history file.

 Returns the dosage taken object for convenience, but please
 do NOT save it yourself.
 */
- (APCMedicationDosageTaken *) takeDoseNowAndSave;

@end
