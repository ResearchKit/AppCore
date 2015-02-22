//
//  APCMedicationColorViewController.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCMedicationColorViewController;
@class  APCMedTrackerScheduleColor;

@protocol  APCMedicationColorViewControllerDelegate  <NSObject>

- (void)colorController:(APCMedicationColorViewController *)colorController didSelectColorLabelName:(APCMedTrackerScheduleColor *)colorObject;

@end

@interface APCMedicationColorViewController : UIViewController

@property  (nonatomic, weak)  id  <APCMedicationColorViewControllerDelegate>  delegate;

@end
