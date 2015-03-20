/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ORKAudioContentView.h"
#import "ORKHelpers.h"
#import "ORKSkin.h"
#import "ORKLabel.h"
#import "ORKHeadlineLabel.h"
#import "ORKAccessibility.h"

// Spec values from HI
static const CGFloat GraphViewBlueZoneHeight = 170; // The central blue region
static const CGFloat GraphViewRedZoneHeight = 25;   // The two bands at top and bottom which are "loud" each have this height


@interface ORKAudioGraphView : UIView

@property (nonatomic, strong) UIColor *keyColor;
@property (nonatomic, strong) UIColor *alertColor;

@property (nonatomic, copy) NSArray *values;

@property (nonatomic) CGFloat alertThreshold;

@end

static const CGFloat kValueLineWidth = 4.5;
static const CGFloat kValueLineMargin = 1.5;

@implementation ORKAudioGraphView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CGFLOAT_MAX];
        c1.priority = UILayoutPriorityFittingSizeLevel;
        NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:CGFLOAT_MAX];
        c2.priority = UILayoutPriorityFittingSizeLevel;
        [NSLayoutConstraint activateConstraints:@[c1,c2]];
        
#if TARGET_IPHONE_SIMULATOR
        _values = @[@(0.2),@(0.6),@(0.55), @(0.1), @(0.75), @(0.7)];
#endif
    }
    return self;
}

- (void)setValues:(NSArray *)values {
    _values = [values copy];
    [self setNeedsDisplay];
}

- (void)setKeyColor:(UIColor *)keyColor {
    _keyColor = [keyColor copy];
    [self setNeedsDisplay];
}

- (void)setAlertColor:(UIColor *)alertColor {
    _alertColor = [alertColor copy];
    [self setNeedsDisplay];
}

- (void)setAlertThreshold:(CGFloat)alertThreshold {
    _alertThreshold = alertThreshold;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGRect r = self.bounds;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, r);
    
    CGFloat scale = [self.window.screen scale];
    
    CGFloat midY = CGRectGetMidY(r);
    CGFloat maxX = CGRectGetMaxX(r);
    CGFloat halfHeight = r.size.height/2;
    CGContextSaveGState(ctx);
    {
        UIBezierPath *centerLine = [UIBezierPath new];
        [centerLine moveToPoint:(CGPoint){.x=0,.y=midY}];
        [centerLine addLineToPoint:(CGPoint){.x=maxX,.y=midY}];
        
        CGContextSetLineWidth(ctx, 1/scale);
        [_keyColor setStroke];
        CGFloat lengths[2] = {3,3};
        CGContextSetLineDash(ctx, 0, lengths, 2);
        
        [centerLine stroke];
    }
    CGContextRestoreGState(ctx);
    
    CGFloat lineStep = kValueLineMargin + kValueLineWidth;
    
    CGContextSaveGState(ctx);
    {
        CGFloat x = maxX - lineStep/2;
        CGContextSetLineWidth(ctx, kValueLineWidth);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        
        UIBezierPath *path1 = [UIBezierPath new];
        path1.lineCapStyle = kCGLineCapRound;
        path1.lineWidth = kValueLineWidth;
        UIBezierPath *path2 = [path1 copy];
        
        for (NSNumber *value in [_values reverseObjectEnumerator]) {
            CGFloat floatValue = [value doubleValue];
            
            UIBezierPath *p = nil;
            if (floatValue > _alertThreshold) {
                p = path1;
                [_alertColor setStroke];
            } else {
                p = path2;
                [_keyColor setStroke];
            }
            [p moveToPoint:(CGPoint){.x=x,.y=midY-floatValue*halfHeight}];
            [p addLineToPoint:(CGPoint){.x=x,.y=midY+floatValue*halfHeight}];
            
            x -= lineStep;
            
            if (x < 0) {
                break;
            }
            
        }
        
        [_alertColor setStroke];
        [path1 stroke];
        
        [_keyColor setStroke];
        [path2 stroke];
        
    }
    CGContextRestoreGState(ctx);
    
}

@end

@interface ORKAudioTimerLabel : ORKLabel

@end

@implementation ORKAudioTimerLabel

+ (UIFont *)defaultFont {
    
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *alternativeDescriptor = ORKFontDescriptorForLightStylisticAlternative(descriptor);
    return [UIFont fontWithDescriptor:alternativeDescriptor size:[alternativeDescriptor pointSize]+4];
}


@end

@interface ORKAudioContentView()

@property (nonatomic, strong) ORKHeadlineLabel *alertLabel;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) ORKAudioGraphView *graphView;

@end

@implementation ORKAudioContentView
{
    NSArray *_constraints;
    NSMutableArray *_samples;
    UIColor *_keyColor;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat margin = ORKStandardMarginForView(self);
        self.layoutMargins = (UIEdgeInsets){.left=2*margin,.right=2*margin};
        
        self.alertLabel = [ORKHeadlineLabel new];
        _alertLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.timerLabel = [ORKAudioTimerLabel new];
        _timerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timerLabel.textAlignment = NSTextAlignmentRight;
        self.graphView = [ORKAudioGraphView new];
        _graphView.translatesAutoresizingMaskIntoConstraints = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.alertColor = [UIColor ork_redColor];
        
        [self addSubview:_alertLabel];
        [self addSubview:_timerLabel];
        [self addSubview:_graphView];
        
        _timerLabel.text = @"06:00";
        _alertLabel.text = ORKLocalizedString(@"AUDIO_TOO_LOUD_LABEL", nil);
        
        self.alertThreshold = GraphViewBlueZoneHeight/(GraphViewRedZoneHeight*2+GraphViewBlueZoneHeight);
        
        [self _updateGraphSamples];
        [self _applyKeyColor];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)tintColorDidChange {
    [self _applyKeyColor];
}

- (void)setFinished:(BOOL)finished {
    _finished = finished;
    [self _updateAlertLabelHidden];
}

- (void)_applyKeyColor {
    UIColor *keyColor = [self keyColor];
    _timerLabel.textColor = keyColor;
    _graphView.keyColor = keyColor;
}

- (UIColor *)keyColor {
    return _keyColor ? : [self tintColor];
}

- (void)setKeyColor:(UIColor *)keyColor {
    _keyColor = keyColor;
    [self _applyKeyColor];
}

- (void)setAlertColor:(UIColor *)alertColor {
    _alertColor = alertColor;
    
    _alertLabel.textColor = alertColor;
    _graphView.alertColor = alertColor;
}

- (void)updateConstraints {
    if ([_constraints count]) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
        _constraints = nil;
    }
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_timerLabel, _alertLabel, _graphView);
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_graphView]-[_alertLabel]|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_alertLabel
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1 constant:0]];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_graphView]-2-[_timerLabel]-|"
                                             options:NSLayoutFormatAlignAllCenterY
                                             metrics:nil views:views]];
    
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_graphView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:(GraphViewBlueZoneHeight+GraphViewRedZoneHeight*2)]];
    
    _constraints = constraints;
    [NSLayoutConstraint activateConstraints:constraints];
    [super updateConstraints];
}

- (void)setAlertThreshold:(CGFloat)alertThreshold {
    _alertThreshold = alertThreshold;
    _graphView.alertThreshold = alertThreshold;
    [self _updateGraphSamples];
}

- (void)setTimeLeft:(NSTimeInterval)timeLeft {
    _timeLeft = timeLeft;
    [self _updateTimerLabel];
}

- (void)_updateTimerLabel {
    static NSDateComponentsFormatter *_formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDateComponentsFormatter *fmt = [NSDateComponentsFormatter new];
        fmt.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
        fmt.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        fmt.allowedUnits = NSCalendarUnitMinute | NSCalendarUnitSecond;
        _formatter = fmt;
    });
    
    NSString *s = [_formatter stringFromTimeInterval:MAX(round(_timeLeft),0)];
    _timerLabel.text = s;
    _timerLabel.hidden = (s == nil);
    
}

- (void)_updateGraphSamples {
    _graphView.values = _samples;
    [self _updateAlertLabelHidden];
}

- (void)_updateAlertLabelHidden {
    NSNumber *sample = [_samples lastObject];
    BOOL hide = _finished || !([sample doubleValue] > _alertThreshold);
    _alertLabel.hidden = hide;
}

- (void)setSamples:(NSArray *)samples {
    _samples = [samples mutableCopy];
    [self _updateGraphSamples];
}

- (void)addSample:(NSNumber *)sample {
    NSAssert(sample != nil, @"Sample should be non-nil");
    if (! _samples) {
        _samples = [NSMutableArray array];
    }
    [_samples addObject:sample];
    // Try to keep around 250 samples
    if ([_samples count] > 500) {
        _samples = [[_samples subarrayWithRange:(NSRange){250,_samples.count-250}] mutableCopy];
    }
    [self _updateGraphSamples];
}

- (void)removeAllSamples {
    _samples = nil;
    [self _updateGraphSamples];
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    if (_alertLabel.isHidden) {
        return _timerLabel.accessibilityLabel;
    }
    
    return ORKAccessibilityStringForVariables(_timerLabel.accessibilityLabel, _alertLabel.accessibilityLabel);
}

- (UIAccessibilityTraits)accessibilityTraits {
    return [super accessibilityTraits] | UIAccessibilityTraitUpdatesFrequently;
}

@end
