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

@end

@interface APCMedicationNameViewController : UIViewController

@property  (nonatomic, weak)  id  <APCMedicationNameViewControllerDelegate>  delegate;

@end

