//
//  APCPasscodeView.m
//  UI
//
//  Created by Karthik Keyan on 9/8/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCPasscodeView.h"
#import "CALayer+AppearanceCategory.h"

@interface APCPasscodeView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *hiddenTextField;

@end

@implementation APCPasscodeView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self loadViews];
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadViews];
    }
    
    return self;
}

- (void) loadViews {
    _digitViews = [NSMutableArray new];
    
    {
        _hiddenTextField = [UITextField new];
        _hiddenTextField.delegate = self;
        _hiddenTextField.hidden = YES;
        _hiddenTextField.keyboardType = UIKeyboardTypeNumberPad;
        [self addSubview:_hiddenTextField];
    }
    
    
    CGFloat digitWidth = self.bounds.size.width/4;
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
    return [self.hiddenTextField resignFirstResponder];
}

- (BOOL) isFirstResponder {
    return self.hiddenTextField.isFirstResponder;
}


#pragma mark - UITextFieldDelegate

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL canAppendText = NO;
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (text.length <= 4) {
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
        
        if (text.length == 4) {
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
        
        [self reset];
    }
    
    return self;
}


#pragma mark - Public Methods

- (void) occupied {
    self.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, kAPCPasscodeDigitViewLayerMargin, kAPCPasscodeDigitViewLayerMargin) cornerRadius:self.bounds.size.width/2];
    
    self.shapeLayer.strokeColor = [CALayer lineColor];
    self.shapeLayer.lineWidth = 2.0;
    self.shapeLayer.path = self.path.CGPath;
}

- (void) reset {
    _path = [UIBezierPath bezierPath];
    
    [self.path moveToPoint:CGPointMake(kAPCPasscodeDigitViewLayerMargin, CGRectGetMidY(self.bounds))];
    [self.path addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds) - kAPCPasscodeDigitViewLayerMargin, CGRectGetMidY(self.bounds))];
    
    self.shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    self.shapeLayer.lineWidth = 4.0;
    self.shapeLayer.path = self.path.CGPath;
}

@end
