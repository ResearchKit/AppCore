//
//  APCPassiveCoreActivityManagerSink.m
//  APCAppCore
//
// Copyright (c) 2015, Apple Inc. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "APCPassiveCoreActivityManagerSink.h"
#import "APCAppCore.h"
#import "zipzap.h"
#import "APCDataVerificationClient.h"
#import "CMMotionActivity+Helper.h"

static NSString *const kCollectorFolder = @"newCollector";
static NSString *const kUploadFolder = @"upload";

static NSString *const kIdentifierKey = @"identifier";
static NSString *const kStartDateKey = @"startDate";
static NSString *const kEndDateKey = @"endDate";

static NSString *const kInfoFilename = @"info.json";
static NSString *const kCSVFilename  = @"data.csv";

@implementation APCPassiveCoreActivityManagerSink

/**********************************************************************/
#pragma mark - APCCollectorProtocol Delegate Methods
/**********************************************************************/

- (void) didRecieveArrayOfValuesFromHealthKitCollector:(NSArray*)quantitySamples {
    
    __weak typeof(self) weakSelf = self;
    
    [quantitySamples enumerateObjectsUsingBlock: ^(id quantitySample, NSUInteger __unused idx, BOOL * __unused stop) {
        __typeof(self) strongSelf = weakSelf;
        
        [strongSelf processUpdatesFromHealthKitForSampleType:quantitySample];
        
    }];
}

- (void) didRecieveUpdatedValueFromHealthKitCollector:(id)quantitySample {
    
    [self processUpdatesFromHealthKitForSampleType:quantitySample];
}

/**********************************************************************/
#pragma mark - Helper Methods
/**********************************************************************/


- (void) processUpdatesFromHealthKitForSampleType:(id)quantitySample {
    
    __weak typeof(self) weakSelf = self;
    
    [self.healthKitCollectorQueue addOperationWithBlock:^{
        __typeof(self) strongSelf = weakSelf;
        NSString * rowString = nil;
        NSString * csvFilePath = nil;
        NSArray  * arrayOfStuffToPrint = nil;
        
        if ([quantitySample isKindOfClass: [CMMotionActivity class]])
        {
            /*
             This csvColumnValues property comes from our CMMotionActivity+Helper
             category. These values will be in the same order as the matching
             csvColumnNames.  Those names will be shoved into the outbound .csv
             file because they're returned by the -columnNames method of the
             incoming Tracker.
             */
            arrayOfStuffToPrint = ((CMMotionActivity *) quantitySample).csvColumnValues;
        }

        if (arrayOfStuffToPrint.count > 0)
        {
            rowString = [[arrayOfStuffToPrint componentsJoinedByString: @","] stringByAppendingString: @"\n"];
            csvFilePath = [strongSelf.folder stringByAppendingPathComponent: kCSVFilename];
            
            [APCPassiveDataCollector createOrAppendString: rowString toFile: csvFilePath];
        }
        
        [strongSelf checkIfDataNeedsToBeFlushed];
        
    }];
}

@end
