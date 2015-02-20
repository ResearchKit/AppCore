//
//  APCMedicationTrackerDetailViewController.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCMedicationModel;
@class  APCLozengeButton;

@interface APCMedicationTrackerDetailViewController : UIViewController

@property  (nonatomic, strong)  APCMedicationModel     *model;
@property  (nonatomic, strong)  APCLozengeButton       *follower;

@end
