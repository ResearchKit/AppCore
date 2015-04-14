// 
//  APCIntroductionViewController.m 
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
 
#import "APCIntroductionViewController.h"
#import "APCAppCore.h"

static NSInteger    const kTitleFontSize        = 18.0;
static NSInteger    const kRegularFontSize      = 17.0;
static CGFloat      const kHeadlineHeight       = 42.0f;
static CGFloat      const kParagraphYPosition   = 20.0;

@interface APCIntroductionViewController  ( ) <UIScrollViewDelegate>

@property  (nonatomic, weak)    IBOutlet  UIScrollView   *textScroller;
@property  (nonatomic, weak)    IBOutlet  UIScrollView   *imageScroller;
@property  (nonatomic, weak)    IBOutlet  UIPageControl  *pager;


@property  (nonatomic, strong)  NSArray  *instructionalImages;
@property  (nonatomic, strong)  NSArray  *nonLocalisedParagraphs;
@property  (nonatomic, strong)  NSArray  *nonLocalisedHeadlines;
@property  (nonatomic, strong)  NSArray  *localisedParagraphs;
@property  (nonatomic, strong)  NSArray  *localisedHeadlines;

@property  (nonatomic, assign, getter = wasScrolledViaPageControl)  BOOL  scrolledViaPageControl;

@end

@implementation APCIntroductionViewController

#pragma  mark  -  Initialise Scroll View With Images

- (void)initialiseImageScrollView
{
    CGSize  contentSize = CGSizeMake(0.0, CGRectGetHeight(self.imageScroller.frame));
    NSUInteger  imageIndex = 0;
    [self.imageScroller.subviews enumerateObjectsUsingBlock: ^(UIView* view,
                                                               NSUInteger __unused idx,
                                                               BOOL* __unused stop)
     {
         [view removeFromSuperview];
     }];
    
    for (NSString  *imageName  in  self.instructionalImages) {
        
        UIImage    *anImage = [UIImage imageNamed:imageName];
        
        CGRect  frame = CGRectMake(imageIndex * CGRectGetWidth(self.imageScroller.frame), 0.0, CGRectGetWidth(self.imageScroller.frame), CGRectGetHeight(self.imageScroller.frame));
        UIImageView  *imager = [[UIImageView alloc] initWithFrame:frame];
        imager.contentMode = UIViewContentModeScaleAspectFit;
        imager.image = anImage;
        [self.imageScroller addSubview:imager];
        
        contentSize.width = contentSize.width + CGRectGetWidth(self.imageScroller.frame);
        
        imageIndex = imageIndex + 1;
    }
    self.imageScroller.contentSize = contentSize;
    
    self.pager.numberOfPages = [self.instructionalImages count];
}

#pragma  mark  -  Initialise Scroll View With Paragraphs

- (void)initialiseParagraphsScrollView
{
    CGSize  contentSize = CGSizeMake(0.0, CGRectGetHeight(self.textScroller.frame));
    NSUInteger  paragraphIndex = 0;
    
    [self.textScroller.subviews enumerateObjectsUsingBlock: ^(UIView* view,
                                                              NSUInteger __unused idx,
                                                              BOOL * __unused stop)
     {
         [view removeFromSuperview];
     }];

    int counter = 0;
    
    for (NSString  *string  in  self.nonLocalisedHeadlines) {
        
        CGRect  frame = CGRectMake(paragraphIndex * CGRectGetWidth(self.textScroller.frame), 0.0, CGRectGetWidth(self.textScroller.frame), kHeadlineHeight);
        UILabel  *texter = [[UILabel alloc] initWithFrame:frame];
        texter.font = [UIFont fontWithName:@"Helvetica Neue" size:kTitleFontSize];
        texter.lineBreakMode = NSLineBreakByWordWrapping;
        texter.numberOfLines = 0;
        texter.text = string;
        texter.backgroundColor = [UIColor clearColor];
        [self.textScroller addSubview:texter];
        texter.textAlignment = NSTextAlignmentCenter;
        
        CGRect  paragraphFrame = CGRectMake(paragraphIndex * CGRectGetWidth(self.textScroller.frame),
                                            kParagraphYPosition,
                                            CGRectGetWidth(self.textScroller.frame),
                                            CGRectGetHeight(self.textScroller.frame));
        UILabel  *paragraphText = [[UILabel alloc] initWithFrame:paragraphFrame];
        paragraphText.font = [UIFont fontWithName:@"Helvetica Neue" size:kRegularFontSize];
        paragraphText.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphText.numberOfLines = 0;
        paragraphText.text = self.nonLocalisedParagraphs[counter];
        paragraphText.backgroundColor = [UIColor clearColor];
        [self.textScroller addSubview:paragraphText];
        paragraphText.textAlignment = NSTextAlignmentCenter;
        
        
        contentSize.width = contentSize.width + CGRectGetWidth(self.textScroller.frame);
        
        paragraphIndex = paragraphIndex + 1;
        counter++;
    }
    self.textScroller.contentSize = contentSize;
}

#pragma  mark  -  Localise Instructional Paragraphs

- (void)setupWithInstructionalImages:(NSArray *)imageNames headlines:(NSArray *)headlines andParagraphs:(NSArray *)paragraphs
{
    self.instructionalImages = imageNames;
    
    self.nonLocalisedParagraphs = paragraphs;
    self.nonLocalisedHeadlines = headlines;
}


- (void)setupWithInstructionalImages:(NSArray *)imageNames andParagraphs:(NSArray *)paragraphs
{
    [self setupWithInstructionalImages:imageNames headlines:nil andParagraphs:paragraphs];
}

#pragma  mark  -  Page Control Action Methods

- (void)scrollImageScroller:(NSInteger)pageNumber
{
    CGRect  imageFrame = self.imageScroller.frame;
    imageFrame.origin.x = CGRectGetWidth(imageFrame) * pageNumber;
    imageFrame.origin.y = 0.0;
    [self.imageScroller scrollRectToVisible:imageFrame animated:YES];
}

- (void)scrollTextScroller:(NSInteger)pageNumber
{
    CGRect  paragraphFrame = self.imageScroller.frame;
    paragraphFrame.origin.x = CGRectGetWidth(paragraphFrame) * pageNumber;
    paragraphFrame.origin.y = 0.0;
    [self.textScroller scrollRectToVisible:paragraphFrame animated:YES];
}

- (void)performScroll:(NSInteger)pageNumber
{
    [self scrollImageScroller:pageNumber];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollTextScroller:pageNumber];
    });
}

- (IBAction)pageControlChangedValue:(UIPageControl *)sender
{
    NSInteger  pageNumber = sender.currentPage;
    
    [self performScroll:pageNumber];
    
    self.scrolledViaPageControl = YES;
}

#pragma  mark  -  Scroll View Delegate Methods

- (void) scrollViewDidEndScrollingAnimation: (UIScrollView *) __unused sender
{
    self.scrolledViaPageControl = NO;
}

- (void) scrollViewDidScroll: (UIScrollView *) __unused sender
{
    if (self.wasScrolledViaPageControl == NO) {
        CGFloat  pageWidth = CGRectGetWidth(self.imageScroller.frame);
        NSInteger  pageNumber = floor((self.imageScroller.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if (self.pager.currentPage != pageNumber) {
            self.pager.currentPage = pageNumber;
            [self scrollTextScroller:pageNumber];
        }
    }
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
    }
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pager.pageIndicatorTintColor = [UIColor colorWithWhite:0.850 alpha:1.000];
    self.pager.currentPageIndicatorTintColor = [UIColor appPrimaryColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.title) {
        self.navigationController.navigationBar.topItem.title = self.title;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self initialiseImageScrollView];
    [self initialiseParagraphsScrollView];
}

@end
