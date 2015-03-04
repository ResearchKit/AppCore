//
//  APCFormTextField.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol APCFormTextFieldDelegate;

@interface APCFormTextField : UITextField

@property (nonatomic, strong) UIButton *validationButton;

@property (nonatomic, getter=isValid) BOOL valid;

@property (nonatomic, weak) id <APCFormTextFieldDelegate> validationDelegate;

@end

@protocol APCFormTextFieldDelegate <NSObject>

- (void)formTextFieldDidTapValidButton:(APCFormTextField *)textField;

@end

