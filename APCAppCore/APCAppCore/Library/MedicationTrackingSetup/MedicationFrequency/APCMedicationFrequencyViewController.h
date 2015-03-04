//
//  APCMedicationFrequencyViewController.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCMedicationFrequencyViewController;

@protocol  APCMedicationFrequencyViewControllerDelegate <NSObject>

- (void)frequencyController:(APCMedicationFrequencyViewController *)frequencyController didSelectFrequency:(NSDictionary *)daysAndNumbers;

@end

@interface APCMedicationFrequencyViewController : UIViewController

@property  (nonatomic, strong)    NSDictionary                                   *daysNumbersDictionary;

@property  (nonatomic, weak)  id  <APCMedicationFrequencyViewControllerDelegate>  delegate;

@end
