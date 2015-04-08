//
//  APCPassiveHealthKitSleepSink.m
//  APCAppCore
//
//  Created by Justin Warmkessel on 4/8/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCPassiveHealthKitSleepSink.h"
#import "APCAppCore.h"

static NSString *const kCollectorFolder = @"newCollector";
static NSString *const kUploadFolder = @"upload";

static NSString *const kIdentifierKey = @"identifier";
static NSString *const kStartDateKey = @"startDate";
static NSString *const kEndDateKey = @"endDate";

static NSString *const kInfoFilename = @"info.json";
static NSString *const kCSVFilename  = @"data.csv";

@implementation APCPassiveHealthKitSleepSink

/**********************************************************************/
#pragma mark - APCCollectorProtocol Delegate Methods
/**********************************************************************/

- (void) didRecieveArrayOfValuesFromHealthKitCollector:(NSArray*)quantitySamples {
    
    [quantitySamples enumerateObjectsUsingBlock: ^(id quantitySample, NSUInteger __unused idx, BOOL * __unused stop) {
        
        [self processUpdatesFromHealthKitForSampleType:quantitySample];
        
    }];
}

- (void) didRecieveUpdatedValueFromHealthKitCollector:(id)quantitySample {
    
    [self processUpdatesFromHealthKitForSampleType:quantitySample];
}


/**********************************************************************/
#pragma mark - Helper Methods
/**********************************************************************/


- (void) processUpdatesFromHealthKitForSampleType:(id)quantitySample {
    [self.healthKitCollectorQueue addOperationWithBlock:^{

        NSString *dateTimeStamp = [[NSDate date] toStringInISO8601Format];
        NSString *healthKitType = nil;
        NSString *quantityValue = nil;
        NSString *quantitySource = nil;
        
        
        HKCategorySample *catSample = (HKCategorySample *)quantitySample;
        healthKitType = catSample.categoryType.identifier;
        quantityValue = [NSString stringWithFormat:@"%ld", (long)catSample.value];
        
        // Get the difference in seconds between the start and end date for the sample
        NSDateComponents *secondsSpentInBedOrAsleep = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond
                                                                                      fromDate:catSample.startDate
                                                                                        toDate:catSample.endDate
                                                                                       options:NSCalendarWrapComponents];
        if (catSample.value == HKCategoryValueSleepAnalysisInBed) {
            quantityValue = [NSString stringWithFormat:@"%ld,seconds in bed", (long)secondsSpentInBedOrAsleep.second];
        } else if (catSample.value == HKCategoryValueSleepAnalysisAsleep) {
            quantityValue = [NSString stringWithFormat:@"%ld,seconds asleep", (long)secondsSpentInBedOrAsleep.second];
        }
    
        NSString *stringToWrite = [NSString stringWithFormat:@"%@,%@,%@,%@\n", dateTimeStamp, healthKitType, quantityValue, quantitySource];
        
        //Write to file
        [APCPassiveDataSink createOrAppendString:stringToWrite
                                          toFile:[self.folder stringByAppendingPathComponent:kCSVFilename]];
        
        [self checkIfDataNeedsToBeFlushed];
        
    }];
}

@end
