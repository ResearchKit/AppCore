//
//  APCMedicationNameViewController.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCMedicationNameViewController;
@class  APCMedTrackerMedication;

@protocol  APCMedicationNameViewControllerDelegate <NSObject>

- (void)nameController:(APCMedicationNameViewController *)nameController didSelectMedicineName:(APCMedTrackerMedication *)medicationObject;
- (void)nameControllerDidCancel:(APCMedicationNameViewController *)nameController;

@end

@interface APCMedicationNameViewController : UIViewController

@property  (nonatomic, strong)  APCMedTrackerMedication  *medicationRecord;

@property  (nonatomic, weak)  id  <APCMedicationNameViewControllerDelegate>  delegate;

@end

