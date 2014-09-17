//
//  APCPasscodeView.h
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/8/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import UIKit;

@class APCPasscodeView, APCPasscodeDigitView;

@protocol APCPasscodeViewDelegate <NSObject>

@optional
- (void) passcodeView:(APCPasscodeView *)passcodeView didChangeDigit:(NSNumber *)digit atIndex:(NSUInteger)index;

- (void) passcodeViewDidFinish:(APCPasscodeView *)passcodeView withCode:(NSString *)code;

@end


@interface APCPasscodeView : UIView

@property (nonatomic, strong) NSMutableArray *digitViews;

@property (nonatomic, copy) NSString *code;

@property (nonatomic, weak) id<APCPasscodeViewDelegate> delegate;

- (instancetype) init NS_UNAVAILABLE;

- (void) reset;

@end


@interface APCPasscodeDigitView : UIView

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) UIBezierPath *path;

- (void) occupied;

- (void) reset;

@end
