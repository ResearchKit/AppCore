//
//  APCFileManagerForCollector.m
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

#import "APCPassiveHealthKitQuantityDataSink.h"
#import "APCAppCore.h"

static NSString *const kCollectorFolder = @"newCollector";
static NSString *const kUploadFolder = @"upload";

static NSString *const kIdentifierKey = @"identifier";
static NSString *const kStartDateKey = @"startDate";
static NSString *const kEndDateKey = @"endDate";

static NSString *const kInfoFilename = @"info.json";
static NSString *const kCSVFilename  = @"data.csv";


@implementation APCPassiveHealthKitQuantityDataSink

/**********************************************************************/
#pragma mark - APCCollectorProtocol Delegate Methods
/**********************************************************************/
- (void) didRecieveUpdatedValuesFromCollector:(NSArray*)quantitySamples {
    __weak typeof(self) weakSelf = self;
    [quantitySamples enumerateObjectsUsingBlock: ^(id quantitySample, NSUInteger __unused idx, BOOL * __unused stop) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf processUpdatesFromCollector:quantitySample];
        
    }];
}

- (void) didRecieveUpdatedValueFromCollector:(id)result {
    
    [self processUpdatesFromCollector:result];
}

- (void)processUpdatesFromCollector:(id)quantitySample {

    //Super must be called here.
    [super processUpdatesFromCollector:quantitySample];
    
    __weak typeof(self) weakSelf = self;
    [self.healthKitCollectorQueue addOperationWithBlock:^{
        __typeof(self) strongSelf = weakSelf;
        HKQuantitySample*   qtySample           = (HKQuantitySample *)quantitySample;
        NSString*           startDateTimeStamp  = [qtySample.startDate toStringInISO8601Format];
        NSString*           endDateTimeStamp    = [qtySample.endDate toStringInISO8601Format];
        NSString*           healthKitType       = qtySample.quantityType.identifier;
        

        NSString*           quantityValueRep    = [NSString stringWithFormat:@"%@", qtySample.quantity];
        NSArray*            valueSplit          = [quantityValueRep componentsSeparatedByString:@" "];
        NSString*           quantityValue       = [valueSplit objectAtIndex:0];

        NSString*           quantityUnit        = @"";
        for (int i = 1; i < (int)[valueSplit count]; i++)
        {
            quantityUnit = [quantityUnit stringByAppendingString:valueSplit[i]];
        }
        
        NSString*           quantitySource      = qtySample.source.name;

        if (quantitySource == nil)
        {
            quantitySource = @"";
        }
        else if ([[[UIDevice currentDevice] name] isEqualToString:quantitySource])
        {
         quantitySource = @"iPhone";
        }
    
        
        NSString *stringToWrite = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@\n",
                                   startDateTimeStamp,
                                   endDateTimeStamp,
                                   healthKitType,
                                   quantityValue,
                                   quantityUnit,
                                   quantitySource];
                
        [APCPassiveDataSink createOrAppendString:stringToWrite
                                               toFile:[strongSelf.folder stringByAppendingPathComponent:kCSVFilename]];

        [strongSelf checkIfDataNeedsToBeFlushed];
        
    }];
}




@end
