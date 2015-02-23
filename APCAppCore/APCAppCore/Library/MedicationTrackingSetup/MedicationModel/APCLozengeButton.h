//
//  APCLozengeButton.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  APCMedTrackerPrescription;

@interface APCLozengeButton : UIButton

@property  (nonatomic, strong)  APCMedTrackerPrescription  *prescription;

@property  (nonatomic, strong)  UIColor                    *completedTickColor;
@property  (nonatomic, strong)  UIColor                    *completedBackgroundColor;
@property  (nonatomic, strong)  UIColor                    *completedBorderColor;

@property  (nonatomic, strong)  UIColor                    *incompleteTickColor;
@property  (nonatomic, strong)  UIColor                    *incompleteBackgroundColor;
@property  (nonatomic, strong)  UIColor                    *incompleteBorderColor;

@property  (nonatomic, assign, getter = isCompleted)  BOOL  completed;

@end
