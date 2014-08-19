//
//  ConsentTutorialViewController.m
//  Consent
//
//  Created by Karthik Keyan on 8/18/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import "ConsentTutorialViewController.h"

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
    
    UIPanGestureRecognizer *leftSwipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    [self.view addGestureRecognizer:leftSwipeGesture];
    
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

- (void) leftSwipe:(UIPanGestureRecognizer *)swipeGesture {
    if (swipeGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [swipeGesture translationInView:self.view];
        
        CGFloat x = translation.x;
        CGFloat d = self.stepsScrollView.frame.size.width;
        CGFloat c = 0.55;
        
        CGFloat b = (1.0 - (1.0 / ((x * c / d) + 1.0))) * d;
        
        CGFloat resistance = x/b;
        
        CGPoint offset = self.stepsScrollView.contentOffset;
        
        NSLog(@"%f", resistance);
        
        if (resistance > 1.0 && resistance < 2.6) {
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
            swipeGesture.enabled = NO;
        }
        
//        if (ABS(x) <= 70) {
//            CGFloat ratio = -x/100;
//            CGFloat deltaX = 60 * ratio;
//            
//            CGPoint point = CGPointMake((self.stepsScrollView.frame.size.width * step) + deltaX, 0);
//            self.stepsScrollView.contentOffset = point;
//        }
//        else {
//            if (x < 0) {
//                step += 1;
//            }
//            else {
//                if (step != 0) {
//                    step -= 1;
//                }
//            }
//            
//            CGPoint point = CGPointMake(self.stepsScrollView.frame.size.width * step, 0);
//            [self.stepsScrollView setContentOffset:point animated:YES];
//            
//            swipeGesture.cancelsTouchesInView = YES;
//        }
    }
    else if (swipeGesture.state == UIGestureRecognizerStateEnded) {
        swipeGesture.enabled = YES;
        
        NSInteger step = ceil(self.stepsScrollView.contentOffset.x/self.stepsScrollView.frame.size.width);
        CGPoint point = CGPointMake(self.stepsScrollView.frame.size.width * step, 0);
        [self.stepsScrollView setContentOffset:point animated:YES];
    }
    else {
        swipeGesture.enabled = YES;
    }
}

- (void) layoutStepOneForMovedRatio:(CGFloat)movedRatio {
    
}

@end
