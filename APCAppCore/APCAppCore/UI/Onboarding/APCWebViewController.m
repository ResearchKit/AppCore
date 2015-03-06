//
//  APCWebViewController.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCWebViewController.h"

@interface APCWebViewController ()

@end

@implementation APCWebViewController

-(void)viewDidLoad{
    self.webview.delegate = self;
    self.webview.alpha = 0.0;
    
    self.webview.scalesPageToFit = YES;
}

-(void)webViewDidFinishLoad:(UIWebView *) __unused webView{
    [UIView animateWithDuration:1.0 animations:^{
        self.webview.alpha = 1.0;
    }];
}

- (UIRectEdge)edgesForExtendedLayout
{
    return UIRectEdgeNone;
}

- (BOOL)automaticallyAdjustsScrollViewInsets
{
    return YES;
}

- (IBAction)close:(id) __unused sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
