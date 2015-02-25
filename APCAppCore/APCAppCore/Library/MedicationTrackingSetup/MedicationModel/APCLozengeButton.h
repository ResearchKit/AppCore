//
//  APCLozengeButton.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCMedTrackerDailyDosageRecord;
@class  APCMedTrackerPrescription;

@interface APCLozengeButton : UIButton

@property  (nonatomic, strong)  APCMedTrackerDailyDosageRecord  *dailyDosageRecord;
@property  (nonatomic, strong)  APCMedTrackerPrescription       *prescription;

@property  (nonatomic, strong)  NSDate                          *currentDate;
@property  (nonatomic, strong)  NSNumber                        *numberOfDosesTaken;

@property  (nonatomic, strong)  UIColor                         *completedTickColor;
@property  (nonatomic, strong)  UIColor                         *completedBackgroundColor;
@property  (nonatomic, strong)  UIColor                         *completedBorderColor;

@property  (nonatomic, assign, getter = isCompleted)  BOOL  completed;

@end
