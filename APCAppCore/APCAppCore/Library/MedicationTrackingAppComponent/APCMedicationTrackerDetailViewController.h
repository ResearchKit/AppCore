//
//  APCMedicationTrackerDetailViewController.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCMedTrackerMedicationSchedule;
@class  APCLozengeButton;

@interface APCMedicationTrackerDetailViewController : UIViewController

@property  (nonatomic, strong)  APCMedTrackerMedicationSchedule  *schedule;
@property  (nonatomic, strong)  APCLozengeButton                 *lozenge;

@end
