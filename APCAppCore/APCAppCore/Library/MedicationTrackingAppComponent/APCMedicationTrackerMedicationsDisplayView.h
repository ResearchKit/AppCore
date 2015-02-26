//
//  APCMedicationTrackerMedicationsDisplayView.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCMedicationTrackerMedicationsDisplayView;

@class  APCLozengeButton;
@class  APCMedTrackerPrescription;

@protocol  APCMedicationTrackerMedicationsDisplayViewDelegate  <NSObject>

- (void)displayView:(APCMedicationTrackerMedicationsDisplayView *)displayView lozengeButtonWasTapped:(APCLozengeButton *)lozenge;

@end

@interface APCMedicationTrackerMedicationsDisplayView : UIView

@property  (nonatomic, strong)  NSArray  *prescriptions;
@property  (nonatomic, strong)  NSDate   *startOfWeekDate;

@property  (nonatomic, weak)  id <APCMedicationTrackerMedicationsDisplayViewDelegate>  delegate;

- (void)makePrescriptionDisplaysWithPrescriptions:(NSArray *)thePrescriptions andDate:(NSDate *)aDate;

@end
