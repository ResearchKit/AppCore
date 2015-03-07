// 
//  APCStudyDetailsViewController.m 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import "APCStudyDetailsViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCAppCore.h"

@interface APCStudyDetailsViewController () <UIWebViewDelegate>

@end

@implementation APCStudyDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupAppearance];
    [self setupNavAppearance];
    
    self.title = self.studyDetails.caption;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.studyDetails.detailText ofType:@"html" inDirectory:@"HTMLContent"];
    NSURL *targetURL = [NSURL URLWithString:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    self.webView.delegate = self;
    [self.webView loadRequest:request];
    [self.webView setDataDetectorTypes:UIDataDetectorTypeAll];
    self.webView.scalesPageToFit = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
  APCLogViewControllerAppeared();
}

-(void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    // A Hack to get rid of the black border surrounding the PDF in the UIWebView
    UIView *view = self.webView;
    while (view) {
        view.backgroundColor = [UIColor whiteColor];
        view = [view.subviews firstObject];
    }
}

- (void)setupNavAppearance
{
    UIBarButtonItem  *backster = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(back) tintColor:[UIColor appPrimaryColor]];
    [self.navigationItem setLeftBarButtonItem:backster];
}

#pragma mark - Setup

- (void)setupAppearance
{
    
}

- (BOOL)               webView: (UIWebView *) __unused webView
    shouldStartLoadWithRequest: (NSURLRequest*)request
                navigationType: (UIWebViewNavigationType)navigationType
{
    BOOL    shouldLoad = NO;
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:[request URL]];
    }
    else
    {
        shouldLoad = YES;
    }
    
    return shouldLoad;
}

#pragma mark - Selectors / IBActions

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WebView Delegates

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // Disable user selection
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
}


@end
