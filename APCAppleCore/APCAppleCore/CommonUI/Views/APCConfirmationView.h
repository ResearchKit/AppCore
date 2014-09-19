//
//  APHConfirmationView.h
//  Parkinson
//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCConfirmationView : UIView

@property  (nonatomic, strong)  UIColor  *completedTickColor;
@property  (nonatomic, strong)  UIColor  *completedBackgroundColor;

@property  (nonatomic, strong)  UIColor  *incompleteTickColor;
@property  (nonatomic, strong)  UIColor  *incompleteBackgroundColor;

@property  (nonatomic, assign, getter = isCompleted)  BOOL  completed;

@end
