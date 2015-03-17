//
//  APCMedicationColorViewController.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCMedicationColorViewController;
@class  APCMedTrackerPrescriptionColor;

@protocol  APCMedicationColorViewControllerDelegate  <NSObject>

- (void)colorController:(APCMedicationColorViewController *)colorController didSelectColorLabelName:(APCMedTrackerPrescriptionColor *)colorObject;
- (void)colorControllerDidCancel:(APCMedicationColorViewController *)colorController;

@end

@interface APCMedicationColorViewController : UIViewController

@property  (nonatomic, strong)  APCMedTrackerPrescriptionColor  *oneColorDescriptor;

@property  (nonatomic, weak)    id  <APCMedicationColorViewControllerDelegate>  delegate;

@end
