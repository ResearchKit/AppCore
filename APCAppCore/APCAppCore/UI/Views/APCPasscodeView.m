// 
//  APCPasscodeView.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCPasscodeView.h"
#import "UIView+Helper.h"
#import "UIColor+APCAppearance.h"

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
        _hiddenTextField.keyboardAppearance = UIKeyboardAppearanceLight;
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

- (void)touchesBegan:(NSSet *)__unused touches withEvent:(UIEvent *)__unused event
{
    if (!self.hiddenTextField.isFirstResponder) {
        [self.hiddenTextField becomeFirstResponder];
    }
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
    textField.text = nil;
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
    
    self.shapeLayer.strokeColor = [UIColor appPrimaryColor].CGColor;
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
