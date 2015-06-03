// 
//  APCMedicationLozenge.h 
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

@class APCMedicationWeeklySchedule;
@class APCMedicationDosageTaken;

@interface APCMedicationLozenge : NSObject

@property (nonatomic, strong) APCMedicationWeeklySchedule *schedule;
@property (nonatomic, strong) NSNumber *dosesTakenSoFar;
@property (nonatomic, strong) NSNumber *maxNumberOfDoses;
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
