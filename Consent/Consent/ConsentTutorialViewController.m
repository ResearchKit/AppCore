//
//  ConsentTutorialViewController.m
//  Consent
//
//  Created by Karthik Keyan on 8/18/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "ConsentTutorialViewController.h"

static const CGFloat kConsentRubberBandElasticConstant      = 0.55;

static const CGFloat kLeftPanMaximunResistance              = 1.0;
static const CGFloat kRightPanMaximunResistance             = 2.6;

@interface ConsentTutorialViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *stepsScrollView;

@end

@implementation ConsentTutorialViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addNavigationButton];
    [self addViews];
}


#pragma mark - UI Creation Methods

- (void) addNavigationButton {
    
}

- (void) addViews {
    CGRect rect = self.view.bounds;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:rect];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.scrollEnabled = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.contentSize = (CGSize){CGRectGetWidth(rect) * 10, CGRectGetHeight(rect)};
    [self.view addSubview:scrollView];
    
    for (int i = 0; i < 10; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * CGRectGetWidth(rect), 0, CGRectGetWidth(rect), CGRectGetHeight(rect))];
        view.backgroundColor = (i % 2 == 0)?[UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0]:[UIColor colorWithRed:0.0 green:1.0 blue:0 alpha:1.0];
        [scrollView addSubview:view];
    }
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:panGesture];
    
    self.stepsScrollView = scrollView;
}


#pragma mark - UIScrolViewDelegate

//- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat xOffset = scrollView.contentOffset.x;
//    CGFloat scrollViewWidth = CGRectGetWidth(scrollView.bounds);
//    
//    NSInteger step = xOffset/scrollViewWidth;
//    
//    CGFloat movedX = xOffset - (scrollViewWidth *  step);
//    CGFloat movedRatio = movedX/scrollViewWidth;
//    
//    switch (step) {
//        case 1:
//            [self layoutStepOneForMovedRatio:movedRatio];
//            break;
//            
//        default:
//            break;
//    }
//}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger step = scrollView.contentOffset.x/scrollView.frame.size.width;
    
    switch (step) {
        case 1:
            [self layoutStepOneForMovedRatio:1.0];
            break;
            
        default:
            break;
    }
}


#pragma mark - Private Methods

- (void) pan:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:self.view];
        
        CGFloat x = translation.x;
        
        CGFloat distance = self.stepsScrollView.frame.size.width;
        
        CGFloat rubberBandElasticValue = (1.0 - (1.0 / ((x * kConsentRubberBandElasticConstant / distance) + 1.0))) * distance;
        
        CGFloat resistance = x/rubberBandElasticValue;
        
        CGPoint offset = self.stepsScrollView.contentOffset;
        
        NSLog(@"%f", resistance);
        
        if (resistance > kLeftPanMaximunResistance && resistance < kRightPanMaximunResistance) {
            if (x > 0) {
                offset.x -= resistance;
            }
            else {
                offset.x += resistance;
            }
            
            self.stepsScrollView.contentOffset = offset;
        }
        else {
            NSInteger step = self.stepsScrollView.contentOffset.x/self.stepsScrollView.frame.size.width;
            if (translation.x < 0) {
                step++;
            }
            
            CGPoint point = CGPointMake(self.stepsScrollView.frame.size.width * step, 0);
            
            [self.stepsScrollView setContentOffset:point animated:YES];
            panGesture.enabled = NO;
        }
    }
    else {
        panGesture.enabled = YES;
        
        if (panGesture.state == UIGestureRecognizerStateEnded) {
            NSInteger step = ceil(self.stepsScrollView.contentOffset.x/self.stepsScrollView.frame.size.width);
            
            CGPoint point = CGPointMake(self.stepsScrollView.frame.size.width * step, 0);
            
            [self.stepsScrollView setContentOffset:point animated:YES];
        }
    }
}

- (void) layoutStepOneForMovedRatio:(CGFloat)movedRatio {
    
}

@end
