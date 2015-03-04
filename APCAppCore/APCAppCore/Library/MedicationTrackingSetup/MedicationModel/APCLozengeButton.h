//
//  APCLozengeButton.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
#import <UIKit/UIKit.h>

@class  APCMedTrackerDailyDosageRecord;
@class  APCMedTrackerPrescription;

@interface APCLozengeButton : UIButton

@property  (nonatomic, strong)  APCMedTrackerDailyDosageRecord  *dailyDosageRecord;
@property  (nonatomic, strong)  APCMedTrackerPrescription       *prescription;

@property  (nonatomic, strong)  NSDate                          *currentDate;
@property  (nonatomic, strong)  NSNumber                        *numberOfDosesTaken;

@property  (nonatomic, strong)  UIColor                         *lozengeColor;

@end
