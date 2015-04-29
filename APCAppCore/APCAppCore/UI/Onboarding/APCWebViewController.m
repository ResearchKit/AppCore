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

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBarButtonItem;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarButtonItem;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopBarButtonItem;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardBarButtonItem;

@end

@implementation APCWebViewController

-(void)viewDidLoad{
    
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    
    if (self.link.length > 0) {
        NSString *encodedURLString=[self.link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:encodedURLString]]];
    }
}

- (UIRectEdge)edgesForExtendedLayout
{
    return UIRectEdgeNone;
}

- (BOOL)automaticallyAdjustsScrollViewInsets
{
    return YES;
}

/*********************************************************************************/
#pragma mark - UIWebViewDelegate methods
/*********************************************************************************/

- (void)webViewDidStartLoad:(UIWebView *)__unused webView
{
    [self updateToolbarButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)__unused webView
{
    [self updateToolbarButtons];
}

- (void)webView:(UIWebView *)__unused webView didFailLoadWithError:(NSError *)__unused error
{
    [self updateToolbarButtons];
}

- (BOOL)webView:(UIWebView *)__unused webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
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


/*********************************************************************************/
#pragma mark - Helper methods
/*********************************************************************************/

- (void)updateToolbarButtons
{
    self.refreshBarButtonItem.enabled = !self.webView.isLoading;
    self.stopBarButtonItem.enabled = !self.webView.isLoading;
    
    self.backBarButtonItem.enabled = self.webView.canGoBack;
    self.forwardBarButtonItem.enabled = self.webView.canGoForward;
}

/*********************************************************************************/
#pragma mark - IBActions
/*********************************************************************************/

- (IBAction)back:(id)__unused sender
{
    [self.webView goBack];
}

- (IBAction)refresh:(id)__unused sender
{
    [self.webView reload];
}

- (IBAction)stop:(id)__unused sender
{
    [self.webView stopLoading];
}

- (IBAction)forward:(id)__unused sender
{
    [self.webView goForward];
}

- (IBAction)close:(id) __unused sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
