//
//  APCMedicationDosageViewController.h
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCMedicationDosageViewController;
@class  APCMedTrackerPossibleDosage;

@protocol  APCMedicationDosageViewControllerDelegate  <NSObject>

- (void)dosageController:(APCMedicationDosageViewController *)dosageController didSelectDosageAmount:(APCMedTrackerPossibleDosage *)dosageAmount;

@end

@interface APCMedicationDosageViewController : UIViewController

@property  (nonatomic, weak)  id  <APCMedicationDosageViewControllerDelegate>  delegate;

@end
