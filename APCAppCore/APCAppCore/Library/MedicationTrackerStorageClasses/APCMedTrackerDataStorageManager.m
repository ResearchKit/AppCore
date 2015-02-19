//
//  APCMedTrackerDataStorageManager.m
//  APCAppCore
//
//  Created by Ron Conescu on 2/18/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedTrackerDataStorageManager.h"
#import "APCMedTrackerMedication+Helper.h"
#import "APCMedTrackerScheduleColor+Helper.h"
#import "APCMedTrackerPossibleDosage+Helper.h"


static NSString * const FILE_WITH_PREDEFINED_MEDICATIONS = @"APCMedTrackerPredefinedMedications.plist";
static NSString * const FILE_WITH_PREDEFINED_SCHEDULE_COLORS = @"APCMedTrackerPredefinedScheduleColors.plist";
static NSString * const FILE_WITH_PREDEFINED_POSSIBLE_DOSAGES = @"APCMedTrackerPredefinedPossibleDosages.plist";


@implementation APCMedTrackerDataStorageManager

+ (void) reloadPredefinedItemsFromPlistFilesUsingQueue: (NSOperationQueue *) queue
                                     andDoThisWhenDone: (APCMedTrackerFileLoadCallback) callbackBlock
{
    [APCMedTrackerMedication reloadAllFromPlistFileNamed: FILE_WITH_PREDEFINED_MEDICATIONS
                                              usingQueue: queue
                                       andDoThisWhenDone: NULL];

    [APCMedTrackerScheduleColor reloadAllFromPlistFileNamed: FILE_WITH_PREDEFINED_SCHEDULE_COLORS
                                                 usingQueue: queue
                                          andDoThisWhenDone: NULL];

    [APCMedTrackerPossibleDosage reloadAllFromPlistFileNamed: FILE_WITH_PREDEFINED_POSSIBLE_DOSAGES
                                                  usingQueue: queue
                                           andDoThisWhenDone: callbackBlock];
}

@end
