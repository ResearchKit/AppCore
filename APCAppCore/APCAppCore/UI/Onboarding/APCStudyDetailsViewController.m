// 
//  APCStudyDetailsViewController.m 
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
 
#import "APCStudyDetailsViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCAppCore.h"

@interface APCStudyDetailsViewController () <UIWebViewDelegate>

@end

@implementation APCStudyDetailsViewController

- (void)dealloc {
    _webView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupAppearance];
    [self setupNavAppearance];
    
    self.title = self.studyDetails.caption;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.studyDetails.detailText ofType:@"html"];
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
