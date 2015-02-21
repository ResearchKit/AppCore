//
//  APCMedicationTrackerMedicationsDisplayView.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCMedicationTrackerMedicationsDisplayView;
@class  APCLozengeButton;

@protocol  APCMedicationTrackerMedicationsDisplayViewDelegate  <NSObject>

- (void)displayView:(APCMedicationTrackerMedicationsDisplayView *)displayView lozengeButtonWasTapped:(APCLozengeButton *)lozenge;

@end

@interface APCMedicationTrackerMedicationsDisplayView : UIView

@property  (nonatomic, strong)  NSArray  *medicationModels;

@property  (nonatomic, weak)  id <APCMedicationTrackerMedicationsDisplayViewDelegate>  delegate;

@end
