// 
//  APCWebViewController.m 
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
 
#import "APCWebViewController.h"

@interface APCWebViewController ()

@end

@implementation APCWebViewController

- (void)dealloc {
	_webview.delegate = nil;
}

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
