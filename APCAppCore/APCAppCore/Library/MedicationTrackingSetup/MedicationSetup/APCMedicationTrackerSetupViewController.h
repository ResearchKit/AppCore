//
//  APCMedicationTrackerSetupViewController.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCMedicationTrackerSetupViewController;

@protocol  APCMedicationTrackerSetupViewControllerDelegate <NSObject>

- (void)medicationSetup:(APCMedicationTrackerSetupViewController *)medicationSetup didCreateMedications:(NSArray *)theMedications;

@end

@interface APCMedicationTrackerSetupViewController : UIViewController

@property  (nonatomic, weak)  id <APCMedicationTrackerSetupViewControllerDelegate> delegate;

@end

