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


#import "ORKVisualConsentStepViewController.h"
#import "ORKVisualConsentStep.h"
#import "ORKResult.h"
#import "ORKSignatureView.h"
#import "ORKHelpers.h"
#import <MessageUI/MessageUI.h>
#import "ORKSkin.h"
#import "ORKStepViewController_Internal.h"
#import "ORKConsentSceneViewController.h"
#import "ORKConsentDocument.h"
#import <QuartzCore/QuartzCore.h>
#import "ORKConsentSection+AssetLoading.h"
#import "ORKVisualConsentTransitionAnimator.h"
#import "ORKEAGLMoviePlayerView.h"
#import "UIBarButtonItem+ORKBarButtonItem.h"
#import "ORKContinueButton.h"
#import "ORKAccessibility.h"

@interface ORKVisualConsentStepViewController () <UIPageViewControllerDelegate>
{
    BOOL _hasAppeared;
    ORKStepViewControllerNavigationDirection _navDirection;
    
    BOOL _transitioning;
    ORKVisualConsentTransitionAnimator *_animator;
    
    NSArray *_visualSections;
}

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSMutableDictionary *viewControllers;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic) NSUInteger currentPage;

@property (nonatomic, strong) ORKContinueButton *continueActionButton;

- (ORKConsentSceneViewController *)_viewControllerForIndex:(NSUInteger)index;
- (NSUInteger)_currentIndex ;
- (NSUInteger)_indexOfViewController:(UIViewController *)viewController ;

@end

@interface ORKAnimationPlaceholderView : UIView

@property (nonatomic, strong) ORKEAGLMoviePlayerView *playerView;

@end

@implementation ORKAnimationPlaceholderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _playerView = [ORKEAGLMoviePlayerView new];
        _playerView.hidden = YES;
        [self addSubview:_playerView];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    
    CGRect frame = self.frame;
    frame.size.height = ORKGetMetricForScreenType(ORKScreenMetricIllustrationHeight, ORKGetScreenTypeForWindow(newWindow));
    self.frame = frame;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _playerView.frame = self.bounds;
}

@end

@implementation ORKVisualConsentStepViewController



- (void)_stepDidChange
{
    [super _stepDidChange];
    {
        NSMutableArray *vs = [NSMutableArray new];
        
        NSArray *sections = self.visualConsentStep.consentDocument.sections;
        for (ORKConsentSection *scene in sections) {
            if (scene.type != ORKConsentSectionTypeOnlyInDocument) {
                [vs addObject:scene];
            }
        }
        _visualSections = [vs copy];
    }
    
    if (self.step && [self _pageCount] == 0)
    {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Visual consent step has no visible scenes" userInfo:nil];
    }
    
    
    _viewControllers = nil;
    
    [self _showViewController:[self _viewControllerForIndex:0] forward:YES animated:NO];
    
}


- (ORKEAGLMoviePlayerView *)animationPlayerView {
    return [(ORKAnimationPlaceholderView *)_animationView playerView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect viewBounds = self.view.bounds;
    
    self.view.backgroundColor = ORKColor(ORKBackgroundColorKey);
   
    // Prepare pageViewController
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    //_pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    
    
    [[self scrollView] setBounces:NO];
    
    if ([_pageViewController respondsToSelector:@selector(edgesForExtendedLayout)]) {
        _pageViewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    _pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pageViewController.view.frame = viewBounds;
    [self.view addSubview:_pageViewController.view];
    [self addChildViewController:_pageViewController];
    [_pageViewController didMoveToParentViewController:self];
    
    self.animationView = [[ORKAnimationPlaceholderView alloc] initWithFrame:(CGRect){{0,0},{viewBounds.size.width,ORKGetMetricForScreenType(ORKScreenMetricIllustrationHeight, ORKScreenTypeiPhone4)}}];
    _animationView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    _animationView.backgroundColor = [UIColor clearColor];
    _animationView.userInteractionEnabled = NO;
    [self.view addSubview:_animationView];
    
    [self _updatePageIndex];
}


- (ORKVisualConsentStep *)visualConsentStep {
    assert(!self.step || [self.step isKindOfClass:[ORKVisualConsentStep class]]);
    return (ORKVisualConsentStep *)self.step;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_pageViewController.viewControllers.count == 0) {

        _hasAppeared = YES;
        
        // Add first viewController
        NSUInteger idx = 0;
        if (_navDirection == ORKStepViewControllerNavigationDirectionReverse)
        {
            idx = [self _pageCount]-1;
        }
        
        [self _showViewController:[self _viewControllerForIndex:idx] forward:YES animated:NO];
    }
    [self _updateBackButton];
    [self _updatePageIndex];
}

- (void)_willNavigateDirection:(ORKStepViewControllerNavigationDirection)direction
{
    _navDirection = direction;
}

- (UIBarButtonItem *)_goToPreviousPageButton {
    UIBarButtonItem *button = [UIBarButtonItem _obk_backBarButtonItemWithTarget:self action:@selector(_goToPreviousPage)];
    button.accessibilityLabel = ORKLocalizedString(@"AX_BUTTON_BACK", nil);
    return button;
}

- (void)_setBackButtonItem:(UIBarButtonItem *)backButton {
    [super _setBackButtonItem:backButton];
}

- (void)_updateNavLeftBarButtonItem {
    if ([self _currentIndex] == 0) {
        [super _updateNavLeftBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self _goToPreviousPageButton];
    }
}

- (void)_updateBackButton
{
    if (! _hasAppeared)
    {
        return;
    }
    
    [self _updateNavLeftBarButtonItem];
}


#pragma mark - actions

- (IBAction)_goToPreviousPage {
    
    [self _showViewController:[self _viewControllerForIndex:[self _currentIndex]-1] forward:NO animated:YES];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (IBAction)_next {
    [self _showViewController:[self _viewControllerForIndex:[self _currentIndex]+1] forward:YES animated:YES];
    ORKAccessibilityPostNotificationAfterDelay(UIAccessibilityScreenChangedNotification, nil, 0.5);
}


#pragma mark - internal

- (UIScrollView *)scrollView {
    
    if (_scrollView == nil) {
        for (UIView *view in self.pageViewController.view.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                _scrollView = (UIScrollView *)view;
            }
        }
    }
    
    return _scrollView;
}


- (void)_updatePageIndex {
    
    NSUInteger currentIndex = [self _currentIndex];
    if (currentIndex == NSNotFound)
    {
        return;
    }
    
    _currentPage = currentIndex;
    
    [self _updateBackButton];
    [self _setScrollEnabled:NO];
    
    ORKConsentSection *currentSection = (ORKConsentSection *)_visualSections[currentIndex];
    if (currentSection.type == ORKConsentSectionTypeOverview) {
        _animationView.isAccessibilityElement = NO;
    }
    else {
        _animationView.isAccessibilityElement = YES;
        _animationView.accessibilityLabel = [NSString stringWithFormat:ORKLocalizedString(@"AX_IMAGE_ILLUSTRATION", nil), currentSection.title];
        _animationView.accessibilityTraits |= UIAccessibilityTraitImage;
    }
}

- (void)_setScrollEnabled:(BOOL)enabled {
    [[self scrollView] setScrollEnabled:enabled];
}

- (NSArray *)_visualSections {
    return _visualSections;
}

- (NSUInteger)_pageCount {
    return _visualSections.count;
}

- (UIImageView *)_findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self _findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)_doShowViewController:(ORKConsentSceneViewController *)viewController direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated semaphore:(dispatch_semaphore_t)sem {
    
    UIView *pvcView = self.pageViewController.view;
    pvcView.userInteractionEnabled = NO;
    [self.pageViewController setViewControllers:@[viewController] direction:direction animated:animated completion:^(BOOL finished) {
        pvcView.userInteractionEnabled = YES;
        if (animated) {
            dispatch_semaphore_signal(sem);
        }
    }];
}

- (ORKVisualConsentTransitionAnimator *)_doAnimateFromViewController:(ORKConsentSceneViewController *)fromController toController:(ORKConsentSceneViewController *)viewController direction:(UIPageViewControllerNavigationDirection)direction semaphore:(dispatch_semaphore_t)sem url:(NSURL *)url animateBeforeTransition:(BOOL)animateBeforeTransition transitionBeforeAnimate:(BOOL)transitionBeforeAnimate {
    
    __weak typeof(self) weakSelf = self;
    _animator = [[ORKVisualConsentTransitionAnimator alloc] initWithVisualConsentStepViewController:self movieURL:url];
    
    [_animator animateTransitionWithDirection:direction
                                          withLoadHandler:^(ORKVisualConsentTransitionAnimator *animator, UIPageViewControllerNavigationDirection direction) {
                                              fromController.imageHidden = YES;
                                              viewController.imageHidden = YES;
                                              
                                              if (!animateBeforeTransition && !transitionBeforeAnimate) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      __strong typeof(self) strongSelf = weakSelf;
                                                      [strongSelf _doShowViewController:viewController direction:direction animated:YES semaphore:sem];                                         });
                                              }
                                          }
                                        completionHandler:^(ORKVisualConsentTransitionAnimator *animator, UIPageViewControllerNavigationDirection direction) {
                                            
                                            if (animateBeforeTransition && !transitionBeforeAnimate) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    __strong typeof(self) strongSelf = weakSelf;
                                                    [strongSelf _doShowViewController:viewController direction:direction animated:YES semaphore:sem];                                         });
                                            } else {
                                                viewController.imageHidden = NO;
                                                fromController.imageHidden = NO;
                                            }
                                            
                                            __strong typeof(self) strongSelf = weakSelf;
                                            [strongSelf _finishTransitioningAnimator:animator];

                                            dispatch_semaphore_signal(sem);
                                        }];
    return _animator;
}

- (void)_finishTransitioningAnimator:(ORKVisualConsentTransitionAnimator *)animator {
    if (animator == nil) {
        animator = _animator;
    }
    
    
    [animator finish];
    if (_transitioning && animator == _animator) {
        _transitioning = NO;
        [[self animationPlayerView] setHidden:YES];
    }
    if (animator == _animator) {
        _animator = nil;
    }
}

- (void)_showViewController:(ORKConsentSceneViewController *)viewController forward:(BOOL)forward animated:(BOOL)animated {

    if (! viewController) {
        return;
    }
    
    ORKConsentSceneViewController *fromController = nil;
    NSUInteger currentIndex = [self _currentIndex];
    if (currentIndex == NSNotFound) {
        animated = NO;
    } else {
        fromController = _viewControllers[@(currentIndex)];
    }
    
    if (_transitioning) {
        [self _finishTransitioningAnimator:nil];
        
        fromController.imageHidden = NO;
    }
    
    NSUInteger toIndex = [self _indexOfViewController:viewController];
    
    NSURL *url = nil;
    BOOL animateBeforeTransition = NO;
    BOOL transitionBeforeAnimate = NO;
    if (animated) {
        
        ORKConsentSectionType currentSection = [(ORKConsentSection *)_visualSections[currentIndex] type];
        ORKConsentSectionType destSection = (toIndex != NSNotFound) ? [(ORKConsentSection *)_visualSections[toIndex] type] : ORKConsentSectionTypeCustom;
        
        // Only animate when going forward
        if (toIndex > currentIndex) {
            
            // Use the custom animation URL, if there is one for the destination index.
            if (toIndex != NSNotFound && toIndex < [_visualSections count]) {
                url = [ORKDynamicCast(_visualSections[toIndex], ORKConsentSection) customAnimationURL];
            }
            BOOL isCustomURL = (url != nil);
            
            // If there's no custom URL, use an animation only if transitioning in the expected order.
            // Exception for datagathering, which does an arrival animation AFTER.
            if (!isCustomURL) {
                if (destSection == ORKConsentSectionTypeDataGathering) {
                    transitionBeforeAnimate = YES;
                    url = ORKMovieURLForConsentSectionType(ORKConsentSectionTypeOverview);
                } else if ( (destSection - currentSection) == 1) {
                    url = ORKMovieURLForConsentSectionType(currentSection);
                }
            }
        }
    }
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    
    UIPageViewControllerNavigationDirection direction = forward?UIPageViewControllerNavigationDirectionForward:UIPageViewControllerNavigationDirectionReverse;
    
    if (! url) {
        [self _doShowViewController:viewController direction:direction animated:animated semaphore:sem];
    }
    
    
    
    
    
    if (animated)
    {
        // Disable user interaction during the animated transition, and re-enable when finished
        _transitioning = YES;
        
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Defensive timeouts
            typeof(self) strongSelf = weakSelf;
            
            dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 5));
            
            __block ORKVisualConsentTransitionAnimator *animator = nil;
            
            if (url && transitionBeforeAnimate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    animator = [strongSelf _doAnimateFromViewController:fromController
                                                           toController:viewController
                                                              direction:direction
                                                              semaphore:sem
                                                                    url:url
                                                animateBeforeTransition:animateBeforeTransition
                                                transitionBeforeAnimate:transitionBeforeAnimate];
                });
            }
            
            dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 5));
            
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                viewController.imageHidden = NO;
                fromController.imageHidden = NO;
                
                if (animator) {
                    [strongSelf _finishTransitioningAnimator:animator];
                }
                
                [strongSelf _updatePageIndex];
            });
        });
        
        
        
        if (url) {
            if (transitionBeforeAnimate) {
                
                viewController.imageHidden = YES;
                
                [self _doShowViewController:viewController direction:direction animated:YES semaphore:sem];
                
            } else {
                
                [self _doAnimateFromViewController:fromController
                                      toController:viewController
                                         direction:direction
                                         semaphore:sem
                                               url:url
                           animateBeforeTransition:animateBeforeTransition
                           transitionBeforeAnimate:transitionBeforeAnimate];
            }
        } else {
            // No animation - complete now.
            viewController.imageHidden = NO;
            dispatch_semaphore_signal(sem);
        }
    }
    
}


- (ORKConsentSceneViewController *)_viewControllerForIndex:(NSUInteger)index {
    
    if (_viewControllers == nil) {
        _viewControllers = [NSMutableDictionary new];
    }
    
    ORKConsentSceneViewController *vc = nil;
    
    if (_viewControllers[@(index)]) {
        vc = _viewControllers[@(index)];
    } else if (index>=[self _pageCount]) {
        vc = nil;
    } else {
        ORKConsentSceneViewController *sceneVc = [[ORKConsentSceneViewController alloc] initWithSection:[self _visualSections][index]];
        vc = sceneVc;
        
        if (index == [self _pageCount]-1) {
            sceneVc.continueButtonItem = self.continueButtonItem;
        } else {
            NSString *buttonTitle = ORKLocalizedString(@"BUTTON_NEXT", nil);
            if (sceneVc.section.type == ORKConsentSectionTypeOverview) {
                buttonTitle = ORKLocalizedString(@"BUTTON_GET_STARTED", nil);
            }
            
            sceneVc.continueButtonItem = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStylePlain target:self action:@selector(_next)];
        }
    }
    
    if (vc) {
        _viewControllers[@(index)] = vc;
    }
    
    return vc;
}

- (NSUInteger)_indexOfViewController:(UIViewController *)viewController {
    if (! viewController) {
        return NSNotFound;
    }
    
    NSUInteger index = NSNotFound;
    for (NSNumber *key in _viewControllers) {
        if (_viewControllers[key] == viewController) {
            index = [key unsignedIntegerValue];
        }
    }
    return index;
}

- (NSUInteger)_currentIndex {
    return [self _indexOfViewController:[_pageViewController.viewControllers firstObject]];
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self _indexOfViewController:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    return [self _viewControllerForIndex:index-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self _indexOfViewController:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    return [self _viewControllerForIndex:index+1];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    if (finished && completed) {
        
        [self _updatePageIndex];
    }
    
}

static NSString * const _ORKCurrentPageRestoreKey = @"currentPage";
static NSString * const _ORKHasAppearedRestoreKey = @"hasAppeared";
static NSString * const _ORKInitialBackButtonRestoreKey = @"initialBackButton";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeInteger:_currentPage forKey:_ORKCurrentPageRestoreKey];
    [coder encodeBool:_hasAppeared forKey:_ORKHasAppearedRestoreKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.currentPage = [coder decodeIntegerForKey:_ORKCurrentPageRestoreKey];
    _hasAppeared = [coder decodeBoolForKey:_ORKHasAppearedRestoreKey];
    
    _viewControllers = nil;
    [self _showViewController:[self _viewControllerForIndex:_currentPage] forward:YES animated:NO];
}


@end
