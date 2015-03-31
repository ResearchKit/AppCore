// 
//  APCMedTrackerPrescription.h 
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
 
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class APCMedTrackerDailyDosageRecord, APCMedTrackerMedication, APCMedTrackerPossibleDosage, APCMedTrackerPrescriptionColor;

@interface APCMedTrackerPrescription : NSManagedObject

@property (nonatomic, retain) NSDate * dateStartedUsing;
@property (nonatomic, retain) NSDate * dateStoppedUsing;
@property (nonatomic, retain) NSNumber * didStopUsingOnDoctorsOrders;
@property (nonatomic, retain) NSNumber * numberOfTimesPerDay;
@property (nonatomic, retain) NSString * zeroBasedDaysOfTheWeek;
@property (nonatomic, retain) NSSet *actualDosesTaken;
@property (nonatomic, retain) APCMedTrackerPrescriptionColor *color;
@property (nonatomic, retain) APCMedTrackerPossibleDosage *dosage;
@property (nonatomic, retain) APCMedTrackerMedication *medication;
@end

@interface APCMedTrackerPrescription (CoreDataGeneratedAccessors)

- (void)addActualDosesTakenObject:(APCMedTrackerDailyDosageRecord *)value;
- (void)removeActualDosesTakenObject:(APCMedTrackerDailyDosageRecord *)value;
- (void)addActualDosesTaken:(NSSet *)values;
- (void)removeActualDosesTaken:(NSSet *)values;

@end
