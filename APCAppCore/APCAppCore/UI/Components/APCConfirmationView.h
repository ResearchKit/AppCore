// 
//  APCConfirmationView.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

@interface APCConfirmationView : UIView

@property  (nonatomic, strong)  UIColor  *completedTickColor;
@property  (nonatomic, strong)  UIColor  *completedBackgroundColor;

@property  (nonatomic, strong)  UIColor  *incompleteTickColor;
@property  (nonatomic, strong)  UIColor  *incompleteBackgroundColor;

@property  (nonatomic, assign, getter = isCompleted)  BOOL  completed;

@end
