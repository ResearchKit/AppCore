//
//  APCCircularProgressView.m
//  ProgressConrtrol
//
//  Created by Ramsundar Shandilya on 9/8/14.
//  Copyright (c) 2014 Ramsundar Shandilya. All rights reserved.
//

#import "APCCircularProgressView.h"

static NSString * const APCCircularProgressViewAnimationKey = @"APCCircularProgressViewAnimationKey";

@interface APCCircularProgressView ()

@property (nonatomic, strong) CAShapeLayer *circularTrackLayer;
@property (nonatomic, strong) CAShapeLayer *circularProgressLayer;

@end

@implementation APCCircularProgressView

@synthesize tintColor = _tintColor;

#pragma mark - Init methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    [self defaultValues];
    
    [self setupProgressLayers];
    [self setupProgresslabel];
    
    self.tintColor = [UIColor colorWithRed:29/255.f green:90/255.f blue:170/255.f alpha:1.0];
}

- (void)defaultValues
{
    /* ivars are used since the method is called from Init method. */
    _progress = 0.0f;
    
    _animationDuration = 0.3f;
    _lineWidth = 4.0f;
    _hidesProgressValue = NO;
}

#pragma mark - Setup Sub Views/Layers

- (void)setupProgressLayers
{
    /* ivars are used since the method is called from Init method. */
    
    _circularTrackLayer = [CAShapeLayer layer];
    [_circularTrackLayer setFrame:self.bounds];
    [_circularTrackLayer setFillColor:[UIColor clearColor].CGColor];
    _circularTrackLayer.strokeColor = [UIColor grayColor].CGColor;
    [self.layer addSublayer:_circularTrackLayer];
    
    _circularProgressLayer = [CAShapeLayer layer];
    [_circularProgressLayer setFrame:self.bounds];
    [_circularProgressLayer setFillColor:[UIColor clearColor].CGColor];
    [self.layer addSublayer:_circularProgressLayer];
}

- (void)setupProgresslabel
{
    /* iVars are used since the method is called from Init method. */
    
    //Calc. frame of the largest square that fits inside the circle
    CGFloat circleDiameter = CGRectGetWidth(self.bounds) - self.lineWidth;;
    CGFloat labelFrameWidth = circleDiameter/sqrt(2.0);
    
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - labelFrameWidth)/2, (CGRectGetHeight(self.bounds) - labelFrameWidth)/2, labelFrameWidth, labelFrameWidth)];
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.adjustsFontSizeToFitWidth = YES;
    [_progressLabel setTextColor:[UIColor darkGrayColor]];
    [self addSubview:_progressLabel];
    self.progressLabel.text = @"0 %";
    
    _progressLabel.backgroundColor = [UIColor clearColor];
}

#pragma mark - View Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.circularTrackLayer.frame = self.bounds;
    self.circularTrackLayer.cornerRadius = MIN(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    self.circularTrackLayer.path = [self circularArcPath].CGPath;
    self.circularTrackLayer.lineWidth = self.lineWidth;
    
    self.circularProgressLayer.frame = self.bounds;
    self.circularProgressLayer.cornerRadius = MIN(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    self.circularProgressLayer.path = [self circularArcPath].CGPath;
    self.circularProgressLayer.lineWidth = self.lineWidth;
    
    self.progressLabel.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
}

- (UIBezierPath *)circularArcPath
{
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    CGFloat radius = MIN(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2) - self.lineWidth/2;
    
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = 3*M_PI_2;
    
    UIBezierPath *circularArcBezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    return circularArcBezierPath;
}

#pragma mark - Public Accessors

#pragma mark Tint/Track Color

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    self.circularProgressLayer.strokeColor = tintColor.CGColor;
}

- (void)setTrackColor:(UIColor *)trackColor
{
    _trackColor = trackColor;
    self.circularTrackLayer.strokeColor = trackColor.CGColor;
}

#pragma mark Line Width

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    
    self.circularTrackLayer.lineWidth = lineWidth;
    self.circularProgressLayer.lineWidth = lineWidth;
}

- (void)setHidesProgressValue:(BOOL)hidesProgressValue
{
    _hidesProgressValue = hidesProgressValue;
    self.progressLabel.hidden = hidesProgressValue;
}

#pragma mark - Progress

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO];
}

-(void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    progress = MAX(0.0, MIN(1.0, progress));
    
    if (progress != _progress) {
        
        if (animated) {
            [self animateLayerForProgress:progress];
            _progress = progress;
        } else {
            [self updateStrokeEndForProgress:progress];
            _progress = progress;
            
            NSUInteger progressPercent = progress * 100;
            self.progressLabel.text = [NSString stringWithFormat:@"%lu%%", (unsigned long)progressPercent];
        }
    }
}

- (void)updateStrokeEndForProgress:(CGFloat)progress
{
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    self.circularProgressLayer.strokeEnd = progress;
    [CATransaction commit];
}

#pragma mark - Animations

- (void)animateLayerForProgress:(CGFloat)progress
{
    CABasicAnimation *progressAnimation = [CABasicAnimation animationWithKeyPath:@"stokeEnd"];
    progressAnimation.duration = self.animationDuration;
    progressAnimation.fromValue = @(self.progress);
    progressAnimation.toValue = @(progress);
    progressAnimation.delegate = self;
    progressAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.circularProgressLayer addAnimation:progressAnimation forKey:APCCircularProgressViewAnimationKey];
    
}

#pragma mark - CAAnimationDelegate methods

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self updateStrokeEndForProgress:_progress];
    
    NSUInteger progressPercent = _progress * 100;
    self.progressLabel.text = [NSString stringWithFormat:@"%lu%%", (unsigned long)progressPercent];
}

@end
