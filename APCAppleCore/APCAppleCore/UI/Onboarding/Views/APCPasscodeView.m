//
//  APCPasscodeView.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/8/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCPasscodeView.h"
#import "UIView+Helper.h"

static CGFloat const kAPCPasscodeViewPinLength = 4;

@interface APCPasscodeView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *hiddenTextField;

@end

@implementation APCPasscodeView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self addControls];
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addControls];
    }
    
    return self;
}

- (void) addControls {
    _digitViews = [NSMutableArray new];
    
    {
        _hiddenTextField = [UITextField new];
        _hiddenTextField.delegate = self;
        _hiddenTextField.hidden = YES;
        _hiddenTextField.keyboardType = UIKeyboardTypeNumberPad;
        _hiddenTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        [self addSubview:_hiddenTextField];
    }
    
    
    CGFloat digitWidth = self.bounds.size.width/kAPCPasscodeViewPinLength;
    CGRect frame = CGRectMake(0, 0, digitWidth, digitWidth);
    
    {
        APCPasscodeDigitView *digitView = [[APCPasscodeDigitView alloc] initWithFrame:frame];
        [self addSubview:digitView];
        
        [self.digitViews addObject:digitView];
    }
    
    {
        frame.origin.x += digitWidth;
        
        APCPasscodeDigitView *digitView = [[APCPasscodeDigitView alloc] initWithFrame:frame];
        [self addSubview:digitView];
        
        [self.digitViews addObject:digitView];
    }
    
    {
        frame.origin.x += digitWidth;
        
        APCPasscodeDigitView *digitView = [[APCPasscodeDigitView alloc] initWithFrame:frame];
        [self addSubview:digitView];
        
        [self.digitViews addObject:digitView];
    }
    
    {
        frame.origin.x += digitWidth;
        
        APCPasscodeDigitView *digitView = [[APCPasscodeDigitView alloc] initWithFrame:frame];
        [self addSubview:digitView];
        
        [self.digitViews addObject:digitView];
    }
}

- (void) reset {
    self.code = nil;
    self.hiddenTextField.text = nil;
    [self.digitViews makeObjectsPerformSelector:@selector(reset)];
}

- (BOOL) becomeFirstResponder {
    return [self.hiddenTextField becomeFirstResponder];
}

- (BOOL) resignFirstResponder {
    [super resignFirstResponder];
    return [self.hiddenTextField resignFirstResponder];
}

- (BOOL) isFirstResponder {
    return self.hiddenTextField.isFirstResponder;
}


#pragma mark - UITextFieldDelegate

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL canAppendText = NO;
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (text.length <= kAPCPasscodeViewPinLength) {
        canAppendText = YES;
        
        APCPasscodeDigitView *digitView = (APCPasscodeDigitView *)self.digitViews[range.location];
        self.code = nil;
        
        NSNumber *digit = nil;
        if (string.length == 0) {
            [digitView reset];
        }
        else {
            digit = @([string integerValue]);
            [digitView occupied];
        }
        
        if ([self.delegate respondsToSelector:@selector(passcodeView:didChangeDigit:atIndex:)]) {
            [self.delegate passcodeView:self didChangeDigit:digit atIndex:range.location];
        }
        
        if (text.length == kAPCPasscodeViewPinLength) {
            [textField performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.3];
        }
    }
    
    return canAppendText;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    self.code = textField.text;
    
    if ([self.delegate respondsToSelector:@selector(passcodeViewDidFinish:withCode:)]) {
        [self.delegate passcodeViewDidFinish:self withCode:self.code];
    }
}

@end



#pragma mark - APCPasscodeDigitView

static CGFloat const kAPCPasscodeDigitViewLayerMargin   = 10;

@interface APCPasscodeDigitView ()

@end



@implementation APCPasscodeDigitView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.allowsEdgeAntialiasing = YES;
        [self.layer addSublayer:_shapeLayer];
        
        // Once the view is initialized, then calling reset method will make shape layer to inital state (i.e. hypen (-))
        [self reset];
    }
    
    return self;
}


#pragma mark - Public Methods

- (void) occupied {
    self.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, kAPCPasscodeDigitViewLayerMargin, kAPCPasscodeDigitViewLayerMargin) cornerRadius:self.innerWidth/2];
    
    self.shapeLayer.strokeColor = [UIColor colorWithRed:45/255.0f green:180/255.0f blue:251/255.0f alpha:1.0].CGColor;
    self.shapeLayer.lineWidth = 2.0;
    self.shapeLayer.path = self.path.CGPath;
}

- (void) reset {
    self.path = [UIBezierPath bezierPath];
    
    [self.path moveToPoint:CGPointMake(kAPCPasscodeDigitViewLayerMargin, self.verticalCenter)];
    [self.path addLineToPoint:CGPointMake(self.width - kAPCPasscodeDigitViewLayerMargin, self.verticalCenter)];
    
    self.shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    self.shapeLayer.lineWidth = 4.0;
    self.shapeLayer.path = self.path.CGPath;
}

@end
