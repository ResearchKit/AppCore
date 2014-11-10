//
//  APCIntroductionViewController.m
//  APCAppleCore
//
//  Created by Henry McGilton on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCIntroductionViewController.h"
#import "APCAppleCore.h"

@interface APCIntroductionViewController  ( ) <UIScrollViewDelegate>

@property  (nonatomic, weak)    IBOutlet  UIScrollView   *textScroller;
@property  (nonatomic, weak)    IBOutlet  UIScrollView   *imageScroller;
@property  (nonatomic, weak)    IBOutlet  UIPageControl  *pager;


@property  (nonatomic, strong)  NSArray  *instructionalImages;
@property  (nonatomic, strong)  NSArray  *nonLocalisedParagraphs;
@property  (nonatomic, strong)  NSArray  *localisedParagraphs;

@property  (nonatomic, assign, getter = wasScrolledViaPageControl)  BOOL  scrolledViaPageControl;

@end

@implementation APCIntroductionViewController

- (UIImage *)imageOfName:(NSString *)name
{
    return  nil;
}

#pragma  mark  -  Initialise Scroll View With Images

- (void)initialiseImageScrollView
{
    CGSize  contentSize = CGSizeMake(0.0, CGRectGetHeight(self.imageScroller.frame));
    NSUInteger  imageIndex = 0;
    
    for (NSString  *imageName  in  self.instructionalImages) {
        
        UIImage    *anImage = [self imageOfName:imageName];
        
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
    self.pager.currentPageIndicatorTintColor = [UIColor appPrimaryColor];
}

#pragma  mark  -  Initialise Scroll View With Paragraphs

- (void)initialiseParagraphsScrollView
{
    CGSize  contentSize = CGSizeMake(0.0, CGRectGetHeight(self.textScroller.frame));
    NSUInteger  paragraphIndex = 0;

    for (NSAttributedString  *string  in  self.localisedParagraphs) {
        
        CGRect  frame = CGRectMake(paragraphIndex * CGRectGetWidth(self.textScroller.frame), 0.0, CGRectGetWidth(self.textScroller.frame), CGRectGetHeight(self.textScroller.frame));
        UITextView  *texter = [[UITextView alloc] initWithFrame:frame];
        texter.attributedText = string;
        [self.textScroller addSubview:texter];
        
        contentSize.width = contentSize.width + CGRectGetWidth(self.textScroller.frame);
        
        paragraphIndex = paragraphIndex + 1;
    }
    self.textScroller.contentSize = contentSize;
}

#pragma  mark  -  Localise Instructional Paragraphs

- (void)initialiseInstructionalParagraphs
{
    NSMutableArray  *localised = [NSMutableArray array];
    
    NSMutableParagraphStyle *paragrapStyle = NSMutableParagraphStyle.new;
    paragrapStyle.alignment                = NSTextAlignmentCenter;

    
    NSDictionary  *attributes = @{
                                  NSFontAttributeName : [UIFont systemFontOfSize: 16.0],
                                  NSForegroundColorAttributeName : [UIColor grayColor],
                                  NSParagraphStyleAttributeName:paragrapStyle
                                  };
    
    for (NSString *paragraph  in  self.nonLocalisedParagraphs) {
        NSString  *translated = NSLocalizedString(paragraph, nil);
        NSAttributedString  *styled = [[NSAttributedString alloc] initWithString:translated attributes:attributes];
        [localised addObject:styled];
    }
    self.localisedParagraphs = localised;
}

- (void)setupWithInstructionalImages:(NSArray *)imageNames andParagraphs:(NSArray *)paragraphs
{
    self.instructionalImages = imageNames;
    
    [self initialiseImageScrollView];
    
    self.nonLocalisedParagraphs = paragraphs;
    [self initialiseInstructionalParagraphs];
    [self initialiseParagraphsScrollView];
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

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)sender
{
    self.scrolledViaPageControl = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
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
}

@end
