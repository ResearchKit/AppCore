//
//  APCPassiveDisplacementTrackingSink.m
//  APCAppCore
//
//  Created by Justin Warmkessel on 4/15/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCPassiveDisplacementTrackingSink.h"

static NSString *const kCollectorFolder = @"newCollector";
static NSString *const kUploadFolder = @"upload";

static NSString *const kIdentifierKey = @"identifier";
static NSString *const kStartDateKey = @"startDate";
static NSString *const kEndDateKey = @"endDate";

static NSString *const kInfoFilename = @"info.json";
static NSString *const kCSVFilename  = @"data.csv";

@implementation APCPassiveDisplacementTrackingSink

- (void) didRecieveUpdatedValueFromCollector:(id)results
{
    __weak typeof(self) weakSelf = self;
    
    [self.healthKitCollectorQueue addOperationWithBlock:^{
        __typeof(self) strongSelf = weakSelf;
        
        if ([results isKindOfClass: [NSArray class]])
        {
            NSString *stringToWrite = [NSString stringWithFormat:@"%@,%@,%@,%@,%@\n", results[0], results[1], results[2], results[3], results[4]];
            
            //Write to file
            [APCPassiveDataSink createOrAppendString:stringToWrite
                                              toFile:[strongSelf.folder stringByAppendingPathComponent:kCSVFilename]];
        }
        
        [strongSelf checkIfDataNeedsToBeFlushed];
        
    }];
}

@end
