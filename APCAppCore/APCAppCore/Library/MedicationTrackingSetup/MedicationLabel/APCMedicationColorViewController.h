//
//  APCMedicationColorViewController.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCMedicationColorViewController;
@class  APCMedTrackerPrescriptionColor;

@protocol  APCMedicationColorViewControllerDelegate  <NSObject>

- (void)colorController:(APCMedicationColorViewController *)colorController didSelectColorLabelName:(APCMedTrackerPrescriptionColor *)colorObject;

@end

@interface APCMedicationColorViewController : UIViewController

@property  (nonatomic, weak)  id  <APCMedicationColorViewControllerDelegate>  delegate;

@end
